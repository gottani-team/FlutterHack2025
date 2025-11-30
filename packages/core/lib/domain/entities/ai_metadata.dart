import 'package:freezed_annotation/freezed_annotation.dart';

import 'crystal_tier.dart';
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

  CrystalTier get tier => CrystalTier.fromKarmaValue(score);
}
