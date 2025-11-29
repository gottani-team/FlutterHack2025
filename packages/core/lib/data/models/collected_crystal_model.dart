import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/collected_crystal.dart';
import '../converters/timestamp_converter.dart';
import 'ai_metadata_model.dart';

part 'collected_crystal_model.g.dart';

/// CollectedCrystalのFirestore用モデル
///
/// **Firestore Collection**: `users/{userId}/collected_crystals`
/// **Document Structure**:
/// ```json
/// {
///   "secretText": String,
///   "imageUrl": String,
///   "karmaCost": int,
///   "aiMetadata": { "emotionType": String, "score": int },
///   "decipheredAt": Timestamp,
///   "originalCreatorId": String,
///   "originalCreatorNickname": String
/// }
/// ```
@JsonSerializable()
class CollectedCrystalModel {
  CollectedCrystalModel({
    required this.id,
    required this.secretText,
    required this.imageUrl,
    required this.karmaCost,
    required this.aiMetadata,
    required this.decipheredAt,
    required this.originalCreatorId,
    required this.originalCreatorNickname,
  });

  /// FirestoreドキュメントからCollectedCrystalModelを作成
  factory CollectedCrystalModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw ArgumentError('Document data is null');
    }

    return CollectedCrystalModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  /// JSONからデシリアライズ
  factory CollectedCrystalModel.fromJson(Map<String, dynamic> json) =>
      _$CollectedCrystalModelFromJson(json);

  /// Domain EntityからModelを作成
  factory CollectedCrystalModel.fromEntity(CollectedCrystal entity) {
    return CollectedCrystalModel(
      id: entity.id,
      secretText: entity.secretText,
      imageUrl: entity.imageUrl,
      karmaCost: entity.karmaCost,
      aiMetadata: AIMetadataModel.fromEntity(entity.aiMetadata),
      decipheredAt: Timestamp.fromDate(entity.decipheredAt),
      originalCreatorId: entity.originalCreatorId,
      originalCreatorNickname: entity.originalCreatorNickname,
    );
  }

  final String id;
  final String secretText;
  final String imageUrl;
  final int karmaCost;
  final AIMetadataModel aiMetadata;

  @TimestampConverter()
  final Timestamp decipheredAt;

  final String originalCreatorId;
  final String originalCreatorNickname;

  /// JSONシリアライズ
  Map<String, dynamic> toJson() => _$CollectedCrystalModelToJson(this);

  /// Firestore保存用のMapに変換（IDは除外）
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  /// ModelからDomain Entityに変換
  CollectedCrystal toEntity() {
    return CollectedCrystal(
      id: id,
      secretText: secretText,
      imageUrl: imageUrl,
      karmaCost: karmaCost,
      aiMetadata: aiMetadata.toEntity(),
      decipheredAt: decipheredAt.toDate(),
      originalCreatorId: originalCreatorId,
      originalCreatorNickname: originalCreatorNickname,
    );
  }
}
