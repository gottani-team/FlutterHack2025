import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Firestore GeoPoint ↔ JSON 変換
///
/// JsonSerializableで使用するカスタムコンバーター。
/// FirestoreのGeoPoint型をJSON形式に相互変換する。
class GeoPointConverter implements JsonConverter<GeoPoint, Object> {
  const GeoPointConverter();

  @override
  GeoPoint fromJson(Object json) {
    // Firestoreから直接取得した場合はGeoPointオブジェクト
    if (json is GeoPoint) {
      return json;
    }

    // JSONシリアライズされた場合はMap
    if (json is Map<String, dynamic>) {
      return GeoPoint(
        (json['_latitude'] as num).toDouble(),
        (json['_longitude'] as num).toDouble(),
      );
    }

    throw ArgumentError('Invalid GeoPoint format: $json');
  }

  @override
  Map<String, dynamic> toJson(GeoPoint object) {
    return {
      '_latitude': object.latitude,
      '_longitude': object.longitude,
    };
  }
}
