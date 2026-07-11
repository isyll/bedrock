import 'package:bedrock/shared/animations/app_motion.dart';
import 'package:flutter/widgets.dart';

class TapScale extends StatefulWidget {
  const TapScale({
    required this.child,
    this.pressedScale = 0.97,
    this.enabled = true,
    super.key,
  });

  final Widget child;
  final double pressedScale;
  final bool enabled;

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: AppMotion.shortDuration,
        curve: AppMotion.decelerate,
        child: widget.child,
      ),
    );
  }
}
