import 'dart:ui';

import 'package:dio/dio.dart';

typedef LocaleResolver = String? Function();

final class LocaleInterceptor extends Interceptor {
  const LocaleInterceptor({this._resolver});

  final LocaleResolver? _resolver;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] =
        _resolver?.call() ?? PlatformDispatcher.instance.locale.toLanguageTag();
    handler.next(options);
  }
}
