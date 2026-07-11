import 'package:firebase_core/firebase_core.dart';

final class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    this.authEndpoints = const .new(),
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

  bool get firebaseEnabled => firebaseOptions != null;
  bool get isDev => flavor == .dev;
  bool get isProd => flavor == .prod;
}

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
