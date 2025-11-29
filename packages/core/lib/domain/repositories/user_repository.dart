import '../common/result.dart';
import '../entities/user.dart';

/// ユーザーリポジトリ
///
/// ユーザー情報とカルマ残高を管理する。
abstract class UserRepository {
  /// ユーザー情報を取得
  ///
  /// [userId]: ユーザーID
  ///
  /// Returns: ユーザー情報（存在しない場合はnull）
  Future<Result<User?>> getUser(String userId);

  /// ユーザーを作成（初回ログイン時）
  ///
  /// [userId]: ユーザーID
  /// [initialKarma]: 初期カルマ（デフォルト0）
  ///
  /// Returns: 作成されたユーザー
  Future<Result<User>> createUser({
    required String userId,
    int initialKarma = 0,
  });

  /// ユーザーを取得、存在しなければ作成
  ///
  /// [userId]: ユーザーID
  /// [initialKarma]: 初期カルマ（デフォルト0）
  ///
  /// Returns: ユーザー情報
  Future<Result<User>> getOrCreateUser({
    required String userId,
    int initialKarma = 0,
  });

  /// カルマ残高を取得
  ///
  /// [userId]: ユーザーID
  ///
  /// Returns: 現在のカルマ残高
  Future<Result<int>> getKarma(String userId);

  /// カルマを加算
  ///
  /// [userId]: ユーザーID
  /// [amount]: 加算量
  ///
  /// Returns: 更新後のカルマ残高
  Future<Result<int>> addKarma({
    required String userId,
    required int amount,
  });

  /// カルマを減算
  ///
  /// [userId]: ユーザーID
  /// [amount]: 減算量
  ///
  /// Returns: 更新後のカルマ残高
  ///
  /// Errors:
  /// - InsufficientKarmaFailure: カルマ不足
  Future<Result<int>> subtractKarma({
    required String userId,
    required int amount,
  });

  /// ユーザー情報をリアルタイムで監視
  ///
  /// [userId]: ユーザーID
  ///
  /// Returns: ユーザー情報のStream
  Stream<Result<User?>> watchUser(String userId);
}
