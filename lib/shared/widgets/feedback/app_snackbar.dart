import 'package:bedrock/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  SnackBarKind kind = SnackBarKind.info,
}) {
  final colorScheme = context.colorScheme;
  final semantic = context.semanticColors;

  final (background, foreground) = switch (kind) {
    .info => (
      colorScheme.inverseSurface,
      colorScheme.onInverseSurface,
    ),
    .success => (semantic.success, semantic.onSuccess),
    .error => (colorScheme.error, colorScheme.onError),
  };

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      .new(
        content: Text(message, style: .new(color: foreground)),
        backgroundColor: background,
      ),
    );
}

enum SnackBarKind { info, success, error }
