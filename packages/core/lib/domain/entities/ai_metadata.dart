import 'package:freezed_annotation/freezed_annotation.dart';

import 'emotion_type.dart';

part 'ai_metadata.freezed.dart';

/// AI解析メタデータ
///
/// Gemini AIによる秘密テキストの分析結果を保持する。
/// - emotionType: 感情タイプ（8種類の感情）
/// - score: 秘密の「重さ」スコア（0-100）= カルマ値
@freezed
abstract class AIMetadata with _$AIMetadata {
  const factory AIMetadata({
    /// 感情タイプ
    required EmotionType emotionType,

    /// スコア（0-100）- 秘密の「重さ」= カルマ値
    required int score,
  }) = _AIMetadata;

  const AIMetadata._();

  /// クリスタルアセット名を取得
  /// 例: "happiness", "sadness"
  String get assetName => emotionType.name;

  /// レアリティティア名を取得
  /// FR-026: Common (0-59), Rare (60-89), S-Rare (90-100)
  String get rarityTier {
    if (score >= 90) return 'srare';
    if (score >= 60) return 'rare';
    return 'common';
  }

  /// レアリティ表示名
  String get rarityDisplayName {
    if (score >= 90) return 'S-Rare';
    if (score >= 60) return 'Rare';
    return 'Common';
  }

  /// クリスタル画像URLを生成
  /// FR-027: 24アセット（8 emotions × 3 rarities）
  /// 例: /crystal_images/happiness_rare.png
  String get imageUrl => '/crystal_images/${assetName}_$rarityTier.png';
}
