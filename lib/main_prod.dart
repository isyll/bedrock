import 'package:bedrock/app/bootstrap.dart';
import 'package:bedrock/core/config/app_config.dart';
import 'package:bedrock/core/config/firebase/firebase_options_prod.dart';

Future<void> main() {
  return bootstrap(
    AppConfig(
      flavor: AppFlavor.prod,
      appName: 'Bedrock',
      apiBaseUrl: 'https://api.example.com/v1',
      tokenEndpoint: '/oauth/token',
      deepLinkHost: 'app.example.com',
      firebaseOptions: ProdFirebaseOptions.currentPlatformOrNull,
    ),
  );
}
