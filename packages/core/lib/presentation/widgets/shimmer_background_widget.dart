import 'dart:math';

import 'package:flutter/material.dart';

/// A background widget with animated shimmer dots that fade in and out
/// like an AI loading indicator
class ShimmerBackgroundWidget extends StatefulWidget {
  const ShimmerBackgroundWidget({
    super.key,
    this.backgroundColor = const Color(0xFF9ACCFD),
    this.dotColor = Colors.white,
    this.dotCount = 30,
    this.child,
  });

  /// Background color (default: #9ACCFD)
  final Color backgroundColor;

  /// Color of the shimmer dots
  final Color dotColor;

  /// Number of dots to animate
  final int dotCount;

  /// Optional child widget to display on top of the background
  final Widget? child;

  @override
  State<ShimmerBackgroundWidget> createState() =>
      _ShimmerBackgroundWidgetState();
}

class _ShimmerBackgroundWidgetState extends State<ShimmerBackgroundWidget>
    with TickerProviderStateMixin {
  late List<_ShimmerDot> _dots;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initDots();
  }

  void _initDots() {
    _dots = List.generate(widget.dotCount, (index) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 1500 + _random.nextInt(2000)),
        vsync: this,
      );

      // Stagger the start times for natural effect
      Future.delayed(Duration(milliseconds: _random.nextInt(3000)), () {
        if (mounted) {
          controller.repeat(reverse: true);
        }
      });

      return _ShimmerDot(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 2 + _random.nextDouble() * 4,
        controller: controller,
      );
    });
  }

  @override
  void dispose() {
    for (final dot in _dots) {
      dot.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      color: widget.backgroundColor,
      child: Stack(
        children: [
          // Shimmer dots layer
          ..._dots.map((dot) {
            return Positioned(
              left: dot.x * size.width,
              top: dot.y * size.height,
              child: AnimatedBuilder(
                animation: dot.controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: dot.controller.value * 0.8,
                    child: Container(
                      width: dot.size,
                      height: dot.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.dotColor,
                        boxShadow: [
                          BoxShadow(
                            color: widget.dotColor.withValues(alpha: 0.5),
                            blurRadius: dot.size * 2,
                            spreadRadius: dot.size * 0.5,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          // Child widget on top
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _ShimmerDot {
  _ShimmerDot({
    required this.x,
    required this.y,
    required this.size,
    required this.controller,
  });

  final double x;
  final double y;
  final double size;
  final AnimationController controller;
}
