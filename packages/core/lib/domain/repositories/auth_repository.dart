import '../entities/user_session.dart';
import '../common/result.dart';

/// 認証リポジトリのインターフェース
///
/// Feature層はこのインターフェースのみに依存し、実装の詳細は知らない。
/// Data層の `AuthRepositoryImpl` がこのインターフェースを実装する。
///
/// **キャッシュ機能**:
/// - セッション情報はキャッシュされ、同一セッション中は再取得不要
/// - `requireUserId()` で現在のユーザーIDを効率的に取得可能
abstract class AuthRepository {
  /// 現在のユーザーIDを取得（キャッシュ使用）
  ///
  /// 認証済みの場合はキャッシュからユーザーIDを返す。
  /// キャッシュがない場合はFirebase Authから取得してキャッシュを更新。
  /// 未認証の場合はCoreFailure.authを返す。
  ///
  /// **使用例**:
  /// ```dart
  /// final result = await authRepository.requireUserId();
  /// switch (result) {
  ///   case Success(value: final userId):
  ///     // userIdを使用
  ///   case Failure(error: final failure):
  ///     // 未認証エラー処理
  /// }
  /// ```
  Future<Result<String>> requireUserId();

  /// 現在のユーザーIDを同期的に取得（キャッシュのみ）
  ///
  /// キャッシュにセッションがある場合のみユーザーIDを返す。
  /// キャッシュがない場合やセッションが無効な場合はnullを返す。
  ///
  /// **注意**: 初回アクセス時はnullになる可能性があるため、
  /// 確実にユーザーIDが必要な場合は `requireUserId()` を使用すること。
  String? get cachedUserId;

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
