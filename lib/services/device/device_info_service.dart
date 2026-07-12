import 'dart:io';
import 'dart:math';

import 'package:bedrock/core/logging/app_logger.dart';
import 'package:bedrock/core/storage/secure_storage.dart';
import 'package:bedrock/core/storage/storage_keys.dart';
import 'package:bedrock/services/device/device_info.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

typedef PlatformDetails = ({
  String platform,
  String osVersion,
  String model,
  String manufacturer,
});

class DeviceInfoService {
  DeviceInfoService({
    required this._storage,
    Future<PlatformDetails> Function()? platformDetailsLoader,
    Future<PackageInfo> Function()? packageInfoLoader,
    this._logger = const .new('DeviceInfoService'),
  }) : _platformDetailsLoader = platformDetailsLoader ?? _loadPlatformDetails,
       _packageInfoLoader = packageInfoLoader ?? PackageInfo.fromPlatform;

  final SecureStorage _storage;
  final Future<PlatformDetails> Function() _platformDetailsLoader;
  final Future<PackageInfo> Function() _packageInfoLoader;
  final AppLogger _logger;

  DeviceInfo? _info;

  DeviceInfo get info {
    final info = _info;
    if (info == null) {
      throw StateError('DeviceInfoService.load must complete before use');
    }
    return info;
  }

  Future<DeviceInfo> load() async {
    final cached = _info;
    if (cached != null) return cached;

    final (deviceId, details, package) = await (
      _ensureInstallId(),
      _resolvePlatformDetails(),
      _packageInfoLoader(),
    ).wait;

    final info = DeviceInfo(
      deviceId: deviceId,
      platform: details.platform,
      osVersion: details.osVersion,
      model: details.model,
      manufacturer: details.manufacturer,
      appVersion: package.version,
      buildNumber: package.buildNumber,
    );
    _info = info;
    return info;
  }

  Future<String> _ensureInstallId() async {
    final existing = await _storage.read(StorageKeys.installId);
    if (existing != null && existing.isNotEmpty) return existing;

    final id = _generateUuidV4();
    await _storage.write(StorageKeys.installId, id);
    return id;
  }

  Future<PlatformDetails> _resolvePlatformDetails() async {
    try {
      return await _platformDetailsLoader();
    } on Exception catch (error) {
      _logger.warning('Failed to read platform details', error);
      return (
        platform: Platform.operatingSystem,
        osVersion: Platform.operatingSystemVersion,
        model: 'unknown',
        manufacturer: 'unknown',
      );
    }
  }

  static String _generateUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }

  static Future<PlatformDetails> _loadPlatformDetails() async {
    final plugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final android = await plugin.androidInfo;
      return (
        platform: 'android',
        osVersion: android.version.release,
        model: android.model,
        manufacturer: android.manufacturer,
      );
    }

    if (Platform.isIOS) {
      final ios = await plugin.iosInfo;
      return (
        platform: 'ios',
        osVersion: ios.systemVersion,
        model: ios.utsname.machine,
        manufacturer: 'Apple',
      );
    }

    return (
      platform: Platform.operatingSystem,
      osVersion: Platform.operatingSystemVersion,
      model: 'unknown',
      manufacturer: 'unknown',
    );
  }
}
