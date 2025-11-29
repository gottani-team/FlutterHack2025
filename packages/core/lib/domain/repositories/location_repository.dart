import '../entities/geo_location.dart';
import 'base_repository.dart';

/// 位置情報取得のリポジトリインターフェース
abstract class LocationRepository extends BaseRepository {
  /// 現在位置を取得する
  ///
  /// Returns: GeoLocation
  ///
  /// Throws:
  /// - [LocationPermissionDeniedException] 位置情報権限が拒否された
  /// - [LocationServiceDisabledException] 位置情報サービスが無効
  /// - [TimeoutException] タイムアウト
  Future<GeoLocation> getCurrentLocation();

  /// 位置情報権限をリクエストする
  ///
  /// Returns: 権限が許可されたかどうか
  Future<bool> requestPermission();

  /// 位置情報権限が許可されているか確認する
  ///
  /// Returns: 権限が許可されているかどうか
  Future<bool> isPermissionGranted();

  /// 位置情報サービスが有効か確認する
  ///
  /// Returns: サービスが有効かどうか
  Future<bool> isServiceEnabled();
}
