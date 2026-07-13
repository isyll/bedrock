final class DeviceInfo {
  const DeviceInfo({
    required this.deviceId,
    required this.bundleId,
    required this.platform,
    required this.osVersion,
    required this.model,
    required this.manufacturer,
    required this.appVersion,
    required this.buildNumber,
  });

  final String deviceId;
  final String bundleId;
  final String platform;
  final String osVersion;
  final String model;
  final String manufacturer;
  final String appVersion;
  final String buildNumber;

  int get buildNumberValue => .tryParse(buildNumber) ?? 0;

  String get fullVersion => '$appVersion ($buildNumber)';

  Map<String, Object> toSessionPayload() => {
    'device_id': deviceId,
    'platform': platform,
    'os_version': osVersion,
    'model': model,
    'manufacturer': manufacturer,
    'app_version': appVersion,
    'build_number': buildNumber,
  };
}
