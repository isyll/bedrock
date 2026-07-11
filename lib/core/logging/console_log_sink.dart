import 'dart:math' as math;

import 'package:bedrock/core/logging/log_record.dart';
import 'package:flutter/foundation.dart';

final class ConsoleLogSink implements LogSink {
  const ConsoleLogSink({
    this.minimumLevel = kDebugMode ? .debug : .error,
    this.useColors = kDebugMode,
    this.lineLength = 88,
    this.maxStackFrames = 8,
  });

  static const _reset = '\x1B[0m';

  static const _bold = '\x1B[1m';
  static const _frame = '\x1B[38;5;240m';
  static const _muted = '\x1B[38;5;246m';

  @override
  final LogLevel minimumLevel;
  final bool useColors;
  final int lineLength;
  final int maxStackFrames;

  @override
  void write(LogRecord record) {
    final buffer = StringBuffer()..writeln(_header(record));
    _writeBody(buffer, record.message, '');

    final error = record.error;
    if (error != null) {
      buffer.writeln(_divider());
      _writeBody(buffer, error.toString(), _levelColor(record.level));
    }

    final stackTrace = record.stackTrace;
    if (stackTrace != null) {
      buffer.writeln(_divider());
      _writeBody(buffer, _formatStack(stackTrace), _muted);
    }

    buffer.write(_footer());
    debugPrint(buffer.toString());
  }

  String _divider() {
    final rule = '╌' * (lineLength - 1);
    return useColors ? '$_frame├$rule$_reset' : '├$rule';
  }

  String _footer() {
    final rule = '─' * (lineLength - 1);
    return useColors ? '$_frame╰$rule$_reset' : '╰$rule';
  }

  String _formatStack(StackTrace stackTrace) {
    final frames = stackTrace
        .toString()
        .trimRight()
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    if (frames.length <= maxStackFrames) return frames.join('\n');
    final hidden = frames.length - maxStackFrames;
    return [
      ...frames.take(maxStackFrames),
      '… $hidden more frames',
    ].join('\n');
  }

  String _header(LogRecord record) {
    final color = _levelColor(record.level);
    final title =
        '${record.level.symbol} ${record.level.label}'
        ' · ${record.loggerName} · ${_time(record.timestamp)}';
    final rule = '─' * math.max(4, lineLength - title.length - 5);
    if (!useColors) return '╭─ $title $rule';
    return '$_frame╭─$_reset $color$_bold$title$_reset $_frame$rule$_reset';
  }

  String _levelColor(LogLevel level) => switch (level) {
    .debug => '\x1B[38;5;244m',
    .info => '\x1B[38;5;75m',
    .warning => '\x1B[38;5;214m',
    .error => '\x1B[38;5;203m',
  };

  String _time(DateTime timestamp) {
    String pad(int value, [int width = 2]) =>
        value.toString().padLeft(width, '0');
    return '${pad(timestamp.hour)}:${pad(timestamp.minute)}'
        ':${pad(timestamp.second)}.${pad(timestamp.millisecond, 3)}';
  }

  void _writeBody(StringBuffer buffer, String text, String color) {
    final bar = useColors ? '$_frame│$_reset' : '│';
    for (final line in text.trimRight().split('\n')) {
      if (useColors && color.isNotEmpty) {
        buffer.writeln('$bar $color$line$_reset');
      } else {
        buffer.writeln('$bar $line');
      }
    }
  }
}
