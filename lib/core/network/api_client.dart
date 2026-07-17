import 'package:bedrock/core/config/app_config.dart';
import 'package:bedrock/core/error/app_exception.dart';
import 'package:bedrock/core/error/result.dart';
import 'package:bedrock/core/network/exception_mapper.dart';
import 'package:bedrock/core/network/interceptors/auth_interceptor.dart';
import 'package:bedrock/core/network/interceptors/client_info_interceptor.dart';
import 'package:bedrock/core/network/interceptors/locale_interceptor.dart';
import 'package:bedrock/core/network/interceptors/logging_interceptor.dart';
import 'package:bedrock/core/network/network_timeouts.dart';
import 'package:bedrock/core/session/session_manager.dart';
import 'package:bedrock/services/device/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

final class ApiClient {
  const ApiClient(this.dio);

  final Dio dio;

  void close() => dio.close();

  Future<Result<T>> run<T>(Future<T> Function(Dio dio) action) async {
    try {
      return .success(await action(dio));
    } on DioException catch (error) {
      return .failure(mapDioException(error));
    } on AppException catch (error) {
      return .failure(error);
    } on Object catch (error, stackTrace) {
      return .failure(
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
    required this._deviceInfo,
    this._localeResolver,
  });

  final AppConfig _config;
  final SessionManager _session;
  final DeviceInfo _deviceInfo;
  final LocaleResolver? _localeResolver;

  ApiClient backend() => create(baseUrl: _config.apiBaseUrl);

  ApiClient create({
    required String baseUrl,
    bool authenticated = true,
    Duration timeout = NetworkTimeouts.receive,
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
      ClientInfoInterceptor(info: _deviceInfo),
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
      connectTimeout: NetworkTimeouts.connect,
      sendTimeout: timeout,
      receiveTimeout: timeout,
      receiveDataWhenStatusError: true,
      headers: {'Accept': 'application/json', ...headers},
    ),
  );
}
