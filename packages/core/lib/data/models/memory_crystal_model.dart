import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/emotion_type.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/memory_crystal.dart';
import '../converters/geopoint_converter.dart';
import '../converters/timestamp_converter.dart';
import '../utils/geohash.dart';

part 'memory_crystal_model.g.dart';

/// MemoryCrystalのFirestore用モデル
///
/// **Firestore Collection**: `crystals`
/// **Document Structure**:
/// ```json
/// {
///   "location": GeoPoint,
///   "geohash": String,  // geohash for efficient querying
///   "emotion": String,
///   "creatorId": String,
///   "createdAt": Timestamp,
///   "isExcavated": bool,
///   "text": String?,
///   "excavatedBy": String?,
///   "excavatedAt": Timestamp?
/// }
/// ```
@JsonSerializable()
class MemoryCrystalModel {
  MemoryCrystalModel({
    required this.id,
    required this.location,
    required this.geohash,
    required this.emotion,
    required this.creatorId,
    required this.createdAt,
    required this.isExcavated,
    this.text,
    this.excavatedBy,
    this.excavatedAt,
  });

  /// FirestoreドキュメントからMemoryCrystalModelを作成
  factory MemoryCrystalModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw ArgumentError('Document data is null');
    }

    return MemoryCrystalModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  /// JSON からデシリアライズ
  factory MemoryCrystalModel.fromJson(Map<String, dynamic> json) =>
      _$MemoryCrystalModelFromJson(json);

  /// Domain EntityからModelを作成
  factory MemoryCrystalModel.fromEntity(MemoryCrystal entity) {
    final geoPoint = GeoPoint(
      entity.location.latitude,
      entity.location.longitude,
    );

    final geohash = GeohashUtil.encode(entity.location, precision: 5);

    return MemoryCrystalModel(
      id: entity.id,
      location: geoPoint,
      geohash: geohash,
      emotion: entity.emotion,
      creatorId: entity.creatorId,
      createdAt: Timestamp.fromDate(entity.createdAt),
      isExcavated: entity.isExcavated,
      text: entity.text,
      excavatedBy: entity.excavatedBy,
      excavatedAt: entity.excavatedAt != null
          ? Timestamp.fromDate(entity.excavatedAt!)
          : null,
    );
  }
  final String id;

  @GeoPointConverter()
  final GeoPoint location;

  final String geohash;

  @JsonKey(fromJson: EmotionType.fromJson, toJson: _emotionTypeToJson)
  final EmotionType emotion;

  final String creatorId;

  @TimestampConverter()
  final Timestamp createdAt;

  final bool isExcavated;
  final String? text;
  final String? excavatedBy;

  @TimestampConverter()
  final Timestamp? excavatedAt;

  /// JSONシリアライズ
  Map<String, dynamic> toJson() => _$MemoryCrystalModelToJson(this);

  /// Firestore保存用のMapに変換（IDは除外）
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // IDはドキュメントIDとして使用するため除外
    return json;
  }

  /// ModelからDomain Entityに変換
  MemoryCrystal toEntity() {
    return MemoryCrystal(
      id: id,
      location: Location(
        latitude: location.latitude,
        longitude: location.longitude,
      ),
      emotion: emotion,
      creatorId: creatorId,
      createdAt: createdAt.toDate(),
      isExcavated: isExcavated,
      text: text,
      excavatedBy: excavatedBy,
      excavatedAt: excavatedAt?.toDate(),
    );
  }
}

/// EmotionType を JSON 文字列に変換
String _emotionTypeToJson(EmotionType emotion) => emotion.toJson();
