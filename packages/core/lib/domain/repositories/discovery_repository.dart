import '../entities/location.dart';
import '../entities/memory_crystal.dart';
import '../common/result.dart';

/// メモリー発見リポジトリのインターフェース
///
/// Feature層はこのインターフェースのみに依存し、実装の詳細は知らない。
/// Data層の `DiscoveryRepositoryImpl` がこのインターフェースを実装する。
abstract class DiscoveryRepository {
  /// 指定位置の周辺にあるクリスタルを発見する
  ///
  /// **使用例**:
  /// ```dart
  /// final currentLocation = Location(latitude: 35.6812, longitude: 139.7671);
  /// final result = await discoveryRepository.discoverNearby(
  ///   location: currentLocation,
  ///   radiusKm: 1.0,
  /// );
  /// switch (result) {
  ///   case Success(value: final crystals):
  ///     print('Found ${crystals.length} crystals');
  ///   case Failure(error: final failure):
  ///     print('Discovery failed: ${failure.message}');
  /// }
  /// ```
  ///
  /// **Parameters**:
  /// - [location]: 現在のGPS位置
  /// - [radiusKm]: 検索半径（キロメートル）デフォルト: 1.0km
  /// - [limit]: 取得する最大件数 デフォルト: 50
  ///
  /// **Success Case**: `Success(List<MemoryCrystal>)`
  /// - 半径内のクリスタルのリスト（採掘済み・未採掘の両方を含む）
  /// - クリスタルが見つからない場合は空リスト `[]`
  ///
  /// **Failure Cases**:
  /// - `Failure(CoreFailure.network())`: Firestore接続エラー
  /// - `Failure(CoreFailure.permission())`: 読み取り権限なし
  /// - `Failure(CoreFailure.unknown())`: その他のエラー
  ///
  /// **Performance**: Geohash indexingにより<2秒で完了（仕様書 SC-002）
  ///
  /// **Implementation Note**:
  /// - Firestoreの geohash フィールドを使用して効率的に検索
  /// - クライアント側で距離計算を行い、正確な半径内のみ返す
  Future<Result<List<MemoryCrystal>>> discoverNearby({
    required Location location,
    double radiusKm = 1.0,
    int limit = 50,
  });

  /// 特定のクリスタルをIDで取得
  ///
  /// **使用例**:
  /// ```dart
  /// final result = await discoveryRepository.getCrystalById('crystal_123');
  /// switch (result) {
  ///   case Success(value: final crystal):
  ///     print('Crystal: ${crystal.emotion.displayName}');
  ///   case Failure(error: final failure):
  ///     print('Not found: ${failure.message}');
  /// }
  /// ```
  ///
  /// **Parameters**:
  /// - [id]: クリスタルのFirestore ドキュメントID
  ///
  /// **Success Case**: `Success(MemoryCrystal)`
  /// **Failure Cases**:
  /// - `Failure(CoreFailure.notFound())`: クリスタルが存在しない
  /// - `Failure(CoreFailure.network())`: Firestore接続エラー
  /// - `Failure(CoreFailure.permission())`: 読み取り権限なし
  ///
  /// **Performance**: Firestore単一ドキュメント取得、<1秒で完了
  Future<Result<MemoryCrystal>> getCrystalById(String id);

  /// クリスタル発見イベントをリッスンするStream
  ///
  /// **使用例**:
  /// ```dart
  /// final currentLocation = Location(latitude: 35.6812, longitude: 139.7671);
  /// discoveryRepository.watchNearby(
  ///   location: currentLocation,
  ///   radiusKm: 0.5,
  /// ).listen((result) {
  ///   switch (result) {
  ///     case Success(value: final crystals):
  ///       print('Real-time update: ${crystals.length} crystals');
  ///     case Failure(error: final failure):
  ///       print('Stream error: ${failure.message}');
  ///   }
  /// });
  /// ```
  ///
  /// **Parameters**:
  /// - [location]: 監視するGPS位置
  /// - [radiusKm]: 検索半径（キロメートル）デフォルト: 1.0km
  /// - [limit]: 取得する最大件数 デフォルト: 50
  ///
  /// **Stream Emissions**:
  /// - `Success(List<MemoryCrystal>)`: クリスタルリストの変更時
  /// - `Failure(CoreFailure)`: Stream エラー
  ///
  /// **Note**:
  /// - Firestoreのリアルタイムリスナーを使用
  /// - 新しいクリスタルが作成されたとき、または採掘されたときに通知
  /// - Feature層はこのStreamを監視してUI状態をリアルタイム更新する
  Stream<Result<List<MemoryCrystal>>> watchNearby({
    required Location location,
    double radiusKm = 1.0,
    int limit = 50,
  });
}
