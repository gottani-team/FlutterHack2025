import 'dart:math';

import 'package:flutter/material.dart';

/// A background widget with a grid of dots that shimmer (show/hide)
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
    with TickerProviderStateMixin {
  List<_ShimmerDot>? _dots;
  final Random _random = Random();
  Size? _lastSize;
  AnimationController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _initDots(Size screenSize) {
    // Dispose old controller if reinitializing
    _controller?.dispose();

    final cols = (screenSize.width / widget.dotSpacing).floor();
    final rows = (screenSize.height / widget.dotSpacing).floor();

    // Create a single animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Create all dots with phase offsets (no controllers needed!)
    _dots = [];
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        _dots!.add(
          _ShimmerDot(
            x: col * widget.dotSpacing,
            y: row * widget.dotSpacing,
            maxOpacity: 0.1 + _random.nextDouble() * 0.2,
            phaseOffset: _random.nextDouble(), // Offset between 0 and 1
          ),
        );
      }
    }

    _lastSize = screenSize;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Initialize or reinitialize dots if screen size changed
    if (_dots == null || _lastSize != screenSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _initDots(screenSize);
          });
        }
      });
    }

    return Container(
      color: widget.backgroundColor,
      child: Stack(
        children: [
          // Grid of shimmer dots
          if (_dots != null && _controller != null)
            ..._dots!.map((dot) {
              return Positioned(
                left: dot.x,
                top: dot.y,
                child: AnimatedBuilder(
                  animation: _controller!,
                  builder: (context, child) {
                    // Calculate opacity using sin wave with phase offset
                    // This creates a smooth fade in/out effect
                    final phase = (_controller!.value + dot.phaseOffset) % 1.0;
                    final opacity = (sin(phase * pi * 2) + 1) / 2; // 0 to 1
                    return Opacity(
                      opacity: opacity * dot.maxOpacity,
                      child: Container(
                        width: widget.dotSize,
                        height: widget.dotSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.dotColor,
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
    required this.maxOpacity,
    required this.phaseOffset,
  });

  final double x;
  final double y;
  final double maxOpacity;
  final double phaseOffset; // Phase offset between 0 and 1 for animation timing
}
