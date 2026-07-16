# Template analysis

A full audit of the Bedrock template: how every feature is implemented, how it compares against what typical Android and iOS apps need, and a prioritized list of corrections and improvements. Written against the state of the repo on 2026-07-16.

Verification snapshot at the time of writing:

| Check | Result |
| --- | --- |
| `flutter analyze --no-pub` | 0 issues |
| `flutter test` | 115 tests, all passing |
| Toolchain | Flutter 3.44, Dart 3.12 (uses dot-shorthand syntax such as `.new(...)`, so older SDKs will not compile) |

> [!NOTE]
> This document analyzes the template. For the step-by-step setup of a new project, use the `project-setup` skill and [CUSTOMIZATION.md](CUSTOMIZATION.md).

## 1. Startup and composition

### Boot sequence

`bootstrap()` in [lib/app/bootstrap.dart](../lib/app/bootstrap.dart) runs in this order:

1. `WidgetsFlutterBinding.ensureInitialized()`, then global error handling is wired first (`FlutterError.onError`, `PlatformDispatcher.onError`, `ErrorWidget.builder`), so nothing that follows can crash unobserved.
2. Firebase init, system UI configuration, and `configureDependencies` run in parallel. Firebase init returns `false` when the options files are still placeholders, and everything downstream (Crashlytics, push) degrades gracefully.
3. `CrashReporter.initialize` enables collection only in non-debug builds and only when Firebase is available.
4. The persisted session is restored before `runApp`, so the very first router redirect already sees a resolved auth status and there is no sign-in flash.
5. Crashlytics user id is bound to the session and kept in sync on every auth change.
6. `runApp`, then push notifications initialize fire-and-forget if Firebase is ready.

### Widget tree

[lib/app/app.dart](../lib/app/app.dart) provides five app-wide blocs from `get_it` (`SessionBloc`, `ThemeCubit`, `LocaleCubit`, `AppLockCubit`, `AppUpdateCubit`) above `MaterialApp.router`. The `builder` wraps every routed page in a fixed chain:

```text
session-expired snackbar listener
  > AppLifecycleHandler   (update checks, review session counting)
    > AppLockGate         (biometric lock overlay, locks on hide)
      > AppUpdateGate     (iOS update dialog)
        > text scaling clamped to 2.0
          > routed page
```

### Dependency injection

[lib/core/di/injector.dart](../lib/core/di/injector.dart) is the single composition root. It awaits `KeyValueStorage.create()` and `DeviceInfoService.load()` concurrently before registering anything, then registers everything else as lazy singletons with `dispose` callbacks. Fake versus real auth is selected here from `AppConfig.useFakeAuth`. Constructor injection everywhere; no locator calls inside business logic.

One fragility to know about: several factories read `DeviceInfoService.info`, a getter that throws before `load()` completes. This is safe only because `configureDependencies` awaits `load()` first. Keep that ordering if you reorganize the file.

## 2. Feature inventory and implementation notes

### Flavors and configuration

- Two flavors (`dev`, `prod`) with separate entry points that each build an immutable `AppConfig` ([lib/core/config/app_config.dart](../lib/core/config/app_config.dart)) and import only their own Firebase options file, so the other flavor's values are tree-shaken away.
- Dev supports `--dart-define=API_BASE_URL` overrides and ships with `useFakeAuth: true`, so the whole app runs end to end with no backend.
- Auth endpoint paths live in `AuthEndpoints` with `/v1` defaults, overridable per flavor.

### Auth and session (the backbone)

The strongest part of the template. Key pieces:

- [lib/core/session/auth_tokens.dart](../lib/core/session/auth_tokens.dart): tolerant token parsing. Accepts `access_token` or `token`, keeps the old refresh token when the server does not rotate it, unwraps `{data: {...}}` envelopes, and reads expiry from `expires_at` / `expired_at` (ISO string or epoch, seconds and millis auto-detected) or `expires_in` (number or string). A 30 second leeway treats tokens as expired slightly early.
- [lib/core/session/session_manager.dart](../lib/core/session/session_manager.dart): owns the token lifecycle and never touches UI. Single-flight refresh (concurrent callers share one in-flight future), a dedicated interceptor-free Dio for the refresh call so refresh can never recurse, and a clear failure policy: 400/401 from the refresh endpoint ends the session, transient errors keep it alive.
- [lib/core/network/interceptors/auth_interceptor.dart](../lib/core/network/interceptors/auth_interceptor.dart): two-layer defense. `onRequest` checks expiry and refreshes proactively before the request goes out; `onError` catches a 401, refreshes once (guarded by an `authRetried` flag), and replays the request through a bare retry client. Sign-in and refresh requests carry `skipAuth` so they can never loop.
- `SessionBloc` exposes the session to the UI and computes an `expired` flag (authenticated to unauthenticated without an explicit sign-out) that drives a localized "session expired" snackbar.

