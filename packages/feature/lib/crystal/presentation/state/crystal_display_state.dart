import 'package:flutter/material.dart';

/// Represents the current phase of the crystal display screen with tap mode
enum CrystalDisplayPhase {
  /// User is tapping the crystal
  tapping,

  /// Crystal reached tap threshold, content is revealing
  revealing,

  /// Content is fully visible, user is reading
  reading,
}

/// Represents the UI state for the crystal display screen with tap mode
@immutable
class CrystalDisplayUIState {
  const CrystalDisplayUIState({
    this.phase = CrystalDisplayPhase.tapping,
    this.tapCount = 0,
    this.tapThreshold = 7,
    this.isTextFullyRevealed = false,
  });

  /// Current phase of the display experience
  final CrystalDisplayPhase phase;

  /// Number of taps on the crystal so far
  final int tapCount;

  /// Number of taps required to reveal the memory text (5-10)
  final int tapThreshold;

  /// Whether the text reveal animation has completed
  final bool isTextFullyRevealed;

  /// Progress towards revealing text (0.0 to 1.0)
  double get progress => (tapCount / tapThreshold).clamp(0.0, 1.0);

  /// Whether the tap threshold has been reached
  bool get hasReachedThreshold => tapCount >= tapThreshold;

  CrystalDisplayUIState copyWith({
    CrystalDisplayPhase? phase,
    int? tapCount,
    int? tapThreshold,
    bool? isTextFullyRevealed,
  }) {
    return CrystalDisplayUIState(
      phase: phase ?? this.phase,
      tapCount: tapCount ?? this.tapCount,
      tapThreshold: tapThreshold ?? this.tapThreshold,
      isTextFullyRevealed: isTextFullyRevealed ?? this.isTextFullyRevealed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CrystalDisplayUIState &&
        other.phase == phase &&
        other.tapCount == tapCount &&
        other.tapThreshold == tapThreshold &&
        other.isTextFullyRevealed == isTextFullyRevealed;
  }

  @override
  int get hashCode {
    return Object.hash(
      phase,
      tapCount,
      tapThreshold,
      isTextFullyRevealed,
    );
  }
}
