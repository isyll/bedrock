import 'package:bedrock/core/extensions/context_extensions.dart';
import 'package:bedrock/shared/animations/app_lottie.dart';
import 'package:bedrock/shared/animations/app_motion.dart';
import 'package:bedrock/shared/animations/staggered_column.dart';
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    this.title,
    this.message,
    this.animationAsset = AppAnimations.empty,
    this.action,
    super.key,
  });

  final String? title;
  final String? message;
  final String animationAsset;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: StaggeredColumn(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLottie(animationAsset, size: 140),
            const SizedBox(height: 16),
            Text(
              title ?? l10n.emptyTitle,
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message ?? l10n.emptyMessage,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}
