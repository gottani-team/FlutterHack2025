import 'dart:math';

import 'package:equatable/equatable.dart';

/// 地理的位置情報を表現する値オブジェクト（Core Package共有用）
class GeoLocation extends Equatable {
  const GeoLocation({
    required this.latitude,
    required this.longitude,
  });

  /// 緯度（-90.0 ～ 90.0）
  final double latitude;

  /// 経度（-180.0 ～ 180.0）
  final double longitude;

  /// 位置情報が有効かどうか
  bool get isValid =>
      latitude >= -90.0 &&
      latitude <= 90.0 &&
      longitude >= -180.0 &&
      longitude <= 180.0;

  @override
  List<Object?> get props => [latitude, longitude];

  @override
  String toString() => 'GeoLocation(lat: $latitude, lng: $longitude)';

  /// 2つの位置間の距離を計算（メートル単位）
  /// Haversine公式を使用
  double distanceTo(GeoLocation other) {
    const earthRadiusKm = 6371.0;

    final dLat = _toRadians(other.latitude - latitude);
    final dLon = _toRadians(other.longitude - longitude);

    final lat1 = _toRadians(latitude);
    final lat2 = _toRadians(other.latitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c * 1000; // メートルに変換
  }

  double _toRadians(double degrees) => degrees * pi / 180.0;
}
