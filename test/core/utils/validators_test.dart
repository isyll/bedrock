import 'package:bedrock/core/l10n/app_localizations_en.dart';
import 'package:bedrock/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('Validators.email', () {
    test('requires a value', () {
      expect(Validators.email(l10n, null), l10n.emailRequired);
      expect(Validators.email(l10n, ''), l10n.emailRequired);
      expect(Validators.email(l10n, '   '), l10n.emailRequired);
    });

    test('rejects malformed addresses', () {
      for (final input in ['plain', 'a@b', 'a@b.', '@example.com', 'a b@c.d']) {
        expect(Validators.email(l10n, input), l10n.emailInvalid);
      }
    });

    test('accepts valid addresses and trims whitespace', () {
      expect(Validators.email(l10n, 'user@example.com'), isNull);
      expect(Validators.email(l10n, '  user.name+tag@sub.example.co '), isNull);
    });
  });

  group('Validators.password', () {
    test('requires a value', () {
      expect(Validators.password(l10n, null), l10n.passwordRequired);
      expect(Validators.password(l10n, ''), l10n.passwordRequired);
    });

    test(
      'enforces the minimum length',
      () => expect(
        Validators.password(l10n, 'short'),
        l10n.passwordTooShort(Validators.passwordMinLength),
      ),
    );

    test(
      'accepts passwords at or above the minimum length',
      () => expect(Validators.password(l10n, 'longenough'), isNull),
    );
  });
}
