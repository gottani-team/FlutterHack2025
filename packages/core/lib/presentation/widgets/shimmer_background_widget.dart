import 'dart:math';

import 'package:flutter/material.dart';

/// A background widget with a grid of dots that shimmer (show/hide)
/// Uses CustomPainter for optimal performance
class ShimmerBackgroundWidget extends StatefulWidget {
  const ShimmerBackgroundWidget({
    super.key,
    this.backgroundColor = const Color(0xFF9ACCFD),
    this.dotColor = Colors.black,
    this.dotSpacing = 10.0,
    this.dotSize = 2.0,
    this.child,
  });

  /// Background color (default: #9ACCFD)
  final Color backgroundColor;

  /// Color of the shimmer dots
  final Color dotColor;

  /// Spacing between dots in pixels
  final double dotSpacing;

  /// Size of each dot
  final double dotSize;

  /// Optional child widget to display on top of the background
  final Widget? child;

  @override
  State<ShimmerBackgroundWidget> createState() =>
      _ShimmerBackgroundWidgetState();
}

class _ShimmerBackgroundWidgetState extends State<ShimmerBackgroundWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<_ShimmerDot>? _dots;
  Size? _lastSize;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initDots(Size size) {
    final cols = (size.width / widget.dotSpacing).floor();
    final rows = (size.height / widget.dotSpacing).floor();

    _dots = [];
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        _dots!.add(
          _ShimmerDot(
            x: col * widget.dotSpacing,
            y: row * widget.dotSpacing,
            maxOpacity: 0.1 + _random.nextDouble() * 0.2,
            phaseOffset: _random.nextDouble(),
          ),
        );
      }
    }
    _lastSize = size;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        // Initialize dots if needed
        if (_dots == null || _lastSize != size) {
          _initDots(size);
        }

        return Container(
          color: widget.backgroundColor,
          child: Stack(
            children: [
              // Use RepaintBoundary to isolate the shimmer animation
              RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      size: size,
                      painter: _ShimmerPainter(
                        dots: _dots!,
                        animationValue: _controller.value,
                        dotColor: widget.dotColor,
                        dotSize: widget.dotSize,
                      ),
                    );
                  },
                ),
              ),
              // Child widget on top
              if (widget.child != null) widget.child!,
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  _ShimmerPainter({
    required this.dots,
    required this.animationValue,
    required this.dotColor,
    required this.dotSize,
  });

  final List<_ShimmerDot> dots;
  final double animationValue;
  final Color dotColor;
  final double dotSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final dot in dots) {
      final phase = (animationValue + dot.phaseOffset) % 1.0;
      final opacity = (sin(phase * pi * 2) + 1) / 2;
      paint.color = dotColor.withValues(alpha: opacity * dot.maxOpacity);
      canvas.drawCircle(
        Offset(dot.x, dot.y),
        dotSize / 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ShimmerPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class _ShimmerDot {
  _ShimmerDot({
    required this.x,
    required this.y,
    required this.maxOpacity,
    required this.phaseOffset,
  });

  final double x;
  final double y;
  final double maxOpacity;
  final double phaseOffset;
}
