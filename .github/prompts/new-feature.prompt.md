---
mode: agent
description: Scaffold a new feature following the Bedrock architecture (data, domain, presentation, bloc/cubit, routing, l10n, DI).
---

Scaffold a new feature named by me (snake_case) following the Bedrock architecture.

1. Create `lib/features/<feature>/` with:
   - `data/<feature>_api.dart`: abstract interface plus an HTTP implementation taking `ApiClient`, and a fake implementation if the backend is not ready.
   - `domain/`: plain `Equatable` entities with hand-written `fromJson`/`toJson`, and `<feature>_repository.dart` whose methods return `Result<T>`.
   - `presentation/bloc/` or `presentation/cubit/`: a `Bloc` for event-driven or long-lived flows, a `Cubit` for simple screen state, with `Equatable` states in a `part` file.
   - `presentation/pages/<feature>_page.dart` providing its bloc via `BlocProvider`, and `presentation/widgets/` for page-specific widgets.
2. Register the data source and repository in `lib/core/di/injector.dart` as lazy singletons.
3. Add the route in `lib/app/router/app_routes.dart` and `lib/app/router/app_router.dart`. Add the path to `AppRoutes.publicPaths` only if it must be reachable while signed out.
4. Add user-facing strings to `assets/l10n/app_en.arb` and `assets/l10n/app_fr.arb`, run `flutter gen-l10n`, and use `context.l10n` in widgets.
5. Map errors with `mapDioException` and surface them with `localizedMessage`. Use adaptive widgets from `lib/shared/widgets/` where a platform-specific look matters.
6. Verify with `dart format lib` and `flutter analyze --no-pub` (zero issues required).

Respect AGENTS.md conventions: no code comments, no em dashes, simple commit messages.
