import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/common/result.dart';
import '../../domain/entities/emotion_type.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/memory_crystal.dart';
import '../../domain/failures/core_failure.dart';
import '../../domain/repositories/creation_repository.dart';
import '../datasources/firestore_creation_service.dart';

/// CreationRepository の実装
///
/// Firestore Creation Service を使用してクリスタル作成機能を提供する。
/// バリデーションとエラーハンドリングのロジックを担当。
class CreationRepositoryImpl implements CreationRepository {
  CreationRepositoryImpl(this._creationService);
  final FirestoreCreationService _creationService;

  @override
  Future<Result<MemoryCrystal>> createCrystal({
    required String text,
    required Location location,
    required String userId,
  }) async {
    // バリデーション: テキストが空
    if (text.trim().isEmpty) {
      return Result.failure(
        const CoreFailure.invalidData(message: 'Text cannot be empty'),
      );
    }

    // バリデーション: テキストが長すぎる（500文字制限）
    if (text.length > 500) {
      return Result.failure(
        CoreFailure.invalidData(
          message:
              'Text must be 500 characters or less (current: ${text.length})',
        ),
      );
    }

    // バリデーション: 緯度が範囲外
    if (location.latitude < -90 || location.latitude > 90) {
      return Result.failure(
        CoreFailure.invalidData(
          message: 'Invalid latitude: ${location.latitude} (must be -90 to 90)',
        ),
      );
    }

    // バリデーション: 経度が範囲外
    if (location.longitude < -180 || location.longitude > 180) {
      return Result.failure(
        CoreFailure.invalidData(
          message:
              'Invalid longitude: ${location.longitude} (must be -180 to 180)',
        ),
      );
    }

    try {
      // AI分析で感情タイプを判定
      // TODO: Firebase AI (Gemini API) に置き換え
      final emotion = _analyzeEmotionFromText(text.trim());

      final model = await _creationService.createCrystal(
        text: text.trim(),
        location: location,
        emotion: emotion,
        userId: userId,
      );

      return Result.success(model.toEntity());
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Result.failure(
          CoreFailure.permission(
            message: 'No permission to create crystals: ${e.message ?? ""}',
          ),
        );
      }

      if (e.code == 'unauthenticated') {
        return Result.failure(
          CoreFailure.auth(
            message: 'User is not authenticated: ${e.message ?? ""}',
            code: e.code,
          ),
        );
      }

      return Result.failure(
        CoreFailure.network(
          message: 'Failed to create crystal: ${e.message ?? ""}',
          code: e.code,
        ),
      );
    } catch (e, stackTrace) {
      return Result.failure(
        CoreFailure.unknown(
          message: 'Unexpected error during creation: $e\n$stackTrace',
        ),
      );
    }
  }

  @override
  Future<Result<List<MemoryCrystal>>> getCreatedCrystals({
    required String userId,
    int limit = 50,
  }) async {
    try {
      final models = await _creationService.getCreatedCrystals(
        userId: userId,
        limit: limit,
      );

      final entities = models.map((model) => model.toEntity()).toList();

      return Result.success(entities);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Result.failure(
          CoreFailure.permission(
            message: 'No permission to read crystals: ${e.message ?? ""}',
          ),
        );
      }

      if (e.code == 'unauthenticated') {
        return Result.failure(
          CoreFailure.auth(
            message: 'User is not authenticated: ${e.message ?? ""}',
            code: e.code,
          ),
        );
      }

      return Result.failure(
        CoreFailure.network(
          message: 'Failed to get created crystals: ${e.message ?? ""}',
          code: e.code,
        ),
      );
    } catch (e, stackTrace) {
      return Result.failure(
        CoreFailure.unknown(
          message: 'Unexpected error getting created crystals: $e\n$stackTrace',
        ),
      );
    }
  }

  /// テキストから感情タイプを分析（簡易実装）
  ///
  /// **TODO**: Firebase AI (Gemini API) に置き換え
  /// - 現在: キーワードベースの簡易判定
  /// - 将来: Gemini API でのセマンティック分析
  ///
  /// **EmotionType の4種類**:
  /// - passion (情熱): 熱い感情、興奮、エネルギー
  /// - silence (静寂): 落ち着き、平穏、瞑想
  /// - joy (喜び): 幸福、楽しさ、ポジティブ
  /// - healing (癒やし): 安らぎ、回復、優しさ
  ///
  /// [text]: 分析するテキスト
  /// Returns: 判定された EmotionType
  EmotionType _analyzeEmotionFromText(String text) {
    final lowerText = text.toLowerCase();

    // 簡易キーワード判定（日本語対応）
    // TODO: Gemini API に置き換える

    // 喜び（黄系）
    if (_containsAny(
      lowerText,
      ['楽しい', '嬉しい', '幸せ', '最高', '素晴らしい', 'happy', 'joy', 'fun', '笑'],
    )) {
      return EmotionType.joy;
    }

    // 情熱（赤系）
    if (_containsAny(
      lowerText,
      ['情熱', '熱い', '燃える', '頑張', '挑戦', 'passion', 'fire', 'energy', 'hot'],
    )) {
      return EmotionType.passion;
    }

    // 静寂（青系）
    if (_containsAny(
      lowerText,
      ['静か', '落ち着', '平穏', '穏やか', '瞑想', 'peace', 'calm', 'quiet', 'silence'],
    )) {
      return EmotionType.silence;
    }

    // デフォルトは癒やし（緑系）
    // 悲しみや寂しさなども「癒やし」として扱う
    return EmotionType.healing;
  }

  /// テキストに指定されたキーワードが含まれているかチェック
  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }
}
