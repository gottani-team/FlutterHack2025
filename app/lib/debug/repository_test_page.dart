import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// リポジトリ統合テストページ
///
/// 解読フローを含む全APIをテストするデバッグページ。
class RepositoryTestPage extends ConsumerStatefulWidget {
  const RepositoryTestPage({super.key});

  @override
  ConsumerState<RepositoryTestPage> createState() => _RepositoryTestPageState();
}

class _RepositoryTestPageState extends ConsumerState<RepositoryTestPage> {
  final List<String> _logs = [];
  bool _isRunning = false;
  final _karmaController = TextEditingController(text: '100');
  int? _currentKarma;

  @override
  void initState() {
    super.initState();
    _refreshKarma();
  }

  @override
  void dispose() {
    _karmaController.dispose();
    super.dispose();
  }

  void _log(String message) {
    setState(() {
      _logs.add(
          '[${DateTime.now().toIso8601String().substring(11, 19)}] $message');
    });
    debugPrint(message);
  }

  Future<void> _setKarma() async {
    final amount = int.tryParse(_karmaController.text);
    if (amount == null || amount < 0) {
      _log('❌ 無効なカルマ値です');
      return;
    }

    setState(() => _isRunning = true);
    try {
      final userRepo = ref.read(userRepositoryProvider);
      final result = await userRepo.setKarma(amount: amount);

      switch (result) {
        case Success(value: final karma):
          setState(() => _currentKarma = karma);
          _log('✅ カルマを $karma に設定しました');
        case Failure(error: final e):
          _log('❌ カルマ設定失敗: $e');
      }
    } finally {
      setState(() => _isRunning = false);
    }
  }

  Future<void> _refreshKarma() async {
    final userRepo = ref.read(userRepositoryProvider);
    final result = await userRepo.getKarma();

    switch (result) {
      case Success(value: final karma):
        setState(() => _currentKarma = karma);
      case Failure():
        break;
    }
  }

