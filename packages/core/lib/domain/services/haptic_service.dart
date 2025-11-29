import 'package:flutter/services.dart';

/// Service for managing haptic feedback across the application.
///
/// Provides synchronized haptic pulses for the proximity detection feature.
/// Supports different intensities based on distance to crystals.
class HapticService {
  HapticService._();

  static final HapticService instance = HapticService._();

  bool _isEnabled = true;

  /// Whether haptic feedback is enabled (can be toggled for accessibility)
  bool get isEnabled => _isEnabled;

  /// Enable or disable haptic feedback
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Trigger a light haptic pulse
  /// Used for subtle feedback at long distances
  Future<void> lightPulse() async {
    if (!_isEnabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Trigger a medium haptic pulse
  /// Used for moderate feedback at medium distances
  Future<void> mediumPulse() async {
    if (!_isEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Trigger a heavy haptic pulse
  /// Used for strong feedback at close distances (heartbeat effect)
  Future<void> heavyPulse() async {
    if (!_isEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Trigger a selection click
  /// Used for UI interactions
  Future<void> selectionClick() async {
    if (!_isEnabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Trigger haptic feedback based on intensity (0.0 to 1.0)
  ///
  /// - 0.0-0.3: Light pulse
  /// - 0.3-0.7: Medium pulse
  /// - 0.7-1.0: Heavy pulse
  Future<void> pulseWithIntensity(double intensity) async {
    if (!_isEnabled) return;

    if (intensity < 0.3) {
      await lightPulse();
    } else if (intensity < 0.7) {
      await mediumPulse();
    } else {
      await heavyPulse();
    }
  }

  /// Trigger vibration pattern for mining interaction
  Future<void> miningImpact() async {
    if (!_isEnabled) return;
    await HapticFeedback.heavyImpact();
  }
}
