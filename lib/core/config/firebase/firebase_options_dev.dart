import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

abstract final class DevFirebaseOptions {
  static const configured = false;

  static const _android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FLUTTERFIRE',
    appId: 'REPLACE_WITH_FLUTTERFIRE',
    messagingSenderId: 'REPLACE_WITH_FLUTTERFIRE',
    projectId: 'REPLACE_WITH_FLUTTERFIRE',
  );

  static const _ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FLUTTERFIRE',
    appId: 'REPLACE_WITH_FLUTTERFIRE',
    messagingSenderId: 'REPLACE_WITH_FLUTTERFIRE',
    projectId: 'REPLACE_WITH_FLUTTERFIRE',
    iosBundleId: 'com.ibrahimasylla.bedrock.dev',
  );

  static FirebaseOptions? get currentPlatformOrNull =>
      configured ? _currentPlatform : null;

  static FirebaseOptions get _currentPlatform =>
      switch (defaultTargetPlatform) {
        .android => _android,
        .iOS => _ios,
        _ => throw UnsupportedError(
          'DevFirebaseOptions only supports Android and iOS',
        ),
      };
}
