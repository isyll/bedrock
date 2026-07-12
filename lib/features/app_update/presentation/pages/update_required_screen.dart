import 'dart:async';

import 'package:bedrock/core/extensions/context_extensions.dart';
import 'package:bedrock/features/app_update/presentation/cubit/app_update_cubit.dart';
import 'package:bedrock/shared/animations/staggered_column.dart';
import 'package:bedrock/shared/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateRequiredScreen extends StatelessWidget {
  const UpdateRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const .new(maxWidth: 360),
              child: StaggeredColumn(
                mainAxisSize: .min,
                crossAxisAlignment: .stretch,
                children: [
                  Icon(
                    Icons.system_update_alt,
                    size: 72,
                    color: context.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.updateRequiredTitle,
                    style: context.textTheme.headlineSmall,
                    textAlign: .center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.updateRequiredMessage,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: .center,
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    label: l10n.updateButton,
                    onPressed: () =>
                        unawaited(context.read<AppUpdateCubit>().openStore()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
