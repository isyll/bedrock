import 'package:bedrock/core/config/app_config.dart';
import 'package:bedrock/core/error/app_exception.dart';
import 'package:bedrock/core/error/result.dart';
import 'package:bedrock/core/network/exception_mapper.dart';
import 'package:bedrock/core/network/interceptors/auth_interceptor.dart';
import 'package:bedrock/core/network/interceptors/locale_interceptor.dart';
import 'package:bedrock/core/network/interceptors/logging_interceptor.dart';
import 'package:bedrock/core/session/session_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

final class ApiClient {
  const ApiClient(this.dio);

  final Dio dio;

  void close() => dio.close();

  Future<Result<T>> run<T>(Future<T> Function(Dio dio) action) async {
    try {
      return Result.success(await action(dio));
    } on DioException catch (error) {
      return Result.failure(mapDioException(error));
    } on AppException catch (error) {
      return Result.failure(error);
    } on Object catch (error, stackTrace) {
      return Result.failure(
        UnexpectedException(
          'An unexpected error occurred',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}

final class ApiClientFactory {
  const ApiClientFactory({
    required this._config,
    required this._session,
    this._localeResolver,
  });

  final AppConfig _config;
  final SessionManager _session;
  final LocaleResolver? _localeResolver;

  ApiClient backend() => create(baseUrl: _config.apiBaseUrl);

  ApiClient create({
    required String baseUrl,
    bool authenticated = true,
    Duration timeout = const .new(seconds: 30),
    Map<String, String> headers = const {},
    List<Interceptor> interceptors = const [],
  }) {
    final dio = _bareDio(baseUrl: baseUrl, timeout: timeout, headers: headers);

    if (authenticated) {
      dio.interceptors.add(
        AuthInterceptor(
          session: _session,
          retryClient: _bareDio(
            baseUrl: baseUrl,
            timeout: timeout,
            headers: headers,
          ),
        ),
      );
    }

    dio.interceptors.addAll([
      LocaleInterceptor(resolver: _localeResolver),
      ...interceptors,
      if (kDebugMode) const LoggingInterceptor(),
    ]);

    return .new(dio);
  }

  Dio _bareDio({
    required String baseUrl,
    required Duration timeout,
    required Map<String, String> headers,
  }) => .new(
    .new(
      baseUrl: baseUrl,
      connectTimeout: const .new(seconds: 15),
      sendTimeout: timeout,
      receiveTimeout: timeout,
      receiveDataWhenStatusError: true,
      headers: {'Accept': 'application/json', ...headers},
    ),
  );
}
