import 'dart:math' as math;

import 'package:flutter/material.dart';

/// クリスタル表示ウィジェット
///
/// 埋葬完了後に表示されるクリスタルのアニメーション
class CrystalDisplay extends StatefulWidget {
  const CrystalDisplay({
    super.key,
    this.showAnalyzing = true,
    this.onAnalysisComplete,
  });

  /// 「解析中...」を表示するか
  final bool showAnalyzing;

  /// 解析完了時のコールバック
  final VoidCallback? onAnalysisComplete;

  @override
  State<CrystalDisplay> createState() => _CrystalDisplayState();
}

class _CrystalDisplayState extends State<CrystalDisplay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _ringController;

  @override
  void initState() {
    super.initState();

    // クリスタルの脈動アニメーション
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // リングの回転アニメーション
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // 解析完了のシミュレーション
    if (widget.showAnalyzing) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          widget.onAnalysisComplete?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // クリスタル + グロー + リング（画面中央）
        Center(
          child: SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 回転する円弧（外側・大きめ・時計回り）
                AnimatedBuilder(
                  animation: _ringController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _ringController.value * 2 * math.pi,
                      child: child,
                    );
                  },
                  child: CustomPaint(
                    size: const Size(280, 280),
                    painter: _ArcPainter(
                      radius: 130,
                      sweepAngle: 250, // 250度の円弧
                      color: const Color(0xFFF37255).withOpacity(0.35),
                    ),
                  ),
                ),

                // 回転する円弧（中間・反時計回り）
                AnimatedBuilder(
                  animation: _ringController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: -_ringController.value * 2 * math.pi * 0.8,
                      child: child,
                    );
                  },
                  child: CustomPaint(
                    size: const Size(220, 220),
                    painter: _ArcPainter(
                      radius: 100,
                      sweepAngle: 180, // 180度の円弧
                      color: const Color(0xFFF37255).withOpacity(0.3),
                    ),
                  ),
                ),

                // 回転する円弧（内側・時計回り・遅め）
                AnimatedBuilder(
                  animation: _ringController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _ringController.value * 2 * math.pi * 0.6,
                      child: child,
                    );
                  },
                  child: CustomPaint(
                    size: const Size(160, 160),
                    painter: _ArcPainter(
                      radius: 70,
                      sweepAngle: 90, // 90度の円弧
                      color: const Color(0xFFF37255).withOpacity(0.25),
                    ),
                  ),
                ),

                // グローエフェクト
                const _CrystalGlow(),

                // クリスタル（脈動アニメーション）
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 1.0 +
                        math.sin(_pulseController.value * math.pi * 2) * 0.03;
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: const CrystalPlaceholder(),
                ),
              ],
            ),
          ),
        ),

        // 解析中テキスト（下部中央）
        if (widget.showAnalyzing)
          Positioned(
            left: 0,
            right: 0,
            bottom: 80,
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final dotCount =
                      ((_pulseController.value * 3) % 3).floor() + 1;
                  final dots = '.' * dotCount;
                  return Text(
                    '解析中$dots',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1A1A2E),
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

/// 回転する円弧を描画するPainter
class _ArcPainter extends CustomPainter {
  _ArcPainter({
    required this.radius,
    required this.sweepAngle,
    required this.color,
  });

  final double radius;
  final double sweepAngle; // 度数（0-360）
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round; // 端を丸くする

    final rect = Rect.fromCircle(center: center, radius: radius);

    // sweepAngleを度からラジアンに変換
    final sweepRadians = sweepAngle * math.pi / 180;

    canvas.drawArc(
      rect,
      0, // 開始角度
      sweepRadians, // 描画する角度
      false, // 中心を通らない
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.color != color;
  }
}

/// クリスタル周りのグローエフェクト
class _CrystalGlow extends StatelessWidget {
  const _CrystalGlow();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          // 外側の大きなグロー
          BoxShadow(
            color: const Color(0xFFF37255).withOpacity(0.3),
            blurRadius: 50,
            spreadRadius: 20,
          ),
          // 内側のグロー
          BoxShadow(
            color: const Color(0xFFFFB8A8).withOpacity(0.25),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}

/// クリスタルのプレースホルダー（3Dモデル用）
///
/// TODO: 後で3Dモデルに置き換える
class CrystalPlaceholder extends StatelessWidget {
  const CrystalPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 120,
      child: CustomPaint(
        painter: _CrystalPlaceholderPainter(),
      ),
    );
  }
}

/// クリスタルのプレースホルダーを描画するPainter
class _CrystalPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // メインクリスタル（中央・大きめ）
    _drawCrystal(
      canvas,
      centerX,
      centerY - 15,
      28,
      70,
      const Color(0xFF7B68EE),
      const Color(0xFF5A4FCF),
    );

    // 左のクリスタル
    _drawCrystal(
      canvas,
      centerX - 25,
      centerY + 10,
      18,
      45,
      const Color(0xFFB39DDB),
      const Color(0xFF9575CD),
    );

    // 右のクリスタル
    _drawCrystal(
      canvas,
      centerX + 25,
      centerY + 10,
      18,
      45,
      const Color(0xFFCE93D8),
      const Color(0xFFBA68C8),
    );

    // 左外側の小さなクリスタル
    _drawCrystal(
      canvas,
      centerX - 38,
      centerY + 25,
      12,
      30,
      const Color(0xFFE1BEE7),
      const Color(0xFFCE93D8),
    );

    // 右外側の小さなクリスタル
    _drawCrystal(
      canvas,
      centerX + 38,
      centerY + 25,
      12,
      30,
      const Color(0xFFD1C4E9),
      const Color(0xFFB39DDB),
    );
  }

  void _drawCrystal(
    Canvas canvas,
    double x,
    double y,
    double width,
    double height,
    Color lightColor,
    Color darkColor,
  ) {
    // クリスタルの形状（六角形に近い形）
    final path = Path()
      ..moveTo(x, y - height / 2) // 上頂点
      ..lineTo(x + width / 2, y - height / 4) // 右上
      ..lineTo(x + width / 2, y + height / 4) // 右下
      ..lineTo(x, y + height / 2) // 下頂点
      ..lineTo(x - width / 2, y + height / 4) // 左下
      ..lineTo(x - width / 2, y - height / 4) // 左上
      ..close();

    // グラデーション塗りつぶし
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lightColor, darkColor],
      ).createShader(
        Rect.fromCenter(
          center: Offset(x, y),
          width: width,
          height: height,
        ),
      );

    canvas.drawPath(path, paint);

    // ハイライト（左上面）
    final highlightPath = Path()
      ..moveTo(x, y - height / 2)
      ..lineTo(x - width / 2, y - height / 4)
      ..lineTo(x - width / 2, y)
      ..lineTo(x, y - height / 6)
      ..close();

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    canvas.drawPath(highlightPath, highlightPaint);

    // 輪郭
    final outlinePaint = Paint()
      ..color = darkColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.drawPath(path, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
