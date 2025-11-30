import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'glass_card_widget.dart';

/// A custom app bar with glass effect using GlassCardWidget.
///
/// Features:
/// - Title on the left with Imbue font
/// - Icon button on the right
/// - Frosted glass background with gradient border
class GlassAppBarWidget extends StatelessWidget {
  const GlassAppBarWidget({
    required this.title,
    super.key,
    this.onIconPressed,
    this.icon = Icons.menu,
    this.titleStyle,
    this.enableBlur = true,
  });

  /// The title text displayed on the left
  final String title;

  /// The icon displayed on the right
  final IconData icon;

  /// Callback when the icon is pressed
  final VoidCallback? onIconPressed;

  /// Custom style for the title (defaults to Imbue font)
  final TextStyle? titleStyle;

  /// Whether to enable backdrop blur effect.
  /// Set to false for better performance on screens with complex backgrounds.
  final bool enableBlur;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: GlassCardWidget(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        borderRadius: 22, // Fully round (half of height 44)
        enableBlur: enableBlur,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title on the left
            Text(
              title,
              style: titleStyle ??
                  GoogleFonts.imbue(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
            ),
            // Text(
            //   title,
            //   style: titleStyle ??
            // const TextStyle(
            //   fontFamily: 'Hiragino Sans',
            //   fontSize: 20,
            //   fontWeight: FontWeight.w600,
            //   color: Colors.black,
            //   fontStyle: FontStyle.italic,
            // ),
            // ),
            // Icon on the right
            GestureDetector(
              onTap: onIconPressed,
              child: Icon(
                icon,
                size: 24,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
