import '../common/result.dart';
import '../entities/memory_crystal.dart';

/// メモリーコレクション管理リポジトリのインターフェース
///
/// Feature層はこのインターフェースのみに依存し、実装の詳細は知らない。
/// Data層の `CollectionRepositoryImpl` がこのインターフェースを実装する。
abstract class CollectionRepository {
  /// 自分が採掘したクリスタルのコレクションを取得
  ///
  /// **使用例**:
  /// ```dart
  /// final result = await collectionRepository.getExcavatedCrystals(
  ///   userId: 'user123',
  ///   limit: 50,
  /// );
  /// switch (result) {
  ///   case Success(value: final crystals):
  ///     print('Excavated ${crystals.length} crystals');
  ///     for (final crystal in crystals) {
  ///       print('${crystal.emotion.displayName}: ${crystal.text}');
  ///     }
  ///   case Failure(error: final failure):
  ///     print('Failed to get collection: ${failure.message}');
  /// }
  /// ```
  ///
  /// **Parameters**:
  /// - [userId]: ユーザーID（必須）
  /// - [limit]: 取得する最大件数（デフォルト: 50）
  ///
  /// **Success Case**: `Success(List<MemoryCrystal>)`
  /// - ユーザーが採掘したクリスタルのリスト
  /// - excavatedBy == userId のクリスタルのみ
  /// - 採掘日時の降順でソート（最新が先頭）
  /// - すべてのクリスタルは isExcavated = true
  /// - text フィールドが閲覧可能
  ///
  /// **Failure Cases**:
  /// - `Failure(CoreFailure.auth())`: ユーザーが認証されていない
  /// - `Failure(CoreFailure.network())`: Firestore接続エラー
  /// - `Failure(CoreFailure.permission())`: 読み取り権限なし
  /// - `Failure(CoreFailure.unknown())`: その他のエラー
  ///
  /// **Performance**: Firestore query、<1秒で完了（仕様書 SC-005）
  ///
  /// **Note**: コレクション画面でユーザーが採掘した思い出を振り返るために使用する。
  Future<Result<List<MemoryCrystal>>> getExcavatedCrystals({
    required String userId,
    int limit = 50,
  });

  /// 採掘したクリスタルの統計情報を取得
  ///
  /// **使用例**:
  /// ```dart
  /// final result = await collectionRepository.getCollectionStats(
  ///   userId: 'user123',
  /// );
  /// switch (result) {
  ///   case Success(value: final stats):
  ///     print('Total excavated: ${stats.totalCount}');
  ///     print('Joy crystals: ${stats.emotionCounts[EmotionType.joy]}');
  ///   case Failure(error: final failure):
  ///     print('Failed to get stats: ${failure.message}');
  /// }
  /// ```
  ///
  /// **Parameters**:
  /// - [userId]: ユーザーID（必須）
  ///
  /// **Success Case**: `Success(CollectionStats)`
  /// - totalCount: 採掘した総数
  /// - emotionCounts: 感情タイプごとの採掘数（`Map<EmotionType, int>`）
  /// - firstExcavatedAt: 最初の採掘日時（null = まだ採掘していない）
  /// - latestExcavatedAt: 最新の採掘日時（null = まだ採掘していない）
  ///
  /// **Failure Cases**:
  /// - `Failure(CoreFailure.auth())`: ユーザーが認証されていない
  /// - `Failure(CoreFailure.network())`: Firestore接続エラー
  /// - `Failure(CoreFailure.permission())`: 読み取り権限なし
  ///
  /// **Performance**: Firestore aggregation query、<2秒で完了
  ///
  /// **Implementation Note**:
  /// - Firestoreから全クリスタルを取得してクライアント側で集計
  /// - 将来的にはFirestore Aggregation Queriesを使用して最適化可能
  Future<Result<CollectionStats>> getCollectionStats({
    required String userId,
  });

  /// 採掘したクリスタルのリアルタイムリスナー
  ///
  /// **使用例**:
  /// ```dart
  /// collectionRepository.watchExcavatedCrystals(
  ///   userId: 'user123',
  ///   limit: 20,
  /// ).listen((result) {
  ///   switch (result) {
  ///     case Success(value: final crystals):
  ///       print('Collection updated: ${crystals.length} crystals');
  ///     case Failure(error: final failure):
  ///       print('Stream error: ${failure.message}');
  ///   }
  /// });
  /// ```
  ///
  /// **Parameters**:
  /// - [userId]: ユーザーID（必須）
  /// - [limit]: 取得する最大件数（デフォルト: 50）
  ///
  /// **Stream Emissions**:
  /// - `Success(List<MemoryCrystal>)`: コレクションが変更された時
  /// - `Failure(CoreFailure)`: Stream エラー
  ///
  /// **Note**:
  /// - 新しいクリスタルを採掘したときにリアルタイムで通知
  /// - コレクション画面でStreamを監視してUIを自動更新
  Stream<Result<List<MemoryCrystal>>> watchExcavatedCrystals({
    required String userId,
    int limit = 50,
  });
}

/// コレクション統計情報
///
/// ユーザーが採掘したクリスタルの統計データ。
class CollectionStats {
  const CollectionStats({
    required this.totalCount,
    required this.emotionCounts,
    this.firstExcavatedAt,
    this.latestExcavatedAt,
  });

  /// 空の統計情報を作成
  factory CollectionStats.empty() {
    return const CollectionStats(
      totalCount: 0,
      emotionCounts: {},
      firstExcavatedAt: null,
      latestExcavatedAt: null,
    );
  }

  /// 採掘した総数
  final int totalCount;

  /// 感情タイプごとの採掘数
  ///
  /// 例: {EmotionType.joy: 5, EmotionType.sadness: 3, ...}
  final Map<String, int> emotionCounts;

  /// 最初の採掘日時（null = まだ採掘していない）
  final DateTime? firstExcavatedAt;

  /// 最新の採掘日時（null = まだ採掘していない）
  final DateTime? latestExcavatedAt;
}
