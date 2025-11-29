import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Widget that displays a crystal image
class CrystalImageWidget extends StatelessWidget {
  const CrystalImageWidget({
    super.key,
    required this.imageUrl,
    required this.size,
  });

  /// URL of the crystal image (can be asset path or network URL)
  final String imageUrl;

  /// Size of the crystal display (width and height)
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
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
