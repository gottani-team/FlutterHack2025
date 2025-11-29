import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/ai_metadata.dart';
import '../../domain/entities/emotion_type.dart';

part 'ai_metadata_model.g.dart';

/// AIMetadataのFirestore用モデル
///
/// **Firestore Field**: `aiMetadata`
/// **Structure**:
/// ```json
/// {
///   "emotionType": "passion" | "silence" | "joy" | "healing",
///   "score": 0-100
/// }
/// ```
@JsonSerializable()
class AIMetadataModel {
  AIMetadataModel({
    required this.emotionType,
    required this.score,
  });

  /// JSONからデシリアライズ
  factory AIMetadataModel.fromJson(Map<String, dynamic> json) =>
      _$AIMetadataModelFromJson(json);

  /// Domain EntityからModelを作成
  factory AIMetadataModel.fromEntity(AIMetadata entity) {
    return AIMetadataModel(
      emotionType: entity.emotionType.toJson(),
      score: entity.score,
    );
  }

  final String emotionType;
  final int score;

  /// JSONシリアライズ
  Map<String, dynamic> toJson() => _$AIMetadataModelToJson(this);

  /// ModelからDomain Entityに変換
  AIMetadata toEntity() {
    return AIMetadata(
      emotionType: EmotionType.fromJson(emotionType),
      score: score,
    );
  }
}
