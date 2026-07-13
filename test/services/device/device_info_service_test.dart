import 'package:bedrock/core/storage/storage_keys.dart';
import 'package:bedrock/services/device/device_info_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  final uuidV4 = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  DeviceInfoService buildService(InMemorySecureStorage storage) => .new(
    storage: storage,
    platformDetailsLoader: () async => (
      platform: 'android',
      osVersion: '15',
      model: 'Pixel 9',
      manufacturer: 'Google',
    ),
    packageInfoLoader: () async => .new(
      appName: 'Bedrock',
      packageName: 'com.example.bedrock',
      version: '1.2.3',
      buildNumber: '42',
    ),
  );

  group('DeviceInfoService', () {
    test('generates a v4 install id and persists it', () async {
      final storage = InMemorySecureStorage();

      final info = await buildService(storage).load();

      expect(info.deviceId, matches(uuidV4));
      expect(storage.values[StorageKeys.installId], info.deviceId);
    });

    test('reuses the persisted install id across instances', () async {
      final storage = InMemorySecureStorage();

      final first = await buildService(storage).load();
      final second = await buildService(storage).load();

      expect(second.deviceId, first.deviceId);
    });

    test('exposes loaded info synchronously after load', () async {
      final storage = InMemorySecureStorage();
      final service = buildService(storage);

      await service.load();

      expect(service.info.model, 'Pixel 9');
      expect(service.info.fullVersion, '1.2.3 (42)');
      expect(service.info.buildNumberValue, 42);
    });

    test('throws when info is read before load', () {
      final service = buildService(.new());

      expect(() => service.info, throwsStateError);
    });

    test('builds the session payload from device and app details', () async {
      final info = await buildService(.new()).load();

      expect(info.toSessionPayload(), {
        'device_id': info.deviceId,
        'platform': 'android',
        'os_version': '15',
        'model': 'Pixel 9',
        'manufacturer': 'Google',
        'app_version': '1.2.3',
        'build_number': '42',
      });
    });

    test('falls back to host platform details when the loader fails', () async {
      final service = DeviceInfoService(
        storage: InMemorySecureStorage(),
        platformDetailsLoader: () async => throw Exception('unavailable'),
        packageInfoLoader: () async => .new(
          appName: 'Bedrock',
          packageName: 'com.example.bedrock',
          version: '1.2.3',
          buildNumber: '42',
        ),
      );

      final info = await service.load();

      expect(info.model, 'unknown');
      expect(info.appVersion, '1.2.3');
    });
  });
}
