import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_session.freezed.dart';

/// ユーザーセッションエンティティ
///
/// Firebase匿名認証によって作成されたユーザーセッション情報を表現する。
@freezed
abstract class UserSession with _$UserSession {
  const factory UserSession({
    required String id,
    required bool isAnonymous,
    required DateTime createdAt,
  }) = _UserSession;
}
