import 'package:bedrock/app/bootstrap.dart';
import 'package:bedrock/core/config/firebase/firebase_options_prod.dart';

Future<void> main() => bootstrap(
  .new(
    flavor: .prod,
    appName: 'Bedrock',
    apiBaseUrl: 'https://api.example.com',
    firebaseOptions: ProdFirebaseOptions.currentPlatformOrNull,
  ),
);
