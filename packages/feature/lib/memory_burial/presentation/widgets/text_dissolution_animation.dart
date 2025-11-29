import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 文字バラバラ吸い込みアニメーション
///
/// 入力テキストの各文字が画面上に散らばり、
/// 下中央のボタンに向かって吸い込まれていくアニメーション
class TextDissolutionAnimation extends StatefulWidget {
  const TextDissolutionAnimation({
    super.key,
    required this.text,
    required this.onComplete,
    this.duration = const Duration(milliseconds: 4000),
  });

  /// 分解するテキスト
  final String text;

  /// アニメーション完了時のコールバック
  final VoidCallback onComplete;

  /// アニメーションの長さ
  final Duration duration;

  @override
  State<TextDissolutionAnimation> createState() =>
      _TextDissolutionAnimationState();
}

class _TextDissolutionAnimationState extends State<TextDissolutionAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_CharacterData> _characters;
  final math.Random _random = math.Random(42);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _initializeCharacters();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    // アニメーション開始
    _controller.forward();
  }

  void _initializeCharacters() {
    final chars = widget.text.split('');
    _characters = [];

    for (var i = 0; i < chars.length; i++) {
      final char = chars[i];
      if (char == ' ' || char == '\n') continue;

      _characters.add(
        _CharacterData(
          character: char,
          index: i,
          totalCount: chars.length,
          random: _random,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // 画面の一番下の中央
    final targetPosition = Offset(screenSize.width / 2, screenSize.height + 50);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _DissolutionPainter(
            characters: _characters,
            progress: _controller.value,
            targetPosition: targetPosition,
            screenSize: screenSize,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// 各文字のデータを保持するクラス
class _CharacterData {
  _CharacterData({
    required this.character,
    required this.index,
    required this.totalCount,
    required math.Random random,
  }) {
    // 文字ごとにランダムな散らばり位置を計算
    scatterAngle = random.nextDouble() * 2 * math.pi;
    scatterDistance = 50 + random.nextDouble() * 150;
    rotationSpeed = (random.nextDouble() - 0.5) * 4;
    delay = (index / totalCount) * 0.2;
    initialRotation = random.nextDouble() * math.pi * 2;
  }

  final String character;
  final int index;
  final int totalCount;

  late final double scatterAngle;
  late final double scatterDistance;
  late final double rotationSpeed;
  late final double delay;
  late final double initialRotation;
}

/// 文字の散らばりと吸い込みを描画するPainter
class _DissolutionPainter extends CustomPainter {
  _DissolutionPainter({
    required this.characters,
    required this.progress,
    required this.targetPosition,
    required this.screenSize,
  });

  final List<_CharacterData> characters;
  final double progress;
  final Offset targetPosition;
  final Size screenSize;

  @override
  void paint(Canvas canvas, Size size) {
    for (final charData in characters) {
      _drawCharacter(canvas, charData);
    }
  }

  void _drawCharacter(Canvas canvas, _CharacterData charData) {
    // 各文字の進行度を計算（遅延を考慮）
    final adjustedProgress =
        ((progress - charData.delay) / (1.0 - charData.delay)).clamp(0.0, 1.0);

    if (adjustedProgress <= 0) return;

    // フェーズ1: 散らばり (0.0 ~ 0.3)
    // フェーズ2: 浮遊 (0.3 ~ 0.6)
    // フェーズ3: 吸い込み (0.6 ~ 1.0)

    // 初期位置（テキストが表示されていた位置付近）
    final row = charData.index ~/ 15;
    final col = charData.index % 15;
    final startX = 30.0 + col * 22.0;
    final startY = 80.0 + row * 30.0;
    final startPos = Offset(startX, startY);

    // 散らばり位置
    final scatterX =
        startX + math.cos(charData.scatterAngle) * charData.scatterDistance;
    final scatterY =
        startY + math.sin(charData.scatterAngle) * charData.scatterDistance;
    final scatterPos = Offset(
      scatterX.clamp(20.0, screenSize.width - 20),
      scatterY.clamp(50.0, screenSize.height * 0.5),
    );

    // 現在位置を計算
    Offset currentPos;
    double opacity;
    double scale;
    double rotation;

    if (adjustedProgress < 0.3) {
      // フェーズ1: 散らばり
      final phaseProgress = adjustedProgress / 0.3;
      final easedProgress = Curves.easeOutCubic.transform(phaseProgress);

      currentPos = Offset.lerp(startPos, scatterPos, easedProgress)!;
      opacity = 1.0;
      scale = 1.0 + (easedProgress * 0.2);
      rotation =
          charData.initialRotation + (easedProgress * charData.rotationSpeed);
    } else if (adjustedProgress < 0.6) {
      // フェーズ2: 浮遊
      final phaseProgress = (adjustedProgress - 0.3) / 0.3;

      // わずかに揺れる動き
      final wobbleX = math.sin(phaseProgress * math.pi * 4) * 5;
      final wobbleY = math.cos(phaseProgress * math.pi * 3) * 3;

      currentPos = Offset(
        scatterPos.dx + wobbleX,
        scatterPos.dy + wobbleY,
      );
      opacity = 1.0;
      scale = 1.2 - (phaseProgress * 0.1);
      rotation = charData.initialRotation +
          (0.3 * charData.rotationSpeed) +
          (phaseProgress * charData.rotationSpeed * 0.5);
    } else {
      // フェーズ3: 吸い込み
      final phaseProgress = (adjustedProgress - 0.6) / 0.4;
      final easedProgress = Curves.easeInQuart.transform(phaseProgress);

      currentPos = Offset.lerp(scatterPos, targetPosition, easedProgress)!;
      opacity = (1.0 - easedProgress * 1.5).clamp(0.0, 1.0);
      scale = (1.1 - easedProgress * 0.9).clamp(0.1, 1.1);
      rotation = charData.initialRotation +
          (0.8 * charData.rotationSpeed) +
          (easedProgress * math.pi * 2);
    }

    if (opacity <= 0) return;

    // テキストを描画
    final textPainter = TextPainter(
      text: TextSpan(
        text: charData.character,
        style: TextStyle(
          fontSize: 18 * scale,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1A1A2E).withOpacity(opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(currentPos.dx, currentPos.dy);
    canvas.rotate(rotation);
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DissolutionPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// シンプルなテキスト分解アニメーション（レガシー互換）
class SimpleTextDissolutionAnimation extends StatelessWidget {
  const SimpleTextDissolutionAnimation({
    super.key,
    required this.text,
    required this.progress,
    required this.buttonCenter,
  });

  final String text;
  final double progress;
  final Offset buttonCenter;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final characters = text.split('');
    final random = math.Random(42);

    return CustomPaint(
      painter: _LegacyDissolutionPainter(
        characters: characters,
        progress: progress,
        buttonCenter: buttonCenter,
        screenSize: screenSize,
        random: random,
      ),
      size: Size.infinite,
    );
  }
}

class _LegacyDissolutionPainter extends CustomPainter {
  _LegacyDissolutionPainter({
    required this.characters,
    required this.progress,
    required this.buttonCenter,
    required this.screenSize,
    required this.random,
  });

  final List<String> characters;
  final double progress;
  final Offset buttonCenter;
  final Size screenSize;
  final math.Random random;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < characters.length; i++) {
      final char = characters[i];
      if (char == ' ' || char == '\n') continue;

      _drawChar(canvas, char, i);
    }
  }

  void _drawChar(Canvas canvas, String char, int index) {
    // 初期位置
    final row = index ~/ 15;
    final col = index % 15;
    final startX = 30.0 + col * 22.0;
    final startY = 80.0 + row * 30.0;

    // 遅延
    final delay = (index / characters.length) * 0.2;
    final charProgress = ((progress - delay) / (1.0 - delay)).clamp(0.0, 1.0);

    if (charProgress <= 0) return;

    // 散らばり角度と距離
    final scatterAngle = random.nextDouble() * 2 * math.pi;
    final scatterDistance = 50.0 + random.nextDouble() * 150;

    // 散らばり位置
    final scatterX = startX + math.cos(scatterAngle) * scatterDistance;
    final scatterY = startY + math.sin(scatterAngle) * scatterDistance;
    final scatterPos = Offset(
      scatterX.clamp(20.0, screenSize.width - 20),
      scatterY.clamp(50.0, screenSize.height * 0.5),
    );

    // フェーズに応じた位置計算
    Offset currentPos;
    double opacity;
    double scale;

    if (charProgress < 0.4) {
      // 散らばりフェーズ
      final phaseProgress = charProgress / 0.4;
      final easedProgress = Curves.easeOutCubic.transform(phaseProgress);
      currentPos =
          Offset.lerp(Offset(startX, startY), scatterPos, easedProgress)!;
      opacity = 1.0;
      scale = 1.0 + (easedProgress * 0.2);
    } else {
      // 吸い込みフェーズ
      final phaseProgress = (charProgress - 0.4) / 0.6;
      final easedProgress = Curves.easeInQuart.transform(phaseProgress);
      currentPos = Offset.lerp(scatterPos, buttonCenter, easedProgress)!;
      opacity = (1.0 - easedProgress * 1.3).clamp(0.0, 1.0);
      scale = (1.2 - easedProgress * 1.0).clamp(0.1, 1.2);
    }

    if (opacity <= 0) return;

    final rotation = charProgress * math.pi * (random.nextDouble() - 0.5) * 2;

    final textPainter = TextPainter(
      text: TextSpan(
        text: char,
        style: TextStyle(
          fontSize: 18 * scale,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1A1A2E).withOpacity(opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(currentPos.dx, currentPos.dy);
    canvas.rotate(rotation);
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LegacyDissolutionPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
