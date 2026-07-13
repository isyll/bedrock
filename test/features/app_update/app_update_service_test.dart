import 'package:bedrock/features/app_update/data/app_update_service.dart';
import 'package:bedrock/services/device/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  AppUpdateService buildService({
    required DeviceInfo deviceInfo,
    Future<ResponseBody> Function(RequestOptions options)? handler,
    PlatformUpdateRunner? androidUpdateRunner,
  }) {
    final dio =
        Dio(
            .new(baseUrl: AppUpdateService.appStoreLookupBaseUrl),
          )
          ..httpClientAdapter = ScriptedHttpAdapter(
            handler ?? (_) async => jsonResponseBody(const {}),
          );

    return .new(
      deviceInfo: deviceInfo,
      storeClient: .new(dio),
      androidUpdateRunner: androidUpdateRunner,
    );
  }

  group('iOS', () {
    test('returns the store version when it is newer', () async {
      final service = buildService(
        deviceInfo: iosDeviceInfo,
        handler: (_) async => jsonResponseBody(const {
          'resultCount': 1,
          'results': [
            {'version': '2.0.0'},
          ],
        }),
      );

      expect(await service.check(), '2.0.0');
    });

    test('returns null when the installed version is current', () async {
      final service = buildService(
        deviceInfo: iosDeviceInfo,
        handler: (_) async => jsonResponseBody(const {
          'results': [
            {'version': '1.2.3'},
          ],
        }),
      );

      expect(await service.check(), isNull);
    });

    test('returns null and swallows lookup failures', () async {
      final service = buildService(
        deviceInfo: iosDeviceInfo,
        handler: (_) async => jsonResponseBody(const {}, statusCode: 500),
      );

      expect(await service.check(), isNull);
    });
  });

  group('Android', () {
    test('runs the native flow and returns null', () async {
      var ran = false;
      final service = buildService(
        deviceInfo: testDeviceInfo,
        androidUpdateRunner: () async => ran = true,
      );

      expect(await service.check(), isNull);
      expect(ran, isTrue);
    });

    test('swallows native update failures', () async {
      final service = buildService(
        deviceInfo: testDeviceInfo,
        androidUpdateRunner: () async => throw Exception('not owned by Play'),
      );

      expect(await service.check(), isNull);
    });
  });
}
