import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Firestore Timestamp ↔ JSON 変換
///
/// JsonSerializableで使用するカスタムコンバーター。
/// FirestoreのTimestamp型をJSON形式に相互変換する。
class TimestampConverter implements JsonConverter<Timestamp, Object> {
  const TimestampConverter();

  @override
  Timestamp fromJson(Object json) {
    // Firestoreから直接取得した場合はTimestampオブジェクト
    if (json is Timestamp) {
      return json;
    }

    // JSONシリアライズされた場合はMap
    if (json is Map<String, dynamic>) {
      return Timestamp(
        json['_seconds'] as int,
        json['_nanoseconds'] as int,
      );
    }

    throw ArgumentError('Invalid Timestamp format: $json');
  }

  @override
  Map<String, dynamic> toJson(Timestamp object) {
    return {
      '_seconds': object.seconds,
      '_nanoseconds': object.nanoseconds,
    };
  }
}
