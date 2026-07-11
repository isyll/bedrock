import 'package:bedrock/core/logging/app_logger.dart';
import 'package:bedrock/services/permissions/app_permission.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

final class PermissionsService {
  const PermissionsService({
    this._logger = const AppLogger('Permissions'),
  });

  final AppLogger _logger;

  Future<PermissionResult> status(AppPermission permission) async {
    final value = await permission.platformPermission.status;
    return _mapStatus(value);
  }

  Future<PermissionResult> request(AppPermission permission) async {
    final value = await permission.platformPermission.request();
    final result = _mapStatus(value);
    _logger.info('Permission ${permission.name}: ${result.name}');
    return result;
  }

  Future<PermissionResult> ensure(AppPermission permission) async {
    final current = await status(permission);
    if (current.isUsable || current == PermissionResult.permanentlyDenied) {
      return current;
    }
    return request(permission);
  }

  Future<bool> openSettings() => permission_handler.openAppSettings();

  PermissionResult _mapStatus(permission_handler.PermissionStatus status) {
    return switch (status) {
      permission_handler.PermissionStatus.granted => PermissionResult.granted,
      permission_handler.PermissionStatus.limited => PermissionResult.limited,
      permission_handler.PermissionStatus.provisional =>
        PermissionResult.granted,
      permission_handler.PermissionStatus.denied => PermissionResult.denied,
      permission_handler.PermissionStatus.permanentlyDenied =>
        PermissionResult.permanentlyDenied,
      permission_handler.PermissionStatus.restricted =>
        PermissionResult.restricted,
    };
  }
}
