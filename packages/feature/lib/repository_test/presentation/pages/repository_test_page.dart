import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// リポジトリテスト画面
///
/// 新しいカルマシステムに対応した全てのCore層リポジトリのインターフェースを
/// 実際に呼び出してテストするための画面
class RepositoryTestPage extends ConsumerStatefulWidget {
  const RepositoryTestPage({super.key});

  @override
  ConsumerState<RepositoryTestPage> createState() =>
      _RepositoryTestPageState();
}

class _RepositoryTestPageState extends ConsumerState<RepositoryTestPage> {
  final _logs = <String>[];
  String? _currentUserId;
  int _currentKarma = 0;
  bool _isAnonymous = false;

  // テスト用に作成したクリスタルID
  String? _createdCrystalId;

  @override
  void initState() {
    super.initState();
    _addLog('テスト画面を初期化しました');
    _checkInitialAuthState();
  }

  Future<void> _checkInitialAuthState() async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.getCurrentSession();

    switch (result) {
      case Success(value: final session):
        setState(() {
          _currentUserId = session.id;
          _isAnonymous = session.isAnonymous;
        });
        _addLog('✅ 既存セッションを検出: ${session.id}');
        await _refreshKarma();
      case Failure():
        _addLog('ℹ️ 認証されていません - 匿名認証を実行してください');
    }
  }

  Future<void> _refreshKarma() async {
    if (_currentUserId == null) return;

    final userRepo = ref.read(userRepositoryProvider);
    final result = await userRepo.getKarma(_currentUserId!);

    switch (result) {
      case Success(value: final karma):
        setState(() {
          _currentKarma = karma;
        });
      case Failure():
        break;
    }
  }

  void _addLog(String message) {
    setState(() {
      final timestamp = DateTime.now().toString().substring(11, 19);
      final logMessage = '[$timestamp] $message';
      _logs.insert(0, logMessage);
      developer.log(logMessage, name: 'RepositoryTest');
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return '${diff.inSeconds}秒前';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}分前';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}時間前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}日前';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
    _addLog('ログをクリアしました');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repository Test (Karma System)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearLogs,
            tooltip: 'ログをクリア',
          ),
        ],
      ),
      body: Column(
        children: [
          // ユーザー情報表示
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User ID: ${_currentUserId ?? "未認証"}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_currentUserId != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Karma: $_currentKarma | Anonymous: $_isAnonymous',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),

          // テストボタン群
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 自動テストボタン
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🚀 自動テスト (Karma System)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '認証→昇華(evaluate/confirm)→クリスタル取得→解読→ジャーナル',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _runAutoTest,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('自動テスト実行'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // AuthRepository
                  _buildSectionTitle('🔐 AuthRepository'),
                  _buildTestButton('匿名認証', _testSignInAnonymously),
                  _buildTestButton('現在のセッション取得', _testGetCurrentSession),
                  _buildTestButton('サインアウト', _testSignOut),
                  const SizedBox(height: 16),

                  // UserRepository
                  _buildSectionTitle('👤 UserRepository'),
                  _buildTestButton('ユーザー情報取得', _testGetUser),
                  _buildTestButton('カルマ残高取得', _testGetKarma),
                  _buildTestButton('カルマ+10加算', _testAddKarma),
                  _buildTestButton('カルマ-5減算', _testSubtractKarma),
                  const SizedBox(height: 16),

                  // SublimationRepository
                  _buildSectionTitle('✨ SublimationRepository (昇華)'),
                  _buildTestButton('秘密を評価 (evaluate)', _testEvaluate),
                  _buildTestButton('クリスタル作成 (confirm)', _testConfirm),
                  const SizedBox(height: 16),

                  // CrystalRepository
                  _buildSectionTitle('💎 CrystalRepository'),
                  _buildTestButton('利用可能クリスタル取得', _testGetAvailableCrystals),
                  _buildTestButton('作成したクリスタル取得', _testGetCreatedCrystals),
                  _buildTestButton('クリスタル詳細取得', _testGetCrystal),
                  const SizedBox(height: 16),

                  // DeciphermentRepository
                  _buildSectionTitle('🔓 DeciphermentRepository (解読)'),
                  _buildTestButton('クリスタルを解読', _testDecipher),
                  const SizedBox(height: 16),

                  // JournalRepository
                  _buildSectionTitle('📚 JournalRepository'),
                  _buildTestButton('収集クリスタル取得', _testGetCollectedCrystals),
                  _buildTestButton('収集数取得', _testGetCollectedCount),
                ],
              ),
            ),
          ),

          // ログ表示
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  width: double.infinity,
                  color: Colors.grey.shade800,
                  child: const Text(
                    'ログ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: Text(
                          _logs[index],
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTestButton(String label, Future<void> Function() onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: () async {
          _addLog('▶ $label を実行中...');
          try {
            await onPressed();
          } catch (e) {
            _addLog('❌ エラー: $e');
          }
        },
        child: Text(label),
      ),
    );
  }

  // ========== AuthRepository Tests ==========

  Future<void> _testSignInAnonymously() async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signInAnonymously();

    switch (result) {
      case Success(value: final session):
        setState(() {
          _currentUserId = session.id;
          _isAnonymous = session.isAnonymous;
        });
        _addLog('✅ 匿名認証成功');
        _addLog('   User ID: ${session.id}');
        await _refreshKarma();
      case Failure(error: final failure):
        _addLog('❌ 匿名認証失敗: ${failure.message}');
    }
  }

  Future<void> _testGetCurrentSession() async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.getCurrentSession();

    switch (result) {
      case Success(value: final session):
        setState(() {
          _currentUserId = session.id;
          _isAnonymous = session.isAnonymous;
        });
        _addLog('✅ セッション取得成功');
        _addLog('   User ID: ${session.id}');
        await _refreshKarma();
      case Failure(error: final failure):
        _addLog('❌ セッション取得失敗: ${failure.message}');
    }
  }

  Future<void> _testSignOut() async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signOut();

    switch (result) {
      case Success():
        setState(() {
          _currentUserId = null;
          _isAnonymous = false;
          _currentKarma = 0;
        });
        _addLog('✅ サインアウト成功');
      case Failure(error: final failure):
        _addLog('❌ サインアウト失敗: ${failure.message}');
    }
  }

  // ========== UserRepository Tests ==========

  Future<void> _testGetUser() async {
    if (_currentUserId == null) {
      _addLog('❌ 先に認証してください');
      return;
    }

    final repo = ref.read(userRepositoryProvider);
    final result = await repo.getUser(_currentUserId!);

    switch (result) {
      case Success(value: final user):
        if (user != null) {
          _addLog('✅ ユーザー取得成功');
          _addLog('   ID: ${user.id}');
          _addLog('   Karma: ${user.currentKarma}');
          _addLog('   Created: ${user.createdAt}');
        } else {
          _addLog('⚠️ ユーザーが見つかりません');
        }
      case Failure(error: final failure):
        _addLog('❌ ユーザー取得失敗: ${failure.message}');
    }
  }

  Future<void> _testGetKarma() async {
    if (_currentUserId == null) {
      _addLog('❌ 先に認証してください');
      return;
    }

    final repo = ref.read(userRepositoryProvider);
    final result = await repo.getKarma(_currentUserId!);

    switch (result) {
      case Success(value: final karma):
        setState(() {
          _currentKarma = karma;
        });
        _addLog('✅ カルマ取得成功: $karma');
      case Failure(error: final failure):
        _addLog('❌ カルマ取得失敗: ${failure.message}');
    }
  }

  Future<void> _testAddKarma() async {
    if (_currentUserId == null) {
      _addLog('❌ 先に認証してください');
      return;
    }

    final repo = ref.read(userRepositoryProvider);
    final result = await repo.addKarma(
      userId: _currentUserId!,
      amount: 10,
    );

    switch (result) {
      case Success(value: final newKarma):
        setState(() {
          _currentKarma = newKarma;
        });
        _addLog('✅ カルマ加算成功: +10 → $newKarma');
      case Failure(error: final failure):
        _addLog('❌ カルマ加算失敗: ${failure.message}');
    }
  }

  Future<void> _testSubtractKarma() async {
    if (_currentUserId == null) {
      _addLog('❌ 先に認証してください');
      return;
    }

    final repo = ref.read(userRepositoryProvider);
    final result = await repo.subtractKarma(
      userId: _currentUserId!,
      amount: 5,
    );

    switch (result) {
      case Success(value: final newKarma):
        setState(() {
          _currentKarma = newKarma;
        });
        _addLog('✅ カルマ減算成功: -5 → $newKarma');
      case Failure(error: final failure):
        _addLog('❌ カルマ減算失敗: ${failure.message}');
    }
  }

  // ========== SublimationRepository Tests ==========

  // 評価結果を一時保存
  EvaluationResult? _lastEvaluationResult;
  String? _lastSecretText;

  Future<void> _testEvaluate() async {
    final repo = ref.read(sublimationRepositoryProvider);
    final secretText =
        'これは誰にも言えない秘密です。本当に恥ずかしい出来事でした。${DateTime.now()}';

    final result = await repo.evaluate(secretText: secretText);

    switch (result) {
      case Success(value: final evaluation):
        _lastEvaluationResult = evaluation;
        _lastSecretText = secretText;
        _addLog('✅ 評価成功 (Step 1)');
        _addLog('   感情: ${evaluation.emotionDisplayName}');
        _addLog('   スコア: ${evaluation.aiMetadata.score}');
        _addLog('   獲得予定カルマ: ${evaluation.karmaToEarn}');
        _addLog('   → confirmを実行してクリスタルを作成できます');
      case Failure(error: final failure):
        _addLog('❌ 評価失敗: ${failure.message}');
    }
  }

  Future<void> _testConfirm() async {
    if (_currentUserId == null) {
      _addLog('❌ 先に認証してください');
      return;
    }

    if (_lastEvaluationResult == null || _lastSecretText == null) {
      _addLog('❌ 先にevaluateを実行してください');
      return;
    }

    final repo = ref.read(sublimationRepositoryProvider);

    final result = await repo.confirm(
      secretText: _lastSecretText!,
      evaluation: _lastEvaluationResult!,
      userId: _currentUserId!,
      nickname: 'TestNickname${DateTime.now().millisecondsSinceEpoch}',
    );

    switch (result) {
      case Success(value: final sublimation):
        _createdCrystalId = sublimation.crystal.id;
        _addLog('✅ クリスタル作成成功 (Step 2)');
        _addLog('   Crystal ID: ${sublimation.crystal.id}');
        _addLog('   感情: ${sublimation.aiMetadata.emotionType.displayName}');
        _addLog('   カルマ獲得: +${sublimation.karmaAwarded}');
        _lastEvaluationResult = null;
        _lastSecretText = null;
        await _refreshKarma();
      case Failure(error: final failure):
        _addLog('❌ クリスタル作成失敗: ${failure.message}');
    }
  }

  // ========== CrystalRepository Tests ==========

  Future<void> _testGetAvailableCrystals() async {
    final repo = ref.read(crystalRepositoryProvider);
    final result = await repo.getAvailableCrystals(limit: 10);

    switch (result) {
      case Success(value: final crystals):
        _addLog('✅ 利用可能クリスタル取得成功');
        _addLog('   件数: ${crystals.length}');
        for (var i = 0; i < crystals.length && i < 3; i++) {
          final c = crystals[i];
          final createdTime = _formatDateTime(c.createdAt);
          _addLog(
            '   [${i + 1}] ${c.emotionDisplayName} (${c.aiMetadata.emotionType.displayNameEn})',
          );
          _addLog(
            '       💎 Karma: ${c.karmaValue} | 👤 ${c.creatorNickname} | 🕐 $createdTime',
          );
        }
        if (crystals.isNotEmpty) {
          _createdCrystalId ??= crystals.first.id;
        }
      case Failure(error: final failure):
        _addLog('❌ 利用可能クリスタル取得失敗: ${failure.message}');
    }
  }

  Future<void> _testGetCreatedCrystals() async {
    if (_currentUserId == null) {
      _addLog('❌ 先に認証してください');
      return;
    }

    final repo = ref.read(crystalRepositoryProvider);
    final result = await repo.getCreatedCrystals(
      userId: _currentUserId!,
      limit: 10,
    );

    switch (result) {
      case Success(value: final crystals):
        _addLog('✅ 作成クリスタル取得成功');
        _addLog('   件数: ${crystals.length}');
        for (var i = 0; i < crystals.length && i < 3; i++) {
          final c = crystals[i];
          final createdTime = _formatDateTime(c.createdAt);
          final statusEmoji = c.status == CrystalStatus.available ? '🟢' : '🔴';
          _addLog(
            '   [${i + 1}] $statusEmoji ${c.emotionDisplayName} (${c.aiMetadata.emotionType.displayNameEn})',
          );
          _addLog(
            '       💎 Karma: ${c.karmaValue} | 🕐 $createdTime | Status: ${c.status.name}',
          );
        }
        if (crystals.isNotEmpty) {
          _createdCrystalId = crystals.first.id;
        }
      case Failure(error: final failure):
        _addLog('❌ 作成クリスタル取得失敗: ${failure.message}');
    }
  }

  Future<void> _testGetCrystal() async {
    if (_createdCrystalId == null) {
      _addLog('❌ 先にクリスタルを作成してください');
      return;
    }

    final repo = ref.read(crystalRepositoryProvider);
    final result = await repo.getCrystal(_createdCrystalId!);

    switch (result) {
      case Success(value: final crystal):
        if (crystal != null) {
          _addLog('✅ クリスタル詳細取得成功');
          _addLog('   ID: ${crystal.id}');
          _addLog('   Status: ${crystal.status.name}');
          _addLog('   感情: ${crystal.emotionDisplayName}');
          _addLog('   カルマ値: ${crystal.karmaValue}');
          _addLog('   作成者: ${crystal.createdBy}');
          _addLog('   ニックネーム: ${crystal.creatorNickname}');
        } else {
          _addLog('⚠️ クリスタルが見つかりません');
        }
      case Failure(error: final failure):
        _addLog('❌ クリスタル詳細取得失敗: ${failure.message}');
    }
  }

  // ========== DeciphermentRepository Tests ==========

  Future<void> _testDecipher() async {
    if (_currentUserId == null) {
      _addLog('❌ 先に認証してください');
      return;
    }

    // 解読可能なクリスタルを探す（自分以外が作成した available なクリスタル）
    final crystalRepo = ref.read(crystalRepositoryProvider);
    final availableResult = await crystalRepo.getAvailableCrystals(limit: 20);

    String? targetCrystalId;
    int? targetKarmaValue;

    switch (availableResult) {
      case Success(value: final crystals):
        for (final c in crystals) {
          if (c.createdBy != _currentUserId && c.karmaValue <= _currentKarma) {
            targetCrystalId = c.id;
            targetKarmaValue = c.karmaValue;
            break;
          }
        }
      case Failure():
        break;
    }

    if (targetCrystalId == null) {
      _addLog('❌ 解読可能なクリスタルが見つかりません');
      _addLog('   (他ユーザーが作成したavailableなクリスタルで、カルマが足りるもの)');
      return;
    }

    _addLog('🔓 解読対象: $targetCrystalId (Karma: $targetKarmaValue)');

    final repo = ref.read(deciphermentRepositoryProvider);
    final result = await repo.decipher(
      crystalId: targetCrystalId,
      userId: _currentUserId!,
    );

    switch (result) {
      case Success(value: final decipherment):
        final textPreview = decipherment.secretText.length > 30
            ? '${decipherment.secretText.substring(0, 30)}...'
            : decipherment.secretText;
        _addLog('✅ クリスタル解読成功');
        _addLog('   秘密テキスト: $textPreview');
        _addLog('   消費カルマ: -${decipherment.karmaSpent}');
        await _refreshKarma();
      case Failure(error: final failure):
        _addLog('❌ クリスタル解読失敗: ${failure.message}');
    }
  }

  // ========== JournalRepository Tests ==========

  Future<void> _testGetCollectedCrystals() async {
    if (_currentUserId == null) {
      _addLog('❌ 先に認証してください');
      return;
    }

    final repo = ref.read(journalRepositoryProvider);
    final result = await repo.getCollectedCrystals(
      userId: _currentUserId!,
      limit: 10,
    );

    switch (result) {
      case Success(value: final crystals):
        _addLog('✅ 収集クリスタル取得成功');
        _addLog('   件数: ${crystals.length}');
        for (var i = 0; i < crystals.length && i < 3; i++) {
          final c = crystals[i];
          _addLog('   - ${c.emotionDisplayName} (Cost: ${c.karmaCost})');
        }
      case Failure(error: final failure):
        _addLog('❌ 収集クリスタル取得失敗: ${failure.message}');
    }
  }

  Future<void> _testGetCollectedCount() async {
    if (_currentUserId == null) {
      _addLog('❌ 先に認証してください');
      return;
    }

    final repo = ref.read(journalRepositoryProvider);
    final result = await repo.getCollectedCount(userId: _currentUserId!);

    switch (result) {
      case Success(value: final count):
        _addLog('✅ 収集数取得成功: $count');
      case Failure(error: final failure):
        _addLog('❌ 収集数取得失敗: ${failure.message}');
    }
  }

  // ========== 自動テスト ==========

  /// 自動テストフロー実行
  ///
  /// 1. 認証
  /// 2. 昇華 (evaluate → confirm)
  /// 3. クリスタル取得
  /// 4. ユーザー情報確認
  /// 5. ジャーナル確認
  Future<void> _runAutoTest() async {
    _addLog('🚀 自動テスト開始');
    _addLog('═══════════════════════════════════════');

    try {
      // Step 1: 認証
      _addLog('');
      _addLog('📍 Step 1/5: 認証');
      await _testSignInAnonymously();

      if (_currentUserId == null) {
        _addLog('❌ 認証に失敗したため、テストを中止します');
        return;
      }

      await Future.delayed(const Duration(milliseconds: 500));

      // Step 2: 昇華 (クリスタル作成)
      _addLog('');
      _addLog('📍 Step 2/5: 昇華 (秘密をクリスタルに変換)');
      _addLog('   2-1: evaluate (AI評価)');
      await _testEvaluate();

      if (_lastEvaluationResult != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        _addLog('   2-2: confirm (クリスタル作成)');
        await _testConfirm();
      }

      await Future.delayed(const Duration(milliseconds: 500));

      // Step 3: クリスタル取得
      _addLog('');
      _addLog('📍 Step 3/5: クリスタル取得');
      await _testGetAvailableCrystals();
      await Future.delayed(const Duration(milliseconds: 300));
      await _testGetCreatedCrystals();

      await Future.delayed(const Duration(milliseconds: 500));

      // Step 4: ユーザー情報確認
      _addLog('');
      _addLog('📍 Step 4/5: ユーザー情報確認');
      await _testGetUser();

      await Future.delayed(const Duration(milliseconds: 500));

      // Step 5: ジャーナル確認
      _addLog('');
      _addLog('📍 Step 5/5: ジャーナル確認');
      await _testGetCollectedCount();
      await _testGetCollectedCrystals();

      _addLog('');
      _addLog('═══════════════════════════════════════');
      _addLog('✅ 自動テスト完了！');
    } catch (e, stackTrace) {
      _addLog('');
      _addLog('❌ 自動テスト中にエラーが発生: $e');
      _addLog('   スタックトレース: $stackTrace');
      _addLog('═══════════════════════════════════════');
    }
  }
}
