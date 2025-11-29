import '../common/result.dart';
import '../entities/collected_crystal.dart';

/// ジャーナルリポジトリ
///
/// ユーザーが解読したクリスタルのコレクションを管理する。
/// FR-042〜FR-046に対応。
///
/// **認証要件**:
/// すべてのメソッドは現在認証中のユーザーに対して動作する。
/// 未認証の場合はCoreFailure.authを返す。
abstract class JournalRepository {
  /// 解読したクリスタル一覧を取得
  ///
  /// [limit]: 最大取得件数（デフォルト50）
  ///
  /// Returns: 解読日時降順のクリスタル一覧
  ///
  /// Errors:
  /// - AuthFailure: 未認証の場合
  Future<Result<List<CollectedCrystal>>> getCollectedCrystals({
    int limit = 50,
  });

  /// 特定の解読済みクリスタルを取得
  ///
  /// [crystalId]: クリスタルID
  ///
  /// Returns: クリスタル詳細（見つからない場合はnull）
  ///
  /// Errors:
  /// - AuthFailure: 未認証の場合
  Future<Result<CollectedCrystal?>> getCollectedCrystal({
    required String crystalId,
  });

  /// 解読済みクリスタル数を取得
  ///
  /// Returns: 解読済みクリスタル数
  ///
  /// Errors:
  /// - AuthFailure: 未認証の場合
  Future<Result<int>> getCollectedCount();
}
