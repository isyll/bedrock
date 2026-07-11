import 'package:bedrock/core/error/app_exception.dart';
import 'package:bedrock/core/error/error_messages.dart';
import 'package:bedrock/core/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('AppExceptionMessage.localizedMessage', () {
    test('maps network failures by kind', () {
      const timeout = NetworkException(
        'timed out',
        kind: NetworkFailureKind.timeout,
      );
      const offline = NetworkException(
        'offline',
        kind: NetworkFailureKind.offline,
      );

      expect(timeout.localizedMessage(l10n), l10n.errorTimeoutMessage);
      expect(offline.localizedMessage(l10n), l10n.errorNetworkMessage);
    });

    test('maps auth and validation failures', () {
      const unauthorized = UnauthorizedException('nope');
      const validation = ValidationException('bad', fieldErrors: {});

      expect(
        unauthorized.localizedMessage(l10n),
        l10n.errorUnauthorizedMessage,
      );
      expect(validation.localizedMessage(l10n), l10n.errorValidationMessage);
    });

    test('maps permission failures by severity', () {
      const denied = PermissionException('denied');
      const permanent = PermissionException(
        'denied',
        permanentlyDenied: true,
      );

      expect(
        denied.localizedMessage(l10n),
        l10n.errorPermissionDeniedMessage,
      );
      expect(
        permanent.localizedMessage(l10n),
        l10n.errorPermissionPermanentlyDeniedMessage,
      );
    });

    test('maps location failures', () {
      const disabled = LocationException('off', serviceDisabled: true);

      expect(
        disabled.localizedMessage(l10n),
        l10n.errorLocationDisabledMessage,
      );
    });

    test('surfaces server-provided API messages', () {
      const api = ApiException('Quota exceeded', statusCode: 429);

      expect(api.localizedMessage(l10n), 'Quota exceeded');
    });

    test('falls back to the generic message', () {
      const unexpected = UnexpectedException('boom');

      expect(unexpected.localizedMessage(l10n), l10n.errorGenericMessage);
    });
  });
}
