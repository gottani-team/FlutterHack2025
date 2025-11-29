import 'dart:math';

import 'package:flutter/material.dart';

/// Widget that wraps a child and provides a rotation animation on tap
class CrystalShakeWidget extends StatefulWidget {
  const CrystalShakeWidget({
    super.key,
    required this.child,
    this.rotateDuration = const Duration(milliseconds: 300),
    this.rotateAngle = 0.08, // radians (~4.5 degrees)
  });

  /// The widget to apply rotation animation to
  final Widget child;

  /// Duration of the rotation animation
  final Duration rotateDuration;

  /// Maximum rotation angle in radians
  final double rotateAngle;

  @override
  State<CrystalShakeWidget> createState() => CrystalShakeWidgetState();
}

class CrystalShakeWidgetState extends State<CrystalShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.rotateDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Trigger the rotation animation
  void shake() {
    // Random direction: left (-1) or right (1)
    final direction = _random.nextBool() ? 1.0 : -1.0;
    final angle = widget.rotateAngle * direction;

    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: angle),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: angle, end: -angle * 0.5),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -angle * 0.5, end: angle * 0.25),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: angle * 0.25, end: 0),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary isolates this animation from parent repaints
    // ensuring rotation animation runs at 60fps without triggering
    // unnecessary repaints in the parent widget tree
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _animation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
