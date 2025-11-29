import '../common/result.dart';
import '../entities/location.dart';
import '../entities/memory_crystal.dart';

/// メモリー作成リポジトリのインターフェース
///
/// Feature層はこのインターフェースのみに依存し、実装の詳細は知らない。
/// Data層の `CreationRepositoryImpl` がこのインターフェースを実装する。
abstract class CreationRepository {
  /// 新しいクリスタルを作成してFirestoreに保存
  ///
  /// **使用例**:
  /// ```dart
  /// final location = Location(latitude: 35.6812, longitude: 139.7671);
  /// final result = await creationRepository.createCrystal(
  ///   text: '今日はとても楽しい日だった',
  ///   location: location,
  /// );
  /// switch (result) {
  ///   case Success(value: final crystal):
  ///     print('Crystal created: ${crystal.id}');
  ///     print('AI analyzed emotion: ${crystal.emotion.displayName}');
  ///   case Failure(error: final failure):
  ///     print('Creation failed: ${failure.message}');
  /// }
  /// ```
  ///
  /// **Parameters**:
  /// - [text]: 記憶のテキスト（必須、1〜500文字）
  /// - [location]: GPS位置（必須）
  /// - [userId]: 作成者のユーザーID（必須）
  ///
  /// **Success Case**: `Success(MemoryCrystal)`
  /// - 新しく作成されたクリスタル
  /// - isExcavated = false（未採掘状態）
  /// - Firestore document IDが付与されている
  ///
  /// **Failure Cases**:
  /// - `Failure(CoreFailure.auth())`: ユーザーが認証されていない
  /// - `Failure(CoreFailure.invalidData())`: テキストが空、または500文字超
  /// - `Failure(CoreFailure.network())`: Firestore接続エラー
  /// - `Failure(CoreFailure.permission())`: 書き込み権限なし
  /// - `Failure(CoreFailure.unknown())`: その他のエラー
  ///
  /// **Performance**: Firestore書き込み + AI分析、<3秒で完了（仕様書 SC-003）
  ///
  /// **Implementation Note**:
  /// - 感情タイプはAI（Firebase AI/Gemini API）が自動判定
  /// - テキスト内容は暗号化せずに保存（採掘時に初めて表示される仕様）
  /// - Geohashは自動計算してFirestoreに保存
  /// - createdAtはサーバータイムスタンプを使用
  Future<Result<MemoryCrystal>> createCrystal({
    required String text,
    required Location location,
    required String userId,
  });

  /// クリスタルの作成履歴を取得
  ///
  /// **使用例**:
  /// ```dart
  /// final result = await creationRepository.getCreatedCrystals(
  ///   userId: 'user123',
  ///   limit: 20,
  /// );
  /// switch (result) {
  ///   case Success(value: final crystals):
  ///     print('Created ${crystals.length} crystals');
  ///   case Failure(error: final failure):
  ///     print('Failed to get history: ${failure.message}');
  /// }
  /// ```
  ///
  /// **Parameters**:
  /// - [userId]: 作成者のユーザーID（必須）
  /// - [limit]: 取得する最大件数（デフォルト: 50）
  ///
  /// **Success Case**: `Success(List<MemoryCrystal>)`
  /// - ユーザーが作成したクリスタルのリスト
  /// - 作成日時の降順でソート（最新が先頭）
  /// - 採掘済み・未採掘の両方を含む
  ///
  /// **Failure Cases**:
  /// - `Failure(CoreFailure.auth())`: ユーザーが認証されていない
  /// - `Failure(CoreFailure.network())`: Firestore接続エラー
  /// - `Failure(CoreFailure.permission())`: 読み取り権限なし
  ///
  /// **Performance**: Firestore query、<1秒で完了
  ///
  /// **Note**: 自分が作成したクリスタルは採掘できないため、
  /// UI側で区別して表示する必要がある。
  Future<Result<List<MemoryCrystal>>> getCreatedCrystals({
    required String userId,
    int limit = 50,
  });
}
