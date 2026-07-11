import 'package:firebase_core/firebase_core.dart';

enum AppFlavor { dev, prod }

final class AuthEndpoints {
  const AuthEndpoints({
    this.signIn = '/auth/login',
    this.refresh = '/auth/refresh',
    this.signOut = '/auth/logout',
    this.profile = '/me',
  });

  final String signIn;
  final String refresh;
  final String signOut;
  final String profile;
}

final class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    this.authEndpoints = const AuthEndpoints(),
    this.firebaseOptions,
    this.deepLinkScheme = 'bedrock',
    this.deepLinkHost = '',
    this.useFakeAuth = false,
  });

  final AppFlavor flavor;
  final String appName;
  final String apiBaseUrl;
  final AuthEndpoints authEndpoints;
  final FirebaseOptions? firebaseOptions;
  final String deepLinkScheme;
  final String deepLinkHost;
  final bool useFakeAuth;

  bool get isDev => flavor == AppFlavor.dev;
  bool get isProd => flavor == AppFlavor.prod;
  bool get firebaseEnabled => firebaseOptions != null;
}
