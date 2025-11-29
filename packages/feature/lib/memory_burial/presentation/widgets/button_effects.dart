import 'dart:math' as math;

import 'package:flutter/material.dart';

/// ボタン周囲の回転する円弧エフェクト
class RotatingArcsEffect extends StatefulWidget {
  const RotatingArcsEffect({
    super.key,
    required this.isVisible,
    required this.intensity, // 0.0〜1.0で強度を制御
  });

  final bool isVisible;
  final double intensity;

  @override
  State<RotatingArcsEffect> createState() => _RotatingArcsEffectState();
}

class _RotatingArcsEffectState extends State<RotatingArcsEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.isVisible ? widget.intensity : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      child: SizedBox(
        width: 300,
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 外側の円弧（時計回り）
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * math.pi,
                  child: child,
                );
              },
              child: CustomPaint(
                size: const Size(280, 280),
                painter: _ArcPainter(
                  radius: 130,
                  sweepAngle: 250,
                  color: const Color(0xFF5AADE0).withOpacity(0.35),
                ),
              ),
            ),

            // 中間の円弧（反時計回り）
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: -_rotationController.value * 2 * math.pi * 0.8,
                  child: child,
                );
              },
              child: CustomPaint(
                size: const Size(220, 220),
                painter: _ArcPainter(
                  radius: 100,
                  sweepAngle: 180,
                  color: const Color(0xFF5AADE0).withOpacity(0.3),
                ),
              ),
            ),

            // 内側の円弧（時計回り・遅め）
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * math.pi * 0.6,
                  child: child,
                );
              },
              child: CustomPaint(
                size: const Size(160, 160),
                painter: _ArcPainter(
                  radius: 70,
                  sweepAngle: 90,
                  color: const Color(0xFF5AADE0).withOpacity(0.25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 円弧を描画するPainter
class _ArcPainter extends CustomPainter {
  _ArcPainter({
    required this.radius,
    required this.sweepAngle,
    required this.color,
  });

  final double radius;
  final double sweepAngle;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepRadians = sweepAngle * math.pi / 180;

    canvas.drawArc(rect, 0, sweepRadians, false, paint);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.color != color;
  }
}

/// ボタン下の光の柱エフェクト（放射線状）
class LightPillarEffect extends StatelessWidget {
  const LightPillarEffect({
    super.key,
    required this.isVisible,
    required this.intensity, // 0.0〜1.0で強度を制御
  });

  final bool isVisible;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: CustomPaint(
        size: Size(200 + (intensity * 100), 180 + (intensity * 60)),
        painter: _RadialLightPainter(intensity: intensity),
      ),
    );
  }
}

/// 放射線状の光を描画するPainter
class _RadialLightPainter extends CustomPainter {
  _RadialLightPainter({required this.intensity});

  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final topY = 0.0;

    // 放射線状のグラデーション（上から下に広がる扇形）
    final path = Path()
      ..moveTo(centerX - 30, topY) // 上部の狭い部分
      ..lineTo(centerX + 30, topY)
      ..lineTo(centerX + size.width * 0.45, size.height) // 下部の広い部分
      ..lineTo(centerX - size.width * 0.45, size.height)
      ..close();

    // グラデーション
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.1 * intensity),
          Colors.white.withOpacity(0.5 * intensity),
          Colors.white.withOpacity(0.7 * intensity),
          const Color(0xFF7EC8E3).withOpacity(0.5 * intensity),
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);

    // 中央により強い光
    final centerGlowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 1.5,
        colors: [
          Colors.white.withOpacity(0.6 * intensity),
          Colors.white.withOpacity(0.2 * intensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.6));

    final centerPath = Path()
      ..moveTo(centerX - 20, topY)
      ..lineTo(centerX + 20, topY)
      ..lineTo(centerX + 60, size.height * 0.5)
      ..lineTo(centerX - 60, size.height * 0.5)
      ..close();

    canvas.drawPath(centerPath, centerGlowPaint);
  }

  @override
  bool shouldRepaint(covariant _RadialLightPainter oldDelegate) {
    return oldDelegate.intensity != intensity;
  }
}

/// ボタン下の楕円形の影（より強く）
class ButtonShadowEffect extends StatelessWidget {
  const ButtonShadowEffect({
    super.key,
    required this.isVisible,
    required this.intensity,
  });

  final bool isVisible;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: CustomPaint(
        size: Size(180 + (intensity * 80), 60 + (intensity * 30)),
        painter: _ShadowPainter(intensity: intensity),
      ),
    );
  }
}

/// 楕円形の影を描画するPainter
class _ShadowPainter extends CustomPainter {
  _ShadowPainter({required this.intensity});

  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // 外側の柔らかい影
    final outerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF5A9EC4).withOpacity(0.5 * intensity),
          const Color(0xFF5A9EC4).withOpacity(0.2 * intensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: size.width,
          height: size.height,
        ),
      );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: size.width,
        height: size.height,
      ),
      outerPaint,
    );

    // 内側の明るいグロー（光の反射）
    final innerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.4 * intensity),
          Colors.white.withOpacity(0.1 * intensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(
        Rect.fromCenter(
          center: Offset(centerX, centerY * 0.7),
          width: size.width * 0.6,
          height: size.height * 0.5,
        ),
      );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY * 0.7),
        width: size.width * 0.6,
        height: size.height * 0.5,
      ),
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ShadowPainter oldDelegate) {
    return oldDelegate.intensity != intensity;
  }
}

