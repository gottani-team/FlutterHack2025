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
  });

  final ButtonPhase phase;
  final VoidCallback? onPressed;
  final int textLength;

  @override
  State<AnimatedBurialButton> createState() => _AnimatedBurialButtonState();
}

class _AnimatedBurialButtonState extends State<AnimatedBurialButton>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _entryEffectController;
  late AnimationController _arrowFadeController;
  late AnimationController _crystalFadeController;

  // エフェクトのアニメーション
  late Animation<double> _entryAnimation;
  late Animation<double> _arrowFadeAnimation;
  late Animation<double> _crystalFadeAnimation;

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

    // 矢印フェードアウトアニメーション（下降中に徐々に薄くなる）
    _arrowFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _arrowFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _arrowFadeController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInQuart),
      ),
    );

    // クリスタルフェードインアニメーション（矢印が消えた後に浮かんでくる）
    _crystalFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _crystalFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _crystalFadeController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void didUpdateWidget(AnimatedBurialButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // processingに移行したらエフェクト開始
    if (widget.phase == ButtonPhase.processing &&
        oldWidget.phase != ButtonPhase.processing) {
      _entryEffectController.forward(from: 0);
      _arrowFadeController.forward(from: 0);

      // 文字が集まりきる頃（2.5秒アニメーションの終盤）にクリスタルが浮かび上がる
      // 文字がボタンに吸い込まれてクリスタルになる感じ
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted && widget.phase == ButtonPhase.processing) {
          _crystalFadeController.forward(from: 0);
        }
      });
    }

    // completedに移行した時点でクリスタルが表示されていなければ開始
    if (widget.phase == ButtonPhase.completed &&
        oldWidget.phase != ButtonPhase.completed) {
      if (!_crystalFadeController.isAnimating && _crystalFadeController.value < 1.0) {
        _crystalFadeController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _entryEffectController.dispose();
    _arrowFadeController.dispose();
    _crystalFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.textLength / 10.0).clamp(0.0, 1.0);

    final isProcessingOrCompleted =
        widget.phase == ButtonPhase.processing ||
        widget.phase == ButtonPhase.completed;

    // ボタンのサイズと位置
    final double buttonWidth;
    final double buttonHeight;
    final double buttonTopOffset;
    final double arcsCenterY;
    final double arcsIntensity;
    final _ButtonIcon icon;

    if (isProcessingOrCompleted) {
      buttonWidth = 160;
      buttonHeight = 240;
      buttonTopOffset = 146;
      arcsCenterY = 266;
      arcsIntensity = 1.0;
      // processing中も矢印を表示（徐々にフェードアウト）、completed後はクリスタル
      icon = widget.phase == ButtonPhase.completed
          ? _ButtonIcon.diamond
          : _ButtonIcon.arrowDown;
    } else {
      buttonWidth = 65 + (160 - 65) * progress;
      buttonHeight = 104 + (160 - 104) * progress;
      buttonTopOffset = 148 - (148 - 120) * progress;
      arcsCenterY = 200;
      arcsIntensity = progress * 0.8;
      icon = _ButtonIcon.arrowDown;
    }

    // ボタンの下端位置
    final buttonBottomY = buttonTopOffset + buttonHeight;

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
                    buttonBottomY: buttonBottomY,
                    buttonWidth: buttonWidth,
                    buttonHeight: buttonHeight,
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
              opacity: arcsIntensity,
              duration: const Duration(milliseconds: 200),
              child: _ConcentricArcs(
                controller: _rotationController,
                intensity: arcsIntensity.clamp(0.1, 1.0),
                centerY: arcsCenterY,
              ),
            ),
          ),

          // ボタン本体
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
                  width: buttonWidth,
                  height: buttonHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(buttonWidth / 2),
                    color: const Color(0xFFFF3C00).withOpacity(0.22),
                    border: Border.all(
                      color: const Color(0xFFFF3C00).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: _buildAnimatedIcon(icon),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// アニメーション付きアイコンを構築
  Widget _buildAnimatedIcon(_ButtonIcon icon) {
    // processing中は矢印がフェードアウトし、その後クリスタルがフェードイン
    if (widget.phase == ButtonPhase.processing) {
      return AnimatedBuilder(
        animation: Listenable.merge([_arrowFadeAnimation, _crystalFadeAnimation]),
        builder: (context, child) {
          // 矢印とクリスタルを重ねて表示
          return Stack(
            alignment: Alignment.center,
            children: [
              // 矢印（フェードアウト）
              if (_arrowFadeAnimation.value > 0)
                Opacity(
                  opacity: _arrowFadeAnimation.value,
                  child: const Icon(
                    Icons.arrow_downward,
                    key: ValueKey('arrow'),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              // クリスタル（フェードイン + 下から浮かんでくる）
              if (_crystalFadeAnimation.value > 0)
                Transform.translate(
                  offset: Offset(0, 30.0 * (1.0 - _crystalFadeAnimation.value)),
                  child: Opacity(
                    opacity: _crystalFadeAnimation.value,
                    child: CustomPaint(
                      key: const ValueKey('diamond'),
                      size: const Size(48, 48),
                      painter: _CrystalPainter(opacity: _crystalFadeAnimation.value),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    }

    // completed時はクリスタルを表示
    if (widget.phase == ButtonPhase.completed) {
      return AnimatedBuilder(
        animation: _crystalFadeAnimation,
        builder: (context, child) {
          // 下から上へ浮かんでくる動き
          final offsetY = 30.0 * (1.0 - _crystalFadeAnimation.value);
          return Transform.translate(
            offset: Offset(0, offsetY),
            child: Opacity(
              opacity: _crystalFadeAnimation.value,
              child: CustomPaint(
                key: const ValueKey('diamond'),
                size: const Size(48, 48),
                painter: _CrystalPainter(opacity: _crystalFadeAnimation.value),
              ),
            ),
          );
        },
      );
    }

    // 通常時は矢印
    return const Icon(
      Icons.arrow_downward,
      key: ValueKey('arrow'),
      color: Colors.white,
      size: 28,
    );
  }
}

enum _ButtonIcon { arrowDown, diamond }

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

  /// 外側の青いグラデーションエリア
  void _drawOuterGlow(
    Canvas canvas,
    double centerX,
    double startY,
    double intensity,
  ) {
    if (intensity <= 0) return;

    // 下に広がる大きな形状
    final width = buttonWidth * 3.5;
    final height = 320.0;

    final path = Path();
    path.moveTo(centerX - buttonWidth * 0.5, startY);
    path.quadraticBezierTo(
      centerX - width * 0.5,
      startY + height * 0.5,
      centerX,
      startY + height,
    );
    path.quadraticBezierTo(
      centerX + width * 0.5,
      startY + height * 0.5,
      centerX + buttonWidth * 0.5,
      startY,
    );
    path.close();

    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(centerX, startY),
        Offset(centerX, startY + height),
        [
          const Color(0xFFFFB8A8).withOpacity(0.5 * intensity),
          const Color(0xFFF37255).withOpacity(0.4 * intensity),
          const Color(0xFFF37255).withOpacity(0.15 * intensity),
          Colors.transparent,
        ],
        [0.0, 0.25, 0.6, 1.0],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    canvas.drawPath(path, paint);
  }

  /// 中間の水色エリア
  void _drawMiddleGlow(
    Canvas canvas,
    double centerX,
    double startY,
    double intensity,
  ) {
    if (intensity <= 0) return;

    final width = buttonWidth * 2.2;
    final height = 180.0;

    final path = Path();
    path.moveTo(centerX - buttonWidth * 0.4, startY);
    path.quadraticBezierTo(
      centerX - width * 0.45,
      startY + height * 0.4,
      centerX,
      startY + height,
    );
    path.quadraticBezierTo(
      centerX + width * 0.45,
      startY + height * 0.4,
      centerX + buttonWidth * 0.4,
      startY,
    );
    path.close();

    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(centerX, startY),
        Offset(centerX, startY + height),
        [
          const Color(0xFFFFD5C8).withOpacity(0.7 * intensity),
          const Color(0xFFFFB8A8).withOpacity(0.5 * intensity),
          const Color(0xFFFFB8A8).withOpacity(0.2 * intensity),
          Colors.transparent,
        ],
        [0.0, 0.3, 0.6, 1.0],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);

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

/// クリスタルアイコン（添付画像のような宝石デザイン）
class _CrystalPainter extends CustomPainter {
  _CrystalPainter({this.opacity = 1.0});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // クリスタルの各頂点を定義（添付画像に合わせた形状）
    // 上部の頂点
    final top = Offset(w * 0.5, 0);
    // 上部左右の角
    final topLeft = Offset(w * 0.15, h * 0.25);
    final topRight = Offset(w * 0.85, h * 0.25);
    // 中間左右の角（最も広い部分）
    final midLeft = Offset(0, h * 0.4);
    final midRight = Offset(w, h * 0.4);
    // 下部の頂点
    final bottom = Offset(w * 0.5, h);

    // 外側の輪郭を描画
    final outlinePath = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..lineTo(midRight.dx, midRight.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(midLeft.dx, midLeft.dy)
      ..lineTo(topLeft.dx, topLeft.dy)
      ..close();

    canvas.drawPath(outlinePath, paint);

    // 内部の線（クリスタルのカット面）
    // 上部から中央への線
    canvas.drawLine(top, Offset(w * 0.35, h * 0.25), paint);
    canvas.drawLine(top, Offset(w * 0.65, h * 0.25), paint);

    // 横の区切り線
    canvas.drawLine(topLeft, topRight, paint);

    // 下部への斜め線
    canvas.drawLine(topLeft, bottom, paint);
    canvas.drawLine(topRight, bottom, paint);

    // 中央から下への線
    canvas.drawLine(Offset(w * 0.35, h * 0.25), bottom, paint);
    canvas.drawLine(Offset(w * 0.65, h * 0.25), bottom, paint);
  }

  @override
  bool shouldRepaint(covariant _CrystalPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}
