import 'dart:ui';

import 'package:core/core.dart';
import 'package:core/presentation/widgets/glass_card_widget.dart';
import 'package:flutter/material.dart';

import 'crystal_image_widget.dart';

/// Widget that displays a collected crystal in a grid cell
class CrystalGridItemWidget extends StatelessWidget {
  const CrystalGridItemWidget({
    super.key,
    required this.crystal,
    required this.onTap,
  });

  final CollectedCrystal crystal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // final emotionColor = Color(crystal.aiMetadata.emotionType.colorHex);

    return GestureDetector(
      onTap: onTap,
      child: GlassCardWidget(
        padding: const EdgeInsets.all(12),
        borderRadius: 16,
        // backgroundColor: emotionColor.withValues(alpha: 0.15),
        borderColor: Color(crystal.aiMetadata.emotionType.colorHex),
        borderWidth: 2,
        useGradientBorder: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Crystal image with elliptical emotion color shadow
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.maxWidth * 0.7;
                  final emotionColor =
                      Color(crystal.aiMetadata.emotionType.colorHex);
                  return Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Elliptical shadow at bottom
                      Positioned(
                        bottom: -120,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                            sigmaX: 24,
                            sigmaY: 24,
                          ),
                          child: Container(
                            width: size * 1.5,
                            height: size,
                            decoration: BoxDecoration(
                              color: emotionColor.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.all(
                                Radius.elliptical(size * 0.6, size * 0.25),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Crystal image
                      CrystalImageWidget(
                        imageUrl: crystal.aiMetadata.imageUrl,
                        size: size,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // Secret text preview
            Text(
              '${crystal.originalCreatorNickname}さんのヒミツ',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Hiragino Sans',
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
