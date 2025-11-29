import 'package:core/data/providers.dart';
import 'package:core/domain/common/result.dart';
import 'package:core/domain/repositories/sublimation_repository.dart';
import 'package:core/presentation/widgets/glass_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/memory_burial_providers.dart';
import '../widgets/animated_burial_button.dart';
import '../widgets/background_effects.dart';
import '../widgets/crystal_display.dart';
import '../widgets/input_badges.dart';
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
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _nicknameFocusNode = FocusNode();
  final FocusNode _textFocusNode = FocusNode();
  final GlobalKey _buttonKey = GlobalKey();

  _ScreenPhase _phase = _ScreenPhase.input;
  String _animatingText = '';
  EvaluationResult? _evaluationResult;
  bool _isConfirming = false;

  late AnimationController _ringAnimationController;

  @override
  void initState() {
    super.initState();

    _ringAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // 画面表示後にニックネーム欄にフォーカス
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nicknameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _textController.dispose();
    _nicknameFocusNode.dispose();
    _textFocusNode.dispose();
    _ringAnimationController.dispose();
    super.dispose();
  }

  /// テキスト状態に応じたボタンフェーズを計算
  ButtonPhase _getButtonPhase(
    String nickname,
    String memoryText,
    bool isButtonEnabled,
  ) {
    if (_phase == _ScreenPhase.animating) {
      return ButtonPhase.processing;
    }

    // ニックネーム必須 + テキスト10文字以上
    if (nickname.isNotEmpty && memoryText.length >= 10) {
      return ButtonPhase.ready;
    } else {
      return ButtonPhase.typing;
    }
  }

  /// 埋葬処理を実行
  Future<void> _handleBuryAction() async {
    final nickname = ref.read(nicknameProvider);
    final memoryText = ref.read(memoryTextProvider);
    if (nickname.isEmpty || memoryText.length < 10 || memoryText.length > 500)
      return;

    // キーボードを閉じる
    _nicknameFocusNode.unfocus();
    _textFocusNode.unfocus();

    setState(() {
      _animatingText = memoryText;
      _phase = _ScreenPhase.animating;
      _evaluationResult = null;
    });

    // 評価を開始（バックグラウンドで実行）
    final sublimationRepository = ref.read(sublimationRepositoryProvider);
    sublimationRepository
        .evaluate(
      secretText: memoryText,
    )
        .then((evaluationResult) {
      // 評価結果を処理
      switch (evaluationResult) {
        case Success(value: final result):
          if (mounted) {
            setState(() {
              _evaluationResult = result;
            });
            // アニメーションが完了していれば、すぐにクリスタル表示画面へ
            if (_phase == _ScreenPhase.animating) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted && _evaluationResult != null) {
                  setState(() {
                    _phase = _ScreenPhase.crystalDisplay;
                  });
                }
              });
            }
          }
          break;
        case Failure(error: final failure):
          if (mounted) {
            _showErrorDialog(
              '評価に失敗しました: ${failure.message ?? '不明なエラー'}',
            );
            _resetToInput();
          }
          break;
      }
    });
  }

  /// アニメーション完了時の処理
  void _onAnimationComplete() {
    // 評価結果が取得できていれば、クリスタル表示画面へ
    if (_evaluationResult != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _phase = _ScreenPhase.crystalDisplay;
          });
        }
      });
    } else {
      // 評価結果がまだ取得できていない場合は待機
      // 評価が完了するまで待つ
    }
  }

  /// 埋めるボタンを押した時の処理
  Future<void> _handleConfirm() async {
    if (_evaluationResult == null || _isConfirming) return;

    final nickname = ref.read(nicknameProvider);
    final memoryText = ref.read(memoryTextProvider);

    setState(() {
      _isConfirming = true;
    });

    final sublimationRepository = ref.read(sublimationRepositoryProvider);
    final confirmResult = await sublimationRepository.confirm(
      secretText: memoryText,
      evaluation: _evaluationResult!,
      nickname: nickname,
    );

    switch (confirmResult) {
      case Success():
        if (mounted) {
          // 成功したらMapに戻る
          context.pop();
        }
        break;
      case Failure(error: final failure):
        if (mounted) {
          setState(() {
            _isConfirming = false;
          });
          _showErrorDialog(
            '埋める処理に失敗しました: ${failure.message ?? '不明なエラー'}',
          );
        }
        break;
    }
  }

  /// キャンセルボタンを押した時の処理
  void _handleCancel() {
    _resetToInput();
  }

  /// 入力画面にリセット
  void _resetToInput() {
    ref.read(nicknameProvider.notifier).clear();
    ref.read(memoryTextProvider.notifier).clear();
    _nicknameController.clear();
    _textController.clear();

    setState(() {
      _phase = _ScreenPhase.input;
      _animatingText = '';
      _evaluationResult = null;
      _isConfirming = false;
    });

    // キーボードを再表示
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _nicknameFocusNode.requestFocus();
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
    final nickname = ref.watch(nicknameProvider);
    final memoryText = ref.watch(memoryTextProvider);
    final isButtonEnabled = ref.watch(isButtonEnabledProvider);

    // 背景のリングは入力画面では非表示（ボタン周囲の円弧で表示する）
    final showBackgroundRings = _phase == _ScreenPhase.crystalDisplay;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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

          // Glass App Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: GlassAppBarWidget(
              title: 'HIMITSU no SECRET',
              icon: Icons.close,
              onIconPressed: () {
                if (Navigator.of(context).canPop()) {
                  context.pop();
                }
              },
            ),
          ),

          // メインコンテンツ
          SafeArea(
            child: _buildContent(
              nickname: nickname,
              memoryText: memoryText,
              isButtonEnabled: isButtonEnabled,
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
    required String nickname,
    required String memoryText,
    required bool isButtonEnabled,
  }) {
    // クリスタル画面は別処理
    if (_phase == _ScreenPhase.crystalDisplay) {
      return _buildCrystalScreen();
    }

    // 入力画面とアニメーション画面は同じボタンを共有
    final buttonPhase = _getButtonPhase(nickname, memoryText, isButtonEnabled);

    // テキスト色
    const textColor = Color(0xFF1A1A2E);
    final placeholderColor = textColor.withOpacity(0.3);

    return Stack(
      children: [
        // 入力エリア
        if (_phase == _ScreenPhase.input)
          Positioned(
            top: MediaQuery.of(context).padding.top + 25, // AppBar の下
            left: 32,
            right: 32,
            bottom: MediaQuery.of(context).viewInsets.bottom + 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ニックネーム欄
                _buildNicknameField(
                  nickname: nickname,
                  textColor: textColor,
                  placeholderColor: placeholderColor,
                ),

                const SizedBox(height: 24),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTextField(
                        memoryText: memoryText,
                        textColor: textColor,
                        placeholderColor: placeholderColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // ボタン（エフェクトは内部に組み込み）
        AnimatedPositioned(
          key: _buttonKey,
          duration: _phase == _ScreenPhase.animating
              ? const Duration(milliseconds: 1500)
              : const Duration(milliseconds: 50),
          curve: Curves.easeOutCubic,
          left: 0,
          right: 0,
          bottom: _phase == _ScreenPhase.animating
              ? -86.0 // エフェクト用にさらに下に
              : (MediaQuery.of(context).viewInsets.bottom - 100)
                  .clamp(14.0, double.infinity),
          child: Center(
            child: AnimatedBurialButton(
              phase: buttonPhase,
              textLength: memoryText.length,
              onPressed:
                  buttonPhase == ButtonPhase.ready ? _handleBuryAction : null,
            ),
          ),
        ),
      ],
    );
  }

  /// ニックネーム入力欄
  Widget _buildNicknameField({
    required String nickname,
    required Color textColor,
    required Color placeholderColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _nicknameController,
            focusNode: _nicknameFocusNode,
            maxLength: 20,
            maxLines: 1,
            cursorColor: textColor,
            cursorWidth: 2.0,
            showCursor: true,
            textInputAction: TextInputAction.next,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
            inputFormatters: [
              LengthLimitingTextInputFormatter(20),
            ],
            decoration: InputDecoration(
              hintText: 'あなたのニックネーム',
              hintStyle: TextStyle(
                color: placeholderColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              counterText: '',
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              ref.read(nicknameProvider.notifier).update(value);
            },
            onSubmitted: (_) {
              // エンターを押したらテキスト入力欄にフォーカス移動
              _textFocusNode.requestFocus();
            },
          ),
        ),
        const SizedBox(width: 8),
        // 必須バッジまたはチェックマーク
        if (nickname.isEmpty) const RequiredBadge() else const CheckBadge(),
      ],
    );
  }

  /// テキスト入力欄
  Widget _buildTextField({
    required String memoryText,
    required Color textColor,
    required Color placeholderColor,
  }) {
    return TextField(
      controller: _textController,
      focusNode: _textFocusNode,
      maxLength: 500,
      maxLines: null,
      minLines: 5,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      cursorColor: textColor,
      cursorWidth: 2.0,
      showCursor: true,
      style: TextStyle(
        color: textColor,
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
          color: placeholderColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        border: InputBorder.none,
        counterText: '',
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
      onChanged: (value) {
        ref.read(memoryTextProvider.notifier).update(value);
      },
    );
  }

  /// クリスタル表示画面
  Widget _buildCrystalScreen() {
    if (_evaluationResult == null) {
      // 評価結果がまだ取得できていない場合はローディング表示
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        // クリスタル表示
        const CrystalDisplay(
          showAnalyzing: false,
          onAnalysisComplete: null,
        ),

        // カルマPT表示とボタン
        Positioned.fill(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // カルマPT表示
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '獲得予定カルマ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_evaluationResult!.karmaToEarn} PT',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _evaluationResult!.emotionDisplayName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // ボタン
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    children: [
                      // キャンセルボタン
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isConfirming ? null : _handleCancel,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'キャンセル',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 埋めるボタン
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isConfirming ? null : _handleConfirm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFFFF3C00),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isConfirming
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  '埋める',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
