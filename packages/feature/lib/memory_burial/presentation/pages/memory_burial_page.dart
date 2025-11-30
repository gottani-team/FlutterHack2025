import 'package:core/data/providers.dart';
import 'package:core/domain/common/result.dart';
import 'package:core/domain/entities/crystal_tier.dart';
import 'package:core/domain/repositories/sublimation_repository.dart';
import 'package:core/presentation/widgets/glass_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/memory_burial_providers.dart';
import '../widgets/animated_burial_button.dart';
import '../widgets/background_effects.dart';
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
  late AnimationController _ptAnimationController;
  late AnimationController _crystalScaleController;
  late Animation<double> _crystalScaleAnimation;
  int _displayedPtValue = 0;

  // 終了アニメーション用
  late AnimationController _exitUiFadeController;
  late AnimationController _exitCrystalController;
  late Animation<double> _exitCrystalScaleAnimation;
  late Animation<double> _exitCrystalPositionAnimation;
  bool _isPlayingExitAnimation = false;

  // 入場アニメーション用（クリスタル表示画面）
  late AnimationController _entryCrystalController;
  late Animation<double> _entryCrystalPositionAnimation;
  late AnimationController _entryUiFadeController;

  /// PTカウントアップアニメーションを有効にするか
  static const bool _enablePtAnimation = true;

  @override
  void initState() {
    super.initState();

    _ringAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _ptAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // クリスタル画像のグレードアップアニメーション（パルス効果）
    _crystalScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // 1.0→0.85→1.15→1.0のパルス効果（一瞬縮んでから大きくなって戻る）
    _crystalScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.85)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.85, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
    ]).animate(_crystalScaleController);

    // 終了アニメーション: UIフェードアウト
    _exitUiFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // 終了アニメーション: クリスタルの拡大と飛行
    _exitCrystalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _exitCrystalScaleAnimation = TweenSequence<double>([
      // 最初の30%で1.0→1.3に拡大（グワァっと）
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
      // 残りの70%で1.3→0.8に縮小しながら飛んでいく
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 0.8)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 70,
      ),
    ]).animate(_exitCrystalController);

    _exitCrystalPositionAnimation = TweenSequence<double>([
      // 最初の30%は待機（拡大中）
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.0),
        weight: 30,
      ),
      // 残りの70%で上に飛んでいく
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -1.5)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 70,
      ),
    ]).animate(_exitCrystalController);

    // 入場アニメーション: クリスタルが下からスライドイン
    _entryCrystalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _entryCrystalPositionAnimation = Tween<double>(
      begin: 1.0, // 画面下から
      end: 0.0, // 表示位置へ
    ).animate(
      CurvedAnimation(
        parent: _entryCrystalController,
        curve: Curves.easeOutCubic,
      ),
    );

    // 入場アニメーション: 他の要素がフェードイン
    _entryUiFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

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
    _ptAnimationController.dispose();
    _crystalScaleController.dispose();
    _entryCrystalController.dispose();
    _entryUiFadeController.dispose();
    _exitUiFadeController.dispose();
    _exitCrystalController.dispose();
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
    if (nickname.isEmpty || memoryText.length < 10 || memoryText.length > 250)
      return;

    // 先にフェーズを変更（animating中のdurationを適用させるため）
    setState(() {
      _animatingText = memoryText;
      _phase = _ScreenPhase.animating;
      _evaluationResult = null;
    });

    // フェーズ変更後にキーボードを閉じる
    _nicknameFocusNode.unfocus();
    _textFocusNode.unfocus();

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
            // PTカウントアップアニメーション開始
            _startPtAnimation(result.karmaToEarn);
            // クリスタル画像の拡大アニメーション開始
            _crystalScaleController.forward(from: 0);
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
    // レスポンスの有無に関わらず、アニメーション完了で少し待ってからクリスタル表示画面へ遷移
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _phase = _ScreenPhase.crystalDisplay;
        });
        // 入場アニメーションを開始
        _startEntryAnimation();
      }
    });
  }

  /// クリスタル表示画面の入場アニメーションを開始
  void _startEntryAnimation() {
    // クリスタルが下からスライドイン
    _entryCrystalController.forward(from: 0);

    // クリスタル到着後、他の要素がフェードイン
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _entryUiFadeController.forward(from: 0);
      }
    });
  }

  /// PTカウントアップアニメーション開始
  void _startPtAnimation(int targetValue) {
    if (_enablePtAnimation) {
      // アニメーションで表示
      _ptAnimationController.reset();
      _ptAnimationController.addListener(() {
        if (mounted) {
          setState(() {
            _displayedPtValue =
                (targetValue * _ptAnimationController.value).round();
          });
        }
      });
      _ptAnimationController.forward();
    } else {
      // 即座に表示（従来の動作）
      setState(() {
        _displayedPtValue = targetValue;
      });
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
          // 成功したら終了アニメーションを開始
          _startExitAnimation();
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

  /// 終了アニメーションを開始
  void _startExitAnimation() {
    setState(() {
      _isPlayingExitAnimation = true;
    });

    // 1. UI要素（ポイント、ボタン、AppBar）をフェードアウト
    _exitUiFadeController.forward();

    // 2. UIフェードアウト完了後、クリスタルのアニメーション開始
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _exitCrystalController.forward();
      }
    });

    // 3. 全アニメーション完了後に画面遷移
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        context.pop();
      }
    });
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
    _ptAnimationController.reset();
    _crystalScaleController.reset();
    _exitUiFadeController.reset();
    _exitCrystalController.reset();
    _entryCrystalController.reset();
    _entryUiFadeController.reset();

    setState(() {
      _phase = _ScreenPhase.input;
      _animatingText = '';
      _evaluationResult = null;
      _isConfirming = false;
      _displayedPtValue = 0;
      _isPlayingExitAnimation = false;
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

    // 背景のリングは待ち状態（crystalDisplay + レスポンス未着）で表示
    final isLoadingInCrystalScreen =
        _phase == _ScreenPhase.crystalDisplay && _evaluationResult == null;
    final showBackgroundRings = isLoadingInCrystalScreen;

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

          // Glass App Bar（終了アニメーション中はフェードアウト）
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: AnimatedBuilder(
              animation: _exitUiFadeController,
              builder: (context, child) {
                return Opacity(
                  opacity: 1.0 - _exitUiFadeController.value,
                  child: child,
                );
              },
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
          ),

          // メインコンテンツ
          SafeArea(
            bottom: false,
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
              ? const Duration(milliseconds: 2500) // 文字アニメーションと同期
              : const Duration(milliseconds: 50),
          curve: Curves.easeOut, // ease-outで画面外へ
          left: 0,
          right: 0,
          bottom: _phase == _ScreenPhase.animating
              ? -550.0 // 画面外に完全に抜ける
              : (MediaQuery.of(context).viewInsets.bottom - 200)
                  .clamp(-200.0, double.infinity),
          child: Center(
            child: AnimatedBurialButton(
              phase: buttonPhase,
              textLength: memoryText.length,
              isEnabled: isButtonEnabled,
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
      maxLength: 250,
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
        LengthLimitingTextInputFormatter(250),
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

  /// カルマ値に応じたクリスタル画像パスを取得
  String _getCrystalImagePath(int karmaValue) {
    return CrystalTier.fromKarmaValue(karmaValue).imageUrl;
  }

  /// PT値をフォーマット（カンマ区切り）
  String _formatPtValue(int value) {
    if (value == 0) return '000,000';
    final str = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  /// クリスタル表示画面
  Widget _buildCrystalScreen() {
    final isLoading = _evaluationResult == null;
    final ptValue = isLoading ? '000,000' : _formatPtValue(_displayedPtValue);

    return Stack(
      children: [
        // 中央コンテンツ（固定位置）
        Positioned.fill(
          child: Column(
            children: [
              const Spacer(flex: 4),

              // クリスタル画像領域（入場・グレードアップ・終了アニメーション対応）
              AnimatedBuilder(
                animation: Listenable.merge([
                  _entryCrystalController,
                  _crystalScaleAnimation,
                  _exitCrystalController,
                ]),
                builder: (context, child) {
                  final screenHeight = MediaQuery.of(context).size.height;

                  // 入場アニメーション（下からスライドイン）
                  final entryOffset =
                      _entryCrystalPositionAnimation.value * screenHeight * 0.5;

                  // グレードアップアニメーション（APIレスポンス後の「ブァっ」）
                  // 評価結果がない時は1.0、ある時はアニメーション値を使用
                  final gradeUpScale = _evaluationResult != null
                      ? _crystalScaleAnimation.value
                      : 1.0;

                  // 終了アニメーション中の場合
                  final exitScale = _isPlayingExitAnimation
                      ? _exitCrystalScaleAnimation.value
                      : 1.0;
                  final exitOffset = _isPlayingExitAnimation
                      ? _exitCrystalPositionAnimation.value * screenHeight
                      : 0.0;

                  return Transform.translate(
                    offset: Offset(0, entryOffset + exitOffset),
                    child: Transform.scale(
                      scale: gradeUpScale * exitScale,
                      child: child,
                    ),
                  );
                },
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Image.asset(
                      // 入場時は最小tier（karmaValue=0）、評価結果が来たら本来のtier
                      _getCrystalImagePath(
                        _evaluationResult?.karmaToEarn ?? 0,
                      ),
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // PT表示（入場アニメーション後にフェードイン、終了時はフェードアウト）
              AnimatedBuilder(
                animation: Listenable.merge([
                  _entryUiFadeController,
                  _exitUiFadeController,
                ]),
                builder: (context, child) {
                  // 入場時のフェードイン × 終了時のフェードアウト
                  final entryOpacity = _entryUiFadeController.value;
                  final exitOpacity = 1.0 - _exitUiFadeController.value;
                  return Opacity(
                    opacity: entryOpacity * exitOpacity,
                    child: child,
                  );
                },
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: ptValue,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E)
                              .withOpacity(isLoading ? 0.4 : 0.8),
                          letterSpacing: 1.5,
                        ),
                      ),
                      TextSpan(
                        text: 'P',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1A1A2E)
                              .withOpacity(isLoading ? 0.3 : 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 解析中テキスト領域（入場アニメーション後にフェードイン）
              AnimatedBuilder(
                animation: _entryUiFadeController,
                builder: (context, child) {
                  return Opacity(
                    opacity:
                        _entryUiFadeController.value * (isLoading ? 1.0 : 0.0),
                    child: child,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '解析中...',
                    style: TextStyle(
                      fontSize: 18,
                      color: const Color(0xFF1A1A2E).withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),

        // ボタン（入場アニメーション後にフェードイン、終了時はフェードアウト）
        Positioned(
          left: 24,
          right: 24,
          bottom: 32,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _entryUiFadeController,
              _exitUiFadeController,
            ]),
            builder: (context, child) {
              // 入場時のフェードイン × 終了時のフェードアウト
              final entryOpacity = _entryUiFadeController.value;
              final exitOpacity = 1.0 - _exitUiFadeController.value;
              return Opacity(
                opacity: entryOpacity * exitOpacity,
                child: child,
              );
            },
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 埋めるボタン（常に同じスペースを確保、表示/非表示を切り替え）
                  AnimatedOpacity(
                    opacity: isLoading ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: isLoading ? 0 : 64,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading || _isConfirming
                                ? null
                                : _handleConfirm,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFFFF3C00),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
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
                      ),
                    ),
                  ),
                  // キャンセルボタン（グラスモーフィズム風、常に表示）
                  SizedBox(
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isConfirming ? null : _handleCancel,
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'キャンセル',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1A1A2E)
                                        .withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
