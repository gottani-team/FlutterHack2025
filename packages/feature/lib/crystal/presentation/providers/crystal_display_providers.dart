import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../state/crystal_display_state.dart';

part 'crystal_display_providers.g.dart';

/// Provider for the crystal display UI state using Riverpod 3.0 Notifier
@riverpod
class CrystalDisplayNotifier extends _$CrystalDisplayNotifier {
  @override
  CrystalDisplayUIState build() {
    // Random threshold between 5-10 taps for natural feel
    final random = Random();
    final threshold = 5 + random.nextInt(6); // 5 to 10
    return CrystalDisplayUIState(tapThreshold: threshold);
  }

  /// Called when user taps on the crystal
  void onTap() {
    if (state.phase != CrystalDisplayPhase.tapping) return;

    final newTapCount = state.tapCount + 1;

    if (newTapCount >= state.tapThreshold) {
      // Transition to revealing phase
      debugPrint(
        'CrystalDisplayNotifier: Threshold reached! Changing to revealing phase',
      );
      state = state.copyWith(
        tapCount: newTapCount,
        phase: CrystalDisplayPhase.revealing,
      );
    } else {
      debugPrint(
        'CrystalDisplayNotifier: Tap $newTapCount/${state.tapThreshold}',
      );
      state = state.copyWith(tapCount: newTapCount);
    }
  }

  /// Called when text reveal animation completes
  void onTextRevealComplete() {
    if (state.phase != CrystalDisplayPhase.revealing) return;

    state = state.copyWith(
      phase: CrystalDisplayPhase.reading,
      isTextFullyRevealed: true,
    );
  }

  /// Reset the display state for a new session
  void reset() {
    state = CrystalDisplayUIState(tapThreshold: state.tapThreshold);
  }
}
