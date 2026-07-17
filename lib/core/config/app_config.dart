import 'package:firebase_core/firebase_core.dart';

final class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    this.authEndpoints = const .new(),
    this.appStoreId = '',
    this.firebaseOptions,
    this.useFakeAuth = false,
  });

  final AppFlavor flavor;
  final String appName;
  final String apiBaseUrl;
  final AuthEndpoints authEndpoints;
  final String appStoreId;
  final FirebaseOptions? firebaseOptions;
  final bool useFakeAuth;

  bool get firebaseEnabled => firebaseOptions != null;
  bool get isDev => flavor == .dev;
  bool get isProd => flavor == .prod;
}

enum AppFlavor { dev, prod }

final class AuthEndpoints {
  const AuthEndpoints({
    this.signIn = '/v1/auth/login',
    this.refresh = '/v1/auth/refresh',
    this.signOut = '/v1/auth/logout',
    this.profile = '/v1/me',
  });

  final String signIn;
  final String refresh;
  final String signOut;
  final String profile;
}
