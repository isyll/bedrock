import 'package:bedrock/core/logging/app_logger.dart';
import 'package:bedrock/services/permissions/app_permission.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

final class PermissionsService {
  const PermissionsService({
    this._logger = const AppLogger('Permissions'),
  });

  final AppLogger _logger;

  Future<PermissionResult> ensure(AppPermission permission) async {
    final current = await status(permission);
    if (current.isUsable || current == .permanentlyDenied) {
      return current;
    }
    return request(permission);
  }

  Future<bool> openSettings() => permission_handler.openAppSettings();

  Future<PermissionResult> request(AppPermission permission) async {
    final value = await permission.platformPermission.request();
    final result = _mapStatus(value);
    _logger.info('Permission ${permission.name}: ${result.name}');
    return result;
  }

  Future<PermissionResult> status(AppPermission permission) async {
    final value = await permission.platformPermission.status;
    return _mapStatus(value);
  }

  PermissionResult _mapStatus(permission_handler.PermissionStatus status) =>
      switch (status) {
        .granted => .granted,
        permission_handler.PermissionStatus.limited => .limited,
        permission_handler.PermissionStatus.provisional => .granted,
        permission_handler.PermissionStatus.denied => .denied,
        permission_handler.PermissionStatus.permanentlyDenied =>
          .permanentlyDenied,
        permission_handler.PermissionStatus.restricted => .restricted,
      };
}
