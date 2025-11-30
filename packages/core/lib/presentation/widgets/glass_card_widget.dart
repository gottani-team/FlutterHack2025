import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';

/// A reusable glass-effect card with backdrop blur and gradient border.
///
/// This widget creates a frosted glass effect with:
/// - Semi-transparent background
/// - Backdrop blur effect
/// - Gradient border (white → transparent → white)
class GlassCardWidget extends StatelessWidget {
  const GlassCardWidget({
    required this.child,
    super.key,
    this.padding = EdgeInsets.zero,
    this.borderRadius = 20,
    this.backgroundColor = const Color(0x38FFFFFF),
    this.blurSigma = 2,
    this.borderWidth = 1,
    this.gradientAngle = 55,
    this.useGradientBorder = true,
    this.borderColor = Colors.white,
    this.enableBlur = true,
  });

  /// The widget to display inside the card
  final Widget child;

  /// Padding inside the card
  final EdgeInsetsGeometry padding;

  /// Border radius of the card
  final double borderRadius;

  /// Background color (semi-transparent recommended)
  final Color backgroundColor;

  /// Blur sigma for the backdrop filter
  final double blurSigma;

  /// Width of the gradient border
  final double borderWidth;

  /// Angle of the gradient in degrees
  final double gradientAngle;

  final bool useGradientBorder;

  /// instead of the default gradient border.
  final Color borderColor;

  /// Whether to enable backdrop blur effect.
  /// Set to false for better performance on screens with complex backgrounds (e.g., maps).
  final bool enableBlur;

  @override
  Widget build(BuildContext context) {
    final containerDecoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: useGradientBorder
          ? GradientBoxBorder(
              gradient: LinearGradient(
                transform: GradientRotation(gradientAngle * 3.14159 / 180),
                colors: [
                  Color.lerp(Colors.white, borderColor, 0.6) ?? Colors.white,
                  borderColor == Colors.white
                      ? Colors.white.withValues(alpha: 0.0)
                      : borderColor,
                  borderColor == Colors.white
                      ? Colors.white.withValues(alpha: 0.0)
                      : borderColor,
                  Color.lerp(Colors.white, borderColor, 0.6) ?? Colors.white,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
              width: borderWidth,
            )
          : Border.all(color: borderColor, width: borderWidth),
    );

    final container = Container(
      padding: padding,
      decoration: containerDecoration,
      child: child,
    );

    // Skip blur for better performance when enableBlur is false
    if (!enableBlur) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: container,
      );
    }

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: container,
        ),
      ),
    );
  }
}
