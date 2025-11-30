import 'package:core/presentation/widgets/glass_app_bar_widget.dart';
import 'package:core/presentation/widgets/shimmer_background_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/collected_crystals_provider.dart';
import '../widgets/crystal_grid_item_widget.dart';

/// Crystal list page that displays collected crystals in a grid
class CrystalListPage extends ConsumerWidget {
  const CrystalListPage({super.key});

  static const _backgroundColor = Color(0xFFD3CCCA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectedCrystalsAsync = ref.watch(collectedCrystalsProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: ShimmerBackgroundWidget(
        dotSpacing: 10,
        dotSize: 2,
        dotColor: Colors.black,
        backgroundColor: _backgroundColor,
        child: Stack(
          children: [
            // Glass App Bar
            Positioned(
              top: topPadding + 8,
              left: 16,
              right: 16,
              child: GlassAppBarWidget(
                title: 'HIMITSU no SECRET',
                icon: Icons.close,
                onIconPressed: () {
                  context.pop();
                },
              ),
            ),

            // Content area
            Positioned(
              top: topPadding + 8 + 44 + 16, // app bar height + spacing
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section title
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'ポケット',
                      style: TextStyle(
                        fontFamily: 'Hiragino Sans',
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grid content
                  Expanded(
                    child: collectedCrystalsAsync.when(
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
                              'Failed to load crystals',
                              style: TextStyle(
                                color: Color(0xFF1A3A5C),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  ref.invalidate(collectedCrystalsProvider),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                      data: (crystals) {
                        if (crystals.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.diamond_outlined,
                                  color: Color(0xFF1A3A5C),
                                  size: 48,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'まだクリスタルがありません',
                                  style: TextStyle(
                                    fontFamily: 'Hiragino Sans',
                                    color: Color(0xFF1A3A5C),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                          itemCount: crystals.length,
                          itemBuilder: (context, index) {
                            final crystal = crystals[index];
                            return CrystalGridItemWidget(
                              crystal: crystal,
                              onTap: () {
                                context.push('/crystal/${crystal.id}');
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
