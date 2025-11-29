import '../entities/user_session.dart';
import '../common/result.dart';

/// 認証リポジトリのインターフェース
///
/// Feature層はこのインターフェースのみに依存し、実装の詳細は知らない。
/// Data層の `AuthRepositoryImpl` がこのインターフェースを実装する。
abstract class AuthRepository {
  /// 匿名認証を実行し、UserSessionを返す
  ///
  /// **使用例**:
  /// ```dart
  /// final result = await authRepository.signInAnonymously();
  /// switch (result) {
  ///   case Success(value: final session):
  ///     print('Logged in as: ${session.id}');
  ///   case Failure(error: final failure):
  ///     print('Auth failed: ${failure.message}');
  /// }
  /// ```
  ///
  /// **Success Case**: `Success(UserSession)`
  /// - `UserSession.id`: Firebase Auth UID
  /// - `UserSession.isAnonymous`: 常に `true`
  /// - `UserSession.createdAt`: 認証日時
  ///
  /// **Failure Cases**:
  /// - `Failure(CoreFailure.auth())`: Firebase Authentication エラー
  /// - `Failure(CoreFailure.network())`: ネットワークエラー
  /// - `Failure(CoreFailure.unknown())`: その他のエラー
  ///
  /// **Performance**: <3秒で完了（仕様書 SC-001）
  Future<Result<UserSession>> signInAnonymously();

  /// 現在の認証状態を取得
  ///
  /// **使用例**:
  /// ```dart
  /// final result = await authRepository.getCurrentSession();
  /// switch (result) {
  ///   case Success(value: final session):
  ///     print('Current user: ${session.id}');
  ///   case Failure(error: final failure):
  ///     print('No active session');
  /// }
  /// ```
  ///
  /// **Success Case**: `Success(UserSession)` - 認証済み
  /// **Failure Cases**:
  /// - `Failure(CoreFailure.auth())`: 認証されていない
  /// - `Failure(CoreFailure.unknown())`: セッション取得失敗
  ///
  /// **Performance**: 即座に完了（ローカルキャッシュから取得）
  Future<Result<UserSession>> getCurrentSession();

  /// 認証状態の変更をリッスンするStream
  ///
  /// **使用例**:
  /// ```dart
  /// authRepository.authStateChanges().listen((result) {
  ///   switch (result) {
  ///     case Success(value: final session):
  ///       if (session != null) {
  ///         print('User signed in: ${session.id}');
  ///       } else {
  ///         print('User signed out');
  ///       }
  ///     case Failure(error: final failure):
  ///       print('Auth state error');
  ///   }
  /// });
  /// ```
  ///
  /// **Stream Emissions**:
  /// - `Success(UserSession?)`: 認証状態変更時
  ///   - `UserSession`: ログイン済み
  ///   - `null`: ログアウト状態
  /// - `Failure(CoreFailure)`: Stream エラー
  ///
  /// **Note**: Feature層はこのStreamを監視してUI状態を更新する
  Stream<Result<UserSession?>> authStateChanges();

  /// サインアウト（現在は未使用、将来の拡張用）
  ///
  /// **Success Case**: `Success(void)`
  /// **Failure Cases**:
  /// - `Failure(CoreFailure.auth())`: サインアウト失敗
  Future<Result<void>> signOut();
}
