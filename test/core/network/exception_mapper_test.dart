import 'package:bedrock/core/error/app_exception.dart';
import 'package:bedrock/core/network/exception_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final options = RequestOptions(path: '/things');

  DioException responseError(int statusCode, Object? body) => .new(
    requestOptions: options,
    type: .badResponse,
    response: Response<Object?>(
      requestOptions: options,
      statusCode: statusCode,
      data: body,
    ),
  );

  group('mapDioException', () {
    test('maps timeouts to a timeout NetworkException', () {
      for (final type in <DioExceptionType>[
        .connectionTimeout,
        .sendTimeout,
        .receiveTimeout,
      ]) {
        final mapped = mapDioException(
          .new(requestOptions: options, type: type),
        );

        expect(mapped, isA<NetworkException>());
        expect(
          (mapped as NetworkException).kind,
          NetworkFailureKind.timeout,
        );
      }
    });

    test('maps connection errors to an offline NetworkException', () {
      final mapped = mapDioException(
        .new(
          requestOptions: options,
          type: .connectionError,
        ),
      );

      expect((mapped as NetworkException).kind, NetworkFailureKind.offline);
    });

    test('maps cancellation and bad certificates', () {
      final cancelled = mapDioException(
        .new(requestOptions: options, type: .cancel),
      );
      final badCertificate = mapDioException(
        .new(
          requestOptions: options,
          type: .badCertificate,
        ),
      );

      expect(
        (cancelled as NetworkException).kind,
        NetworkFailureKind.cancelled,
      );
      expect(
        (badCertificate as NetworkException).kind,
        NetworkFailureKind.badCertificate,
      );
    });

    test('maps 401 responses to UnauthorizedException', () {
      final mapped = mapDioException(
        responseError(401, {'message': 'Nope', 'code': 'invalid_grant'}),
      );

      expect(mapped, isA<UnauthorizedException>());
      expect(mapped.message, 'Nope');
      expect((mapped as UnauthorizedException).code, 'invalid_grant');
    });

    test('maps 422 with field errors to ValidationException', () {
      final mapped = mapDioException(
        responseError(422, {
          'message': 'Invalid input',
          'errors': {
            'email': ['is already taken'],
            'name': 'is required',
          },
        }),
      );

      expect(mapped, isA<ValidationException>());
      final validation = mapped as ValidationException;
      expect(validation.fieldErrors['email'], ['is already taken']);
      expect(validation.fieldErrors['name'], ['is required']);
    });

    test('maps 422 without field errors to a plain ApiException', () {
      final mapped = mapDioException(
        responseError(422, {'message': 'Invalid input'}),
      );

      expect(mapped, isA<ApiException>());
      expect(mapped, isNot(isA<ValidationException>()));
    });

    test('maps server errors and extracts nested messages', () {
      final mapped = mapDioException(
        responseError(503, {
          'error': {'message': 'Down for maintenance', 'code': 'maintenance'},
        }),
      );

      final api = mapped as ApiException;
      expect(api.isServerError, isTrue);
      expect(api.message, 'Down for maintenance');
      expect(api.code, 'maintenance');
    });

    test('falls back to a generic message for unparseable bodies', () {
      final mapped = mapDioException(responseError(500, 'plain text'));

      expect((mapped as ApiException).message, 'Request failed (500)');
    });

    test('maps unknown errors to UnexpectedException', () {
      final mapped = mapDioException(
        .new(requestOptions: options, message: 'socket closed'),
      );

      expect(mapped, isA<UnexpectedException>());
      expect(mapped.message, 'socket closed');
    });
  });
}
