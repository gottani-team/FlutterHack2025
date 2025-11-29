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
        // 背景色
        Container(
          color: const Color(0xFFD3CCCA),
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
      ..color = const Color(0xFFF37255).withOpacity(0.2)
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

  static const double _pi = 3.14159265359;
  static const double _twoPi = 2 * _pi;

  @override
  void paint(Canvas canvas, Size size) {
    // クリスタルの位置を中心に
    final centerPoint = center ?? Offset(size.width / 2, size.height * 0.43);

    // リングの設定: [半径, 開始角度(度), 回転方向(1 or -1), 周回数(整数)]
    // 半径にばらつきを持たせる（等間隔ではない）
    final ringConfigs = [
      [320.0, 0.0, 1.0, 1.0],     // 外側: 時計回り、1周/サイクル
      [220.0, 120.0, -1.0, 1.0],  // 中間: 反時計回り、1周/サイクル
      [150.0, 240.0, 1.0, 2.0],   // 内側: 時計回り、2周/サイクル
    ];

    for (final config in ringConfigs) {
      final radius = config[0];
      final startAngleDegrees = config[1];
      final direction = config[2];
      final revolutions = config[3]; // 1サイクルあたりの周回数（整数）

      // 回転アニメーション（整数周なので0と1で同じ位置に戻る）
      final rotationAngle = animationValue * _twoPi * direction * revolutions;
      final rotation = (startAngleDegrees * _pi / 180) + rotationAngle;

      // SweepGradientでopacityをグラデーション（約40%が見える）
      final gradient = SweepGradient(
        startAngle: 0,
        endAngle: _twoPi,
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.35),
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.35),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.15, 0.3, 0.45, 0.6],
        transform: GradientRotation(rotation),
      );

      final rect = Rect.fromCircle(center: centerPoint, radius: radius);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0
        ..shader = gradient.createShader(rect);

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

