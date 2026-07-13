import 'package:bedrock/core/error/app_exception.dart';
import 'package:bedrock/core/l10n/app_localizations.dart';

extension AppExceptionMessage on AppException {
  String localizedMessage(AppLocalizations l10n) => switch (this) {
    NetworkException(kind: .timeout) => l10n.errorTimeoutMessage,
    NetworkException() => l10n.errorNetworkMessage,
    UnauthorizedException() => l10n.errorUnauthorizedMessage,
    ValidationException() => l10n.errorValidationMessage,
    PermissionException(permanentlyDenied: true) =>
      l10n.errorPermissionPermanentlyDeniedMessage,
    PermissionException() => l10n.errorPermissionDeniedMessage,
    LocationException() => l10n.errorLocationDisabledMessage,
    ApiException(:final message) when message.isNotEmpty => message,
    _ => l10n.errorGenericMessage,
  };
}
