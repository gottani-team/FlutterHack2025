import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A magical particle loading animation for world-immersion experience.
///
/// Displays floating particles that orbit around a central glow,
/// creating a fantasy atmosphere while loading.
class MagicalLoadingOverlay extends StatefulWidget {
  const MagicalLoadingOverlay({
    super.key,
    this.message = '地脈を探索中...',
    this.particleColor = const Color(0xFF4A90D9),
    this.glowColor = const Color(0xFF2E5A8B),
  });

  /// Loading message to display
  final String message;

  /// Primary color for particles
  final Color particleColor;

  /// Glow color for central orb
  final Color glowColor;

  @override
  State<MagicalLoadingOverlay> createState() => _MagicalLoadingOverlayState();
}

class _MagicalLoadingOverlayState extends State<MagicalLoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _orbitController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    // Orbit animation for particles (continuous rotation)
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Pulse animation for central glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Fade in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        color: const Color(0xDD0A0A12),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Particle system
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Central pulsing glow
                    _buildCentralGlow(),
                    // Orbiting particles
                    ..._buildParticles(),
                    // Inner crystal icon
                    _buildCrystalIcon(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Loading message with shimmer effect
              _buildLoadingMessage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCentralGlow() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.3);
        final opacity = 0.3 + (_pulseController.value * 0.2);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.glowColor.withOpacity(opacity),
                  widget.glowColor.withOpacity(0),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.particleColor.withOpacity(opacity * 0.5),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildParticles() {
    const particleCount = 8;
    return List.generate(particleCount, (index) {
      final angle = (index / particleCount) * 2 * math.pi;
      final radius = 45.0;
      final size = 4.0 + (index % 3) * 2.0;
      final speed = 1.0 + (index % 2) * 0.5;

      return AnimatedBuilder(
        animation: _orbitController,
        builder: (context, child) {
          final currentAngle =
              angle + (_orbitController.value * 2 * math.pi * speed);
          final x = math.cos(currentAngle) * radius;
          final y = math.sin(currentAngle) * radius;
          final opacity = 0.5 + (math.sin(currentAngle) * 0.3);

          return Transform.translate(
            offset: Offset(x, y),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.particleColor.withOpacity(opacity),
                boxShadow: [
                  BoxShadow(
                    color: widget.particleColor.withOpacity(opacity * 0.5),
                    blurRadius: size,
                    spreadRadius: size / 2,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildCrystalIcon() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final rotation = _pulseController.value * 0.1;
        return Transform.rotate(
          angle: rotation,
          child: Icon(
            Icons.diamond_outlined,
            size: 28,
            color: widget.particleColor.withOpacity(0.9),
          ),
        );
      },
    );
  }

  Widget _buildLoadingMessage() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final opacity = 0.6 + (_pulseController.value * 0.4);
        return Text(
          widget.message,
          style: TextStyle(
            color: widget.particleColor.withOpacity(opacity),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        );
      },
    );
  }
}
