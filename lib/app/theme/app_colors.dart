import 'package:flutter/material.dart';

abstract final class AppColors {
  static const seed = Color(0xFF4C5FD5);

  static const successLight = Color(0xFF2E7D32);
  static const onSuccessLight = Color(0xFFFFFFFF);
  static const successContainerLight = Color(0xFFC8E6C9);
  static const onSuccessContainerLight = Color(0xFF1B5E20);
  static const successDark = Color(0xFF81C784);
  static const onSuccessDark = Color(0xFF0A3711);
  static const successContainerDark = Color(0xFF1B5E20);
  static const onSuccessContainerDark = Color(0xFFC8E6C9);

  static const warningLight = Color(0xFFB26A00);
  static const onWarningLight = Color(0xFFFFFFFF);
  static const warningContainerLight = Color(0xFFFFE0B2);
  static const onWarningContainerLight = Color(0xFF663C00);
  static const warningDark = Color(0xFFFFB74D);
  static const onWarningDark = Color(0xFF4A2800);
  static const warningContainerDark = Color(0xFF663C00);
  static const onWarningContainerDark = Color(0xFFFFE0B2);

  static const infoLight = Color(0xFF0277BD);
  static const onInfoLight = Color(0xFFFFFFFF);
  static const infoContainerLight = Color(0xFFB3E5FC);
  static const onInfoContainerLight = Color(0xFF01579B);
  static const infoDark = Color(0xFF4FC3F7);
  static const onInfoDark = Color(0xFF00344A);
  static const infoContainerDark = Color(0xFF01579B);
  static const onInfoContainerDark = Color(0xFFB3E5FC);
}

final class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
  });

  static const light = AppSemanticColors(
    success: AppColors.successLight,
    onSuccess: AppColors.onSuccessLight,
    successContainer: AppColors.successContainerLight,
    onSuccessContainer: AppColors.onSuccessContainerLight,
    warning: AppColors.warningLight,
    onWarning: AppColors.onWarningLight,
    warningContainer: AppColors.warningContainerLight,
    onWarningContainer: AppColors.onWarningContainerLight,
    info: AppColors.infoLight,
    onInfo: AppColors.onInfoLight,
    infoContainer: AppColors.infoContainerLight,
    onInfoContainer: AppColors.onInfoContainerLight,
  );

  static const dark = AppSemanticColors(
    success: AppColors.successDark,
    onSuccess: AppColors.onSuccessDark,
    successContainer: AppColors.successContainerDark,
    onSuccessContainer: AppColors.onSuccessContainerDark,
    warning: AppColors.warningDark,
    onWarning: AppColors.onWarningDark,
    warningContainer: AppColors.warningContainerDark,
    onWarningContainer: AppColors.onWarningContainerDark,
    info: AppColors.infoDark,
    onInfo: AppColors.onInfoDark,
    infoContainer: AppColors.infoContainerDark,
    onInfoContainer: AppColors.onInfoContainerDark,
  );

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
  }) => .new(
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    successContainer: successContainer ?? this.successContainer,
    onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
    warning: warning ?? this.warning,
    onWarning: onWarning ?? this.onWarning,
    warningContainer: warningContainer ?? this.warningContainer,
    onWarningContainer: onWarningContainer ?? this.onWarningContainer,
    info: info ?? this.info,
    onInfo: onInfo ?? this.onInfo,
    infoContainer: infoContainer ?? this.infoContainer,
    onInfoContainer: onInfoContainer ?? this.onInfoContainer,
  );

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return .new(
      success: .lerp(success, other.success, t)!,
      onSuccess: .lerp(onSuccess, other.onSuccess, t)!,
      successContainer: .lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      onSuccessContainer: .lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
      warning: .lerp(warning, other.warning, t)!,
      onWarning: .lerp(onWarning, other.onWarning, t)!,
      warningContainer: .lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      onWarningContainer: .lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      )!,
      info: .lerp(info, other.info, t)!,
      onInfo: .lerp(onInfo, other.onInfo, t)!,
      infoContainer: .lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: .lerp(onInfoContainer, other.onInfoContainer, t)!,
    );
  }
}
