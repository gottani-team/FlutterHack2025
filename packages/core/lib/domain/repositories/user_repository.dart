import '../common/result.dart';
import '../entities/user.dart';

/// ユーザーリポジトリ
///
/// ユーザー情報とカルマ残高を管理する。
/// 認証済みユーザーのみが対象（userIdは内部で自動取得）。
abstract class UserRepository {
  /// 現在のユーザー情報を取得
  ///
  /// Returns: ユーザー情報（存在しない場合はnull）
  ///
  /// Errors:
  /// - AuthFailure: 未認証の場合
  Future<Result<User?>> getCurrentUser();

  /// 現在のユーザーを取得、存在しなければ作成
  ///
  /// [initialKarma]: 初期カルマ（デフォルト0）
  ///
  /// Returns: ユーザー情報
  ///
  /// Errors:
  /// - AuthFailure: 未認証の場合
  Future<Result<User>> getOrCreateCurrentUser({
    int initialKarma = 0,
  });

  /// 現在のユーザーのカルマ残高を取得
  ///
  /// Returns: 現在のカルマ残高
  ///
  /// Errors:
  /// - AuthFailure: 未認証の場合
  Future<Result<int>> getKarma();

  /// カルマを加算
  ///
  /// [amount]: 加算量
  ///
  /// Returns: 更新後のカルマ残高
  ///
  /// Errors:
  /// - AuthFailure: 未認証の場合
  Future<Result<int>> addKarma({
    required int amount,
  });

  /// カルマを減算
  ///
  /// [amount]: 減算量
  ///
  /// Returns: 更新後のカルマ残高
  ///
  /// Errors:
  /// - AuthFailure: 未認証の場合
  /// - InsufficientKarmaFailure: カルマ不足
  Future<Result<int>> subtractKarma({
    required int amount,
  });

  /// 現在のユーザー情報をリアルタイムで監視
  ///
  /// Returns: ユーザー情報のStream
  ///
  /// Errors:
  /// - AuthFailure: 未認証の場合
  Stream<Result<User?>> watchCurrentUser();
}
