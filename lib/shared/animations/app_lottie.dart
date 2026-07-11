import 'package:bedrock/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLottie extends StatelessWidget {
  const AppLottie(
    this.asset, {
    this.size,
    this.repeat = true,
    this.semanticLabel,
    super.key,
  });

  final String asset;
  final double? size;
  final bool repeat;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget animation = Lottie.asset(
      asset,
      repeat: repeat,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.animation,
        size: size,
        color: context.colorScheme.onSurfaceVariant,
      ),
    );

    if (size != null) {
      animation = SizedBox(width: size, height: size, child: animation);
    }

    if (semanticLabel != null) {
      animation = Semantics(label: semanticLabel, child: animation);
    }

    return ExcludeSemantics(excluding: semanticLabel == null, child: animation);
  }
}
