import 'package:flutter/material.dart';

/// Overlay widget that creates a pulsing heartbeat effect at screen edges.
///
/// Used during the proximity detection phase to provide visual feedback
/// as the user approaches a crystal. The pulse intensity and frequency
/// increase as the user gets closer.
class HeartbeatOverlay extends StatefulWidget {
  const HeartbeatOverlay({
    super.key,
    required this.color,
    required this.intensity,
  });

  /// The color of the pulse (based on crystal's emotion type)
  final Color color;

  /// The intensity of the pulse (0.0 to 1.0)
  /// Higher intensity = faster pulse, stronger glow
  final double intensity;

  @override
  State<HeartbeatOverlay> createState() => _HeartbeatOverlayState();
}

class _HeartbeatOverlayState extends State<HeartbeatOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  @override
  void didUpdateWidget(HeartbeatOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.intensity != widget.intensity) {
      _updateAnimationDuration();
    }
  }

  void _setupAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: _calculateDuration(),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  void _updateAnimationDuration() {
    _controller.duration = _calculateDuration();
  }

  /// Calculate pulse duration based on intensity
  /// Higher intensity = faster pulse (shorter duration)
  Duration _calculateDuration() {
    // 100m (intensity 0) = 1500ms, 25m (intensity 1) = 400ms
    final ms = (1500 - (widget.intensity * 1100)).clamp(400, 1500).round();
    return Duration(milliseconds: ms);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final pulseValue = _pulseAnimation.value;
        final baseOpacity = 0.1 + (widget.intensity * 0.3);
        final animatedOpacity = baseOpacity * (0.5 + pulseValue * 0.5);

        return IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  widget.color.withOpacity(animatedOpacity * 0.3),
                  widget.color.withOpacity(animatedOpacity),
                ],
                stops: const [0.0, 0.6, 0.85, 1.0],
              ),
            ),
            child: _buildEdgeGlow(pulseValue, animatedOpacity),
          ),
        );
      },
    );
  }

  Widget _buildEdgeGlow(double pulseValue, double opacity) {
    return Stack(
      children: [
        // Top edge glow
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 100 + (pulseValue * 50),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.color.withOpacity(opacity),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Bottom edge glow
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 100 + (pulseValue * 50),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  widget.color.withOpacity(opacity),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Left edge glow
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          width: 80 + (pulseValue * 40),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  widget.color.withOpacity(opacity),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Right edge glow
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          width: 80 + (pulseValue * 40),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  widget.color.withOpacity(opacity),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
