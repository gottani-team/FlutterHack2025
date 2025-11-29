import '../common/result.dart';
import '../entities/collected_crystal.dart';

/// ジャーナルリポジトリ
///
/// ユーザーが解読したクリスタルのコレクションを管理する。
/// FR-042〜FR-046に対応。
abstract class JournalRepository {
  /// 解読したクリスタル一覧を取得
  ///
  /// [userId]: ユーザーID
  /// [limit]: 最大取得件数（デフォルト50）
  ///
  /// Returns: 解読日時降順のクリスタル一覧
  Future<Result<List<CollectedCrystal>>> getCollectedCrystals({
    required String userId,
    int limit = 50,
  });

  /// 特定の解読済みクリスタルを取得
  ///
  /// [userId]: ユーザーID
  /// [crystalId]: クリスタルID
  ///
  /// Returns: クリスタル詳細（見つからない場合はnull）
  Future<Result<CollectedCrystal?>> getCollectedCrystal({
    required String userId,
    required String crystalId,
  });

  /// 解読済みクリスタル数を取得
  ///
  /// [userId]: ユーザーID
  ///
  /// Returns: 解読済みクリスタル数
  Future<Result<int>> getCollectedCount({
    required String userId,
  });
}
