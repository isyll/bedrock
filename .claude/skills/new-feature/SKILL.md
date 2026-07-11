---
name: new-feature
description: Scaffold a new feature following the Bedrock architecture (data, domain, presentation, bloc/cubit, routing, l10n, DI). Use when the user asks to add a screen, page, or feature.
---

# New feature

Given a feature name `<feature>` (snake_case):

1. Create the layout under `lib/features/<feature>/`:
   - `data/<feature>_api.dart`: abstract interface plus an HTTP implementation taking `ApiClient`, and a fake implementation if the backend is not ready.
   - `domain/`: entities (plain `Equatable` classes with hand-written `fromJson`/`toJson`) and `<feature>_repository.dart` returning `Result<T>`.
   - `presentation/bloc/` or `presentation/cubit/`: a `Bloc` for event-driven or long-lived flows, a `Cubit` for simple screen state. States are `Equatable` subclasses in a `part` file.
   - `presentation/pages/<feature>_page.dart`: page widget providing its bloc via `BlocProvider`.
   - `presentation/widgets/`: page-specific widgets.
2. Register data source and repository in `lib/core/di/injector.dart` as lazy singletons.
3. Add the route in `lib/app/router/app_routes.dart` and `lib/app/router/app_router.dart`. Add the path to `AppRoutes.publicPaths` only if it must be reachable while signed out.
4. Add user-facing strings to `assets/l10n/app_en.arb` and `assets/l10n/app_fr.arb`, run `flutter gen-l10n`, and use `context.l10n` in widgets.
5. Follow conventions: no comments, `Result` for all repository methods, errors surfaced with `localizedMessage`, adaptive widgets from `lib/shared/widgets/` where a platform-specific look matters.
6. Verify with `dart format lib` and `flutter analyze --no-pub` (zero issues).
