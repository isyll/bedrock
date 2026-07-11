import 'package:bedrock/core/session/session_manager.dart';
import 'package:dio/dio.dart';

final class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this._session, required this._retryClient});

  static const skipAuthKey = 'skipAuth';
  static const _retriedKey = 'authRetried';

  final SessionManager _session;
  final Dio _retryClient;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final shouldRefresh =
        err.response?.statusCode == 401 &&
        options.extra[skipAuthKey] != true &&
        options.extra[_retriedKey] != true &&
        _session.status == .active;

    if (!shouldRefresh) {
      return handler.next(err);
    }

    final newToken = await _session.refreshAccessToken();
    if (newToken == null) {
      return handler.next(err);
    }

    options.headers['Authorization'] = 'Bearer $newToken';
    options.extra[_retriedKey] = true;

    try {
      final response = await _retryClient.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipAuthKey] == true) {
      return handler.next(options);
    }

    final token = await _session.validAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