End-to-end sign-in flow: form validation > `SignInCubit.submit` > `AuthRepository.signIn` (device payload included in the body) > `SessionManager.start` > status stream > `SessionBloc` > router refresh listenable > redirect back to the `from` destination.

### Navigation and deep links

- `go_router` with a central `redirect` in [lib/app/router/app_router.dart](../lib/app/router/app_router.dart), refreshed by a `ChangeNotifier` bridging the `SessionBloc` stream.
- Unauthenticated users hitting a private route are sent to `/sign-in?from=<original uri>` and returned there after sign-in, so auth-gated deep links survive the detour.
- Deep links are wired natively on both platforms: `autoVerify` https app links plus a `bedrock://` custom scheme on Android, `FlutterDeepLinkingEnabled` plus associated domains on iOS.

### Networking and errors

- [lib/core/network/api_client.dart](../lib/core/network/api_client.dart): `ApiClientFactory` builds any number of Dio clients with a consistent interceptor stack (auth, client info headers, `Accept-Language`, debug logging). `ApiClient.run` converts every thrown error into a `Result<T>`.
- Repositories return `Result<T>` ([lib/core/error/result.dart](../lib/core/error/result.dart)) and never throw across layers. `mapDioException` maps all nine `DioExceptionType`s into a sealed `AppException` hierarchy, extracting message, code, and field errors from several common body shapes. UI strings come from `AppExceptionMessage.localizedMessage`, which is an exhaustive switch, so adding an exception type forces a localized message.
- `ClientInfoInterceptor` stamps `X-App-Version`, `X-Build-Number`, `X-Platform`, `X-OS-Version`, and `X-Device-Id` on every request from every client, including the token refresh client.

### Storage

- `KeyValueStorage` wraps `SharedPreferencesWithCache` (sync reads) for settings; `SecureStorage` wraps `flutter_secure_storage` (Android `migrateWithBackup`, iOS `first_unlock_this_device`) for tokens and the install id.
- Deliberate asymmetry: secure reads and deletes swallow platform failures and degrade, only writes rethrow as `StorageException`. See correction B6 for the logout consequence.

### Localization

ARB sources in `assets/l10n/` (en, fr, about 55 keys), generated into `lib/core/l10n/`, accessed via `context.l10n` with a non-nullable getter, so a missing key is a compile error. The chosen locale is also sent as `Accept-Language` on every request.

### Theming

- Material 3 seeded `ColorScheme`, light and dark, with hand-tuned themes for roughly 30 component families (widget-state-aware focus, hover, pressed, disabled treatments) in [lib/app/theme/app_theme.dart](../lib/app/theme/app_theme.dart).
- `AppSemanticColors` theme extension adds success / warning / info roles with proper `lerp`, accessed via `context.semanticColors`.
- `AppTypography.refine` adjusts weights and spacing on the platform default font. Cupertino-adaptive dialogs and progress indicators live in `lib/shared/widgets/adaptive/`.

### Push notifications

[lib/services/notifications/push_notifications_service.dart](../lib/services/notifications/push_notifications_service.dart) wires FCM: permission request, Android high-importance channel, foreground display through `flutter_local_notifications` (Android only, iOS presents natively), token refresh stream, and `data['route']` deep-linking into the router for taps on notifications, including the cold-start initial message.

### Crash reporting and logging

- `CrashReporter` wraps Crashlytics: fatal Flutter and platform errors from bootstrap, breadcrumbs, non-fatals, user id binding, collection disabled in debug or without Firebase.
- `AppLogger` fans `LogRecord`s out to sinks: a boxed, colored console sink in debug and a Crashlytics sink (breadcrumbs below error level, non-fatal records at error and above) in release.

### App updates, ratings, store

- Android: Google Play in-app updates through `in_app_update` (flexible first, immediate fallback); Play owns the whole UI.
- iOS: App Store lookup API compared against the installed version; a dismissible dialog is shown once per version, and dismissed versions are remembered.
- Checks run at startup and on resume, throttled to once per 6 hours.
- `AppReviewService` gates the native rating prompt by session count (5), days since first session (3), and days between prompts (90), all injectable.

