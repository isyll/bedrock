import 'package:flutter/material.dart';

abstract final class AppColors {
  static const seed = Color(0xFF4C5FD5);

  static const successLight = Color(0xFF2E7D32);
  static const successDark = Color(0xFF81C784);
  static const warningLight = Color(0xFFB26A00);
  static const warningDark = Color(0xFFFFB74D);
  static const infoLight = Color(0xFF0277BD);
  static const infoDark = Color(0xFF4FC3F7);
}

final class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.warning,
    required this.info,
  });

  static const light = AppSemanticColors(
    success: AppColors.successLight,
    warning: AppColors.warningLight,
    info: AppColors.infoLight,
  );

  static const dark = AppSemanticColors(
    success: AppColors.successDark,
    warning: AppColors.warningDark,
    info: AppColors.infoDark,
  );

  final Color success;
  final Color warning;
  final Color info;

  @override
  AppSemanticColors copyWith({Color? success, Color? warning, Color? info}) {
    return AppSemanticColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}
