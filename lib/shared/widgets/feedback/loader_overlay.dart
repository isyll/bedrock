import 'package:bedrock/core/extensions/context_extensions.dart';
import 'package:bedrock/shared/animations/app_motion.dart';
import 'package:bedrock/shared/widgets/adaptive/adaptive_progress_indicator.dart';
import 'package:flutter/material.dart';

abstract final class LoaderOverlay {
  static OverlayEntry? _entry;

  static bool get isVisible => _entry != null;

  static Future<T> during<T>(
    BuildContext context,
    Future<T> operation, {
    String? message,
  }) async {
    show(context, message: message);
    try {
      return await operation;
    } finally {
      hide();
    }
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }

  static void show(BuildContext context, {String? message}) {
    if (_entry != null) return;
    final entry = OverlayEntry(
      builder: (context) => _LoaderOverlayView(message: message),
    );
    _entry = entry;
    Overlay.of(context, rootOverlay: true).insert(entry);
  }
}

class _LoaderOverlayView extends StatelessWidget {
  const _LoaderOverlayView({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final message = this.message;

    return TweenAnimationBuilder<double>(
      tween: .new(begin: 0, end: 1),
      duration: AppMotion.shortDuration,
      curve: AppMotion.decelerate,
      builder: (context, opacity, child) =>
          Opacity(opacity: opacity, child: child),
      child: Stack(
        fit: .expand,
        children: [
          ModalBarrier(
            dismissible: false,
            color: context.colorScheme.scrim.withValues(alpha: 0.45),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const .new(maxWidth: 280),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHigh,
                  borderRadius: const BorderRadius.all(.circular(16)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      const AdaptiveProgressIndicator(size: 32),
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
