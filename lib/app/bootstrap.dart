import 'dart:async';

import 'package:bedrock/app/app.dart';
import 'package:bedrock/app/app_bloc_observer.dart';
import 'package:bedrock/core/config/app_config.dart';
import 'package:bedrock/core/di/injector.dart';
import 'package:bedrock/core/logging/app_logger.dart';
import 'package:bedrock/features/auth/domain/auth_repository.dart';
import 'package:bedrock/services/crash/crash_reporter.dart';
import 'package:bedrock/services/notifications/push_notifications_service.dart';
import 'package:bedrock/shared/widgets/error/app_error_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _logger = AppLogger('Bootstrap');

Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  final crashReporter = CrashReporter();
  _configureErrorHandling(crashReporter);

  final (firebaseReady, _, _) = await (
    _initializeFirebase(config),
    _configureSystemUi(),
    configureDependencies(config, crashReporter: crashReporter),
  ).wait;

  await crashReporter.initialize(firebaseAvailable: firebaseReady);

  final authRepository = sl<AuthRepository>();
  await authRepository.restore();
  _bindCrashReportingToSession(crashReporter, authRepository);

  Bloc.observer = const AppBlocObserver();

  runApp(const App());

  if (firebaseReady) {
    unawaited(sl<PushNotificationsService>().initialize());
  }
}

void _bindCrashReportingToSession(
  CrashReporter crashReporter,
  AuthRepository authRepository,
) {
  crashReporter.setUserIdentifier(authRepository.currentUser?.id);
  authRepository.status.listen((status) {
    final userId = status == .authenticated
        ? authRepository.currentUser?.id
        : null;
    crashReporter.setUserIdentifier(userId);
  });
}

void _configureErrorHandling(CrashReporter crashReporter) {
  FlutterError.onError = (details) {
    if (kDebugMode) {
      FlutterError.presentError(details);
      return;
    }
    crashReporter.recordFlutterError(details);
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    if (kDebugMode) {
      _logger.error('Uncaught platform error', error, stackTrace);
    } else {
      crashReporter.recordError(error, stackTrace, fatal: true);
    }
    return true;
  };

  ErrorWidget.builder = (details) => AppErrorWidget(details: details);
}

Future<void> _configureSystemUi() async {
  await SystemChrome.setPreferredOrientations([.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const .new(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
}

Future<bool> _initializeFirebase(AppConfig config) async {
  final options = config.firebaseOptions;
  if (options == null) {
    const message = 'Firebase is not configured, related services disabled';
    if (config.isProd) {
      _logger.warning(message);
    } else {
      _logger.info(message);
    }
    return false;
  }

  try {
    await Firebase.initializeApp(options: options);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    return true;
  } on Exception catch (error, stackTrace) {
    _logger.error('Firebase initialization failed', error, stackTrace);
    return false;
  }
}
