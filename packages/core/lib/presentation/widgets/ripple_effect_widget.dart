import 'dart:ui';

import 'package:flutter/material.dart';

/// A ripple effect widget that displays animated concentric blurred circular borders.
///
/// Based on the Figma design with 3 circles:
/// - Outer: 468px, top: 0
/// - Middle: 360px, top: 54px
/// - Inner: 248px, top: 110px
class RippleEffectWidget extends StatefulWidget {
  const RippleEffectWidget({
    super.key,
    this.baseSize = 468,
    this.borderWidth = 10,
    this.borderColor = const Color(0x1AFFFFFF), // rgba(255, 255, 255, 0.1)
    this.blurSigma = 12,
    this.animationDuration = const Duration(seconds: 3),
  });

  /// The size of the outermost circle
  final double baseSize;

  /// Width of the circular borders
  final double borderWidth;

  /// Color of the borders (semi-transparent white by default)
  final Color borderColor;

  /// Blur sigma for the filter
  final double blurSigma;

  /// Duration of the full animation cycle
  final Duration animationDuration;

  @override
  State<RippleEffectWidget> createState() => _RippleEffectWidgetState();
}

class _RippleEffectWidgetState extends State<RippleEffectWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _outerAnimation;
  late Animation<double> _middleAnimation;
  late Animation<double> _innerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Staggered animations for each circle
    // Each circle pulses at different times for a ripple effect
    _innerAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6),
      ),
    );

    _middleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.75),
      ),
    );

    _outerAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.9),
      ),
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
    // Calculate sizes based on the CSS ratios
    final outerSize = widget.baseSize;
    final middleSize = widget.baseSize * (360 / 468);
    final innerSize = widget.baseSize * (248 / 468);

    // Calculate top offsets based on original CSS
    const outerTop = 0.0;
    final middleTop = widget.baseSize * (54 / 468);
    final innerTop = widget.baseSize * (110 / 468);

    return SizedBox(
      width: outerSize,
      height: outerSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              // Outer circle (largest)
              Positioned(
                top: outerTop,
                child: Transform.scale(
                  scale: _outerAnimation.value,
                  child: _buildRippleCircle(outerSize),
                ),
              ),
              // Middle circle
              Positioned(
                top: middleTop,
                child: Transform.scale(
                  scale: _middleAnimation.value,
                  child: _buildRippleCircle(middleSize),
                ),
              ),
              // Inner circle (smallest)
              Positioned(
                top: innerTop,
                child: Transform.scale(
                  scale: _innerAnimation.value,
                  child: _buildRippleCircle(innerSize),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRippleCircle(double size) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: widget.blurSigma,
        sigmaY: widget.blurSigma,
      ),
      child: Container(
        width: size,
        height: size,
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
