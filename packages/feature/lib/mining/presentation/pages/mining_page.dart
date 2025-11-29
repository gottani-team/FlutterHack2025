import 'package:audioplayers/audioplayers.dart';
import 'package:core/presentation/widgets/shimmer_background_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/mining_providers.dart';
import '../state/mining_state.dart';
import '../widgets/crystal_display_widget.dart';
import '../widgets/crystal_shake_widget.dart';
import '../widgets/memory_text_widget.dart';

/// Result data returned when mining session completes
class MiningResult {
  const MiningResult({
    required this.crystalId,
    required this.completedAt,
  });

  /// The ID of the crystal that was mined
  final String crystalId;

  /// Timestamp when the mining was completed
  final DateTime completedAt;
}

/// Main mining screen that composes all widgets for the crystal mining experience
class MiningPage extends ConsumerStatefulWidget {
  const MiningPage({
    super.key,
    required this.crystalId,
    required this.crystalImageUrl,
    required this.memoryText,
    this.glowColor,
    this.onComplete,
  });

  final String crystalId;
  final String crystalImageUrl;
  final String memoryText;
  final Color? glowColor;

  /// Callback invoked when mining is complete and user dismisses the screen.
  /// Returns a Future to allow for async operations like saving to database.
  final Future<void> Function(MiningResult result)? onComplete;

  @override
  ConsumerState<MiningPage> createState() => _MiningPageState();
}

class _MiningPageState extends ConsumerState<MiningPage>
    with WidgetsBindingObserver {
  final GlobalKey<CrystalShakeWidgetState> _shakeKey = GlobalKey();
  AudioPlayer? _audioPlayer;
  bool _isAudioReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      _audioPlayer = AudioPlayer();
      // Pre-load the audio for faster playback
      await _audioPlayer?.setSource(AssetSource('sounds/tap_impact.mp3'));
      setState(() {
        _isAudioReady = true;
      });
    } catch (e) {
      // Audio initialization failed - continue without sound
      debugPrint('Audio initialization failed: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Pause audio when app is backgrounded
    if (state == AppLifecycleState.paused) {
      _audioPlayer?.pause();
    } else if (state == AppLifecycleState.resumed) {
      // Re-initialize audio when resuming (in case it was released)
      if (!_isAudioReady) {
        _initAudio();
      }
    }
    // Note: Mining state is preserved automatically via Riverpod
    // The user can continue from where they left off when returning
  }

  void _onCrystalTap() {
    final state = ref.read(miningProvider);
    if (state.phase != MiningPhase.tapping) return;

    // Trigger shake animation
    _shakeKey.currentState?.shake();

    // Trigger haptic feedback
    _triggerHaptic();

    // Play tap sound
    _playTapSound();

    // Update state
    ref.read(miningProvider.notifier).onTap();
  }

  void _triggerHaptic() {
    try {
      HapticFeedback.mediumImpact();
    } catch (e) {
      // Haptic feedback not available - continue silently
    }
  }

  Future<void> _playTapSound() async {
    if (!_isAudioReady || _audioPlayer == null) return;

    try {
      await _audioPlayer?.seek(Duration.zero);
      await _audioPlayer?.resume();
    } catch (e) {
      // Audio playback failed - continue silently
    }
  }

  void _onTextRevealComplete() {
    ref.read(miningProvider.notifier).onTextRevealComplete();
  }

  Future<void> _onDismiss() async {
    final notifier = ref.read(miningProvider.notifier);

    // If there's a completion callback, invoke it
    if (widget.onComplete != null) {
      notifier.startCompleting();

      try {
        final result = MiningResult(
          crystalId: widget.crystalId,
          completedAt: DateTime.now(),
        );
        await widget.onComplete!(result);

        // Success - pop the screen
        if (mounted) {
          Navigator.of(context).pop(result);
        }
      } catch (e) {
        // Error - show error state
        notifier.onCompletionError(e.toString());
      }
    } else {
      // No callback - just pop
      Navigator.of(context).pop();
    }
  }

  void _onRetry() {
    ref.read(miningProvider.notifier).retryFromError();
  }

  @override
  Widget build(BuildContext context) {
    final miningState = ref.watch(miningProvider);
    final screenSize = MediaQuery.of(context).size;
    final crystalSize = screenSize.width * 0.7;

    return Scaffold(
      backgroundColor: const Color(0xFF9ACCFD),
      body: Stack(
        children: [
          // Shimmer background with animated dots
          const Positioned.fill(
            child: ShimmerBackgroundWidget(),
          ),

          // Crystal in the center
          Positioned.fill(
            child: Center(
              child: GestureDetector(
                onTap: _onCrystalTap,
                child: CrystalShakeWidget(
                  key: _shakeKey,
                  child: CrystalDisplayWidget(
                    imageUrl: widget.crystalImageUrl,
                    glowColor: widget.glowColor ?? Colors.blue,
                    size: crystalSize,
                  ),
                ),
              ),
            ),
          ),

          // Tap progress indicator
          if (miningState.phase == MiningPhase.tapping)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: _buildProgressIndicator(miningState),
            ),

          // Memory text rising from bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MemoryTextWidget(
              text: widget.memoryText,
              isVisible: miningState.phase == MiningPhase.revealing ||
                  miningState.phase == MiningPhase.reading ||
                  miningState.phase == MiningPhase.completing ||
                  miningState.phase == MiningPhase.error,
              onAnimationComplete: _onTextRevealComplete,
            ),
          ),

          // Loading overlay during completion
          if (miningState.phase == MiningPhase.completing)
            Positioned.fill(
              child: _buildLoadingOverlay(),
            ),

          // Error overlay
          if (miningState.phase == MiningPhase.error)
            Positioned.fill(
              child: _buildErrorOverlay(miningState.errorMessage),
            ),

          // Dismiss button (only visible after text is fully revealed and not in completing/error state)
          if (miningState.isTextFullyRevealed &&
              miningState.phase == MiningPhase.reading)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: _buildDismissButton(),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(MiningUIState state) {
    const darkBlue = Color(0xFF1A3A5C);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Tap to reveal',
          style: TextStyle(
            color: darkBlue.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 100,
          child: LinearProgressIndicator(
            value: state.progress,
            backgroundColor: darkBlue.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.glowColor ?? Colors.blue,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${state.tapCount}/${state.tapThreshold}',
          style: TextStyle(
            color: darkBlue.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDismissButton() {
    const darkBlue = Color(0xFF1A3A5C);
    return IconButton(
      onPressed: _onDismiss,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: darkBlue.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.close,
          color: darkBlue,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.glowColor ?? Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Saving...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorOverlay(String? errorMessage) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to save',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: _onRetry,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _onDismiss,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.glowColor ?? Colors.blue,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
