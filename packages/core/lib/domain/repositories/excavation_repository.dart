import '../common/result.dart';
import '../entities/memory_crystal.dart';

/// メモリー採掘リポジトリのインターフェース
///
/// Feature層はこのインターフェースのみに依存し、実装の詳細は知らない。
/// Data層の `ExcavationRepositoryImpl` がこのインターフェースを実装する。
abstract class ExcavationRepository {
  /// クリスタルを採掘して内容を閲覧可能にする
  ///
  /// **使用例**:
  /// ```dart
  /// final result = await excavationRepository.excavateCrystal(
  ///   crystalId: 'crystal_abc123',
  ///   userId: 'user_xyz789',
  /// );
  /// switch (result) {
  ///   case Success(value: final crystal):
  ///     print('Excavated: ${crystal.text}'); // テキストが見える
  ///   case Failure(error: final failure):
  ///     print('Excavation failed: ${failure.message}');
  /// }
  /// ```
  ///
  /// **Parameters**:
  /// - [crystalId]: 採掘するクリスタルのID（必須）
  /// - [userId]: 採掘者のユーザーID（必須）
  ///
  /// **Success Case**: `Success(MemoryCrystal)`
  /// - 採掘されたクリスタル
  /// - isExcavated = true
  /// - excavatedBy = userId
  /// - excavatedAt = 現在時刻
  /// - text が閲覧可能
  ///
  /// **Failure Cases**:
  /// - `Failure(CoreFailure.notFound())`: クリスタルが存在しない
  /// - `Failure(CoreFailure.permission())`: 自分が作成したクリスタルは採掘不可
  /// - `Failure(CoreFailure.duplicate())`: すでに採掘済み
  /// - `Failure(CoreFailure.auth())`: ユーザーが認証されていない
  /// - `Failure(CoreFailure.network())`: Firestore接続エラー
  /// - `Failure(CoreFailure.unknown())`: その他のエラー
  ///
  /// **Business Rules**:
  /// - 自分が作成したクリスタルは採掘できない（creatorId == userId の場合）
  /// - すでに採掘済みのクリスタルは再度採掘できない（isExcavated == true の場合）
  /// - 採掘はFirestore Transactionで実行され、競合を防ぐ
  ///
  /// **Performance**: Firestore transaction、<2秒で完了（仕様書 SC-004）
  ///
  /// **Implementation Note**:
  /// - Firestore Transactionを使用して原子性を保証
  /// - 採掘前に `canExcavate` をチェック
  /// - excavatedAt にサーバータイムスタンプを使用
  Future<Result<MemoryCrystal>> excavateCrystal({
    required String crystalId,
    required String userId,
  });

  /// 特定のクリスタルが採掘可能かチェック
  ///
  /// **使用例**:
  /// ```dart
  /// final result = await excavationRepository.canExcavateCrystal(
  ///   crystalId: 'crystal_abc123',
  ///   userId: 'user_xyz789',
  /// );
  /// switch (result) {
  ///   case Success(value: final canExcavate):
  ///     if (canExcavate) {
  ///       print('Can excavate this crystal');
  ///     } else {
  ///       print('Cannot excavate this crystal');
  ///     }
  ///   case Failure(error: final failure):
  ///     print('Check failed: ${failure.message}');
  /// }
  /// ```
  ///
  /// **Parameters**:
  /// - [crystalId]: チェックするクリスタルのID（必須）
  /// - [userId]: チェックするユーザーID（必須）
  ///
  /// **Success Case**: `Success(bool)`
  /// - true: 採掘可能
  /// - false: 採掘不可（自分が作成した、またはすでに採掘済み）
  ///
  /// **Failure Cases**:
  /// - `Failure(CoreFailure.notFound())`: クリスタルが存在しない
  /// - `Failure(CoreFailure.network())`: Firestore接続エラー
  ///
  /// **Note**: このメソッドはUI側で採掘ボタンの有効/無効を判定するために使用する。
  /// 実際の採掘時は `excavateCrystal` 内で再度チェックが行われる。
  Future<Result<bool>> canExcavateCrystal({
    required String crystalId,
    required String userId,
  });
}
