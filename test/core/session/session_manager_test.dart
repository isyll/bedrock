import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bedrock/core/config/app_config.dart';
import 'package:bedrock/core/session/auth_tokens.dart';
import 'package:bedrock/core/session/session_manager.dart';
import 'package:bedrock/core/storage/storage_keys.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

const _config = AppConfig(
  flavor: AppFlavor.dev,
  appName: 'Test',
  apiBaseUrl: 'https://api.test',
);

final class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;
  int requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requestCount++;
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(int statusCode, Map<String, dynamic> body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  late InMemorySecureStorage storage;

  setUp(() {
    storage = InMemorySecureStorage();
  });

  SessionManager buildManager(_ScriptedAdapter adapter) {
    final dio = Dio(BaseOptions(baseUrl: _config.apiBaseUrl))
      ..httpClientAdapter = adapter;
    return SessionManager(config: _config, storage: storage, tokenClient: dio);
  }

  _ScriptedAdapter refuseRequests() {
    return _ScriptedAdapter((options) {
      fail('Unexpected HTTP request to ${options.path}');
    });
  }

  AuthTokens tokensExpiringIn(Duration duration) => AuthTokens(
    accessToken: 'access',
    refreshToken: 'refresh',
    expiresAt: DateTime.now().toUtc().add(duration),
  );

  group('restore', () {
    test('ends up signed out when nothing is stored', () async {
      final manager = buildManager(refuseRequests());

      await manager.restore();

      expect(manager.status, SessionStatus.none);
      expect(manager.accessToken, isNull);
    });

    test('restores a persisted session with its expiry', () async {
      storage.values.addAll({
        StorageKeys.accessToken: 'stored-access',
        StorageKeys.refreshToken: 'stored-refresh',
        StorageKeys.accessTokenExpiry: '2020-01-01T00:00:00.000Z',
      });
      final manager = buildManager(refuseRequests());

      await manager.restore();

      expect(manager.status, SessionStatus.active);
      expect(manager.accessToken, 'stored-access');
      expect(manager.hasValidAccessToken, isFalse);
    });
  });

  group('start and end', () {
    test('start persists tokens and activates the session', () async {
      final manager = buildManager(refuseRequests());

      await manager.start(tokensExpiringIn(const Duration(hours: 1)));

      expect(manager.status, SessionStatus.active);
      expect(storage.values[StorageKeys.accessToken], 'access');
      expect(storage.values[StorageKeys.refreshToken], 'refresh');
      expect(storage.values[StorageKeys.accessTokenExpiry], isNotNull);
    });

    test('end wipes tokens and deactivates the session', () async {
      final manager = buildManager(refuseRequests());
      await manager.start(tokensExpiringIn(const Duration(hours: 1)));

      await manager.end();

      expect(manager.status, SessionStatus.none);
      expect(storage.values, isEmpty);
    });
  });

  group('validAccessToken', () {
    test('returns the current token without a request when valid', () async {
      final adapter = refuseRequests();
      final manager = buildManager(adapter);
      await manager.start(tokensExpiringIn(const Duration(hours: 1)));

      final token = await manager.validAccessToken();

      expect(token, 'access');
      expect(adapter.requestCount, 0);
    });

    test('refreshes an expired token before returning it', () async {
      final adapter = _ScriptedAdapter(
        (options) async => _jsonResponse(200, {
          'access_token': 'fresh-access',
          'refresh_token': 'fresh-refresh',
          'expires_at': '2030-01-01T00:00:00Z',
        }),
      );
      final manager = buildManager(adapter);
      await manager.start(tokensExpiringIn(const Duration(minutes: -5)));

      final token = await manager.validAccessToken();

      expect(token, 'fresh-access');
      expect(adapter.requestCount, 1);
      expect(storage.values[StorageKeys.accessToken], 'fresh-access');
      expect(storage.values[StorageKeys.refreshToken], 'fresh-refresh');
    });
  });

  group('refreshAccessToken', () {
    test('deduplicates concurrent refreshes into one request', () async {
      final gate = Completer<void>();
      final adapter = _ScriptedAdapter((options) async {
        await gate.future;
        return _jsonResponse(200, {
          'access_token': 'fresh-access',
          'refresh_token': 'fresh-refresh',
        });
      });
      final manager = buildManager(adapter);
      await manager.start(tokensExpiringIn(const Duration(minutes: -5)));

      final first = manager.refreshAccessToken();
      final second = manager.refreshAccessToken();
      gate.complete();
      final results = await Future.wait([first, second]);

      expect(results, ['fresh-access', 'fresh-access']);
      expect(adapter.requestCount, 1);
    });

    test('keeps the previous refresh token when rotation is absent', () async {
      final adapter = _ScriptedAdapter(
        (options) async => _jsonResponse(200, {'access_token': 'fresh'}),
      );
      final manager = buildManager(adapter);
      await manager.start(tokensExpiringIn(const Duration(minutes: -5)));

      await manager.refreshAccessToken();

      expect(storage.values[StorageKeys.refreshToken], 'refresh');
    });

    test('ends the session when the refresh token is rejected', () async {
      final adapter = _ScriptedAdapter(
        (options) async => _jsonResponse(401, {'message': 'revoked'}),
      );
      final manager = buildManager(adapter);
      await manager.start(tokensExpiringIn(const Duration(minutes: -5)));

      final token = await manager.refreshAccessToken();

      expect(token, isNull);
      expect(manager.status, SessionStatus.none);
      expect(storage.values, isEmpty);
    });

    test('keeps the session alive on transient refresh failures', () async {
      final adapter = _ScriptedAdapter(
        (options) async => _jsonResponse(503, {'message': 'try later'}),
      );
      final manager = buildManager(adapter);
      await manager.start(tokensExpiringIn(const Duration(minutes: -5)));

      final token = await manager.refreshAccessToken();

      expect(token, isNull);
      expect(manager.status, SessionStatus.active);
      expect(storage.values[StorageKeys.refreshToken], 'refresh');
    });
  });
}
