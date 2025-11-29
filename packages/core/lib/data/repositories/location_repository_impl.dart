import '../../domain/entities/geo_location.dart';
import '../../domain/repositories/location_repository.dart';

/// MVP版: モック位置情報を返すLocationRepository実装
///
/// 将来的にはgeolocatorパッケージを使用して実際の位置情報を取得する
class LocationRepositoryImpl implements LocationRepository {
  @override
  Future<GeoLocation> getCurrentLocation() async {
    // MVP版: 東京駅の座標を返す
    // 実際のGPS取得をシミュレートするため少し遅延を入れる
    await Future.delayed(const Duration(milliseconds: 500));
    return const GeoLocation(latitude: 35.6812, longitude: 139.7671);
  }

  @override
  Future<bool> requestPermission() async {
    // MVP版: 常にtrueを返す
    // TODO: 実際の権限リクエスト実装（geolocatorパッケージ使用）
    return true;
  }

  @override
  Future<bool> isPermissionGranted() async {
    // MVP版: 常にtrueを返す
    // TODO: 実際の権限チェック実装（geolocatorパッケージ使用）
    return true;
  }

  @override
  Future<bool> isServiceEnabled() async {
    // MVP版: 常にtrueを返す
    // TODO: 実際のサービスチェック実装（geolocatorパッケージ使用）
    return true;
  }
}
