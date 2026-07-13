import 'package:bedrock/core/logging/app_logger.dart';
import 'package:bedrock/core/network/api_client.dart';
import 'package:bedrock/features/app_update/domain/app_version.dart';
import 'package:bedrock/services/device/device_info.dart';
import 'package:in_app_update/in_app_update.dart';

Future<void> runAndroidInAppUpdate() async {
  final info = await InAppUpdate.checkForUpdate();
  if (info.updateAvailability != .updateAvailable) return;

  if (info.flexibleUpdateAllowed) {
    final result = await InAppUpdate.startFlexibleUpdate();
    if (result == .success) {
      await InAppUpdate.completeFlexibleUpdate();
    }
  } else if (info.immediateUpdateAllowed) {
    await InAppUpdate.performImmediateUpdate();
  }
}

typedef PlatformUpdateRunner = Future<void> Function();

class AppUpdateService {
  AppUpdateService({
    required this._deviceInfo,
    required this._storeClient,
    PlatformUpdateRunner? androidUpdateRunner,
    this._logger = const .new('AppUpdateService'),
  }) : _androidUpdateRunner = androidUpdateRunner ?? runAndroidInAppUpdate;

  static const appStoreLookupBaseUrl = 'https://itunes.apple.com';
  final DeviceInfo _deviceInfo;
  final ApiClient _storeClient;
  final PlatformUpdateRunner _androidUpdateRunner;

  final AppLogger _logger;

  Future<String?> check() => switch (_deviceInfo.platform) {
    'android' => _runAndroidUpdate(),
    'ios' => _newerAppStoreVersion(),
    _ => .value(),
  };

  Future<String?> _newerAppStoreVersion() async {
    final result = await _storeClient.run((dio) async {
      final response = await dio.get<Map<String, dynamic>>(
        '/lookup',
        queryParameters: {'bundleId': _deviceInfo.bundleId},
      );
      return _readStoreVersion(response.data);
    });

    return result.fold(
      onSuccess: (version) =>
          version != null && isVersionNewer(version, _deviceInfo.appVersion)
          ? version
          : null,
      onFailure: (exception) {
        _logger.warning('App Store version check failed', exception);
        return null;
      },
    );
  }

  Future<String?> _runAndroidUpdate() async {
    try {
      await _androidUpdateRunner();
    } on Object catch (error) {
      _logger.warning('Android in-app update skipped', error);
    }
    return null;
  }

  static String? _readStoreVersion(Map<String, dynamic>? data) {
    final results = data?['results'];
    if (results is List && results.isNotEmpty) {
      final entry = results.first;
      if (entry is Map && entry['version'] is String) {
        return entry['version'] as String;
      }
    }
    return null;
  }
}
