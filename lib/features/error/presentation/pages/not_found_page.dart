import 'package:bedrock/app/router/app_routes.dart';
import 'package:bedrock/core/extensions/context_extensions.dart';
import 'package:bedrock/shared/widgets/buttons/app_button.dart';
import 'package:bedrock/shared/widgets/feedback/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(),
      body: EmptyState(
        title: l10n.notFoundTitle,
        message: l10n.notFoundMessage,
        action: AppButton(
          label: l10n.goHomeButton,
          expanded: false,
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
    );
  }
}
