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
  await _configureSystemUi();

  final firebaseReady = await _initializeFirebase(config);

  await configureDependencies(config, crashReporter: crashReporter);
  await crashReporter.initialize(firebaseAvailable: firebaseReady);

  final authRepository = getIt<AuthRepository>();
  await authRepository.restore();
  _bindCrashReportingToSession(crashReporter, authRepository);

  Bloc.observer = const AppBlocObserver();

  runApp(const App());

  if (firebaseReady) {
    unawaited(getIt<PushNotificationsService>().initialize());
  }
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

void _bindCrashReportingToSession(
  CrashReporter crashReporter,
  AuthRepository authRepository,
) {
  crashReporter.setUserIdentifier(authRepository.currentUser?.id);
  authRepository.status.listen((status) {
    final userId = status == AuthStatus.authenticated
        ? authRepository.currentUser?.id
        : null;
    crashReporter.setUserIdentifier(userId);
  });
}

Future<void> _configureSystemUi() async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
}

Future<bool> _initializeFirebase(AppConfig config) async {
  final options = config.firebaseOptions;
  if (options == null) {
    _logger.info('Firebase is not configured, related services disabled');
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
