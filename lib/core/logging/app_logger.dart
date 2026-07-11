import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

enum LogLevel {
  debug(500),
  info(800),
  warning(900),
  error(1000);

  const LogLevel(this.value);

  final int value;
}

final class AppLogger {
  const AppLogger(this.name);

  final String name;

  static LogLevel minimumLevel = kDebugMode ? LogLevel.debug : LogLevel.error;

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
    if (level.value < minimumLevel.value) return;
    developer.log(
      message,
      name: name,
      level: level.value,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
