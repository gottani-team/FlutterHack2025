import 'package:flutter/material.dart';

/// バッジの共通スタイル定数
class _BadgeStyle {
  static const Color primaryColor = Color(0xFF5558F3);
  static const Color backgroundColor = Color(0x99FFFFFF); // white 60%
  static const double fontSize = 10;
  static const double paddingHorizontal = 6;
  static const double paddingVertical = 5;
  static const double borderRadius = 12;
  static const double borderWidth = 1;
}

/// 必須バッジ
class RequiredBadge extends StatelessWidget {
  const RequiredBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _BadgeStyle.paddingHorizontal,
        vertical: _BadgeStyle.paddingVertical,
      ),
      decoration: BoxDecoration(
        color: _BadgeStyle.backgroundColor,
        borderRadius: BorderRadius.circular(_BadgeStyle.borderRadius),
        border: Border.all(
          color: _BadgeStyle.primaryColor,
          width: _BadgeStyle.borderWidth,
        ),
      ),
      child: const Text(
        '必須',
        style: TextStyle(
          color: _BadgeStyle.primaryColor,
          fontSize: _BadgeStyle.fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// チェックマークバッジ
class CheckBadge extends StatelessWidget {
  const CheckBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: _BadgeStyle.backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: _BadgeStyle.primaryColor,
          width: _BadgeStyle.borderWidth,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.check,
          color: _BadgeStyle.primaryColor,
          size: 14,
        ),
      ),
    );
  }
}

