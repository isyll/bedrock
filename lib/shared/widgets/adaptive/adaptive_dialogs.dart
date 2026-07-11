import 'package:bedrock/core/extensions/context_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  String? cancelLabel,
  bool destructive = false,
}) async {
  final l10n = context.l10n;
  final confirmed = await showAdaptiveDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final platform = Theme.of(dialogContext).platform;
      final isCupertino = platform == .iOS || platform == .macOS;

      final cancelAction = isCupertino
          ? CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(cancelLabel ?? l10n.cancel),
            )
          : TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(cancelLabel ?? l10n.cancel),
            );

      final confirmAction = isCupertino
          ? CupertinoDialogAction(
              isDestructiveAction: destructive,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmLabel ?? l10n.ok),
            )
          : FilledButton(
              style: destructive
                  ? FilledButton.styleFrom(
                      backgroundColor: dialogContext.colorScheme.error,
                      foregroundColor: dialogContext.colorScheme.onError,
                    )
                  : null,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmLabel ?? l10n.ok),
            );

      return AlertDialog.adaptive(
        title: Text(title),
        content: Text(message),
        actions: [cancelAction, confirmAction],
      );
    },
  );
  return confirmed ?? false;
}
