import 'dart:async';

import 'package:bedrock/shared/animations/app_motion.dart';
import 'package:flutter/material.dart';

class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.longDuration,
    this.curve = AppMotion.decelerate,
    this.offset = const Offset(0, 0.08),
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final Offset offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final _animation = CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
  );
  Timer? _delayTimer;

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _animation,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: widget.offset,
        end: .zero,
      ).animate(_animation),
      child: widget.child,
    ),
  );

  @override
  void dispose() {
    _delayTimer?.cancel();
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.delay == .zero) {
      unawaited(_controller.forward());
    } else {
      _delayTimer = .new(widget.delay, () {
        if (mounted) unawaited(_controller.forward());
      });
    }
  }
}
