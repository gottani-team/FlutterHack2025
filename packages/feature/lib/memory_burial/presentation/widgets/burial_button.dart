import 'package:flutter/material.dart';

/// 埋葬ボタンの状態
enum BurialButtonState {
  /// 初期状態（下矢印）
  initial,

  /// 処理中（下矢印 + グロー）
  processing,

  /// 完了（クリスタルアイコン）
  completed,
}

/// カプセル型の埋葬ボタン
class BurialButton extends StatelessWidget {
  const BurialButton({
    super.key,
    required this.state,
    required this.onPressed,
    this.isEnabled = true,
  });

  final BurialButtonState state;
  final VoidCallback? onPressed;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled && state == BurialButtonState.initial ? onPressed : null,
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    // ボタンの色
    final gradientColors = switch (state) {
      BurialButtonState.initial => [
          const Color(0xFF8BCAE8),
          const Color(0xFFA4D4F4),
        ],
      BurialButtonState.processing => [
          const Color(0xFF7AB8D9),
          const Color(0xFFB8A4E8), // 紫がかった色
        ],
      BurialButtonState.completed => [
          const Color(0xFFA4A4E8),
          const Color(0xFFD4A4E8), // 紫グラデーション
        ],
    };

    // 処理中の場合はグローを強める
    final shadows = state == BurialButtonState.processing
        ? [
            BoxShadow(
              color: const Color(0xFF7AB8D9).withOpacity(0.6),
              blurRadius: 30,
              spreadRadius: 5,
            ),
            BoxShadow(
              color: const Color(0xFF5A9EC4).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ]
        : [
            BoxShadow(
              color: const Color(0xFF5A9EC4).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ];

    return Container(
      width: 80,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
        border: Border.all(
          color: const Color(0xFF5A9EC4).withOpacity(0.5),
          width: 2,
        ),
        boxShadow: shadows,
      ),
      child: Center(
        child: _buildIcon(),
      ),
    );
  }

  Widget _buildIcon() {
    return switch (state) {
      BurialButtonState.initial || BurialButtonState.processing => const Icon(
          Icons.arrow_downward,
          color: Colors.white,
          size: 32,
        ),
      BurialButtonState.completed => CustomPaint(
          size: const Size(40, 40),
          painter: CrystalIconPainter(),
        ),
    };
  }
}

/// クリスタルアイコンを描画するPainter
class CrystalIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // ダイヤモンド形状
    final path = Path()
      ..moveTo(centerX, 0) // 上頂点
      ..lineTo(size.width * 0.85, centerY * 0.6) // 右上
      ..lineTo(size.width, centerY) // 右
      ..lineTo(centerX, size.height) // 下頂点
      ..lineTo(0, centerY) // 左
      ..lineTo(size.width * 0.15, centerY * 0.6) // 左上
      ..close();

    canvas.drawPath(path, paint);

    // 内部の線
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
