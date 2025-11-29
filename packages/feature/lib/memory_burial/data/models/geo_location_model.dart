import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/geo_location.dart';

part 'geo_location_model.g.dart';

/// GeoLocationのJSON表現
/// Note: GeoLocationは値オブジェクトのため、BaseModelを継承しない
@JsonSerializable()
class GeoLocationModel {
  const GeoLocationModel({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  factory GeoLocationModel.fromJson(Map<String, dynamic> json) =>
      _$GeoLocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$GeoLocationModelToJson(this);

  /// FirestoreのGeoPointから変換
  factory GeoLocationModel.fromGeoPoint(GeoPoint geoPoint) {
    return GeoLocationModel(
      latitude: geoPoint.latitude,
      longitude: geoPoint.longitude,
    );
  }

  /// FirestoreのGeoPointに変換
  GeoPoint toGeoPoint() => GeoPoint(latitude, longitude);

  /// Entityに変換
  GeoLocation toEntity() => GeoLocation(
        latitude: latitude,
        longitude: longitude,
      );

  /// EntityからModelを生成
  factory GeoLocationModel.fromEntity(GeoLocation entity) {
    return GeoLocationModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }
}
