import 'package:bedrock/shared/animations/app_motion.dart';
import 'package:bedrock/shared/animations/fade_slide_in.dart';
import 'package:flutter/material.dart';

class StaggeredColumn extends StatelessWidget {
  const StaggeredColumn({
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.interval = AppMotion.staggerInterval,
    this.initialDelay = Duration.zero,
    super.key,
  });

  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final Duration interval;
  final Duration initialDelay;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        for (final (index, child) in children.indexed)
          FadeSlideIn(delay: initialDelay + interval * index, child: child),
      ],
    );
  }
}
