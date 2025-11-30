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
    if (score <= 100) return 'stone';
    if (score <= 1000) return 'obsidian';
    if (score <= 5000) return 'copper';
    if (score <= 10000) return 'silver';
    if (score <= 25000) return 'gold';
    return 'crystal';
  }

  /// レアリティ表示名
  String get rarityDisplayName {
    if (score <= 100) return 'stone';
    if (score <= 1000) return 'obsidian';
    if (score <= 5000) return 'copper';
    if (score <= 10000) return 'silver';
    if (score <= 25000) return 'gold';
    return 'crystal';
  }

  /// クリスタル画像
  String get imageUrl => 'assets/images/$rarityTier.png';
}
