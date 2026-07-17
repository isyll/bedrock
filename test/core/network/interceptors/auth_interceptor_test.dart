import 'package:bedrock/core/config/app_config.dart';
import 'package:bedrock/core/network/interceptors/auth_interceptor.dart';
import 'package:bedrock/core/session/auth_tokens.dart';
import 'package:bedrock/core/session/session_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  late InMemorySecureStorage storage;

  setUp(() => storage = .new());

  SessionManager buildSession({
    required Future<ResponseBody> Function(RequestOptions options) onRefresh,
  }) {
    final tokenDio = Dio(.new(baseUrl: _config.apiBaseUrl))
      ..httpClientAdapter = ScriptedHttpAdapter(onRefresh);
    final session = SessionManager(
      config: _config,
      storage: storage,
      tokenClient: tokenDio,
    );
    addTearDown(session.dispose);
    return session;
  }

  Dio buildClient({
    required SessionManager session,
    required ScriptedHttpAdapter mainAdapter,
    required ScriptedHttpAdapter retryAdapter,
  }) {
    final retryDio = Dio(.new(baseUrl: _config.apiBaseUrl))
      ..httpClientAdapter = retryAdapter;
    return Dio(.new(baseUrl: _config.apiBaseUrl))
      ..httpClientAdapter = mainAdapter
      ..interceptors.add(
        AuthInterceptor(session: session, retryClient: retryDio),
      );
  }

  Future<ResponseBody> Function(RequestOptions options) failing(String label) =>
      (options) => fail('Unexpected request during $label');

  AuthTokens tokensExpiringIn(Duration duration) => .new(
    accessToken: 'access',
    refreshToken: 'refresh',
    expiresAt: .now().toUtc().add(duration),
  );

  Future<ResponseBody> freshTokens(RequestOptions _) async => jsonResponseBody({
    'access_token': 'fresh',
    'refresh_token': 'refresh2',
    'expires_at': '2999-01-01T00:00:00Z',
  });

  test('attaches the current access token without refreshing', () async {
    final session = buildSession(onRefresh: failing('a valid request'));
    await session.start(tokensExpiringIn(const .new(hours: 1)));

    RequestOptions? seen;
    final dio = buildClient(
      session: session,
      mainAdapter: .new((options) async {
        seen = options;
        return jsonResponseBody({'ok': true});
      }),
      retryAdapter: .new(failing('a valid request')),
    );

    final response = await dio.get<dynamic>('/data');

    expect(response.statusCode, 200);
    expect(seen?.headers['Authorization'], 'Bearer access');
  });

  test('refreshes proactively when the token is expired', () async {
    var refreshCalls = 0;
    final session = buildSession(
      onRefresh: (options) async {
        refreshCalls++;
        return freshTokens(options);
      },
    );
    await session.start(tokensExpiringIn(const .new(minutes: -5)));

    RequestOptions? seen;
    final dio = buildClient(
      session: session,
      mainAdapter: .new((options) async {
        seen = options;
        return jsonResponseBody({'ok': true});
      }),
      retryAdapter: .new(failing('a proactive refresh')),
    );

    await dio.get<dynamic>('/data');

    expect(refreshCalls, 1);
    expect(seen?.headers['Authorization'], 'Bearer fresh');
  });

  test('skips authentication for requests marked skipAuth', () async {
    final session = buildSession(onRefresh: failing('a skipAuth request'));
    await session.start(tokensExpiringIn(const .new(minutes: -5)));

    RequestOptions? seen;
    final dio = buildClient(
      session: session,
      mainAdapter: .new((options) async {
        seen = options;
        return jsonResponseBody({'ok': true});
      }),
      retryAdapter: .new(failing('a skipAuth request')),
    );

    await dio.get<dynamic>(
      '/data',
      options: .new(extra: const {AuthInterceptor.skipAuthKey: true}),
    );

    expect(seen?.headers.containsKey('Authorization'), isFalse);
  });

  test('refreshes and replays the request once after a 401', () async {
    final session = buildSession(onRefresh: freshTokens);
    await session.start(tokensExpiringIn(const .new(hours: 1)));

    RequestOptions? retried;
    final retryAdapter = ScriptedHttpAdapter((options) async {
      retried = options;
      return jsonResponseBody({'ok': true});
    });
    final dio = buildClient(
      session: session,
      mainAdapter: .new(
        (_) async => jsonResponseBody({'message': 'expired'}, statusCode: 401),
      ),
      retryAdapter: retryAdapter,
    );

    final response = await dio.get<dynamic>('/data');

    expect(response.statusCode, 200);
    expect(retried?.headers['Authorization'], 'Bearer fresh');
    expect(retryAdapter.requestCount, 1);
  });

  test('replays at most once when the retry also fails', () async {
    var refreshCalls = 0;
    final session = buildSession(
      onRefresh: (options) async {
        refreshCalls++;
        return freshTokens(options);
      },
    );
    await session.start(tokensExpiringIn(const .new(hours: 1)));

    final retryAdapter = ScriptedHttpAdapter(
      (_) async => jsonResponseBody({'message': 'still 401'}, statusCode: 401),
    );
    final dio = buildClient(
      session: session,
      mainAdapter: .new(
        (_) async => jsonResponseBody({'message': 'expired'}, statusCode: 401),
      ),
      retryAdapter: retryAdapter,
    );

    await expectLater(dio.get<dynamic>('/data'), throwsA(isA<DioException>()));
    expect(refreshCalls, 1);
    expect(retryAdapter.requestCount, 1);
  });

  test('ends the session and propagates when refresh is rejected', () async {
    final session = buildSession(
      onRefresh: (_) async =>
          jsonResponseBody({'message': 'revoked'}, statusCode: 401),
    );
    await session.start(tokensExpiringIn(const .new(hours: 1)));

    final dio = buildClient(
      session: session,
      mainAdapter: .new(
        (_) async => jsonResponseBody({'message': 'expired'}, statusCode: 401),
      ),
      retryAdapter: .new(failing('a failed refresh')),
    );

    await expectLater(dio.get<dynamic>('/data'), throwsA(isA<DioException>()));
    expect(session.status, SessionStatus.none);
  });

  test('clones form data before replaying a 401', () async {
    final session = buildSession(onRefresh: freshTokens);
    await session.start(tokensExpiringIn(const .new(hours: 1)));

    final retryAdapter = ScriptedHttpAdapter(
      (_) async => jsonResponseBody({'ok': true}),
    );
    final dio = buildClient(
      session: session,
      mainAdapter: .new(
        (_) async => jsonResponseBody({'message': 'expired'}, statusCode: 401),
      ),
      retryAdapter: retryAdapter,
    );

    final response = await dio.post<dynamic>(
      '/upload',
      data: FormData.fromMap({'field': 'value'}),
    );

    expect(response.statusCode, 200);
    expect(retryAdapter.requestCount, 1);
  });
}

const _config = AppConfig(
  flavor: .dev,
  appName: 'Test',
  apiBaseUrl: 'https://api.test',
);
