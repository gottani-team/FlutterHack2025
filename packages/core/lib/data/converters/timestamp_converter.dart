import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Firestore Timestamp ↔ JSON 変換
///
/// JsonSerializableで使用するカスタムコンバーター。
/// FirestoreのTimestamp型をJSON形式に相互変換する。
class TimestampConverter implements JsonConverter<Timestamp, Map<String, dynamic>> {
  const TimestampConverter();

  @override
  Timestamp fromJson(Map<String, dynamic> json) {
    return Timestamp(
      json['_seconds'] as int,
      json['_nanoseconds'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson(Timestamp object) {
    return {
      '_seconds': object.seconds,
      '_nanoseconds': object.nanoseconds,
    };
  }
}
