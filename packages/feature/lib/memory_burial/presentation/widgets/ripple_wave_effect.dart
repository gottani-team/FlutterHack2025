import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// 大気圏突入エフェクト
/// 
/// ボタン（物体）が下に突入する時、
/// ボタンの外側・前方（下）に衝撃波が形成される
class RippleWaveEffect extends StatefulWidget {
  const RippleWaveEffect({
    super.key,
    required this.isActive,
    this.intensity = 1.0,
  });

  final bool isActive;
  final double intensity;

  @override
  State<RippleWaveEffect> createState() => _RippleWaveEffectState();
}

class _RippleWaveEffectState extends State<RippleWaveEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    if (widget.isActive) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(RippleWaveEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _AtmosphericEntryPainter(
            progress: _controller.value,
            intensity: widget.intensity,
          ),
        );
      },
    );
  }
}

class _AtmosphericEntryPainter extends CustomPainter {
  _AtmosphericEntryPainter({
    required this.progress,
    required this.intensity,
  });

  final double progress;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || intensity <= 0) return;
    
    final centerX = size.width / 2;
    // ボタンの下端の位置（エフェクトの起点）
    final buttonBottomY = 0.0;
    
    final p = progress;
    final alpha = intensity;
    
    // === 衝撃波エフェクト ===
    // ボタンの外側に、弓状の衝撃波が広がる
    
    // 1. 最外層の衝撃波（最も離れている）
    _drawShockwave(
      canvas: canvas,
      centerX: centerX,
      startY: buttonBottomY + 120 * p,  // ボタンから離れた位置
      width: 360 * p,
      curveDepth: 80 * p,
      color: const Color(0xFFFF3C00),
      opacity: 0.25 * alpha * p,
      blur: 35,
      strokeWidth: 20,
    );
    
    // 2. 中間層の衝撃波
    _drawShockwave(
      canvas: canvas,
      centerX: centerX,
      startY: buttonBottomY + 80 * p,
      width: 300 * p,
      curveDepth: 60 * p,
      color: const Color(0xFFF37255),
      opacity: 0.4 * alpha * p,
      blur: 25,
      strokeWidth: 25,
    );
    
    // 3. 内層の衝撃波（ボタンに近い）
    _drawShockwave(
      canvas: canvas,
      centerX: centerX,
      startY: buttonBottomY + 45 * p,
      width: 240 * p,
      curveDepth: 45 * p,
      color: const Color(0xFFFFB8A8),
      opacity: 0.6 * alpha * p,
      blur: 18,
      strokeWidth: 22,
    );
    
    // 4. 最内層（白、最も高温、ボタンに最も近い）
    _drawShockwave(
      canvas: canvas,
      centerX: centerX,
      startY: buttonBottomY + 20 * p,
      width: 180 * p,
      curveDepth: 30 * p,
      color: Colors.white,
      opacity: 0.8 * alpha * p,
      blur: 12,
      strokeWidth: 18,
    );
    
    // 5. コア（ボタン直下の最も明るい部分）
    _drawCore(
      canvas: canvas,
      centerX: centerX,
      y: buttonBottomY + 10 * p,
      width: 120 * p,
      height: 40 * p,
      opacity: alpha * p,
    );
  }

  /// 弓状の衝撃波を描画
  void _drawShockwave({
    required Canvas canvas,
    required double centerX,
    required double startY,
    required double width,
    required double curveDepth,
    required Color color,
    required double opacity,
    required double blur,
    required double strokeWidth,
  }) {
    if (opacity <= 0 || width <= 0) return;
    
    // 弓状のパス（下に凸）
    final path = Path();
    final halfWidth = width / 2;
    
    path.moveTo(centerX - halfWidth, startY);
    path.quadraticBezierTo(
      centerX,
      startY + curveDepth,  // 下に凸
      centerX + halfWidth,
      startY,
    );
    
    // 太いストローク + ブラーで「層」を表現
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color.withOpacity(opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    
    canvas.drawPath(path, paint);
    
    // 中心部をより明るく
    final corePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.4
      ..strokeCap = StrokeCap.round
      ..color = color.withOpacity(opacity * 1.2)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur * 0.5);
    
    canvas.drawPath(path, corePaint);
  }

  /// ボタン直下のコア（最も明るい部分）
  void _drawCore({
    required Canvas canvas,
    required double centerX,
    required double y,
    required double width,
    required double height,
    required double opacity,
  }) {
    if (opacity <= 0) return;
    
    final rect = Rect.fromCenter(
      center: Offset(centerX, y + height / 2),
      width: width,
      height: height,
    );
    
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(centerX, y),
        width / 2,
        [
          Colors.white.withOpacity(0.95 * opacity),
          Colors.white.withOpacity(0.6 * opacity),
          const Color(0xFFFFE8E0).withOpacity(0.3 * opacity),
          Colors.transparent,
        ],
        [0.0, 0.3, 0.6, 1.0],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _AtmosphericEntryPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.intensity != intensity;
  }
}
