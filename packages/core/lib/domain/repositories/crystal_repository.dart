import '../common/result.dart';
import '../entities/crystal.dart';

/// クリスタルリポジトリ
///
/// マップ表示用のクリスタル取得を管理する。
/// FR-001〜FR-005に対応。
abstract class CrystalRepository {
  /// 利用可能なクリスタル一覧を取得（デモ用）
  ///
  /// [limit]: 最大取得件数（デフォルト20）
  ///
  /// Returns: status='available' のクリスタル一覧
  Future<Result<List<Crystal>>> getAvailableCrystals({
    int limit = 20,
  });

  /// 特定のクリスタルを取得
  ///
  /// [crystalId]: クリスタルID
  ///
  /// Returns: クリスタル詳細（見つからない場合はnull）
  Future<Result<Crystal?>> getCrystal(String crystalId);

  /// 自分が作成したクリスタル一覧を取得
  ///
  /// [userId]: ユーザーID
  /// [limit]: 最大取得件数（デフォルト50）
  ///
  /// Returns: 作成日時降順のクリスタル一覧
  Future<Result<List<Crystal>>> getCreatedCrystals({
    required String userId,
    int limit = 50,
  });

  /// 利用可能なクリスタルをリアルタイムで監視
  ///
  /// [limit]: 最大取得件数（デフォルト20）
  ///
  /// Returns: クリスタル一覧のStream
  Stream<Result<List<Crystal>>> watchAvailableCrystals({
    int limit = 20,
  });
}
