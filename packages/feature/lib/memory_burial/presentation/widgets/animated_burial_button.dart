import 'dart:math' as math;
import 'dart:ui' as ui;

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
    this.isEnabled = false,
  });

  final ButtonPhase phase;
  final VoidCallback? onPressed;
  final int textLength;
  final bool isEnabled;

  @override
  State<AnimatedBurialButton> createState() => _AnimatedBurialButtonState();
}

class _AnimatedBurialButtonState extends State<AnimatedBurialButton>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _entryEffectController;
  late AnimationController _shapeAnimationController;

  // エフェクトのアニメーション
  late Animation<double> _entryAnimation;
  late Animation<double> _positionAnimation;
  late Animation<double> _widthAnimation;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // 大気圏突入エフェクト（ボタン移動と同じ1500ms）
    _entryEffectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _entryAnimation = CurvedAnimation(
      parent: _entryEffectController,
      curve: Curves.easeOutCubic,
    );

    // 形状・位置アニメーション
    _shapeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 位置アニメーション（ease out）
    _positionAnimation = CurvedAnimation(
      parent: _shapeAnimationController,
      curve: Curves.easeOut,
    );

    // 幅アニメーション: 65 → 160（固定）
    _widthAnimation = Tween<double>(begin: 65, end: 160).animate(
      CurvedAnimation(
        parent: _shapeAnimationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // 高さアニメーション: 104 → 160（円） → 280（オーバーシュート） → 240（最終形）
    _heightAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 104, end: 160)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 160, end: 280)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 280, end: 240)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_shapeAnimationController);
  }

  @override
  void didUpdateWidget(AnimatedBurialButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // processingに移行したらエフェクト開始
    if (widget.phase == ButtonPhase.processing &&
        oldWidget.phase != ButtonPhase.processing) {
      _entryEffectController.forward(from: 0);
      _shapeAnimationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _entryEffectController.dispose();
    _shapeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isProcessingOrCompleted = widget.phase == ButtonPhase.processing ||
        widget.phase == ButtonPhase.completed;
    final isReady = widget.phase == ButtonPhase.ready;

    return AnimatedBuilder(
      animation: _shapeAnimationController,
      builder: (context, child) {
        // アニメーション中の値を再計算
        final animButtonWidth =
            isProcessingOrCompleted ? _widthAnimation.value : 65.0;
        final animButtonHeight =
            isProcessingOrCompleted ? _heightAnimation.value : 104.0;
        final animButtonTopOffset = isProcessingOrCompleted
            ? 148 - (148 - 146) * _positionAnimation.value
            : 148.0;
        final animArcsCenterY = isProcessingOrCompleted
            ? 200 + (266 - 200) * _positionAnimation.value
            : 200.0;
        final animArcsIntensity = isProcessingOrCompleted
            ? _positionAnimation.value
            : (isReady ? 0.5 : 0.0);
        final animButtonBottomY = animButtonTopOffset + animButtonHeight;

        return SizedBox(
          width: 400,
          height: 500, // エフェクト用に高さを拡大
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 大気圏突入エフェクト（ボタンの下に配置）
              if (isProcessingOrCompleted)
                AnimatedBuilder(
                  animation: _entryAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(400, 500),
                      painter: _AtmosphericEntryPainter(
                        progress: _entryAnimation.value,
                        buttonBottomY: animButtonBottomY,
                        buttonWidth: animButtonWidth,
                        buttonHeight: animButtonHeight,
                      ),
                    );
                  },
                ),

              // 同心円
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 400,
                child: AnimatedOpacity(
                  opacity: animArcsIntensity,
                  duration: const Duration(milliseconds: 200),
                  child: _ConcentricArcs(
                    controller: _rotationController,
                    intensity: animArcsIntensity.clamp(0.1, 1.0),
                    centerY: animArcsCenterY,
                  ),
                ),
              ),

              // ボタン本体
              Positioned(
                top: animButtonTopOffset,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: widget.phase == ButtonPhase.ready && widget.isEnabled
                        ? widget.onPressed
                        : null,
                    child: Container(
                      width: animButtonWidth,
                      height: animButtonHeight,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(animButtonWidth / 2),
                        color: widget.isEnabled
                            ? const Color(0xFFFF3C00).withOpacity(0.22)
                            : const Color(0xFF9E9E9E).withOpacity(0.22),
                        border: Border.all(
                          color: widget.isEnabled
                              ? const Color(0xFFFF3C00).withOpacity(0.3)
                              : const Color(0xFF9E9E9E).withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: _buildArrowIcon(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 矢印アイコンを構築（常に矢印固定）
  Widget _buildArrowIcon() {
    return const Icon(
      Icons.arrow_downward,
      key: ValueKey('arrow'),
      color: Colors.white,
      size: 28,
    );
  }
}

/// 大気圏突入エフェクト
class _AtmosphericEntryPainter extends CustomPainter {
  _AtmosphericEntryPainter({
    required this.progress,
    required this.buttonBottomY,
    required this.buttonWidth,
    required this.buttonHeight,
  });

  final double progress;
  final double buttonBottomY;
  final double buttonWidth;
  final double buttonHeight;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final centerX = size.width / 2;

    // エフェクトの起点はボタンの下端
    final effectStartY = buttonBottomY;

    // アニメーションの強度計算
    // 0.0〜0.1: フェードイン
    // 0.1〜0.5: 最大強度維持
    // 0.5〜1.0: フェードアウト
    double intensity;
    if (progress < 0.1) {
      final t = progress / 0.1;
      intensity = Curves.easeOut.transform(t);
    } else if (progress < 0.5) {
      intensity = 1.0;
    } else {
      final t = (progress - 0.5) / 0.5;
      intensity = 1.0 - Curves.easeIn.transform(t);
    }

    // === 外側の青いグラデーションエリア（塗りつぶし） ===
    _drawOuterGlow(canvas, centerX, effectStartY, intensity);

    // === 中間の水色エリア（塗りつぶし） ===
    _drawMiddleGlow(canvas, centerX, effectStartY, intensity);

    // === 白い三日月形のコア（塗りつぶし） ===
    _drawWhiteCrescent(canvas, centerX, effectStartY, intensity);
  }

  /// 外側のオレンジエリア（楕円の下半分、下に凸）
  void _drawOuterGlow(
    Canvas canvas,
    double centerX,
    double startY,
    double intensity,
  ) {
    if (intensity <= 0) return;

    // 楕円の下半分（下に凸のお椀型）
    // 白い三日月と同じ位置から開始し、下に広がる
    final width = buttonWidth * 3.0;
    final height = 100.0;

    // 楕円の下半分を描く（上端が平ら、下が丸い）
    final rect = Rect.fromCenter(
      center: Offset(centerX, startY), // 上端が startY
      width: width,
      height: height * 2, // 楕円全体の高さ（下半分だけ使う）
    );

    final path = Path();
    // 楕円の下半分だけ描画（0からπまでの弧）
    path.arcTo(rect, 0, math.pi, true);
    path.close();

    final paint = Paint()
      ..color = const Color(0xFFF37255).withOpacity(0.35 * intensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    canvas.drawPath(path, paint);
  }

  /// 中間のピンクエリア（楕円の下半分、下に凸）
  void _drawMiddleGlow(
    Canvas canvas,
    double centerX,
    double startY,
    double intensity,
  ) {
    if (intensity <= 0) return;

    // 楕円の下半分（下に凸のお椀型）、外側より小さめ
    final width = buttonWidth * 2.0;
    final height = 60.0;

    // 楕円の下半分を描く（上端が平ら、下が丸い）
    final rect = Rect.fromCenter(
      center: Offset(centerX, startY), // 上端が startY
      width: width,
      height: height * 2, // 楕円全体の高さ（下半分だけ使う）
    );

    final path = Path();
    // 楕円の下半分だけ描画（0からπまでの弧）
    path.arcTo(rect, 0, math.pi, true);
    path.close();

    final paint = Paint()
      ..color = const Color(0xFFFFB8A8).withOpacity(0.5 * intensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawPath(path, paint);
  }

  /// 白い三日月形のコア
  void _drawWhiteCrescent(
    Canvas canvas,
    double centerX,
    double startY,
    double intensity,
  ) {
    if (intensity <= 0) return;

    // 三日月形（ボタン直下の白い発光）
    final crescentWidth = buttonWidth * 1.3;
    final crescentHeight = 50.0;

    // 外側の弧（下に凸）
    final outerPath = Path();
    outerPath.moveTo(centerX - crescentWidth / 2, startY);
    outerPath.quadraticBezierTo(
      centerX,
      startY + crescentHeight,
      centerX + crescentWidth / 2,
      startY,
    );
    // 内側の弧（上に凸、浅い）
    outerPath.quadraticBezierTo(
      centerX,
      startY + crescentHeight * 0.3,
      centerX - crescentWidth / 2,
      startY,
    );
    outerPath.close();

    // 外側のグロー
    final outerGlowPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(centerX, startY + crescentHeight * 0.4),
        crescentWidth * 0.6,
        [
          Colors.white.withOpacity(0.9 * intensity),
          Colors.white.withOpacity(0.5 * intensity),
          const Color(0xFFFFE8E0).withOpacity(0.3 * intensity),
          Colors.transparent,
        ],
        [0.0, 0.4, 0.7, 1.0],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawPath(outerPath, outerGlowPaint);

    // 中間のグロー
    final midGlowPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(centerX, startY + crescentHeight * 0.3),
        crescentWidth * 0.4,
        [
          Colors.white.withOpacity(0.95 * intensity),
          Colors.white.withOpacity(0.7 * intensity),
          Colors.white.withOpacity(0.3 * intensity),
          Colors.transparent,
        ],
        [0.0, 0.3, 0.6, 1.0],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawPath(outerPath, midGlowPaint);

    // 最も明るいコア（小さい三日月）
    final coreWidth = buttonWidth * 0.9;
    final coreHeight = 30.0;

    final corePath = Path();
    corePath.moveTo(centerX - coreWidth / 2, startY + 5);
    corePath.quadraticBezierTo(
      centerX,
      startY + 5 + coreHeight,
      centerX + coreWidth / 2,
      startY + 5,
    );
    corePath.quadraticBezierTo(
      centerX,
      startY + 5 + coreHeight * 0.4,
      centerX - coreWidth / 2,
      startY + 5,
    );
    corePath.close();

    final corePaint = Paint()
      ..color = Colors.white.withOpacity(intensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawPath(corePath, corePaint);

    // ハイライト（純白の線）
    final highlightPath = Path();
    highlightPath.moveTo(centerX - coreWidth * 0.35, startY + 8);
    highlightPath.quadraticBezierTo(
      centerX,
      startY + 8 + coreHeight * 0.6,
      centerX + coreWidth * 0.35,
      startY + 8,
    );

    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(intensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _AtmosphericEntryPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.buttonBottomY != buttonBottomY ||
        oldDelegate.buttonWidth != buttonWidth;
  }
}

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

    paint.color = const Color(0xFFF37255).withOpacity(0.3 * intensity);
    _drawArc(canvas, center, 200, 250, rotation * 2 * math.pi, paint);

    paint.color = const Color(0xFFF37255).withOpacity(0.25 * intensity);
    _drawArc(canvas, center, 150, 180, -rotation * 2 * math.pi * 0.7, paint);

    paint.color = const Color(0xFFF37255).withOpacity(0.2 * intensity);
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

