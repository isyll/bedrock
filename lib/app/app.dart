import 'package:bedrock/app/router/app_router.dart';
import 'package:bedrock/app/theme/app_theme.dart';
import 'package:bedrock/core/di/injector.dart';
import 'package:bedrock/core/extensions/context_extensions.dart';
import 'package:bedrock/core/l10n/app_localizations.dart';
import 'package:bedrock/features/auth/presentation/bloc/session_bloc.dart';
import 'package:bedrock/features/settings/presentation/cubit/locale_cubit.dart';
import 'package:bedrock/features/settings/presentation/cubit/theme_cubit.dart';
import 'package:bedrock/shared/widgets/feedback/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionBloc>.value(value: getIt()),
        BlocProvider<ThemeCubit>.value(value: getIt()),
        BlocProvider<LocaleCubit>.value(value: getIt()),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;

    return MaterialApp.router(
      routerConfig: getIt<AppRouter>().router,
      onGenerateTitle: (context) => context.l10n.appTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return BlocListener<SessionBloc, SessionState>(
          listenWhen: (previous, current) =>
              current.expired && !previous.expired,
          listener: (context, state) {
            showAppSnackBar(
              context,
              context.l10n.sessionExpiredMessage,
              kind: SnackBarKind.error,
            );
          },
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 2,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
