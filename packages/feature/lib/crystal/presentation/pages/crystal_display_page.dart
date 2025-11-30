import 'package:core/presentation/widgets/glass_card_widget.dart';
import 'package:core/presentation/widgets/ripple_effect_widget.dart';
import 'package:core/presentation/widgets/shimmer_background_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/crystal_display_providers.dart';
import '../providers/crystal_providers.dart';
import '../state/crystal_display_state.dart';
import '../widgets/crystal_image_widget.dart';
import '../widgets/crystal_shake_widget.dart';

/// Crystal display page that shows a crystal with its memory text
/// Supports tap-and-reveal mode when [tap] is true
class CrystalDisplayPage extends ConsumerStatefulWidget {
  const CrystalDisplayPage({
    super.key,
    required this.crystalId,
    this.tap = false,
  });

  final String crystalId;

  /// When true, enables tap-and-reveal mode where user must tap crystal
  /// multiple times to reveal the memory text (like mining experience)
  final bool tap;

  @override
  ConsumerState<CrystalDisplayPage> createState() => _CrystalDisplayPageState();
}

class _CrystalDisplayPageState extends ConsumerState<CrystalDisplayPage>
    with SingleTickerProviderStateMixin {
  static const _defaultColor = Color(0xFFD3CCCA);

  late AnimationController _colorController;
  late Animation<Color?> _colorAnimation;
  Color? _targetColor;

  // For tap mode shake animation
  final GlobalKey<CrystalShakeWidgetState> _shakeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _colorController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: _defaultColor,
      end: _defaultColor,
    ).animate(
      CurvedAnimation(
        parent: _colorController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _colorController.dispose();
    super.dispose();
  }

  void _updateTargetColor(Color newColor) {
    if (_targetColor != newColor) {
      _targetColor = newColor;
      _colorAnimation = ColorTween(
        begin: _colorAnimation.value ?? _defaultColor,
        end: newColor,
      ).animate(
        CurvedAnimation(
          parent: _colorController,
          curve: Curves.easeInOut,
        ),
      );
      _colorController.forward(from: 0);
    }
  }

  void _onCrystalTap() {
    final displayState = ref.read(crystalDisplayProvider);
    if (displayState.phase != CrystalDisplayPhase.tapping) return;

    // Trigger shake animation
    _shakeKey.currentState?.shake();

    // Trigger haptic feedback
    _triggerHaptic();

    // Update state
    ref.read(crystalDisplayProvider.notifier).onTap();
  }

  void _triggerHaptic() {
    try {
      HapticFeedback.mediumImpact();
    } catch (e) {
      // Haptic feedback not available - continue silently
    }
  }

  void _onTextRevealComplete() {
    // Delay to match crystal animation, then mark text as revealed
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        ref.read(crystalDisplayProvider.notifier).onTextRevealComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final crystalAsync = ref.watch(crystalProvider(widget.crystalId));
    final screenSize = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;

    // Listen for phase changes in tap mode
    if (widget.tap) {
      ref.listen<CrystalDisplayUIState>(crystalDisplayProvider,
          (previous, next) {
        if (previous?.phase != CrystalDisplayPhase.revealing &&
            next.phase == CrystalDisplayPhase.revealing) {
          _onTextRevealComplete();
          // Trigger color animation when revealing starts
          if (crystalAsync.value != null) {
            final emotionColor = Color(
              crystalAsync.value!.aiMetadata.emotionType.colorHex,
            );
            _updateTargetColor(emotionColor);
          }
        }
      });
    }

    // Trigger color animation when crystal data loads (only in non-tap mode)
    if (!widget.tap && crystalAsync.value != null) {
      final emotionColor = Color(
        crystalAsync.value!.aiMetadata.emotionType.colorHex,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateTargetColor(emotionColor);
      });
    }

    return Scaffold(
      backgroundColor: _defaultColor,
      body: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return ShimmerBackgroundWidget(
            dotSpacing: 10,
            dotSize: 2,
            dotColor: Colors.black,
            backgroundColor: _colorAnimation.value ?? _defaultColor,
            child: child!,
          );
        },
        child: crystalAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF1A3A5C),
            ),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFF1A3A5C),
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load crystal',
                  style: TextStyle(
                    color: Color(0xFF1A3A5C),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(crystalProvider(widget.crystalId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (crystal) => widget.tap
              ? _buildTapModeContent(
                  crystal: crystal,
                  screenSize: screenSize,
                  topPadding: topPadding,
                )
              : _buildReadOnlyContent(
                  crystal: crystal,
                  screenSize: screenSize,
                  topPadding: topPadding,
                ),
        ),
      ),
    );
  }

  /// Builds the read-only content (original behavior when tap: false)
  Widget _buildReadOnlyContent({
    required dynamic crystal,
    required Size screenSize,
    required double topPadding,
  }) {
    // Crystal dimensions
    final crystalSize = screenSize.width * 0.6;

    // Content positioning
    const crystalTopOffset = -40.0;
    final crystalAreaHeight = crystalSize * 1.5;
    final textCardTopOffset =
        topPadding + crystalTopOffset + crystalAreaHeight - 40;

    final emotionColor = Color(crystal.aiMetadata.emotionType.colorHex);

    return Stack(
      children: [
        // Crystal with ripple effect - positioned from top
        Positioned(
          top: topPadding + crystalTopOffset,
          left: 0,
          right: 0,
          child: SizedBox(
            height: crystalAreaHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ripple effect behind crystal
                RippleEffectWidget(
                  baseSize: crystalSize * 3,
                  borderColor: const Color(0x2AFFFFFF),
                  borderWidth: 15,
                  blurSigma: 8,
                  animationDuration: const Duration(seconds: 4),
                ),
                // Crystal image centered with glow
                CrystalImageWidget(
                  imageUrl: crystal.tier.imageUrl,
                  size: crystalSize,
                  glowColor: emotionColor,
                ),
              ],
            ),
          ),
        ),

        // Emotion type label - positioned on top of crystal
        Positioned(
          top: topPadding + crystalTopOffset + crystalSize * 0.32,
          left: 0,
          right: 0,
          child: Center(
            child: GlassCardWidget(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              borderRadius: 20,
              child: Text(
                crystal.aiMetadata.emotionType.displayName,
                style: const TextStyle(
                  fontFamily: 'Hiragino Sans',
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),

        // Memory text card - overlapping the ripple
        Positioned(
          top: textCardTopOffset,
          left: 24,
          right: 24,
          bottom: 0,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Text card with gradient border
                GlassCardWidget(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 20,
                  ),
                  child: Text(
                    crystal.displayText,
                    style: const TextStyle(
                      fontFamily: 'Hiragino Sans',
                      color: Colors.black,
                      fontSize: 16,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Done button
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const GlassCardWidget(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    borderRadius: 12,
                    child: Center(
                      child: Text(
                        'しまう',
                        style: TextStyle(
                          fontFamily: 'Hiragino Sans',
                          color: Colors.black,
                          fontSize: 16,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the tap-and-reveal content (when tap: true)
  Widget _buildTapModeContent({
    required dynamic crystal,
    required Size screenSize,
    required double topPadding,
  }) {
    final displayState = ref.watch(crystalDisplayProvider);

    // Crystal sizes for different states
    final largeCrystalSize = screenSize.width * 1.05;
    final smallCrystalSize = screenSize.width * 0.75;

    // Content positioning (same as read-only mode)
    const crystalTopOffset = -80.0;
    final crystalAreaHeight = smallCrystalSize * 1.2;
    final textCardTopOffset = topPadding + crystalTopOffset + crystalAreaHeight;

    // Determine if we're in revealed state
    final isRevealed = displayState.phase == CrystalDisplayPhase.revealing ||
        displayState.phase == CrystalDisplayPhase.reading;

    // Animated values
    final crystalTop = isRevealed
        ? topPadding + crystalTopOffset
        : (screenSize.height - largeCrystalSize) / 2;

    final emotionColor = Color(crystal.aiMetadata.emotionType.colorHex);

    return Stack(
      children: [
        // Full screen tap area (always rendered to maintain widget tree structure)
        Positioned.fill(
          child: IgnorePointer(
            ignoring: displayState.phase != CrystalDisplayPhase.tapping,
            child: GestureDetector(
              onTap: _onCrystalTap,
              behavior: HitTestBehavior.opaque,
            ),
          ),
        ),

        // Crystal with ripple effect - matches read-only layout when revealed
        AnimatedPositioned(
          key: const ValueKey('crystal_position'),
          duration: const Duration(milliseconds: 2000),
          curve: Curves.easeInOut,
          top: crystalTop,
          left: 0,
          right: 0,
          child: SizedBox(
            height: largeCrystalSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ripple effect behind crystal (only when revealed)
                if (isRevealed)
                  RippleEffectWidget(
                    baseSize: smallCrystalSize * 4,
                    borderColor: const Color(0x2AFFFFFF),
                    borderWidth: 15,
                    blurSigma: 8,
                    animationDuration: const Duration(seconds: 4),
                  ),
                // Crystal image with shake animation
                IgnorePointer(
                  child: CrystalShakeWidget(
                    key: _shakeKey,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 2000),
                      curve: Curves.easeInOut,
                      scale: isRevealed
                          ? smallCrystalSize / largeCrystalSize
                          : 1.0,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: isRevealed
                            ? CrystalImageWidget(
                                key: const ValueKey('crystal'),
                                imageUrl: crystal.tier.imageUrl,
                                size: largeCrystalSize,
                                glowColor: emotionColor,
                              )
                            : CrystalImageWidget(
                                key: const ValueKey('hide'),
                                imageUrl: 'assets/images/hide.png',
                                size: largeCrystalSize,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Emotion type label (only when revealed) - positioned on top of crystal
        if (isRevealed)
          Positioned(
            top: crystalTop + smallCrystalSize * 0.32,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: displayState.phase == CrystalDisplayPhase.revealing
                  ? 0.0
                  : 1.0,
              child: Center(
                child: GlassCardWidget(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  borderRadius: 20,
                  child: Text(
                    crystal.aiMetadata.emotionType.displayName,
                    style: const TextStyle(
                      fontFamily: 'Hiragino Sans',
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Memory text card (only when revealed) - slides up from bottom
        if (isRevealed)
          Positioned(
            top: textCardTopOffset,
            left: 24,
            right: 24,
            bottom: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              offset: displayState.phase == CrystalDisplayPhase.revealing
                  ? const Offset(0, 0.3)
                  : Offset.zero,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                opacity: displayState.phase == CrystalDisplayPhase.revealing
                    ? 0.0
                    : 1.0,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Text card with gradient border
                      GlassCardWidget(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 20,
                        ),
                        child: Text(
                          crystal.displayText,
                          style: const TextStyle(
                            fontFamily: 'Hiragino Sans',
                            color: Colors.black,
                            fontSize: 16,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Done button (only when fully revealed)
                      if (displayState.isTextFullyRevealed)
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: const GlassCardWidget(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            borderRadius: 12,
                            child: Center(
                              child: Text(
                                'しまう',
                                style: TextStyle(
                                  fontFamily: 'Hiragino Sans',
                                  color: Colors.black,
                                  fontSize: 16,
                                  height: 1.4,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
