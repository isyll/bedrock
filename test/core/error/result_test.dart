import 'package:bedrock/core/error/app_exception.dart';
import 'package:bedrock/core/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const exception = UnexpectedException('boom');

  group('Result', () {
    test('success exposes its value', () {
      const result = Result.success(21);

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, 21);
      expect(result.exceptionOrNull, isNull);
    });

    test('failure exposes its exception', () {
      const result = Result<int>.failure(exception);

      expect(result.isSuccess, isFalse);
      expect(result.valueOrNull, isNull);
      expect(result.exceptionOrNull, exception);
    });

    test('map transforms only success values', () {
      const success = Result.success(21);
      const failure = Result<int>.failure(exception);

      expect(success.map((value) => value * 2).valueOrNull, 42);
      expect(failure.map((value) => value * 2).exceptionOrNull, exception);
    });

    test('fold dispatches to the matching branch', () {
      const success = Result.success('ok');
      const failure = Result<String>.failure(exception);

      expect(
        success.fold(
          onSuccess: (value) => 'value:$value',
          onFailure: (error) => 'error',
        ),
        'value:ok',
      );
      expect(
        failure.fold(
          onSuccess: (value) => 'value:$value',
          onFailure: (error) => 'error:${error.message}',
        ),
        'error:boom',
      );
    });
  });
}
