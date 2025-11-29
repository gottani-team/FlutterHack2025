import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/crystal.dart';
import '../../domain/entities/crystal_status.dart';
import '../converters/timestamp_converter.dart';
import 'ai_metadata_model.dart';

part 'crystal_model.g.dart';

/// CrystalのFirestore用モデル
///
/// **Firestore Collection**: `crystals`
/// **Document Structure**:
/// ```json
/// {
///   "status": "available" | "taken",
///   "karmaValue": 0-100,
///   "aiMetadata": { "emotionType": String, "score": int },
///   "createdAt": Timestamp,
///   "secretText": String,
///   "createdBy": String,
///   "creatorNickname": String,
///   "decipheredBy": String?,
///   "decipheredAt": Timestamp?
/// }
/// ```
@JsonSerializable()
class CrystalModel {
  CrystalModel({
    required this.id,
    required this.status,
    required this.karmaValue,
    required this.aiMetadata,
    required this.createdAt,
    required this.secretText,
    required this.createdBy,
    required this.creatorNickname,
    this.decipheredBy,
    this.decipheredAt,
  });

  /// FirestoreドキュメントからCrystalModelを作成
  factory CrystalModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw ArgumentError('Document data is null');
    }

    return CrystalModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  /// JSONからデシリアライズ
  factory CrystalModel.fromJson(Map<String, dynamic> json) =>
      _$CrystalModelFromJson(json);

  /// Domain EntityからModelを作成
  factory CrystalModel.fromEntity(Crystal entity) {
    return CrystalModel(
      id: entity.id,
      status: entity.status.toJson(),
      karmaValue: entity.karmaValue,
      aiMetadata: AIMetadataModel.fromEntity(entity.aiMetadata),
      createdAt: Timestamp.fromDate(entity.createdAt),
      secretText: entity.secretText ?? '',
      createdBy: entity.createdBy,
      creatorNickname: entity.creatorNickname,
      decipheredBy: entity.decipheredBy,
      decipheredAt: entity.decipheredAt != null
          ? Timestamp.fromDate(entity.decipheredAt!)
          : null,
    );
  }

  final String id;
  final String status;
  final int karmaValue;
  final AIMetadataModel aiMetadata;

  @TimestampConverter()
  final Timestamp createdAt;

  final String secretText;
  final String createdBy;
  final String creatorNickname;
  final String? decipheredBy;

  @TimestampConverter()
  final Timestamp? decipheredAt;

  /// JSONシリアライズ
  Map<String, dynamic> toJson() => _$CrystalModelToJson(this);

  /// Firestore保存用のMapに変換（IDは除外）
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  /// ModelからDomain Entityに変換
  Crystal toEntity() {
    return Crystal(
      id: id,
      status: CrystalStatus.fromJson(status),
      karmaValue: karmaValue,
      aiMetadata: aiMetadata.toEntity(),
      createdAt: createdAt.toDate(),
      secretText: secretText,
      createdBy: createdBy,
      creatorNickname: creatorNickname,
      decipheredBy: decipheredBy,
      decipheredAt: decipheredAt?.toDate(),
    );
  }
}
