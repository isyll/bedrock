import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveProgressIndicator extends StatelessWidget {
  const AdaptiveProgressIndicator({super.key, this.size = 24, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return switch (Theme.of(context).platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => CupertinoActivityIndicator(
        radius: size / 2,
        color: color,
      ),
      _ => SizedBox.square(
        dimension: size,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
      ),
    };
  }
}
