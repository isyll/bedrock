enum LogLevel {
  debug(500, 'DEBUG', '◦'),
  info(800, 'INFO', '●'),
  warning(900, 'WARN', '▲'),
  error(1000, 'ERROR', '✖');

  const LogLevel(this.value, this.label, this.symbol);

  final int value;
  final String label;
  final String symbol;

  bool atLeast(LogLevel other) => value >= other.value;
}

final class LogRecord {
  const LogRecord({
    required this.level,
    required this.loggerName,
    required this.message,
    required this.timestamp,
    this.error,
    this.stackTrace,
  });

  final LogLevel level;
  final String loggerName;
  final String message;
  final DateTime timestamp;
  final Object? error;
  final StackTrace? stackTrace;
}

abstract interface class LogSink {
  LogLevel get minimumLevel;

  void write(LogRecord record);
}
