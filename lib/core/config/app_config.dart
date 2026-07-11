import 'package:firebase_core/firebase_core.dart';

enum AppFlavor { dev, prod }

final class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.tokenEndpoint,
    this.oauthClientId,
    this.firebaseOptions,
    this.deepLinkScheme = 'bedrock',
    this.deepLinkHost = '',
    this.useFakeAuth = false,
  });

  final AppFlavor flavor;
  final String appName;
  final String apiBaseUrl;
  final String tokenEndpoint;
  final String? oauthClientId;
  final FirebaseOptions? firebaseOptions;
  final String deepLinkScheme;
  final String deepLinkHost;
  final bool useFakeAuth;

  bool get isDev => flavor == AppFlavor.dev;
  bool get isProd => flavor == AppFlavor.prod;
  bool get firebaseEnabled => firebaseOptions != null;
}
