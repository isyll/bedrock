class ApiException extends AppException {
  const ApiException(
    super.message, {
    required this.statusCode,
    this.code,
    this.details,
  });

  final int statusCode;
  final String? code;
  final Object? details;

  bool get isServerError => statusCode >= 500;
}

sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class LocationException extends AppException {
  const LocationException(super.message, {this.serviceDisabled = false});

  final bool serviceDisabled;
}

final class NetworkException extends AppException {
  const NetworkException(super.message, {required this.kind});

  final NetworkFailureKind kind;
}

enum NetworkFailureKind { offline, timeout, cancelled, badCertificate }

final class PermissionException extends AppException {
  const PermissionException(super.message, {this.permanentlyDenied = false});

  final bool permanentlyDenied;
}

final class StorageException extends AppException {
  const StorageException(super.message);
}

final class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message, {super.code})
    : super(statusCode: 401);
}

final class UpgradeRequiredException extends ApiException {
  const UpgradeRequiredException(super.message, {super.code})
    : super(statusCode: 426);
}

final class UnexpectedException extends AppException {
  const UnexpectedException(super.message, {this.cause, this.stackTrace});

  final Object? cause;
  final StackTrace? stackTrace;
}

final class ValidationException extends ApiException {
  const ValidationException(
    super.message, {
    required this.fieldErrors,
    super.statusCode = 422,
    super.code,
  });

  final Map<String, List<String>> fieldErrors;
}
