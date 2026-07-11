import 'package:bedrock/core/error/app_exception.dart';

final class Failure<T> extends Result<T> {
  const Failure(this.exception);

  final AppException exception;
}

sealed class Result<T> {
  const Result();

  const factory Result.failure(AppException exception) = Failure<T>;

  const factory Result.success(T value) = Success<T>;

  AppException? get exceptionOrNull => switch (this) {
    Success() => null,
    Failure(:final exception) => exception,
  };

  bool get isSuccess => this is Success<T>;

  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    Failure() => null,
  };

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppException exception) onFailure,
  }) => switch (this) {
    Success(:final value) => onSuccess(value),
    Failure(:final exception) => onFailure(exception),
  };

  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Success(:final value) => Result.success(transform(value)),
    Failure(:final exception) => Result.failure(exception),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}
