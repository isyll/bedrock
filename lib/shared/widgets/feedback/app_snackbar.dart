import 'package:bedrock/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

enum SnackBarKind { info, success, error }

void showAppSnackBar(
  BuildContext context,
  String message, {
  SnackBarKind kind = SnackBarKind.info,
}) {
  final colorScheme = context.colorScheme;
  final semantic = context.semanticColors;

  final (background, foreground) = switch (kind) {
    SnackBarKind.info => (
      colorScheme.inverseSurface,
      colorScheme.onInverseSurface,
    ),
    SnackBarKind.success => (semantic.success, semantic.onSuccess),
    SnackBarKind.error => (colorScheme.error, colorScheme.onError),
  };

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: foreground)),
        backgroundColor: background,
      ),
    );
}
