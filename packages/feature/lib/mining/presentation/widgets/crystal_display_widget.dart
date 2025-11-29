import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Widget that displays the crystal image with a subtle glow effect
class CrystalDisplayWidget extends StatelessWidget {
  const CrystalDisplayWidget({
    super.key,
    required this.imageUrl,
    this.glowColor = Colors.blue,
    this.size = 300,
  });

  /// URL of the AI-generated crystal image
  final String imageUrl;

  /// Color of the glow effect based on emotion type
  final Color glowColor;

  /// Size of the crystal display (width and height)
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          // Outer glow
          BoxShadow(
            color: glowColor.withValues(alpha: 0.3),
            blurRadius: 40,
            spreadRadius: 10,
          ),
          // Inner glow
          BoxShadow(
            color: glowColor.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl.isNotEmpty ? _buildImage() : _buildPlaceholder(),
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
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            glowColor.withValues(alpha: 0.6),
            glowColor.withValues(alpha: 0.2),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.diamond_outlined,
          size: size * 0.5,
          color: glowColor.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
