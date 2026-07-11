import 'package:bedrock/app/router/app_route_observer.dart';
import 'package:bedrock/app/router/app_routes.dart';
import 'package:bedrock/app/router/stream_refresh_listenable.dart';
import 'package:bedrock/features/auth/domain/auth_repository.dart';
import 'package:bedrock/features/auth/presentation/bloc/session_bloc.dart';
import 'package:bedrock/features/auth/presentation/pages/sign_in_page.dart';
import 'package:bedrock/features/home/presentation/pages/home_page.dart';
import 'package:bedrock/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

final class AppRouter {
  AppRouter({required this._sessionBloc});

  final SessionBloc _sessionBloc;

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  late final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    refreshListenable: StreamRefreshListenable(_sessionBloc.stream),
    redirect: _redirect,
    observers: [AppRouteObserver()],
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        name: 'signIn',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final status = _sessionBloc.state.status;
    if (status == AuthStatus.unknown) return null;

    final location = state.matchedLocation;
    final isPublic = AppRoutes.isPublic(location);
    final isAuthenticated = status == AuthStatus.authenticated;

    if (!isAuthenticated && !isPublic) {
      final from = Uri.encodeComponent(state.uri.toString());
      return '${AppRoutes.signIn}?from=$from';
    }

    if (isAuthenticated && location == AppRoutes.signIn) {
      final from = state.uri.queryParameters['from'];
      if (from != null && from.isNotEmpty) {
        return Uri.decodeComponent(from);
      }
      return AppRoutes.home;
    }

    return null;
  }

  void dispose() => router.dispose();
}
