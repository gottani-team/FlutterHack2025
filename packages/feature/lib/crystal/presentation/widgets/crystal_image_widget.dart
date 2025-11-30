import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Widget that displays a crystal image with optional glow effect
class CrystalImageWidget extends StatelessWidget {
  const CrystalImageWidget({
    super.key,
    required this.imageUrl,
    required this.size,
    this.glowColor,
  });

  /// URL of the crystal image (can be asset path or network URL)
  final String imageUrl;

  /// Size of the crystal display (width and height)
  final double size;

  /// Optional glow color for the crystal (emotion-based)
  /// When provided, adds a radial glow effect behind the crystal
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final crystalImage = SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: imageUrl.isNotEmpty ? _buildImage() : _buildPlaceholder(),
      ),
    );

    // If no glow color, return just the crystal image
    if (glowColor == null) {
      return crystalImage;
    }

    // Add shadow effect behind the crystal (black shadow)
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shadow layer behind crystal (smaller shadow)
          Container(
            width: size * 0.5,
            height: size * 0.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: size * 0.15,
                  spreadRadius: size * 0.05,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: size * 0.25,
                  spreadRadius: size * 0.1,
                ),
              ],
            ),
          ),
          // Crystal image on top
          crystalImage,
        ],
      ),
    );
  }

  Widget _buildImage() {
    // Check if it's a local asset or network URL
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Color(0x99FFFFFF),
            Color(0x33FFFFFF),
            Colors.transparent,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.diamond_outlined,
          size: size * 0.5,
          color: const Color(0xCCFFFFFF),
        ),
      ),
    );
  }
}
