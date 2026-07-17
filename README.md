<div align="center">

<img src="assets/images/logo.png" alt="Bedrock logo" width="96" />

# Bedrock

**A production-grade Flutter template for Android and iOS.**

Start every mobile project on solid ground: flavors, opaque-token sessions, bloc state management, routing, theming, l10n, push notifications, crash reporting, device services, animations, and quality tooling, all wired and verified.

![Flutter](https://img.shields.io/badge/Flutter-3.44-45cdf5?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.12-0175C2?logo=dart&logoColor=white)
![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS-333)
![Lints](https://img.shields.io/badge/style-very__good__analysis-B22C89)

</div>

> [!TIP]
> This repository is a template. Open it with Claude Code and run the `project-setup` skill, or use the `/project-setup` prompt with GitHub Copilot, to rename, rebrand, and configure a fresh project in minutes. The [customization guide](docs/CUSTOMIZATION.md) covers every knob in detail, including the backend contracts.

## What is inside

| Area | Choice |
| --- | --- |
| State management | `flutter_bloc`: `SessionBloc`, `ThemeCubit`, `LocaleCubit` app-wide, a `Bloc`/`Cubit` per screen |
| Navigation | `go_router` with a session-driven redirect guard and deep link support |
| Networking | `dio` behind a multi-client factory, opaque token auth with proactive expiry checks and single-flight refresh |
| Errors | Sealed `AppException` hierarchy and a hand-rolled `Result<T>`, no exceptions across layers |
| Device identity | Install id (UUID v4 in secure storage) plus app and device metadata headers on every request, device payload stored with the backend session at sign in |
| App updates | Platform-native, no backend: Google Play in-app updates on Android, App Store version check with a dismissible prompt on iOS |
| Ratings | Native in-app review prompts, throttled by session count, app age, and prompt interval |
| DI | `get_it`, plain constructor injection |
| Storage | `shared_preferences` (cached) for settings, hardened `flutter_secure_storage` for tokens |
| Logging | Sink-based `AppLogger` with boxed, colored console output and Crashlytics forwarding |
| Crash reporting | Firebase Crashlytics: fatal handlers, breadcrumbs, non-fatal records, user id binding |
| Push | Firebase Cloud Messaging with `flutter_local_notifications` for foreground display |
| Permissions | `PermissionsService` baseline over `permission_handler`, localized denial errors |
| Media | `MediaPickerService` for gallery, camera, and document picking |
| Location | `LocationService` over `geolocator` with permission-aware `Result` API |
| Biometrics | Opt-in app lock over `local_auth`: settings toggle, locks on background, Face ID and fingerprint |
| Animations | Motion tokens, entrance/stagger/press widgets, Lottie with graceful fallback |
| Localization | ARB files in `assets/l10n`, generated with `flutter gen-l10n` (en, fr), `Accept-Language` on every request |
| Theming | Material 3 seeded color scheme, light and dark, widget-state-aware component themes, semantic color extension, Cupertino-adaptive widgets |
| Security | No cleartext traffic, certificate pin scaffold, obfuscated release builds, device-bound keychain |
| Quality | `very_good_analysis`, `dart format`, opt-in git pre-commit hooks, GitHub Actions CI |

## Getting started

```sh
flutter pub get
flutter run --flavor dev --target lib/main_dev.dart
```

The dev flavor ships with `useFakeAuth: true`, so the app runs end to end (sign in, session, sign out) with no backend.

<details>
<summary><strong>All common commands</strong></summary>

```sh
make get          # fetch dependencies
make l10n         # regenerate localizations
make check        # format check + analyze
make run-dev      # run the dev flavor
make run-prod     # run the prod flavor
make apk          # prod release APK
make aab          # prod release app bundle
make ipa          # prod release IPA (macOS only)
make icons        # regenerate launcher icons
make splash       # regenerate native splash screens
make hooks        # enable the pre-commit hook
```

</details>

## Flavors

Two flavors, two entry points, zero leakage:

```text
dev   com.ibrahimasylla.bedrock.dev   lib/main_dev.dart    Bedrock Dev
prod  com.ibrahimasylla.bedrock       lib/main_prod.dart   Bedrock
```

Each entry point builds its own immutable `AppConfig` and imports only its own Firebase options file. Dart tree shaking guarantees that dev URLs, keys, and Firebase options never appear in the prod binary, and vice versa. On iOS the flavors map to the `dev` and `prod` schemes with `Debug/Release/Profile-<flavor>` configurations; on Android they are Gradle product flavors.

## Architecture

```text
lib/
├── main_dev.dart / main_prod.dart   flavor entry points
├── app/                             bootstrap, root widget, router, theme
├── core/                            config, di, error, l10n, logging,
│                                    network, session, storage, extensions
├── features/
│   ├── about/                       app name, version, licenses, rate app
│   ├── app_update/                  native in-app updates (Play and App Store)
│   ├── auth/                        sign in, session, token lifecycle
│   ├── home/
│   ├── security/                    biometric app lock
│   └── settings/                    theme and language preferences
├── services/                        crash reporting, device info, location,
│                                    media picking, permissions, push
│                                    notifications, review, store
└── shared/                          animations toolkit and reusable UI
    ├── animations/                  AppMotion, FadeSlideIn, TapScale, Lottie
    └── widgets/                     adaptive, buttons, feedback, loaders
```

The session flow is the backbone: the backend issues an opaque access token with an `expires_at` timestamp, `AuthInterceptor` checks that expiry before every request and refreshes stale tokens once for all concurrent requests (with a 401 retry as fallback), `SessionManager` persists and rotates tokens, `SessionBloc` exposes the session to the UI, and the router redirects based on it. A refresh failure ends the session gracefully with a localized notice, never a crash.

## Configuration checklist

- [ ] Run the `project-setup` skill (or follow `.claude/skills/project-setup/SKILL.md` manually)
- [ ] Set API base URLs in `lib/main_dev.dart` and `lib/main_prod.dart`, and endpoint paths via `AuthEndpoints` if they differ from the `/v1` defaults
- [ ] Implement the backend contract (session device payload) described in [docs/CUSTOMIZATION.md](docs/CUSTOMIZATION.md)
- [ ] Set `appStoreId` in `lib/main_prod.dart` once the app exists in App Store Connect (required for the iOS update and review prompts)
- [ ] `flutterfire configure` per flavor, paste into `lib/core/config/firebase/`, flip `configured` to `true`
- [ ] Replace `assets/branding/` images, then `make icons splash`
- [ ] Point deep link hosts at your domains (Gradle placeholders, iOS `DEEP_LINK_HOST`)
- [ ] Review the iOS usage descriptions in `ios/Runner/Info.plist` and keep only the permissions your app requests
- [ ] Pin your API certificates in `android/app/src/main/res/xml/network_security_config.xml` before release
- [ ] Add `android/key.properties` and a keystore for release signing
- [ ] `make hooks` to enable pre-commit checks
- [ ] Enable the GitHub Copilot coding agent on the repository (its environment setup workflow ships preconfigured)

## Notes on production services

- Crash reporting activates automatically in non-debug builds once Firebase is configured; collection stays off in debug and without Firebase options.
- Release builds via `make apk`, `make aab`, and `make ipa` are obfuscated with debug symbols split into `build/symbols`. Keep those symbols to deobfuscate Crashlytics stack traces.
- For native Android crash symbolication, the `google-services` and `firebase-crashlytics` Gradle plugins apply automatically once `android/app/google-services.json` is present, uploading the R8 mapping file to Crashlytics on release builds.

## Release checklist

Template defaults to verify or set before shipping a real build:

- **iOS push environment.** `ios/Runner/Runner.entitlements` pins `aps-environment` to `development`. Xcode rewrites it to `production` when it re-signs a distribution build with automatic signing, but confirm the archive carries `production` before uploading to TestFlight or the App Store.
- **Android release signing.** Provide `android/key.properties` and a keystore. Prod release builds now fail fast when it is missing instead of silently shipping a debug-signed binary.
- **Firebase configuration.** After `flutterfire configure`, flip `configured` to `true` in `lib/core/config/firebase/firebase_options_*.dart`; a prod launch logs a warning while it is still `false`, and the regenerated options replace the placeholder `iosBundleId`.
- **Crashlytics symbols.** Keep the Dart symbols from `build/symbols` to deobfuscate stack traces; native symbolication is wired through the Gradle plugins above.
- **iOS pods.** `ios/Podfile` pins the deployment target and trims unused `permission_handler` code; keep its permission flags in sync with the permissions the app actually requests.

## License

Released under the [MIT License](LICENSE) by [Ibrahima Sylla](https://github.com/isyll). Use it freely for personal and commercial projects.
