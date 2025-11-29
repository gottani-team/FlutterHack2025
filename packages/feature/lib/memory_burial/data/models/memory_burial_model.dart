import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/data/models/base_model.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/memory_burial_entity.dart';
import 'geo_location_model.dart';

part 'memory_burial_model.g.dart';

/// MemoryBurialEntityのJSON表現（FirestoreとFlutterアプリ間のデータ転送）
@JsonSerializable()
class MemoryBurialModel extends BaseModel<MemoryBurialEntity> {
  const MemoryBurialModel({
    required this.id,
    required this.memoryText,
    required this.location,
    required this.buriedAt,
    this.crystalColor,
    this.emotionType,
  });

  final String id;
  final String memoryText;
  final GeoLocationModel location;

  @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  final DateTime buriedAt;

  final String? crystalColor;
  final String? emotionType;

  factory MemoryBurialModel.fromJson(Map<String, dynamic> json) =>
      _$MemoryBurialModelFromJson(json);

  Map<String, dynamic> toJson() => _$MemoryBurialModelToJson(this);

  /// FirestoreのTimestampをDateTimeに変換
  static DateTime _timestampToDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    throw const FormatException('Invalid timestamp format');
  }

  /// DateTimeをFirestoreのTimestampに変換
  static dynamic _dateTimeToTimestamp(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }

  @override
  MemoryBurialEntity toEntity() {
    return MemoryBurialEntity(
      id: id,
      memoryText: memoryText,
      location: location.toEntity(),
      buriedAt: buriedAt,
      crystalColor: crystalColor,
      emotionType: emotionType,
    );
  }

  /// EntityからModelを生成
  factory MemoryBurialModel.fromEntity(MemoryBurialEntity entity) {
    return MemoryBurialModel(
      id: entity.id,
      memoryText: entity.memoryText,
      location: GeoLocationModel.fromEntity(entity.location),
      buriedAt: entity.buriedAt,
      crystalColor: entity.crystalColor,
      emotionType: entity.emotionType,
    );
  }
}
