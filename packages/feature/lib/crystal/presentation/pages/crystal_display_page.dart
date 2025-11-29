import 'dart:ui';

import 'package:core/presentation/widgets/glass_card_widget.dart';
import 'package:core/presentation/widgets/shimmer_background_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/crystal_providers.dart';
import '../widgets/crystal_image_widget.dart';

/// Crystal display page that shows a crystal with its memory text
/// This is a read-only view without tapping interaction
class CrystalDisplayPage extends ConsumerWidget {
  const CrystalDisplayPage({
    super.key,
    required this.crystalId,
  });

  final String crystalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crystalAsync = ref.watch(crystalProvider(crystalId));
    final screenSize = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;

    // Crystal dimensions
    final crystalSize = screenSize.width * 0.5;

    // Shadow dimensions
    final shadowWidth = crystalSize * 0.6;
    final shadowHeight = crystalSize * 0.2;

    return Scaffold(
      backgroundColor: const Color(0xFF9ACCFD),
      body: ShimmerBackgroundWidget(
        dotSpacing: 10,
        dotSize: 2,
        dotColor: Colors.black,
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
                  onPressed: () => ref.invalidate(crystalProvider(crystalId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (crystal) => Column(
            children: [
              // Top padding
              SizedBox(height: topPadding + 40),

              // Crystal image
              CrystalImageWidget(
                imageUrl: mockCrystalImageUrl,
                size: crystalSize,
              ),

              // Shadow below crystal
              SizedBox(
                width: shadowWidth,
                height: shadowHeight,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.elliptical(
                          shadowWidth / 2,
                          shadowHeight / 2,
                        ),
                      ),
                      color: const Color(0x40000000),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Memory text card
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
                        onTap: () => context.go('/'),
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
