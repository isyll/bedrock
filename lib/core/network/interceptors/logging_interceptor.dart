import 'dart:convert';

import 'package:bedrock/core/logging/app_logger.dart';
import 'package:dio/dio.dart';

final class LoggingInterceptor extends Interceptor {
  const LoggingInterceptor({this._logger = const AppLogger('Http')});

  static const _startedAtKey = 'log.started_at';
  static const _maxBodyLength = 2048;
  static const _redactedHeaders = {'authorization', 'cookie', 'set-cookie'};

  final AppLogger _logger;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final status = err.response?.statusCode?.toString() ?? err.type.name;
    _logger.warning(
      _compose([
        '← $status ${options.method} ${options.uri}${_elapsed(options)}',
        _formatBody(err.response?.data),
      ]),
    );
    handler.next(err);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedAtKey] = DateTime.now();
    _logger.debug(
      _compose([
        '→ ${options.method} ${options.uri}',
        _formatHeaders(options.headers),
        _formatBody(options.data),
      ]),
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final options = response.requestOptions;
    final summary =
        '← ${response.statusCode} ${options.method} ${options.uri}'
        '${_elapsed(options)}';
    _logger.debug(_compose([summary, _formatBody(response.data)]));
    handler.next(response);
  }

  String _compose(List<String> sections) =>
      sections.where((section) => section.isNotEmpty).join('\n');

  String _elapsed(RequestOptions options) {
    final startedAt = options.extra[_startedAtKey];
    if (startedAt is! DateTime) return '';
    return ' (${DateTime.now().difference(startedAt).inMilliseconds}ms)';
  }

  String _formatBody(Object? body) {
    if (body == null) return '';
    final rendered = switch (body) {
      final Map<dynamic, dynamic> map => _prettyJson(map),
      final List<dynamic> list => _prettyJson(list),
      final FormData form =>
        'form-data: ${form.fields.map((field) => field.key).join(', ')}',
      final String text when text.isNotEmpty => _prettyText(text),
      _ => body.toString(),
    };
    if (rendered.isEmpty) return '';
    return 'body:\n${_truncate(rendered)}';
  }

  String _formatHeaders(Map<String, Object?> headers) {
    if (headers.isEmpty) return '';
    final lines = headers.entries.map((entry) {
      final value = _redactedHeaders.contains(entry.key.toLowerCase())
          ? '***'
          : entry.value;
      return '  ${entry.key}: $value';
    });
    return 'headers:\n${lines.join('\n')}';
  }

  String _prettyJson(Object? value) {
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } on Object {
      return value.toString();
    }
  }

  String _prettyText(String text) {
    try {
      return _prettyJson(jsonDecode(text));
    } on FormatException {
      return text;
    }
  }

  String _truncate(String value) {
    if (value.length <= _maxBodyLength) return value;
    final omitted = value.length - _maxBodyLength;
    return '${value.substring(0, _maxBodyLength)}\n… $omitted more characters';
  }
}
