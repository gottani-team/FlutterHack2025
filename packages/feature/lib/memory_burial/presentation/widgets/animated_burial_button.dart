import 'dart:math' as math;

import 'package:flutter/material.dart';

/// ボタンの状態フェーズ
enum ButtonPhase {
  /// 入力中（送信不可）
  typing,

  /// 送信可能（10文字以上）
  ready,

  /// 処理中（キーボードが閉じた後）
  processing,

  /// 完了
  completed,
}

/// アニメーション付き埋葬ボタン
class AnimatedBurialButton extends StatefulWidget {
  const AnimatedBurialButton({
    super.key,
    required this.phase,
    required this.onPressed,
    this.textLength = 0,
  });

  final ButtonPhase phase;
  final VoidCallback? onPressed;
  /// 入力テキストの文字数（0-10で連続的にサイズ変化）
  final int textLength;

  @override
  State<AnimatedBurialButton> createState() => _AnimatedBurialButtonState();
}

class _AnimatedBurialButtonState extends State<AnimatedBurialButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 文字数に応じてサイズを連続的に補間（0文字→10文字）
    final progress = (widget.textLength / 10.0).clamp(0.0, 1.0);
    
    // 処理中・完了時は別の設定
    final isProcessingOrCompleted = 
        widget.phase == ButtonPhase.processing || 
        widget.phase == ButtonPhase.completed;

    // サイズの補間
    // 初期: 65x104 → 送信可能: 160x160
    final double width;
    final double height;
    final double buttonTopOffset;
    final double arcsCenterY;
    final double arcsIntensity;
    final _ButtonIcon icon;

    if (isProcessingOrCompleted) {
      // 処理中・完了: 160x240の縦長
      width = 160;
      height = 240;
      buttonTopOffset = 146;
      arcsCenterY = 266;
      arcsIntensity = 1.0;
      icon = widget.phase == ButtonPhase.completed 
          ? _ButtonIcon.diamond 
          : _ButtonIcon.verticalLine;
    } else {
      // 入力中: 文字数に応じて連続変化
      // 65 → 160 (幅)
      width = 65 + (160 - 65) * progress;
      // 104 → 160 (高さ)
      height = 104 + (160 - 104) * progress;
      // 148 → 120 (上からのオフセット)
      buttonTopOffset = 148 - (148 - 120) * progress;
      arcsCenterY = 200;
      arcsIntensity = progress * 0.8;
      icon = _ButtonIcon.arrowDown;
    }

    return SizedBox(
      width: 400,
      height: 400,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 同心円（常に表示、opacityで制御）
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: arcsIntensity,
              duration: const Duration(milliseconds: 200),
              child: _ConcentricArcs(
                controller: _rotationController,
                intensity: arcsIntensity.clamp(0.1, 1.0),
                centerY: arcsCenterY,
              ),
            ),
          ),

          // ボタン本体（AnimatedPositionedで位置もアニメーション）
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            top: buttonTopOffset,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: widget.phase == ButtonPhase.ready ? widget.onPressed : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width / 2),
                    color: const Color(0xFF0D00FF).withOpacity(0.22),
                    border: Border.all(
                      color: const Color(0xFF5A9EC4).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _buildIcon(icon),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(_ButtonIcon icon) {
    return switch (icon) {
      _ButtonIcon.arrowDown => const Icon(
          Icons.arrow_downward,
          key: ValueKey('arrow'),
          color: Colors.white,
          size: 28,
        ),
      _ButtonIcon.verticalLine => Container(
          key: const ValueKey('line'),
          width: 3,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      _ButtonIcon.diamond => CustomPaint(
          key: const ValueKey('diamond'),
          size: const Size(32, 32),
          painter: _DiamondPainter(),
        ),
    };
  }
}

enum _ButtonIcon { arrowDown, verticalLine, diamond }

/// 同心円（円弧）
class _ConcentricArcs extends StatelessWidget {
  const _ConcentricArcs({
    required this.controller,
    required this.intensity,
    required this.centerY,
  });

  final AnimationController controller;
  final double intensity;
  final double centerY;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(400, 400),
          painter: _ConcentricArcsPainter(
            rotation: controller.value,
            intensity: intensity,
            centerY: centerY,
          ),
        );
      },
    );
  }
}

/// 同心円を描画するPainter
class _ConcentricArcsPainter extends CustomPainter {
  _ConcentricArcsPainter({
    required this.rotation,
    required this.intensity,
    required this.centerY,
  });

  final double rotation;
  final double intensity;
  final double centerY;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final center = Offset(centerX, centerY);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // 外側の円弧（時計回り）
    paint.color = const Color(0xFF5AADE0).withOpacity(0.3 * intensity);
    _drawArc(canvas, center, 200, 250, rotation * 2 * math.pi, paint);

    // 中間の円弧（反時計回り）
    paint.color = const Color(0xFF5AADE0).withOpacity(0.25 * intensity);
    _drawArc(canvas, center, 150, 180, -rotation * 2 * math.pi * 0.7, paint);

    // 内側の円弧（時計回り）
    paint.color = const Color(0xFF5AADE0).withOpacity(0.2 * intensity);
    _drawArc(canvas, center, 100, 120, rotation * 2 * math.pi * 0.5, paint);
  }

  void _drawArc(
    Canvas canvas,
    Offset center,
    double radius,
    double sweepDegrees,
    double startAngle,
    Paint paint,
  ) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepRadians = sweepDegrees * math.pi / 180;
    canvas.drawArc(rect, startAngle, sweepRadians, false, paint);
  }

  @override
  bool shouldRepaint(covariant _ConcentricArcsPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.intensity != intensity ||
        oldDelegate.centerY != centerY;
  }
}

/// ダイヤモンドアイコンを描画するPainter
class _DiamondPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final path = Path()
      ..moveTo(centerX, 0)
      ..lineTo(size.width * 0.85, centerY * 0.6)
      ..lineTo(size.width, centerY)
      ..lineTo(centerX, size.height)
      ..lineTo(0, centerY)
      ..lineTo(size.width * 0.15, centerY * 0.6)
      ..close();

    canvas.drawPath(path, paint);

    canvas.drawLine(
      Offset(size.width * 0.15, centerY * 0.6),
      Offset(size.width * 0.85, centerY * 0.6),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.15, centerY * 0.6),
      Offset(centerX, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.85, centerY * 0.6),
      Offset(centerX, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, centerY * 0.6),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
