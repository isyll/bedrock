import 'package:permission_handler/permission_handler.dart';

enum AppPermission {
  camera(.camera),
  photos(.photos),
  microphone(.microphone),
  notifications(.notification),
  locationWhenInUse(.locationWhenInUse),
  locationAlways(.locationAlways);

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
