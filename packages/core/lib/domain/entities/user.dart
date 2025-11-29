import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// ユーザーエンティティ
///
/// プレイヤー情報とカルマ残高を管理する。
@freezed
abstract class User with _$User {
  /// ユーザーを作成
  ///
  /// [id]: Firebase Auth UID
  /// [currentKarma]: 現在のカルマ残高
  /// [createdAt]: アカウント作成日時
  const factory User({
    required String id,
    required int currentKarma,
    required DateTime createdAt,
  }) = _User;

  const User._();

  /// カルマが十分かチェック
  bool hasEnoughKarma(int required) => currentKarma >= required;

  /// カルマを加算した新しいユーザーを返す
  User addKarma(int amount) => copyWith(currentKarma: currentKarma + amount);

  /// カルマを減算した新しいユーザーを返す
  /// 残高が不足している場合は0になる
  User subtractKarma(int amount) =>
      copyWith(currentKarma: (currentKarma - amount).clamp(0, 999999));
}
