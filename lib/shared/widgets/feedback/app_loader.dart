import 'package:bedrock/core/extensions/context_extensions.dart';
import 'package:bedrock/shared/widgets/adaptive/adaptive_progress_indicator.dart';
import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({this.message, this.size = 32, super.key});

  final String? message;
  final double size;

  @override
  Widget build(BuildContext context) {
    final message = this.message;

    return Center(
      child: Column(
        mainAxisSize: .min,
        children: [
          AdaptiveProgressIndicator(size: size),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: .center,
            ),
          ],
        ],
      ),
    );
  }
}
