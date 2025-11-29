import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:core/presentation/widgets/shimmer_background_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/mining_providers.dart';
import '../state/mining_state.dart';
import '../widgets/crystal_display_widget.dart';
import '../widgets/crystal_shake_widget.dart';

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
    required this.crystalLabel,
    required this.memoryText,
    this.glowColor,
    this.onComplete,
  });

  final String crystalId;
  final String crystalImageUrl;
  final String crystalLabel;
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
    // Delay to match crystal animation, then mark text as revealed
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        ref.read(miningProvider.notifier).onTextRevealComplete();
      }
    });
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

        // Success - go back to home
        if (mounted) {
          context.go('/');
        }
      } catch (e) {
        // Error - show error state
        notifier.onCompletionError(e.toString());
      }
    } else {
      // No callback - just go back to home
      context.go('/');
    }
  }

  void _onRetry() {
    ref.read(miningProvider.notifier).retryFromError();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for phase changes to trigger text reveal
    ref.listen<MiningUIState>(miningProvider, (previous, next) {
      if (previous?.phase != MiningPhase.revealing &&
          next.phase == MiningPhase.revealing) {
        _onTextRevealComplete();
      }
    });

    final miningState = ref.watch(miningProvider);
    final screenSize = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;

    // Crystal sizes for different states
    final largeCrystalSize = screenSize.width * 1.05;
    final smallCrystalSize = screenSize.width * 0.35;

    // Determine if we're in revealed state
    final isRevealed = miningState.phase == MiningPhase.revealing ||
        miningState.phase == MiningPhase.reading ||
        miningState.phase == MiningPhase.completing ||
        miningState.phase == MiningPhase.error;

    // Animated values
    final crystalSize = isRevealed ? smallCrystalSize : largeCrystalSize;
    final crystalTop = isRevealed
        ? topPadding + 40
        : (screenSize.height - largeCrystalSize) / 2;

    // Shadow dimensions
    final shadowWidth = crystalSize * 0.6;
    final shadowHeight = crystalSize * 0.2;

    return Scaffold(
      backgroundColor: const Color(0xFF9ACCFD),
      body: Stack(
        children: [
          // Shimmer background with grid of dots
          const Positioned.fill(
            child: ShimmerBackgroundWidget(
              dotSpacing: 10,
              dotSize: 2,
              dotColor: Colors.black,
            ),
          ),

          // Full screen tap area (only during tapping phase)
          if (miningState.phase == MiningPhase.tapping)
            Positioned.fill(
              child: GestureDetector(
                onTap: _onCrystalTap,
                behavior: HitTestBehavior.opaque,
              ),
            ),

          // Crystal and shadow
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  height: crystalTop,
                ),
                IgnorePointer(
                  child: CrystalShakeWidget(
                    key: _shakeKey,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      width: crystalSize,
                      height: crystalSize,
                      child: CrystalDisplayWidget(
                        imageUrl: widget.crystalImageUrl,
                        glowColor: widget.glowColor ?? Colors.blue,
                        size: crystalSize,
                      ),
                    ),
                  ),
                ),
                // Shadow
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  width: shadowWidth,
                  height: shadowHeight,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.elliptical(shadowWidth / 2, shadowHeight / 2),
                        ),
                        color: const Color(0x40000000),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Crystal label (overlapping bottom of crystal when revealed)
          if (isRevealed)
            Positioned(
              left: 0,
              right: 0,
              top: crystalTop + smallCrystalSize - 32,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: miningState.phase == MiningPhase.revealing ? 0.0 : 1.0,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0x33000000),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.crystalLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Memory text and comments (below crystal when revealed)
          if (isRevealed)
            Positioned(
              left: 0,
              right: 0,
              top: crystalTop + smallCrystalSize + 24,
              bottom: 0,
              child: _buildRevealedContent(miningState),
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
        ],
      ),
    );
  }

  Widget _buildRevealedContent(MiningUIState miningState) {
    const darkBlue = Color(0xFF1A3A5C);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: miningState.phase == MiningPhase.revealing ? 0.0 : 1.0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Memory text card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xB3FFFFFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.memoryText,
                style: const TextStyle(
                  color: darkBlue,
                  fontSize: 16,
                  height: 1.7,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 返信 (Replies) section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '返信',
                style: TextStyle(
                  color: Color(0x991A3A5C),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Reply card placeholder
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xB3FFFFFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'まだ返信はありません',
                style: TextStyle(
                  color: Color(0x991A3A5C),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 返信する button
            if (miningState.isTextFullyRevealed)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _onDismiss,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: darkBlue,
                    side: const BorderSide(color: darkBlue, width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '返信する',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: const Color(0xB3000000), // Black 70% opacity
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
            const Text(
              'Saving...',
              style: TextStyle(
                color: Color(0xCCFFFFFF), // White 80% opacity
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
      color: const Color(0xB3000000), // Black 70% opacity
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
                  style: const TextStyle(
                    color: Color(0x99FFFFFF), // White 60% opacity
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
