import 'package:bedrock/core/logging/console_log_sink.dart';
import 'package:bedrock/core/logging/log_record.dart';

export 'package:bedrock/core/logging/log_record.dart';

final class AppLogger {
  const AppLogger(this.name);

  static final _sinks = <LogSink>[const ConsoleLogSink()];

  final String name;

  void debug(String message) => _log(.debug, message);

  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _log(.error, message, error, stackTrace);

  void info(String message) => _log(.info, message);

  void warning(String message, [Object? error]) =>
      _log(.warning, message, error);

  void _log(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    final record = LogRecord(
      level: level,
      loggerName: name,
      message: message,
      timestamp: .now(),
      error: error,
      stackTrace: stackTrace,
    );

    for (final sink in _sinks) {
      if (record.level >= sink.minimumLevel) {
        sink.write(record);
      }
    }
  }

  static void addSink(LogSink sink) => _sinks.add(sink);
}
