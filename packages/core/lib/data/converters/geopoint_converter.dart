import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Firestore GeoPoint ↔ JSON 変換
///
/// JsonSerializableで使用するカスタムコンバーター。
/// FirestoreのGeoPoint型をJSON形式に相互変換する。
class GeoPointConverter implements JsonConverter<GeoPoint, Map<String, dynamic>> {
  const GeoPointConverter();

  @override
  GeoPoint fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      (json['_latitude'] as num).toDouble(),
      (json['_longitude'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson(GeoPoint object) {
    return {
      '_latitude': object.latitude,
      '_longitude': object.longitude,
    };
  }
}
