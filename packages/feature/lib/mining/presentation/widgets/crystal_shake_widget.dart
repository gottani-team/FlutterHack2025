import 'dart:math';

import 'package:flutter/material.dart';

/// Widget that wraps a child and provides a shake animation on demand
class CrystalShakeWidget extends StatefulWidget {
  const CrystalShakeWidget({
    super.key,
    required this.child,
    this.shakeDuration = const Duration(milliseconds: 150),
    this.shakeIntensity = 10.0,
  });

  /// The widget to apply shake animation to
  final Widget child;

  /// Duration of the shake animation
  final Duration shakeDuration;

  /// Maximum offset in pixels for the shake
  final double shakeIntensity;

  @override
  State<CrystalShakeWidget> createState() => CrystalShakeWidgetState();
}

class CrystalShakeWidgetState extends State<CrystalShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.shakeDuration,
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Trigger the shake animation
  void shake() {
    // Generate random offset direction
    final dx = (_random.nextDouble() - 0.5) * 2 * widget.shakeIntensity;
    final dy = (_random.nextDouble() - 0.5) * 2 * widget.shakeIntensity;

    _animation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: Offset(dx, dy),
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset(dx, dy),
          end: Offset(-dx * 0.5, -dy * 0.5),
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset(-dx * 0.5, -dy * 0.5),
          end: Offset.zero,
        ),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary isolates this animation from parent repaints
    // ensuring shake animation runs at 60fps without triggering
    // unnecessary repaints in the parent widget tree
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: _animation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
