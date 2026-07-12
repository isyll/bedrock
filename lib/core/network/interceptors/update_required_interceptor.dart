import 'package:dio/dio.dart';

final class UpdateRequiredInterceptor extends Interceptor {
  const UpdateRequiredInterceptor({required this._onUpdateRequired});

  final void Function() _onUpdateRequired;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 426) _onUpdateRequired();
    handler.next(err);
  }
}
