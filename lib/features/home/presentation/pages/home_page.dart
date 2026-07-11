import 'package:bedrock/app/router/app_routes.dart';
import 'package:bedrock/core/extensions/context_extensions.dart';
import 'package:bedrock/features/auth/presentation/bloc/session_bloc.dart';
import 'package:bedrock/shared/animations/staggered_column.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTitle,
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: StaggeredColumn(
            crossAxisAlignment: .start,
            children: [
              BlocSelector<SessionBloc, SessionState, String?>(
                selector: (state) => state.user?.displayName,
                builder: (context, displayName) => Text(
                  l10n.welcomeMessage(displayName ?? ''),
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: .w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.homeBody,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
