import 'dart:ui';

import 'package:flutter/material.dart';

/// A ripple effect widget that displays animated expanding circles like water ripples.
///
/// Each circle starts small and grows larger while fading out,
/// creating a continuous ripple effect emanating from the center.
class RippleEffectWidget extends StatefulWidget {
  const RippleEffectWidget({
    super.key,
    this.baseSize = 468,
    this.borderWidth = 10,
    this.borderColor = const Color(0x1AFFFFFF),
    this.blurSigma = 12,
    this.animationDuration = const Duration(seconds: 3),
    this.rippleCount = 3,
  });

  /// The maximum size the ripples can grow to
  final double baseSize;

  /// Width of the circular borders
  final double borderWidth;

  /// Color of the borders (semi-transparent white by default)
  final Color borderColor;

  /// Blur sigma for the filter
  final double blurSigma;

  /// Duration of the full animation cycle for each ripple
  final Duration animationDuration;

  /// Number of ripple circles
  final int rippleCount;

  @override
  State<RippleEffectWidget> createState() => _RippleEffectWidgetState();
}

class _RippleEffectWidgetState extends State<RippleEffectWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.baseSize,
      height: widget.baseSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: List.generate(widget.rippleCount, (index) {
              // Stagger each ripple by offset
              final staggerOffset = index / widget.rippleCount;
              final animationValue =
                  (_controller.value + staggerOffset) % 1.0;

              // Scale from 0.3 to 1.0 (small to full size)
              final scale = 0.3 + (animationValue * 0.7);

              // Fade out as it grows (1.0 to 0.0)
              final opacity = (1.0 - animationValue).clamp(0.0, 1.0);

              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: _buildRippleCircle(),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildRippleCircle() {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: widget.blurSigma,
        sigmaY: widget.blurSigma,
      ),
      child: Container(
        width: widget.baseSize,
        height: widget.baseSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderWidth,
          ),
        ),
      ),
    );
  }
}