### Device services

| Service | Implementation |
| --- | --- |
| `DeviceInfoService` | Loads app version, build, device model concurrently at startup; owns the install id (UUID v4 in secure storage, survives updates, keychain-persistent on iOS) |
| `PermissionsService` | `AppPermission` enum over `permission_handler`, `ensure()` skips the request when already usable or permanently denied |
| `MediaPickerService` | Gallery and multi-image picking (quality 85, max 2048px), document picking, camera capture with permission flow |
| `LocationService` | Current and last-known position behind service and permission checks, `Result` failures that localize |
| `BiometricsService` | `local_auth` with a mapped result enum (unavailable, not enrolled, locked out, ...) |

App lock: `AppLockCubit` persists the settings toggle, locks on `onHide`, and `AppLockGate` overlays an opaque lock screen that auto-triggers the biometric prompt on return.

### Animations and shared widgets

Motion tokens (`AppMotion`), entrance animations (`FadeSlideIn`, `StaggeredColumn`), press feedback (`TapScale`), Lottie with icon fallback (`AppLottie`), plus `AppButton` (loading state), `showAppSnackBar` (info / success / error), `AppLoader`, blocking `LoaderOverlay` with a `during(future)` helper, and an `EmptyState` widget.

### Testing and tooling

- 20 test files, 115 tests: `Result`, validators, token parsing, `SessionManager`, exception mapping, `AuthRepository`, all app-level blocs and cubits, review throttling, device info, and a few widgets. Hand-written fakes in [test/helpers/fakes.dart](../test/helpers/fakes.dart) including a scripted Dio `HttpClientAdapter`; no mocking framework.
- Makefile for every task, opt-in pre-commit hook (format, analyze, test), CI running format check, analyze, test, and a dev debug APK artifact.
- Two Claude Code skills: `project-setup` (bootstrap a real project) and `new-feature` (scaffold a feature), mirrored as Copilot prompts.

## 3. Coverage against common mobile app needs

What the template already covers, out of the feature set most Android and iOS apps end up needing:

| Feature | Status |
| --- | --- |
| Flavors, environment config | Included |
| Email and password sign-in, session, token refresh, sign-out | Included |
| Deep links (custom scheme and verified https) | Included |
| Push notifications with tap routing | Included |
| Crash reporting | Included |
| Localization (en, fr) | Included |
| Dark mode, Material 3 design system | Included |
| Biometric app lock | Included |
| In-app updates and review prompts | Included |
| Runtime permissions, camera and gallery, geolocation | Included |
| Secure token storage, install id | Included |
| Settings (theme, language, security, sign-out) | Included |
| CI quality gate, git hooks, strict lints | Included |
| Sign-up and email verification | Missing |
| Forgot and reset password | Missing |
| Onboarding or first-run experience | Missing |
| Profile screen (view and edit, avatar upload) | Missing (`refreshProfile` and `MediaPickerService` exist but no UI consumes them) |
| Account management: change password or email, delete account | Missing (account deletion is an App Store requirement when the app has sign-up) |
| Social sign-in (Google, Apple) | Missing (Apple requires Sign in with Apple whenever third-party social login is offered) |
| Connectivity monitoring and offline UX | Missing (no `connectivity_plus`; offline is only detected through request failures) |
| Analytics | Missing (Crashlytics only) |
| Remote image loading and caching | Missing (no `cached_network_image`) |
| Local database or offline cache | Missing (by design; add `drift` or similar per project) |
| Bottom navigation shell | Missing (router is a flat stack; add a `StatefulShellRoute` when the app grows tabs) |
| Pagination helpers | Missing |
| Feature flags or remote config | Missing |
| Server-driven force update | Missing (updates are store-driven and always dismissible; there is no kill switch for broken versions) |
| Terms of service and privacy policy screens | Missing (only the license page exists) |
| Notification preferences or in-app notification center | Missing |
| Release CI (signed builds, iOS lane, store deploy) | Missing (CI builds a dev debug APK only) |

The missing rows are mostly deliberate template scope decisions, but the first block (sign-up, password reset, profile, delete account) is worth scaffolding into the template itself since nearly every real app needs it, and the `new-feature` skill makes each one cheap to add.

## 4. Corrections

