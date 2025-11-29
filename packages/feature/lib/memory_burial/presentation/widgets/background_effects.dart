import 'package:flutter/material.dart';

/// 水色グラデーション + ドットパターン + 同心円リングの背景
class MemoryBurialBackground extends StatelessWidget {
  const MemoryBurialBackground({
    super.key,
    this.ringCenter,
    this.showRings = true,
    this.ringAnimation,
  });

  /// リングの中心位置（nullの場合は画面中央）
  final Offset? ringCenter;

  /// リングを表示するか
  final bool showRings;

  /// リングのアニメーション値（0.0〜1.0）
  final double? ringAnimation;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // グラデーション背景
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFA4D4F4), // 薄い水色
                Color(0xFF8BC4EA), // やや濃い水色
                Color(0xFFB8E0F7), // 明るい水色
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // ドットパターン
        CustomPaint(
          painter: DotPatternPainter(),
          size: Size.infinite,
        ),
        // 同心円リング
        if (showRings)
          CustomPaint(
            painter: ConcentricRingsPainter(
              center: ringCenter,
              animationValue: ringAnimation ?? 0.0,
            ),
            size: Size.infinite,
          ),
      ],
    );
  }
}

/// ドットパターンを描画するPainter
class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7AB8D9).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const dotRadius = 1.0;

    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 同心円リングを描画するPainter
class ConcentricRingsPainter extends CustomPainter {
  ConcentricRingsPainter({
    this.center,
    this.animationValue = 0.0,
  });

  final Offset? center;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final centerPoint = center ?? Offset(size.width / 2, size.height * 0.55);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 3つのリングを描画
    final radii = [100.0, 180.0, 280.0];

    for (var i = 0; i < radii.length; i++) {
      final baseRadius = radii[i];
      // アニメーションでリングが拡大
      final radius = baseRadius + (animationValue * 20.0);
      final opacity = (0.15 - (animationValue * 0.1)).clamp(0.05, 0.2);

      paint.color = const Color(0xFF5A9EC4).withOpacity(opacity);

      canvas.drawCircle(centerPoint, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ConcentricRingsPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.animationValue != animationValue;
  }
}

/// ボタンの下の光の柱エフェクト
class LightBeamEffect extends StatelessWidget {
  const LightBeamEffect({
    super.key,
    required this.isActive,
    this.height = 200,
  });

  final bool isActive;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isActive ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: CustomPaint(
        size: Size(120, height),
        painter: _LightBeamPainter(),
      ),
    );
  }
}

/// 光の柱を描画するPainter
class _LightBeamPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // 楕円形のグラデーション（上から下へ、透明から明るく）
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 1.5,
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.05),
          Colors.white.withOpacity(0.15),
          Colors.white.withOpacity(0.25),
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
      ).createShader(
        Rect.fromCenter(
          center: Offset(centerX, size.height * 0.6),
          width: size.width,
          height: size.height * 1.2,
        ),
      );

    // 楕円形のパスを描画
    final path = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(centerX, size.height * 0.5),
          width: size.width * 0.8,
          height: size.height,
        ),
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

