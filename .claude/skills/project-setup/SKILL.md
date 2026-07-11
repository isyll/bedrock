---
name: project-setup
description: Bootstrap a new app from the Bedrock template. Renames the project, package, org, and bundle identifiers, sets API URLs and deep link hosts, wires Firebase, regenerates icons and splash screens, and cleans template leftovers. Use when the user asks to initialize, rename, or configure a new project created from this template.
---

# Project setup

Collect from the user before starting (ask if missing):

1. App name (display name, e.g. "My App") and project name (snake_case, e.g. `my_app`)
2. Organization / package prefix (e.g. `com.acme`)
3. API base URLs for dev and prod
4. Auth endpoint paths if they differ from the defaults (`/auth/login`, `/auth/refresh`, `/auth/logout`, `/me`)
5. Deep link hosts for dev and prod (or skip deep links)
6. Whether Firebase/FCM is needed now

## Steps

1. Rename Dart package: replace `name: bedrock` in `pubspec.yaml` with the project name, then replace every `package:bedrock/` import across `lib/` with `package:<project>/`.
2. Rename Android package:
   - In `android/app/build.gradle.kts`: update `namespace`, `applicationId`, and the `resValue("string", "app_name", ...)` entries for both flavors.
   - Move `android/app/src/main/kotlin/com/ibrahimasylla/bedrock/MainActivity.kt` to the new package path and update its `package` declaration.
   - Update `manifestPlaceholders["deepLinkHost"]` per flavor.
3. Rename iOS bundle:
   - In `ios/Runner.xcodeproj/project.pbxproj`: update all `PRODUCT_BUNDLE_IDENTIFIER` values (dev configs get the `.dev` suffix), `APP_DISPLAY_NAME` values, and `DEEP_LINK_HOST` values.
   - In `ios/Runner/Info.plist`: update `CFBundleName` and the `CFBundleURLSchemes` custom scheme.
4. Update app config:
   - `lib/main_dev.dart` and `lib/main_prod.dart`: `appName`, `apiBaseUrl`, `deepLinkHost`, and `authEndpoints` (an `AuthEndpoints` instance) when the backend paths differ from the defaults.
   - `lib/core/config/app_config.dart`: default `deepLinkScheme`.
   - Android custom scheme in `android/app/src/main/AndroidManifest.xml` (`<data android:scheme=...>`).
5. Localizations: update `appTitle` in `assets/l10n/app_en.arb` and `assets/l10n/app_fr.arb`, then run `flutter gen-l10n`.
6. Branding: replace images in `assets/branding/` (keep the same file names), update colors in `flutter_launcher_icons-*.yaml` and `flutter_native_splash.yaml` and `lib/app/theme/app_colors.dart`, then run `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`.
7. Firebase (if needed): run `flutterfire configure` once per flavor project, paste the generated values into `lib/core/config/firebase/firebase_options_dev.dart` and `firebase_options_prod.dart`, and set `configured = true` in each.
8. Fake auth: set `useFakeAuth: false` in `lib/main_dev.dart` once the real backend is reachable.
9. GitHub: update `.github/CODEOWNERS` and repository name references in `README.md` and `AGENTS.md`.
10. Enable hooks: `git config core.hooksPath .githooks`.
11. Verify: `flutter pub get`, `flutter analyze --no-pub` (must be zero issues), then `flutter build apk --debug --flavor dev --target lib/main_dev.dart`.
12. Clean up: rewrite `README.md` for the new project and remove template-only wording.
