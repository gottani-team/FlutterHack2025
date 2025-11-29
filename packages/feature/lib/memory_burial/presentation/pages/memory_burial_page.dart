import 'package:core/presentation/providers/location_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/memory_burial_providers.dart';
import '../providers/memory_burial_state.dart';
import '../widgets/animated_burial_button.dart';
import '../widgets/background_effects.dart';
import '../widgets/crystal_display.dart';
import '../widgets/text_dissolution_animation.dart';

/// 画面の状態
enum _ScreenPhase {
  /// テキスト入力中
  input,

  /// アニメーション中（文字が散らばって吸い込まれる）
  animating,

  /// クリスタル表示（解析中）
  crystalDisplay,
}

/// 記憶埋葬画面
class MemoryBurialPage extends ConsumerStatefulWidget {
  const MemoryBurialPage({super.key});

  @override
  ConsumerState<MemoryBurialPage> createState() => _MemoryBurialPageState();
}

class _MemoryBurialPageState extends ConsumerState<MemoryBurialPage>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _buttonKey = GlobalKey();

  _ScreenPhase _phase = _ScreenPhase.input;
  String _animatingText = '';

  late AnimationController _ringAnimationController;

  @override
  void initState() {
    super.initState();

    _ringAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // 画面表示後にキーボードを自動で表示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _ringAnimationController.dispose();
    super.dispose();
  }

  /// テキスト状態に応じたボタンフェーズを計算
  ButtonPhase _getButtonPhase(String memoryText, bool isButtonEnabled) {
    if (_phase == _ScreenPhase.animating) {
      return ButtonPhase.processing;
    }

    if (memoryText.length >= 10) {
      return ButtonPhase.ready;
    } else {
      return ButtonPhase.typing;
    }
  }

  /// 埋葬処理を実行
  Future<void> _handleBuryAction() async {
    final memoryText = ref.read(memoryTextProvider);
    if (memoryText.length < 10 || memoryText.length > 500) return;

    // キーボードを閉じる
    _focusNode.unfocus();

    setState(() {
      _animatingText = memoryText;
      _phase = _ScreenPhase.animating;
    });

    // API呼び出しを開始（バックグラウンド）
    final buryMemoryUseCase = ref.read(buryMemoryUseCaseProvider);
    final locationRepository = ref.read(locationRepositoryProvider);

    ref.read(memoryBurialNotifierProvider.notifier).buryMemory(
          memoryText,
          buryMemoryUseCase,
          locationRepository,
        );
  }

  /// アニメーション完了時の処理
  void _onAnimationComplete() {
    setState(() {
      _phase = _ScreenPhase.crystalDisplay;
    });
  }

  /// 解析完了時の処理
  void _onAnalysisComplete() {
    // TODO: マップ画面への遷移を実装
    // Navigator.of(context).pushReplacementNamed('/map');

    // 暫定: 状態をリセットして入力画面に戻る
    _resetToInput();
  }

  /// 入力画面にリセット
  void _resetToInput() {
    ref.read(memoryBurialNotifierProvider.notifier).reset();
    ref.read(memoryTextProvider.notifier).clear();
    _textController.clear();

    setState(() {
      _phase = _ScreenPhase.input;
      _animatingText = '';
    });

    // キーボードを再表示
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  /// エラーダイアログを表示
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('エラー'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetToInput();
            },
            child: const Text('閉じる'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetToInput();
              // 少し待ってからリトライ
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _handleBuryAction();
                }
              });
            },
            child: const Text('再試行'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final memoryText = ref.watch(memoryTextProvider);
    final isButtonEnabled = ref.watch(isButtonEnabledProvider);
    final burialState = ref.watch(memoryBurialNotifierProvider);

    // エラー監視
    ref.listen<MemoryBurialState>(memoryBurialNotifierProvider,
        (previous, next) {
      if (next.status == MemoryBurialStatus.error &&
          next.errorMessage != null) {
        _showErrorDialog(next.errorMessage!);
      }
    });

    // 背景のリングは入力画面では非表示（ボタン周囲の円弧で表示する）
    final showBackgroundRings = _phase == _ScreenPhase.crystalDisplay;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 背景
          AnimatedBuilder(
            animation: _ringAnimationController,
            builder: (context, child) {
              return MemoryBurialBackground(
                showRings: showBackgroundRings,
                ringAnimation: _ringAnimationController.value,
                ringCenter: null,
              );
            },
          ),

          // メインコンテンツ
          SafeArea(
            child: _buildContent(
              memoryText: memoryText,
              isButtonEnabled: isButtonEnabled,
              burialState: burialState,
            ),
          ),

          // アニメーションオーバーレイ
          if (_phase == _ScreenPhase.animating)
            Positioned.fill(
              child: IgnorePointer(
                child: TextDissolutionAnimation(
                  text: _animatingText,
                  onComplete: _onAnimationComplete,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent({
    required String memoryText,
    required bool isButtonEnabled,
    required MemoryBurialState burialState,
  }) {
    // クリスタル画面は別処理
    if (_phase == _ScreenPhase.crystalDisplay) {
      return _buildCrystalScreen();
    }

    // 入力画面とアニメーション画面は同じボタンを共有
    final buttonPhase = _getButtonPhase(memoryText, isButtonEnabled);

    return Stack(
      children: [
        // テキスト入力/表示エリア
        if (_phase == _ScreenPhase.input)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 280,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                maxLength: 500,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                cursorColor: const Color(0xFF1A1A2E),
                cursorWidth: 2.0,
                showCursor: true,
                style: const TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(500),
                ],
                decoration: InputDecoration(
                  hintText: 'あなたの言葉',
                  hintStyle: TextStyle(
                    color: const Color(0xFF1A1A2E).withOpacity(0.3),
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  counterText: '',
                ),
                onChanged: (value) {
                  ref.read(memoryTextProvider.notifier).update(value);
                },
              ),
            ),
          ),

        // ボタンエリア（常に同じウィジェット - アニメーションが途切れない）
        Positioned(
          key: _buttonKey,
          left: 0,
          right: 0,
          bottom: 14,
          child: Center(
            child: AnimatedBurialButton(
              phase: buttonPhase,
              textLength: memoryText.length,
              onPressed: buttonPhase == ButtonPhase.ready ? _handleBuryAction : null,
            ),
          ),
        ),
      ],
    );
  }

  /// クリスタル表示画面
  Widget _buildCrystalScreen() {
    return CrystalDisplay(
      showAnalyzing: true,
      onAnalysisComplete: _onAnalysisComplete,
    );
  }
}
