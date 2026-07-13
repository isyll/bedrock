import 'package:bedrock/core/config/app_config.dart';
import 'package:bedrock/core/network/api_client.dart';
import 'package:bedrock/core/session/session_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  const config = AppConfig(
    flavor: .dev,
    appName: 'Bedrock Test',
    apiBaseUrl: 'https://api.test.example.com',
  );

  test('every request carries the client info headers', () async {
    RequestOptions? captured;
    final adapter = ScriptedHttpAdapter((options) async {
      captured = options;
      return jsonResponseBody({'ok': true});
    });

    final session = SessionManager(
      config: config,
      storage: InMemorySecureStorage(),
      tokenClient: .new(),
    );
    final factory = ApiClientFactory(
      config: config,
      session: session,
      deviceInfo: testDeviceInfo,
    );
    final client = factory.create(
      baseUrl: config.apiBaseUrl,
      authenticated: false,
    );
    client.dio.httpClientAdapter = adapter;

    final result = await client.run(
      (dio) => dio.get<Map<String, dynamic>>('/v1/ping'),
    );

    expect(result.isSuccess, isTrue);
    expect(captured!.headers['X-App-Version'], '1.2.3');
    expect(captured!.headers['X-Build-Number'], '42');
    expect(captured!.headers['X-Platform'], 'android');
    expect(captured!.headers['X-OS-Version'], '15');
    expect(captured!.headers['X-Device-Id'], 'test-device-id');
    expect(captured!.headers['Accept-Language'], isNotNull);
  });
}
