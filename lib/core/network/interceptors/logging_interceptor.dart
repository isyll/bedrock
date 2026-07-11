import 'package:bedrock/core/logging/app_logger.dart';
import 'package:dio/dio.dart';

final class LoggingInterceptor extends Interceptor {
  const LoggingInterceptor({this._logger = const AppLogger('Http')});

  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.debug(
      '--> ${options.method} ${options.uri}\n'
      'headers: ${_sanitize(options.headers)}\n'
      'body: ${options.data}',
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logger.debug(
      '<-- ${response.statusCode} ${response.requestOptions.uri}\n'
      'body: ${response.data}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.warning(
      '<-- ${err.response?.statusCode ?? err.type.name} '
      '${err.requestOptions.uri}\n'
      'body: ${err.response?.data}',
    );
    handler.next(err);
  }

  Map<String, Object?> _sanitize(Map<String, Object?> headers) {
    if (!headers.containsKey('Authorization')) return headers;
    return {...headers, 'Authorization': 'Bearer ***'};
  }
}
