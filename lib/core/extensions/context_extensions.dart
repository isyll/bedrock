import 'package:bedrock/app/theme/app_colors.dart';
import 'package:bedrock/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;

  AppSemanticColors get semanticColors =>
      theme.extension<AppSemanticColors>() ?? AppSemanticColors.light;

  bool get isDarkMode => theme.brightness == Brightness.dark;

  Size get screenSize => MediaQuery.sizeOf(this);

  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);
}
