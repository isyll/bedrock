import 'package:bedrock/core/l10n/app_localizations.dart';

abstract final class Validators {
  static const passwordMinLength = 8;

  static final _emailPattern = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]"
    '(?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
    r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
  );

  static String? email(AppLocalizations l10n, String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return l10n.emailRequired;
    if (!_emailPattern.hasMatch(input)) return l10n.emailInvalid;
    return null;
  }

  static String? password(AppLocalizations l10n, String? value) {
    final input = value ?? '';
    if (input.isEmpty) return l10n.passwordRequired;
    if (input.length < passwordMinLength) {
      return l10n.passwordTooShort(passwordMinLength);
    }
    return null;
  }
}
