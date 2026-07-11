<div align="center">

<img src="assets/images/logo.png" alt="Bedrock logo" width="96" />

# Bedrock

**A production-grade Flutter template for Android and iOS.**

Start every mobile project on solid ground: flavors, opaque-token sessions, bloc state management, routing, theming, l10n, push notifications, and quality tooling, all wired and verified.

![Flutter](https://img.shields.io/badge/Flutter-3.44-45cdf5?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.12-0175C2?logo=dart&logoColor=white)
![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS-333)
![Lints](https://img.shields.io/badge/style-very__good__analysis-B22C89)

</div>

> [!TIP]
> This repository is a template. Open it with Claude Code and run the `project-setup` skill, or use the `/project-setup` prompt with GitHub Copilot, to rename, rebrand, and configure a fresh project in minutes.

## What is inside

| Area | Choice |
| --- | --- |
| State management | `flutter_bloc`: `SessionBloc`, `ThemeCubit`, `LocaleCubit` app-wide, a `Bloc`/`Cubit` per screen |
| Navigation | `go_router` with a session-driven redirect guard and deep link support |
| Networking | `dio` behind a multi-client factory, opaque token auth with proactive expiry checks and single-flight refresh |
| Errors | Sealed `AppException` hierarchy and a hand-rolled `Result<T>`, no exceptions across layers |
| DI | `get_it`, plain constructor injection |
| Storage | `shared_preferences` for settings, `flutter_secure_storage` for tokens |
| Push | Firebase Cloud Messaging with `flutter_local_notifications` for foreground display |
| Localization | ARB files in `assets/l10n`, generated with `flutter gen-l10n` (en, fr) |
| Theming | Material 3 seeded color scheme, light and dark, semantic color extension, Cupertino-adaptive widgets |
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
│   ├── auth/                        sign in, session, token lifecycle
│   ├── home/
│   └── settings/                    theme and language preferences
├── services/                        push notifications
└── shared/widgets/                  adaptive, buttons, feedback, error views
```

The session flow is the backbone: the backend issues an opaque access token with an `expires_at` timestamp, `AuthInterceptor` checks that expiry before every request and refreshes stale tokens once for all concurrent requests (with a 401 retry as fallback), `SessionManager` persists and rotates tokens, `SessionBloc` exposes the session to the UI, and the router redirects based on it. A refresh failure ends the session gracefully with a localized notice, never a crash.

## Configuration checklist

- [ ] Run the `project-setup` skill (or follow `.claude/skills/project-setup/SKILL.md` manually)
- [ ] Set API base URLs in `lib/main_dev.dart` and `lib/main_prod.dart`, and auth endpoint paths via `AuthEndpoints` if they differ from the `/auth` defaults
- [ ] `flutterfire configure` per flavor, paste into `lib/core/config/firebase/`, flip `configured` to `true`
- [ ] Replace `assets/branding/` images, then `make icons splash`
- [ ] Point deep link hosts at your domains (Gradle placeholders, iOS `DEEP_LINK_HOST`)
- [ ] Add `android/key.properties` and a keystore for release signing
- [ ] `make hooks` to enable pre-commit checks
- [ ] Enable the GitHub Copilot coding agent on the repository (its environment setup workflow ships preconfigured)

## License

Private template by [Ibrahima Sylla](https://github.com/isyll).
