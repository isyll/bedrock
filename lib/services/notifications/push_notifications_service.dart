import 'dart:async';
import 'dart:io';

import 'package:bedrock/core/logging/app_logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef NotificationRouteHandler = void Function(String route);
typedef TokenHandler = FutureOr<void> Function(String token);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  const AppLogger('Push').debug('Background message: ${message.messageId}');
}

final class PushNotificationsService {
  PushNotificationsService({
    this.onOpenRoute,
    this.onTokenChanged,
    this._logger = const AppLogger('Push'),
  });

  static const _routeKey = 'route';

  static const _androidChannel = AndroidNotificationChannel(
    'default_high_importance',
    'Important notifications',
    description: 'Notifications that require immediate attention',
    importance: Importance.high,
  );

  final NotificationRouteHandler? onOpenRoute;
  final TokenHandler? onTokenChanged;
  final AppLogger _logger;

  final _localNotifications = FlutterLocalNotificationsPlugin();
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<String>? _tokenSubscription;

  Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission();
    _logger.info(
      'Notification permission: ${settings.authorizationStatus.name}',
    );

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _initializeLocalNotifications();

    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _onForegroundMessage,
    );
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _onMessageOpened,
    );

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) _onMessageOpened(initialMessage);

    _tokenSubscription = messaging.onTokenRefresh.listen(_onToken);
    final token = await messaging.getToken();
    if (token != null) await _onToken(token);
  }

  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    await _tokenSubscription?.cancel();
  }

  Future<void> _initializeLocalNotifications() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        final route = response.payload;
        if (route != null && route.isNotEmpty) onOpenRoute?.call(route);
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null || !Platform.isAndroid) return;

    unawaited(
      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: message.data[_routeKey] as String?,
      ),
    );
  }

  void _onMessageOpened(RemoteMessage message) {
    final route = message.data[_routeKey] as String?;
    if (route != null && route.isNotEmpty) onOpenRoute?.call(route);
  }

  Future<void> _onToken(String token) async {
    _logger.debug('FCM token refreshed');
    await onTokenChanged?.call(token);
  }
}
