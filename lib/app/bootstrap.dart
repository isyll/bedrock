import 'dart:async';

import 'package:bedrock/app/app.dart';
import 'package:bedrock/app/app_bloc_observer.dart';
import 'package:bedrock/core/config/app_config.dart';
import 'package:bedrock/core/di/injector.dart';
import 'package:bedrock/core/logging/app_logger.dart';
import 'package:bedrock/features/auth/domain/auth_repository.dart';
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

  _configureErrorHandling();
  await _configureSystemUi();

  final firebaseReady = await _initializeFirebase(config);

  await configureDependencies(config);
  await getIt<AuthRepository>().restore();

  Bloc.observer = const AppBlocObserver();

  runApp(const App());

  if (firebaseReady) {
    unawaited(getIt<PushNotificationsService>().initialize());
  }
}

void _configureErrorHandling() {
  FlutterError.onError = (details) {
    _logger.error('Flutter framework error', details.exception, details.stack);
    if (kDebugMode) FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    _logger.error('Uncaught platform error', error, stackTrace);
    return true;
  };

  ErrorWidget.builder = (details) => AppErrorWidget(details: details);
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
    _logger.info('Firebase is not configured, push notifications disabled');
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
