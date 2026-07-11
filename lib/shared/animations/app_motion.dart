import 'package:flutter/animation.dart';

abstract final class AppAnimations {
  static const empty = 'assets/animations/empty.json';
  static const success = 'assets/animations/success.json';
}

abstract final class AppMotion {
  static const shortDuration = Duration(milliseconds: 150);
  static const mediumDuration = Duration(milliseconds: 300);
  static const longDuration = Duration(milliseconds: 450);
  static const staggerInterval = Duration(milliseconds: 60);

  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
  static const Curve decelerate = Curves.easeOutCubic;
  static const Curve accelerate = Curves.easeInCubic;
  static const Curve spring = Curves.easeOutBack;
}
