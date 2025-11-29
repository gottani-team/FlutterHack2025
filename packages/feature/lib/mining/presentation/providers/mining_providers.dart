import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../state/mining_state.dart';

part 'mining_providers.g.dart';

/// Provider for the mining UI state using Riverpod 3.0 Notifier
@riverpod
class MiningNotifier extends _$MiningNotifier {
  @override
  MiningUIState build() {
    // Random threshold between 5-10 taps for natural feel
    final random = Random();
    final threshold = 5 + random.nextInt(6); // 5 to 10
    return MiningUIState(tapThreshold: threshold);
  }

  /// Called when user taps on the crystal
  void onTap() {
    if (state.phase != MiningPhase.tapping) return;

    final newTapCount = state.tapCount + 1;

    if (newTapCount >= state.tapThreshold) {
      // Transition to revealing phase
      debugPrint('MiningNotifier: Threshold reached! Changing to revealing phase');
      state = state.copyWith(
        tapCount: newTapCount,
        phase: MiningPhase.revealing,
      );
    } else {
      debugPrint('MiningNotifier: Tap $newTapCount/${state.tapThreshold}');
      state = state.copyWith(tapCount: newTapCount);
    }
  }

  /// Called when text reveal animation completes
  void onTextRevealComplete() {
    if (state.phase != MiningPhase.revealing) return;

    state = state.copyWith(
      phase: MiningPhase.reading,
      isTextFullyRevealed: true,
    );
  }

  /// Reset the mining state for a new session
  void reset() {
    state = MiningUIState(tapThreshold: state.tapThreshold);
  }

  /// Called when starting the completion process (saving data)
  void startCompleting() {
    if (state.phase != MiningPhase.reading) return;

    state = state.copyWith(
      phase: MiningPhase.completing,
      clearError: true,
    );
  }

  /// Called when completion process fails
  void onCompletionError(String message) {
    state = state.copyWith(
      phase: MiningPhase.error,
      errorMessage: message,
    );
  }

  /// Called to retry after an error - goes back to reading phase
  void retryFromError() {
    if (state.phase != MiningPhase.error) return;

    state = state.copyWith(
      phase: MiningPhase.reading,
      clearError: true,
    );
  }
}
