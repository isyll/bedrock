import 'package:flutter/material.dart';

abstract final class AppTypography {
  static TextTheme refine(TextTheme base) => base.copyWith(
    displayLarge: base.displayLarge?.copyWith(
      fontWeight: .w700,
      letterSpacing: -1,
    ),
    displayMedium: base.displayMedium?.copyWith(
      fontWeight: .w700,
      letterSpacing: -0.5,
    ),
    displaySmall: base.displaySmall?.copyWith(
      fontWeight: .w700,
      letterSpacing: -0.25,
    ),
    headlineLarge: base.headlineLarge?.copyWith(
      fontWeight: .w700,
      letterSpacing: -0.5,
    ),
    headlineMedium: base.headlineMedium?.copyWith(
      fontWeight: .w700,
      letterSpacing: -0.25,
    ),
    headlineSmall: base.headlineSmall?.copyWith(fontWeight: .w600),
    titleLarge: base.titleLarge?.copyWith(fontWeight: .w600),
    titleMedium: base.titleMedium?.copyWith(
      fontWeight: .w600,
      letterSpacing: 0.1,
    ),
    titleSmall: base.titleSmall?.copyWith(
      fontWeight: .w600,
      letterSpacing: 0.1,
    ),
    bodyLarge: base.bodyLarge?.copyWith(height: 1.5),
    bodyMedium: base.bodyMedium?.copyWith(height: 1.45),
    labelLarge: base.labelLarge?.copyWith(
      fontWeight: .w600,
      letterSpacing: 0.2,
    ),
  );
}
