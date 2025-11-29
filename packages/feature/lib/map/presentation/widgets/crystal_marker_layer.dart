import 'package:flutter/material.dart';

import '../../domain/entities/crystal_entity.dart';
import '../../domain/entities/crystallization_area_entity.dart';

/// Widget that renders crystal markers as pulsing circles on the map.
///
/// Each marker is colored based on the crystal's emotion type:
/// - Red: Passion
/// - Blue: Silence
/// - Yellow: Joy
/// - Green: Healing
class CrystalMarkerLayer extends StatelessWidget {
  const CrystalMarkerLayer({
    super.key,
    required this.areas,
    required this.mapController,
  });

  /// List of crystallization areas to display
  final List<CrystallizationAreaEntity> areas;

  /// Map controller for positioning markers (placeholder type)
  final dynamic mapController;

  @override
  Widget build(BuildContext context) {
    // Note: In actual implementation, this would use Mapbox's
    // CircleLayer or SymbolLayer API to render markers on the map.
    // For now, this is a placeholder structure.
    return const SizedBox.shrink();
  }
}

/// Animated circle marker for a single crystal.
///
/// Creates a pulsing glow effect to indicate an active crystallization area.
class CrystalMarker extends StatefulWidget {
  const CrystalMarker({
    super.key,
    required this.area,
  });

  final CrystallizationAreaEntity area;

  @override
  State<CrystalMarker> createState() => _CrystalMarkerState();
}

class _CrystalMarkerState extends State<CrystalMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _markerColor {
    return Color(widget.area.emotionType.colorValue);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = _pulseAnimation.value;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _markerColor.withOpacity(0.3),
              boxShadow: [
                BoxShadow(
                  color: _markerColor.withOpacity(0.5),
                  blurRadius: 20 * scale,
                  spreadRadius: 5 * scale,
                ),
              ],
              border: Border.all(
                color: _markerColor.withOpacity(0.8),
                width: 2,
              ),
            ),
            child: Center(
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _markerColor,
                  boxShadow: [
                    BoxShadow(
                      color: _markerColor,
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Helper extension for converting emotion type to display properties.
extension CrystalMarkerColors on EmotionType {
  /// Get the marker color for map display
  Color get markerColor => Color(colorValue);

  /// Get the glow color for pulsing effect
  Color get glowColor => Color(colorValue).withOpacity(0.5);
}
