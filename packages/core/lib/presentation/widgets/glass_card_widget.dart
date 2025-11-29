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
    this.borderColor,
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

  /// Optional solid border color. When provided, uses a solid border
  /// instead of the default gradient border.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: borderColor != null
                ? Border.all(color: borderColor!, width: borderWidth)
                : GradientBoxBorder(
                    gradient: LinearGradient(
                      transform:
                          GradientRotation(gradientAngle * 3.14159 / 180),
                      colors: [
                        Colors.white,
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white,
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                    width: borderWidth,
                  ),
          ),
          child: child,
        ),
      ),
    );
  }
}
