import 'dart:async';

import 'package:bedrock/core/logging/app_logger.dart';
import 'package:bedrock/services/crash/crashlytics_log_sink.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

final class CrashReporter {
  CrashReporter({this._logger = const AppLogger('CrashReporter')});

  final AppLogger _logger;

  bool _enabled = false;

  bool get isEnabled => _enabled;

  Future<void> initialize({required bool firebaseAvailable}) async {
    if (!firebaseAvailable) {
      _logger.info('Firebase unavailable, crash reporting disabled');
      return;
    }

    _enabled = !kDebugMode;
    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        _enabled,
      );
    } on Exception catch (error) {
      _enabled = false;
      _logger.warning('Failed to configure crash collection', error);
      return;
    }

    if (_enabled) {
      AppLogger.addSink(CrashlyticsLogSink(reporter: this));
      _logger.info('Crash reporting enabled');
    }
  }

  void leaveBreadcrumb(String message) {
    if (!_enabled) return;
    unawaited(FirebaseCrashlytics.instance.log(message));
  }

  void recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) {
    if (!_enabled) return;
    unawaited(
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      ),
    );
  }

  void recordFlutterError(FlutterErrorDetails details) {
    if (!_enabled) return;
    unawaited(FirebaseCrashlytics.instance.recordFlutterFatalError(details));
  }

  void setCustomKey(String key, Object value) {
    if (!_enabled) return;
    unawaited(FirebaseCrashlytics.instance.setCustomKey(key, value));
  }

  void setUserIdentifier(String? id) {
    if (!_enabled) return;
    unawaited(FirebaseCrashlytics.instance.setUserIdentifier(id ?? ''));
  }
}
