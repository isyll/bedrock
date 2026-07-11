import 'package:bedrock/core/logging/log_record.dart';
import 'package:bedrock/services/crash/crash_reporter.dart';

final class CrashlyticsLogSink implements LogSink {
  const CrashlyticsLogSink({required this._reporter});

  final CrashReporter _reporter;

  @override
  LogLevel get minimumLevel => LogLevel.info;

  @override
  void write(LogRecord record) {
    if (record.level.atLeast(LogLevel.error)) {
      _reporter.recordError(
        record.error ?? record.message,
        record.stackTrace,
        reason: '${record.loggerName}: ${record.message}',
      );
      return;
    }

    final suffix = record.error == null ? '' : ' (${record.error})';
    _reporter.leaveBreadcrumb(
      '${record.level.label} ${record.loggerName}: ${record.message}$suffix',
    );
  }
}
