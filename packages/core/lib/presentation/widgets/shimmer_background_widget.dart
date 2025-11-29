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

  @override
  void dispose() {
    _disposeDots();
    super.dispose();
  }

  void _disposeDots() {
    if (_dots != null) {
      for (final dot in _dots!) {
        dot.controller.dispose();
      }
    }
  }

  void _initDots(Size screenSize) {
    // Dispose old dots if reinitializing
    _disposeDots();

    final cols = (screenSize.width / widget.dotSpacing).floor();
    final rows = (screenSize.height / widget.dotSpacing).floor();

    _dots = [];
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final controller = AnimationController(
          duration: Duration(milliseconds: 1500 + _random.nextInt(2500)),
          vsync: this,
        );

        // Stagger the start times
        Future.delayed(Duration(milliseconds: _random.nextInt(3000)), () {
          if (mounted) {
            controller.repeat(reverse: true);
          }
        });

        _dots!.add(_ShimmerDot(
          x: col * widget.dotSpacing,
          y: row * widget.dotSpacing,
          maxOpacity: 0.1 + _random.nextDouble() * 0.2,
          controller: controller,
        ));
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
          if (_dots != null)
            ..._dots!.map((dot) {
              return Positioned(
                left: dot.x,
                top: dot.y,
                child: AnimatedBuilder(
                  animation: dot.controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: dot.controller.value * dot.maxOpacity,
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
    required this.controller,
  });

  final double x;
  final double y;
  final double maxOpacity;
  final AnimationController controller;
}
