import 'package:flutter/material.dart';

/// Crystal emotion types with associated glow colors
enum EmotionType {
  /// Passion - warm, intense red glow
  passion(Color(0xFFE53935)),

  /// Silence - calm, cool blue glow
  silence(Color(0xFF1E88E5)),

  /// Joy - bright, cheerful yellow glow
  joy(Color(0xFFFDD835)),

  /// Healing - soothing, natural green glow
  healing(Color(0xFF43A047));

  const EmotionType(this.color);

  /// The glow color associated with this emotion type
  final Color color;
}

/// Represents the current phase of the mining screen
enum MiningPhase {
  /// User is tapping the crystal
  tapping,

  /// Crystal reached tap threshold, text is revealing
  revealing,

  /// Text is fully visible, user is reading
  reading,

  /// Completion callback is processing (saving data)
  completing,

  /// Completion failed with an error
  error,
}

/// Represents the UI state for the mining screen
@immutable
class MiningUIState {
  const MiningUIState({
    this.phase = MiningPhase.tapping,
    this.tapCount = 0,
    this.tapThreshold = 7,
    this.isTextFullyRevealed = false,
    this.errorMessage,
  });

  /// Current phase of the mining experience
  final MiningPhase phase;

  /// Number of taps on the crystal so far
  final int tapCount;

  /// Number of taps required to reveal the memory text (5-10)
  final int tapThreshold;

  /// Whether the text reveal animation has completed
  final bool isTextFullyRevealed;

  /// Error message if completion failed
  final String? errorMessage;

  /// Progress towards revealing text (0.0 to 1.0)
  double get progress => (tapCount / tapThreshold).clamp(0.0, 1.0);

  /// Whether the tap threshold has been reached
  bool get hasReachedThreshold => tapCount >= tapThreshold;

  MiningUIState copyWith({
    MiningPhase? phase,
    int? tapCount,
    int? tapThreshold,
    bool? isTextFullyRevealed,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MiningUIState(
      phase: phase ?? this.phase,
      tapCount: tapCount ?? this.tapCount,
      tapThreshold: tapThreshold ?? this.tapThreshold,
      isTextFullyRevealed: isTextFullyRevealed ?? this.isTextFullyRevealed,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MiningUIState &&
        other.phase == phase &&
        other.tapCount == tapCount &&
        other.tapThreshold == tapThreshold &&
        other.isTextFullyRevealed == isTextFullyRevealed &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      phase,
      tapCount,
      tapThreshold,
      isTextFullyRevealed,
      errorMessage,
    );
  }
}
