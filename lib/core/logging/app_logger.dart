import 'package:bedrock/core/logging/console_log_sink.dart';
import 'package:bedrock/core/logging/log_record.dart';

export 'package:bedrock/core/logging/log_record.dart';

final class AppLogger {
  const AppLogger(this.name);

  final String name;

  static final List<LogSink> _sinks = [const ConsoleLogSink()];

  static void addSink(LogSink sink) => _sinks.add(sink);

  void debug(String message) => _log(LogLevel.debug, message);

  void info(String message) => _log(LogLevel.info, message);

  void warning(String message, [Object? error]) =>
      _log(LogLevel.warning, message, error);

  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _log(LogLevel.error, message, error, stackTrace);

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
      timestamp: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );

    for (final sink in _sinks) {
      if (record.level.atLeast(sink.minimumLevel)) {
        sink.write(record);
      }
    }
  }
}
