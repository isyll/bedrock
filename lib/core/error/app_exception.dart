sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

enum NetworkFailureKind { offline, timeout, cancelled, badCertificate }

final class NetworkException extends AppException {
  const NetworkException(super.message, {required this.kind});

  final NetworkFailureKind kind;
}

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

final class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message, {super.code})
    : super(statusCode: 401);
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

final class StorageException extends AppException {
  const StorageException(super.message);
}

final class UnexpectedException extends AppException {
  const UnexpectedException(super.message, {this.cause, this.stackTrace});

  final Object? cause;
  final StackTrace? stackTrace;
}