Bugs and behavior defects found during the audit, ordered by importance.

### B1. `from` redirect is double-decoded and unvalidated

[lib/app/router/app_router.dart](../lib/app/router/app_router.dart#L66-L71): the guard stores the original location with `Uri.encodeComponent`, but `state.uri.queryParameters['from']` already returns the percent-decoded value, so the extra `Uri.decodeComponent(from)` decodes twice. Any original location that itself contained percent-encoded characters (a search query with `%20`, an encoded slash) comes back corrupted. The value is also fed to the router unvalidated, so a crafted `/sign-in?from=...` deep link controls the post-login destination.

Fix: drop the `Uri.decodeComponent` call and only honor `from` when it is an internal path:

```dart
final from = state.uri.queryParameters['from'];
if (from != null && from.startsWith('/')) return from;
return AppRoutes.home;
```

### B2. 401 retry breaks for multipart requests

[lib/core/network/interceptors/auth_interceptor.dart](../lib/core/network/interceptors/auth_interceptor.dart#L37-L42): the retry replays the original `RequestOptions` through the retry client. If the failed request carried a `FormData` body (file upload), Dio throws because a finalized `FormData` cannot be reused. The upload then fails with a confusing error instead of the original 401. Fix: clone the form before retrying (Dio 5.5+ ships `FormData.clone()`):

```dart
if (options.data case final FormData form) {
  options.data = form.clone();
}
```

The proactive refresh in `onRequest` makes this path rare, which is exactly why it would otherwise go unnoticed until a real user hits it.

### B3. `watchLocation` bypasses the guard rails

[lib/services/location/location_service.dart](../lib/services/location/location_service.dart): `currentLocation` and `lastKnownLocation` run through `_ensureReady()` (service enabled, permission granted) and return `Result`, but `watchLocation()` does neither, so subscribers get raw geolocator stream errors when permission is missing. Make it verify readiness first (an `async*` wrapper that awaits `_ensureReady()` before yielding the geolocator stream) so all entry points behave the same.

### B4. `User.fromJson` turns a missing id into the string "null"

[lib/features/auth/domain/user.dart](../lib/features/auth/domain/user.dart): `json['id'].toString()` converts an absent or null id into `"null"` instead of failing fast. Since the Crashlytics user identifier and the session cache key off this, a backend change would corrupt them silently. Throw a `FormatException` like `AuthTokens.fromJson` does.

### B5. Foreground notification ids can collide

[lib/services/notifications/push_notifications_service.dart](../lib/services/notifications/push_notifications_service.dart): the local notification id is `notification.hashCode`, which can collide and silently replace an unrelated notification. Use `message.messageId?.hashCode` or a monotonic counter persisted per session.

### B6. Sign-out can leave tokens on disk

`SecureStorage.delete` swallows `PlatformException` by design, so if a delete fails during `SessionManager.end()` ([lib/core/session/session_manager.dart](../lib/core/session/session_manager.dart#L62-L68)), the in-memory session ends but the ciphertext stays in the keystore, and the next `restore()` resurrects the "logged-in" state. Low probability, but it is a security path: have `end()` fall back to `deleteAll()` on failure, or verify with `containsKey` afterwards.

### B7. Inconsistent service error guards

`MediaPickerService._guarded` catches only `AppException` and `PlatformException`, while `LocationService` also catches generic exceptions. Anything else thrown by the pickers escapes the `Result` contract and reaches the caller as a raw exception. Align both on the broader guard.

## 5. Release checklist traps

Not bugs, but defaults that will bite at ship time. Worth fixing in the template so no future project inherits them:

1. **iOS push is pinned to the sandbox.** `ios/Runner/Runner.entitlements` hardcodes `aps-environment = development`. TestFlight and App Store builds need `production`. Xcode manages this automatically when re-signing, but verify it per project.
2. **Release builds silently fall back to the debug keystore.** `android/app/build.gradle.kts` signs release builds with the debug keystore when `key.properties` is absent, so a "release" build can ship debug-signed with no error. Prefer failing the build with a clear message when the flavor is prod and the keystore is missing.
3. **Android crash reports will be unsymbolicated.** The Makefile builds with `--obfuscate --split-debug-info`, but the `google-services` and `firebase-crashlytics` Gradle plugins are not applied, so mapping files never reach Crashlytics. Add both plugins when wiring Firebase (the README mentions this; automating it in `project-setup` would be better).
4. **Firebase stays silently disabled until `configured = true`.** Running `flutterfire configure` fills the options but the `configured` flag in `lib/core/config/firebase/firebase_options_*.dart` is easy to forget, and nothing warns. Consider logging a warning at bootstrap when the flavor is prod and Firebase is unconfigured. Also note the `iosBundleId` inside both options files is hardcoded to the template bundle id.
5. **No committed `ios/Podfile`.** It is generated on first macOS build, which means no pinned iOS deployment target and no `permission_handler` preprocessor macros trimming unused permission code from the binary.

## 6. Improvements

Ranked by value for effort.

1. **Memoize the themes.** `AppTheme.light` and `AppTheme.dark` are getters that rebuild the entire `ThemeData` (seeded scheme plus ~30 component themes) on every `MaterialApp` rebuild, which happens on every theme or locale change. Make them `static final` fields.
2. **Move the push permission request out of cold start.** `bootstrap` calls `PushNotificationsService.initialize()`, which immediately triggers the OS notification permission dialog on first launch with zero context. Permission prompts convert far better after a priming moment. Split token and listener setup from the permission request, and expose `requestPermission()` for features to call at the right moment.
3. **Redact sensitive bodies in the logging interceptor.** [logging_interceptor.dart](../lib/core/network/interceptors/logging_interceptor.dart) masks auth headers but pretty-prints full request and response bodies, so in debug the console shows sign-in credentials and issued tokens. Redact known keys (`password`, `access_token`, `refresh_token`, ...) before printing. Debug-only today, but the safe default costs nothing.
4. **Give the lock screen an escape hatch.** If biometrics are enrolled but failing (sensor error, lockout), the lock screen offers only "try again", and the user is stuck. Add a sign-out option, and consider allowing device-credential fallback in `BiometricsService.authenticate`.
5. **Add a router `errorBuilder`.** Unknown routes and malformed deep links currently land on go_router's default error screen. Add a localized not-found page.
6. **Test the `AuthInterceptor`.** It contains the highest-risk logic in the template (proactive refresh, single-flight, 401 replay, `skipAuth`, retry guard) and is the one core piece with no test file. The existing `ScriptedHttpAdapter` fake makes this straightforward.
7. **Fake refresh for fake auth.** `FakeAuthApi` issues a 1 hour token but refresh still POSTs to the real (placeholder) URL, so a long dev session dies confusingly. Either give the fake a far-future expiry or route refresh through the fake as well.
8. **Update dialog re-prompt behavior.** `AppUpdateGate` persists the dismissed version even when the user taps "Update", so someone who accepts but does not complete the store update is never reminded of that version again. Persist the dismissal only on "Later" if you want re-prompts.
9. **Remove dead surface.** `SignInState.isSuccess` is set but never consumed (navigation is driven by the session stream), and `AppConfig.deepLinkScheme` / `deepLinkHost` are never read from Dart. Either use them (e.g. validate incoming links) or drop them.
10. **Centralize HTTP timeouts.** `ApiClientFactory` uses connect 15s / send and receive 30s while `SessionManager`'s token client uses connect 15s / receive 20s with no send timeout. Extract shared constants.
11. **Release pipeline.** Extend CI with a tag-triggered signed AAB and IPA lane (secrets for keystore and App Store Connect API key, symbol upload, optional Firebase App Distribution). Today only a dev debug APK is built.
12. **Widget test coverage.** Pages and gates (`SignInForm` validation, `AppLockGate` overlay, `AppUpdateGate` dialog) have no widget tests; the blocs behind them do. A handful of widget tests would cover the gap cheaply.

## 7. Suggested roadmap for the template

If the goal is "clone and ship" for future projects, in this order:

1. Apply corrections B1 to B7 and improvements 1 to 5 (all small, localized changes).
2. Scaffold the standard auth surface: sign-up, forgot password, email verification, profile with avatar upload, delete account. This is the largest gap between the template and a real first release.
3. Add connectivity monitoring (`connectivity_plus` behind a small service plus an offline banner) and `cached_network_image`, since almost every app needs both.
4. Add an analytics seam: an `AnalyticsService` interface with a no-op default, mirroring how `CrashReporter` degrades without Firebase, so screens can log events from day one and the backend (Firebase Analytics or other) is a per-project decision.
5. Add a release CI lane and, when the first multi-tab app arrives, a `StatefulShellRoute` bottom navigation example.