  Future<void> _runDeciphermentTest() async {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
      _logs.clear();
    });

    try {
      final userRepo = ref.read(userRepositoryProvider);
      final sublimationRepo = ref.read(sublimationRepositoryProvider);
      final crystalRepo = ref.read(crystalRepositoryProvider);
      final deciphermentRepo = ref.read(deciphermentRepositoryProvider);
      final journalRepo = ref.read(journalRepositoryProvider);

      _log('=== 解読フロー統合テスト開始 ===');

      // 1. 認証（匿名認証を使用）
      _log('1. 認証を実行...');
      final authRepo = ref.read(authRepositoryProvider);
      final authResult = await authRepo.signInAnonymously();
      switch (authResult) {
        case Success(value: final session):
          _log('   ✅ 認証成功: userId=${session.id}');
        case Failure(error: final e):
          _log('   ❌ 認証失敗: $e');
          return;
      }

      // 2. ユーザーを準備（カルマ100で開始）
      _log('2. ユーザーを準備 (初期カルマ=100)...');
      final userCreateResult = await userRepo.getOrCreateCurrentUser(
        initialKarma: 0,
      );
      switch (userCreateResult) {
        case Success(value: final user):
          final neededKarma = 100 - user.currentKarma;
          if (neededKarma > 0) {
            await userRepo.addKarma(amount: neededKarma);
          }
          final karmaResult = await userRepo.getKarma();
          switch (karmaResult) {
            case Success(value: final karma):
              _log('   ✅ ユーザー準備完了: karma=$karma');
            case Failure(error: final e):
              _log('   ⚠️ カルマ取得失敗: $e');
          }
        case Failure(error: final e):
          _log('   ❌ ユーザー作成失敗: $e');
          return;
      }

      // 3. クリスタルを作成（昇華）
      _log('3. クリスタルを作成（昇華）...');
      const secretText = '誰にも言えない秘密だけど、実は毎晩ぬいぐるみに話しかけている。';

      _log('   3a. AI評価を実行...');
      final evalResult = await sublimationRepo.evaluate(secretText: secretText);
      late String crystalId;
      switch (evalResult) {
        case Success(value: final eval):
          _log(
              '   ✅ 評価完了: ${eval.aiMetadata.emotionType.displayName}, score=${eval.aiMetadata.score}');
          _log('   ✅ レアリティ: ${eval.aiMetadata.tier.displayName}');
          _log('   ✅ 画像URL: ${eval.aiMetadata.tier.imageUrl}');

          _log('   3b. クリスタルを確定...');
          final confirmResult = await sublimationRepo.confirm(
            secretText: secretText,
            evaluation: eval,
            nickname: 'テスト作成者',
          );
          switch (confirmResult) {
            case Success(value: final result):
              crystalId = result.crystal.id;
              _log(
                  '   ✅ クリスタル作成: id=$crystalId, karma獲得=${result.karmaAwarded}');
            case Failure(error: final e):
              _log('   ❌ クリスタル作成失敗: $e');
              return;
          }
        case Failure(error: final e):
          _log('   ❌ AI評価失敗: $e');
          return;
      }

      // 4. 利用可能なクリスタルを取得
      _log('4. 利用可能なクリスタルを取得...');
      final availableResult =
          await crystalRepo.getRandomAvailableCrystals(limit: 10);
      switch (availableResult) {
        case Success(value: final crystals):
          _log('   ✅ 取得件数: ${crystals.length}');
          for (final c in crystals) {
            _log(
                '      - ${c.id}: status=${c.status}, karma=${c.karmaValue}, emotion=${c.aiMetadata.emotionType.displayName}');
          }
        case Failure(error: final e):
          _log('   ❌ クリスタル取得失敗: $e');
      }

      // 5. 解読を実行
      // Note: 自分が作成したクリスタルを自分で解読するテスト
      _log('5. クリスタルを解読...');
      final decipherResult = await deciphermentRepo.decipher(
        crystalId: crystalId,
      );
      switch (decipherResult) {
        case Success(value: final result):
          _log('   ✅ 解読成功!');
          _log('      秘密: "${result.secretText}"');
          _log('      消費カルマ: ${result.karmaSpent}');
          _log('      収集クリスタルID: ${result.collectedCrystal.id}');
        case Failure(error: final e):
          _log('   ❌ 解読失敗: $e');
          return;
      }

      // 6. 解読後のクリスタル状態を確認
      _log('6. 解読後のクリスタル状態を確認...');
      final afterResult = await crystalRepo.getCrystal(crystalId);
      switch (afterResult) {
        case Success(value: final crystal):
          if (crystal != null) {
            _log(
                '   ✅ status=${crystal.status}, decipheredBy=${crystal.decipheredBy}');
          } else {
            _log('   ⚠️ クリスタルが見つかりません');
          }
        case Failure(error: final e):
          _log('   ❌ クリスタル取得失敗: $e');
      }

      // 7. 再度解読を試みる（失敗するはず）
      _log('7. 再度解読を試みる（失敗確認）...');
      final reDecipherResult = await deciphermentRepo.decipher(
        crystalId: crystalId,
      );
      switch (reDecipherResult) {
        case Success(value: _):
          _log('   ⚠️ 予期せず成功（バグ？）');
        case Failure(error: final e):
          _log('   ✅ 期待通り失敗: $e');
      }

      // 8. ジャーナルを確認
      _log('8. ジャーナル（収集クリスタル）を確認...');
      final journalResult = await journalRepo.getAllCollectedCrystals();
      switch (journalResult) {
        case Success(value: final collected):
          _log('   ✅ 収集件数: ${collected.length}');
          for (final c in collected) {
            _log(
                '      - ${c.id}: "${c.secretText.substring(0, 20)}...", cost=${c.karmaCost}');
          }
        case Failure(error: final e):
          _log('   ❌ ジャーナル取得失敗: $e');
      }

      // 9. カルマ残高を確認
      _log('9. カルマ残高を確認...');
      final karmaResult = await userRepo.getKarma();
      switch (karmaResult) {
        case Success(value: final karma):
          _log('   ✅ 残高: $karma');
        case Failure(error: final e):
          _log('   ❌ カルマ取得失敗: $e');
      }

      // 10. カルマ不足テスト
      _log('10. カルマ不足テスト...');
      // カルマを消費して0にする（現在の残高を取得して減算）
      final currentKarmaResult = await userRepo.getKarma();
      switch (currentKarmaResult) {
        case Success(value: final currentKarma):
          if (currentKarma > 0) {
            await userRepo.subtractKarma(amount: currentKarma);
          }
        case Failure(error: _):
          break;
      }
      // 新しいクリスタルを作成
      final eval2 = await sublimationRepo.evaluate(
          secretText: 'もう一つのテスト秘密です。これも誰にも言えません。');
      switch (eval2) {
        case Success(value: final e):
          final confirm2 = await sublimationRepo.confirm(
            secretText: 'もう一つのテスト秘密です。これも誰にも言えません。',
            evaluation: e,
            nickname: 'テスト作成者2',
          );
          switch (confirm2) {
            case Success(value: final r):
              final insufficientResult = await deciphermentRepo.decipher(
                crystalId: r.crystal.id,
              );
              switch (insufficientResult) {
                case Success(value: _):
                  _log('   ⚠️ カルマ0でも解読成功（バグ？）');
                case Failure(error: final err):
                  _log('   ✅ カルマ不足で期待通り失敗: $err');
              }
            case Failure(error: final err):
              _log('   ❌ クリスタル作成失敗: $err');
          }
        case Failure(error: final err):
          _log('   ❌ 評価失敗: $err');
      }

      _log('=== テスト完了 ===');
    } catch (e, st) {
      _log('❌ 予期せぬエラー: $e');
      _log(st.toString());
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repository Test'),
      ),
      body: Column(
        children: [
          // カルマ設定UI
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.orange.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '💎 カルマ設定',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    if (_currentKarma != null)
                      Text(
                        '現在: $_currentKarma',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _karmaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'カルマ値を入力',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isRunning ? null : _setKarma,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('設定'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [0, 50, 100, 500, 1000].map((value) {
                    return ActionChip(
                      label: Text('$value'),
                      onPressed: _isRunning
                          ? null
                          : () {
                              _karmaController.text = '$value';
                              _setKarma();
                            },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _isRunning ? null : _runDeciphermentTest,
              child: _isRunning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Run Decipherment Test'),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.black87,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  Color color = Colors.white;
                  if (log.contains('✅')) color = Colors.green;
                  if (log.contains('❌')) color = Colors.red;
                  if (log.contains('⚠️')) color = Colors.orange;
                  if (log.contains('===')) color = Colors.cyan;
                  return Text(
                    log,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: color,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
