import 'dart:math' show asin, cos, sqrt, sin;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'location.freezed.dart';

/// 位置情報エンティティ
///
/// GPS座標（緯度・経度）を表現し、距離計算機能を提供する。
@freezed
abstract class Location with _$Location {
  /// 位置情報を作成
  ///
  /// [latitude]: 緯度 (-90.0 ~ 90.0)
  /// [longitude]: 経度 (-180.0 ~ 180.0)
  const factory Location({
    required double latitude,
    required double longitude,
  }) = _Location;

  const Location._(); // プライベートコンストラクタでメソッド追加を可能に

  /// 別の位置までの距離を計算（Haversine formula）
  ///
  /// Returns: 距離（キロメートル）
  double distanceTo(Location other) {
    const earthRadiusKm = 6371.0;

    final dLat = _toRadians(other.latitude - latitude);
    final dLon = _toRadians(other.longitude - longitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(latitude)) *
            cos(_toRadians(other.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * asin(sqrt(a));

    return earthRadiusKm * c;
  }

  /// 指定した中心点と半径内にあるかチェック
  ///
  /// [center]: 中心位置
  /// [radiusKm]: 半径（キロメートル）
  /// Returns: 半径内なら true
  bool isWithinRadius(Location center, double radiusKm) {
    return distanceTo(center) <= radiusKm;
  }

  /// 度数法をラジアンに変換
  double _toRadians(double degree) => degree * (3.141592653589793 / 180.0);
}
