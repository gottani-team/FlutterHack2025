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

  void _log(String message) {
    setState(() {
      _logs.add('[${DateTime.now().toIso8601String().substring(11, 19)}] $message');
    });
    debugPrint(message);
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

      // テスト用ユーザーID（実際のアプリでは認証後のUID）
      const creatorUserId = 'test-creator-user';
      const decipherUserId = 'test-decipher-user';

      _log('=== 解読フロー統合テスト開始 ===');

      // 1. 作成者ユーザーを準備
      _log('1. 作成者ユーザーを準備...');
      final creatorResult = await userRepo.getOrCreateUser(
        userId: creatorUserId,
        initialKarma: 0,
      );
      switch (creatorResult) {
        case Success(value: final user):
          _log('   ✅ 作成者: karma=${user.currentKarma}');
        case Failure(error: final e):
          _log('   ❌ 作成者準備失敗: $e');
          return;
      }

      // 2. 解読者ユーザーを準備（カルマ100で開始）
      _log('2. 解読者ユーザーを準備 (初期カルマ=100)...');
      // ユーザーを作成
      final decipherCreateResult = await userRepo.getOrCreateUser(
        userId: decipherUserId,
        initialKarma: 0,
      );
      // カルマを100に設定
      switch (decipherCreateResult) {
        case Success(value: final user):
          final neededKarma = 100 - user.currentKarma;
          if (neededKarma > 0) {
            await userRepo.addKarma(userId: decipherUserId, amount: neededKarma);
          }
        case Failure(error: final e):
          _log('   ❌ 解読者作成失敗: $e');
          return;
      }
      final decipherUserResult = await userRepo.getUser(decipherUserId);
      switch (decipherUserResult) {
        case Success(value: final user):
          _log('   ✅ 解読者: karma=${user?.currentKarma ?? 0}');
        case Failure(error: final e):
          _log('   ❌ 解読者準備失敗: $e');
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
          _log('   ✅ 評価完了: ${eval.aiMetadata.emotionType.displayName}, score=${eval.aiMetadata.score}');
          _log('   ✅ レアリティ: ${eval.aiMetadata.rarityDisplayName}');
          _log('   ✅ 画像URL: ${eval.imageUrl}');

          _log('   3b. クリスタルを確定...');
          final confirmResult = await sublimationRepo.confirm(
            secretText: secretText,
            evaluation: eval,
            userId: creatorUserId,
            nickname: 'テスト作成者',
          );
          switch (confirmResult) {
            case Success(value: final result):
              crystalId = result.crystal.id;
              _log('   ✅ クリスタル作成: id=$crystalId, karma獲得=${result.karmaAwarded}');
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
      final availableResult = await crystalRepo.getAvailableCrystals(limit: 10);
      switch (availableResult) {
        case Success(value: final crystals):
          _log('   ✅ 取得件数: ${crystals.length}');
          for (final c in crystals) {
            _log('      - ${c.id}: status=${c.status}, karma=${c.karmaValue}, emotion=${c.aiMetadata.emotionType.displayName}');
          }
        case Failure(error: final e):
          _log('   ❌ クリスタル取得失敗: $e');
      }

      // 5. 解読を実行
      _log('5. クリスタルを解読...');
      final decipherResult = await deciphermentRepo.decipher(
        crystalId: crystalId,
        userId: decipherUserId,
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
            _log('   ✅ status=${crystal.status}, decipheredBy=${crystal.decipheredBy}');
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
        userId: decipherUserId,
      );
      switch (reDecipherResult) {
        case Success(value: _):
          _log('   ⚠️ 予期せず成功（バグ？）');
        case Failure(error: final e):
          _log('   ✅ 期待通り失敗: $e');
      }

      // 8. ジャーナルを確認
      _log('8. ジャーナル（収集クリスタル）を確認...');
      final journalResult = await journalRepo.getCollectedCrystals(
        userId: decipherUserId,
        limit: 10,
      );
      switch (journalResult) {
        case Success(value: final collected):
          _log('   ✅ 収集件数: ${collected.length}');
          for (final c in collected) {
            _log('      - ${c.id}: "${c.secretText.substring(0, 20)}...", cost=${c.karmaCost}');
          }
        case Failure(error: final e):
          _log('   ❌ ジャーナル取得失敗: $e');
      }

      // 9. 解読者のカルマ残高を確認
      _log('9. 解読者のカルマ残高を確認...');
      final karmaResult = await userRepo.getKarma(decipherUserId);
      switch (karmaResult) {
        case Success(value: final karma):
          _log('   ✅ 残高: $karma');
        case Failure(error: final e):
          _log('   ❌ カルマ取得失敗: $e');
      }

      // 10. カルマ不足テスト
      _log('10. カルマ不足テスト...');
      // カルマを消費して0にする（現在の残高を取得して減算）
      final currentKarmaResult = await userRepo.getKarma(decipherUserId);
      switch (currentKarmaResult) {
        case Success(value: final currentKarma):
          if (currentKarma > 0) {
            await userRepo.subtractKarma(userId: decipherUserId, amount: currentKarma);
          }
        case Failure(error: _):
          break;
      }
      // 新しいクリスタルを作成
      final eval2 = await sublimationRepo.evaluate(secretText: 'もう一つのテスト秘密です。これも誰にも言えません。');
      switch (eval2) {
        case Success(value: final e):
          final confirm2 = await sublimationRepo.confirm(
            secretText: 'もう一つのテスト秘密です。これも誰にも言えません。',
            evaluation: e,
            userId: creatorUserId,
            nickname: 'テスト作成者2',
          );
          switch (confirm2) {
            case Success(value: final r):
              final insufficientResult = await deciphermentRepo.decipher(
                crystalId: r.crystal.id,
                userId: decipherUserId,
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
