---
mode: agent
description: Bootstrap a new app from the Bedrock template by renaming the project, packages, and bundle identifiers, configuring API URLs, deep links, Firebase, and branding.
---

Bootstrap a new app from this Bedrock template.

Collect from me before starting (ask if missing): app display name, project name (snake_case), organization package prefix (e.g. com.acme), dev and prod API base URLs, OAuth token endpoint path and optional client id, deep link hosts per flavor, and whether Firebase/FCM is needed now.

Then apply these steps:

1. Rename the Dart package: `name:` in `pubspec.yaml`, then every `package:bedrock/` import across `lib/`.
2. Rename the Android package: `namespace`, `applicationId`, and both `resValue("string", "app_name", ...)` entries in `android/app/build.gradle.kts`, move `MainActivity.kt` to the new package path and update its `package` declaration, and update `manifestPlaceholders["deepLinkHost"]` per flavor.
3. Rename the iOS bundle: all `PRODUCT_BUNDLE_IDENTIFIER` values in `ios/Runner.xcodeproj/project.pbxproj` (dev configs keep the `.dev` suffix), plus `APP_DISPLAY_NAME` and `DEEP_LINK_HOST` values. Update `CFBundleName` and the custom URL scheme in `ios/Runner/Info.plist`.
4. Update `lib/main_dev.dart` and `lib/main_prod.dart` (`appName`, `apiBaseUrl`, `tokenEndpoint`, `oauthClientId`, `deepLinkHost`), the default `deepLinkScheme` in `lib/core/config/app_config.dart`, and the Android custom scheme in `AndroidManifest.xml`.
5. Update `appTitle` in `assets/l10n/app_en.arb` and `assets/l10n/app_fr.arb`, then run `flutter gen-l10n`.
6. Replace images in `assets/branding/` (same file names), update colors in `flutter_launcher_icons-*.yaml`, `flutter_native_splash.yaml`, and `lib/app/theme/app_colors.dart`, then run `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`.
7. If Firebase is needed, run `flutterfire configure` per flavor, paste the values into `lib/core/config/firebase/firebase_options_dev.dart` and `firebase_options_prod.dart`, and set `configured = true` in each.
8. Set `useFakeAuth: false` in `lib/main_dev.dart` once the real backend is reachable.
9. Update `.github/CODEOWNERS`, `README.md`, and `AGENTS.md` for the new project, then run `git config core.hooksPath .githooks`.
10. Verify with `flutter pub get`, `flutter analyze --no-pub` (zero issues required), and `flutter build apk --debug --flavor dev --target lib/main_dev.dart`.

Respect AGENTS.md conventions: no code comments, no em dashes, simple commit messages.
