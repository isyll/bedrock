import 'package:permission_handler/permission_handler.dart';

enum AppPermission {
  camera(Permission.camera),
  photos(Permission.photos),
  microphone(Permission.microphone),
  notifications(Permission.notification),
  locationWhenInUse(Permission.locationWhenInUse),
  locationAlways(Permission.locationAlways);

  const AppPermission(this.platformPermission);

  final Permission platformPermission;
}

enum PermissionResult {
  granted,
  limited,
  denied,
  permanentlyDenied,
  restricted;

  bool get isUsable => this == granted || this == limited;
}
