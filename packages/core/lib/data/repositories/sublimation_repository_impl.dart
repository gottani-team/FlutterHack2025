import 'dart:developer' as dev;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/common/result.dart';
import '../../domain/entities/ai_metadata.dart';
import '../../domain/entities/crystal.dart';
import '../../domain/entities/crystal_status.dart';
import '../../domain/entities/emotion_type.dart';
import '../../domain/failures/core_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/sublimation_repository.dart';
import '../datasources/karma_evaluation_service.dart';
import '../models/ai_metadata_model.dart';
import '../models/crystal_model.dart';

/// 昇華リポジトリの実装
///
/// Firebase AI Logic を使用してテキストを評価し、クリスタルを作成する。
/// AI評価が失敗した場合はフォールバックとしてダミーロジックを使用。
class SublimationRepositoryImpl implements SublimationRepository {
  SublimationRepositoryImpl(
    this._firestore, {
    required AuthRepository authRepository,
    KarmaEvaluationService? karmaEvaluationService,
  })  : _authRepository = authRepository,
        _karmaEvaluationService =
            karmaEvaluationService ?? KarmaEvaluationService();

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  final KarmaEvaluationService _karmaEvaluationService;
  final _random = Random();

  CollectionReference<Map<String, dynamic>> get _crystalsRef =>
      _firestore.collection('crystals');

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  @override
  Future<Result<EvaluationResult>> evaluate({
    required String secretText,
  }) async {
    try {
      dev.log('[SublimationRepo] evaluate: textLength=${secretText.length}');

      // バリデーション
      if (secretText.length < 10 || secretText.length > 500) {
        dev.log('[SublimationRepo] evaluate: Validation failed');
        return Result.failure(
          const CoreFailure.validation(
            message: 'Secret text must be 10-500 characters',
            field: 'secretText',
          ),
        );
      }

      // Firebase AI Logic で評価を試行、失敗時はフォールバック
      AIMetadata aiMetadata;
      try {
        dev.log('[SublimationRepo] evaluate: Calling Firebase AI...');
        aiMetadata = await _karmaEvaluationService.evaluate(secretText);
        dev.log('[SublimationRepo] evaluate: AI evaluation success');
      } catch (e) {
        dev.log(
          '[SublimationRepo] evaluate: AI evaluation failed, using fallback: $e',
        );
        // フォールバック: ダミーAIロジック
        final emotionType = _analyzeEmotion(secretText);
        final score = _calculateScore(secretText);
        aiMetadata = AIMetadata(
          emotionType: emotionType,
          score: score,
        );
      }

      dev.log(
        '[SublimationRepo] evaluate: emotion=${aiMetadata.emotionType}, score=${aiMetadata.score}',
      );

      return Result.success(
        EvaluationResult(
          aiMetadata: aiMetadata,
          imageUrl: aiMetadata.imageUrl,
        ),
      );
    } catch (e) {
      return Result.failure(
        CoreFailure.aiAnalysis(
          message: 'AI analysis failed: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<SublimationResult>> confirm({
    required String secretText,
    required EvaluationResult evaluation,
    required String nickname,
  }) async {
    // 認証済みユーザーIDを取得
    final userIdResult = await _authRepository.requireUserId();
    switch (userIdResult) {
      case Failure(error: final failure):
        return Result.failure(failure);
      case Success(value: final userId):
        try {
          dev.log(
            '[SublimationRepo] confirm: userId=$userId, nickname=$nickname',
          );

          // クリスタルを作成
          final docRef = _crystalsRef.doc();
          dev.log(
            '[SublimationRepo] confirm: Creating crystal with ID=${docRef.id}',
          );
          final now = Timestamp.now();

          final crystalModel = CrystalModel(
            id: docRef.id,
            status: CrystalStatus.available.toJson(),
            karmaValue: evaluation.aiMetadata.score,
            aiMetadata: AIMetadataModel.fromEntity(evaluation.aiMetadata),
            createdAt: now,
            secretText: secretText,
            createdBy: userId,
            creatorNickname: nickname,
          );

          // トランザクションでクリスタル作成とカルマ加算を行う
          final karmaToAdd = evaluation.karmaToEarn;

          await _firestore.runTransaction((transaction) async {
            // 1. まずすべてのreadを実行
            final userDocRef = _usersRef.doc(userId);
            final userDoc = await transaction.get(userDocRef);

            // 2. 次にすべてのwriteを実行
            // クリスタルを作成
            transaction.set(docRef, crystalModel.toFirestore());

            // ユーザーのカルマを加算
            if (userDoc.exists) {
              final currentKarma =
                  (userDoc.data()?['current_karma'] as num?)?.toInt() ?? 0;
              transaction.update(
                userDocRef,
                {'current_karma': currentKarma + karmaToAdd},
              );
            }
          });

          final crystal = Crystal(
            id: docRef.id,
            status: CrystalStatus.available,
            karmaValue: evaluation.aiMetadata.score,
            aiMetadata: evaluation.aiMetadata,
            createdAt: now.toDate(),
            secretText: secretText,
            createdBy: userId,
            creatorNickname: nickname,
          );

          return Result.success(
            SublimationResult(
              crystal: crystal,
              karmaAwarded: karmaToAdd,
            ),
          );
        } on FirebaseException catch (e) {
          return Result.failure(
            CoreFailure.network(
              message: e.message ?? 'Failed to create crystal',
              code: e.code,
            ),
          );
        } catch (e) {
          return Result.failure(
            CoreFailure.unknown(
              message: 'Failed to confirm sublimation: ${e.toString()}',
            ),
          );
        }
    }
  }

  /// ダミーAI: テキストから感情タイプを分析
  ///
  /// キーワードマッチングとランダム要素を組み合わせる
  EmotionType _analyzeEmotion(String text) {
    final lowerText = text.toLowerCase();

    // 嬉しさ: 喜び、幸福感
    if (_containsAny(lowerText, ['嬉しい', '幸せ', '最高', '素敵', '喜び', '楽しかった'])) {
      return EmotionType.happiness;
    }

    // 楽しさ: 楽しみ、ワクワク
    if (_containsAny(lowerText, ['楽しい', 'ワクワク', '面白い', '笑', '遊び'])) {
      return EmotionType.enjoyment;
    }

    // 安心: 安らぎ、ホッとする
    if (_containsAny(lowerText, ['安心', '落ち着く', 'ほっと', '穏やか', '癒し'])) {
      return EmotionType.relief;
    }

    // 期待: 希望、待ち望む
    if (_containsAny(lowerText, ['期待', '希望', '夢', '願い', '待ち遠しい', '楽しみ'])) {
      return EmotionType.anticipation;
    }

    // 悲しみ: 哀しみ、喪失感
    if (_containsAny(lowerText, ['悲しい', '辛い', '寂しい', '泣', '失', '別れ'])) {
      return EmotionType.sadness;
    }

    // 恥ずかしさ: 羞恥、照れ
    if (_containsAny(lowerText, ['恥ずかしい', '照れ', '失敗', 'ミス', '間違', '黒歴史'])) {
      return EmotionType.embarrassment;
    }

    // 怒り: 憤り、フラストレーション
    if (_containsAny(lowerText, ['怒', '腹', 'むかつく', 'イライラ', '許せない'])) {
      return EmotionType.anger;
    }

    // 虚しさ: 空虚、無力感
    if (_containsAny(lowerText, ['虚しい', '空っぽ', '意味', '無力', 'どうでもいい'])) {
      return EmotionType.emptiness;
    }

    // マッチしない場合はランダムに選択
    const emotions = EmotionType.values;
    return emotions[_random.nextInt(emotions.length)];
  }

  /// ダミーAI: テキストからスコアを算出
  ///
  /// テキスト長と特定キーワードに基づいてスコアを計算
  int _calculateScore(String text) {
    // 基本スコア: テキスト長に基づく（10-60）
    final lengthScore = (text.length / 500 * 50).clamp(10, 60).toInt();

    // ボーナス: 感情的なキーワードがあれば加点
    var bonus = 0;
    final lowerText = text.toLowerCase();

    // 強い感情キーワードでボーナス
    if (_containsAny(lowerText, ['本当に', 'とても', 'すごく', '絶対', '一生'])) {
      bonus += 10;
    }

    // 秘密っぽいキーワードでボーナス
    if (_containsAny(lowerText, ['秘密', '誰にも', '内緒', '言えない', '隠して'])) {
      bonus += 15;
    }

    // 深い感情キーワードでボーナス
    if (_containsAny(lowerText, ['人生', '死', '愛', '家族', '初めて'])) {
      bonus += 10;
    }

    // ランダム要素（-5 ~ +5）
    final randomBonus = _random.nextInt(11) - 5;

    // 最終スコア（0-100にクランプ）
    return (lengthScore + bonus + randomBonus).clamp(0, 100);
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }
}
