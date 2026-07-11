import 'package:bedrock/core/error/app_exception.dart';
import 'package:dio/dio.dart';

AppException mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const NetworkException(
        'The request timed out',
        kind: NetworkFailureKind.timeout,
      );
    case DioExceptionType.connectionError:
      return const NetworkException(
        'Unable to reach the server',
        kind: NetworkFailureKind.offline,
      );
    case DioExceptionType.cancel:
      return const NetworkException(
        'The request was cancelled',
        kind: NetworkFailureKind.cancelled,
      );
    case DioExceptionType.badCertificate:
      return const NetworkException(
        'The server certificate is not trusted',
        kind: NetworkFailureKind.badCertificate,
      );
    case DioExceptionType.badResponse:
      return _mapResponse(error);
    case DioExceptionType.unknown:
      return UnexpectedException(
        error.message ?? 'An unexpected network error occurred',
        cause: error.error,
        stackTrace: error.stackTrace,
      );
  }
}

AppException _mapResponse(DioException error) {
  final response = error.response;
  final statusCode = response?.statusCode ?? 0;
  final body = response?.data;

  final message = _extractMessage(body) ?? 'Request failed ($statusCode)';
  final code = _extractCode(body);

  if (statusCode == 401) return UnauthorizedException(message, code: code);

  if (statusCode == 422 || statusCode == 400) {
    final fieldErrors = _extractFieldErrors(body);
    if (fieldErrors.isNotEmpty) {
      return ValidationException(
        message,
        fieldErrors: fieldErrors,
        statusCode: statusCode,
        code: code,
      );
    }
  }

  return ApiException(
    message,
    statusCode: statusCode,
    code: code,
    details: body,
  );
}

String? _extractMessage(Object? body) {
  if (body is! Map) return null;
  final error = body['error'];
  if (error is Map && error['message'] is String) {
    return error['message'] as String;
  }
  if (body['message'] is String) return body['message'] as String;
  if (body['error_description'] is String) {
    return body['error_description'] as String;
  }
  return null;
}

String? _extractCode(Object? body) {
  if (body is! Map) return null;
  final error = body['error'];
  if (error is Map && error['code'] is String) return error['code'] as String;
  if (error is String) return error;
  if (body['code'] is String) return body['code'] as String;
  return null;
}

Map<String, List<String>> _extractFieldErrors(Object? body) {
  if (body is! Map) return const {};
  final rawErrors = body['errors'];
  if (rawErrors is! Map) return const {};

  final result = <String, List<String>>{};
  rawErrors.forEach((key, value) {
    final field = key.toString();
    if (value is List) {
      result[field] = value.map((entry) => entry.toString()).toList();
    } else if (value != null) {
      result[field] = [value.toString()];
    }
  });
  return result;
}
