import 'package:core/presentation/widgets/glass_card_widget.dart';
import 'package:core/presentation/widgets/ripple_effect_widget.dart';
import 'package:core/presentation/widgets/shimmer_background_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/crystal_providers.dart';
import '../widgets/crystal_image_widget.dart';

/// Crystal display page that shows a crystal with its memory text
/// This is a read-only view without tapping interaction
class CrystalDisplayPage extends ConsumerStatefulWidget {
  const CrystalDisplayPage({
    super.key,
    required this.crystalId,
  });

  final String crystalId;

  @override
  ConsumerState<CrystalDisplayPage> createState() => _CrystalDisplayPageState();
}

class _CrystalDisplayPageState extends ConsumerState<CrystalDisplayPage>
    with SingleTickerProviderStateMixin {
  static const _defaultColor = Color(0xFFD3CCCA);

  late AnimationController _colorController;
  late Animation<Color?> _colorAnimation;
  Color? _targetColor;

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

  @override
  Widget build(BuildContext context) {
    final crystalAsync = ref.watch(crystalProvider(widget.crystalId));
    final screenSize = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;

    // Crystal dimensions
    final crystalSize = screenSize.width * 0.6;

    // Content positioning
    const crystalTopOffset = -40;
    final crystalAreaHeight = crystalSize * 1.5;
    final textCardTopOffset =
        topPadding + crystalTopOffset + crystalAreaHeight - 40;

    // Trigger color animation when crystal data loads
    if (crystalAsync.value != null) {
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
          data: (crystal) => Stack(
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
                      // Crystal image centered
                      CrystalImageWidget(
                        imageUrl: crystal.tier.imageUrl,
                        size: crystalSize,
                      ),
                    ],
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
          ),
        ),
      ),
    );
  }
}
