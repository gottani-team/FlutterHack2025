import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user.dart';
import '../../domain/entities/user_session.dart';
import '../converters/timestamp_converter.dart';

part 'user_model.g.dart';

/// UserのFirestore表現
///
/// Firestore `/users/{userId}` コレクションのドキュメント構造。
@JsonSerializable()
class UserModel {
  UserModel({
    required this.id,
    required this.currentKarma,
    required this.createdAt,
  });

  /// JSONからUserModelを作成
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// FirestoreドキュメントからUserModelを作成
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({'id': doc.id, ...data});
  }

  /// Userエンティティから作成
  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      currentKarma: entity.currentKarma,
      createdAt: Timestamp.fromDate(entity.createdAt),
    );
  }

  final String id;

  @JsonKey(defaultValue: 0)
  final int currentKarma;

  @TimestampConverter()
  final Timestamp createdAt;

  /// UserModelをJSONに変換
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// FirestoreへのMap形式に変換（idは除外）
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  /// Domain EntityのUserに変換
  User toEntity() {
    return User(
      id: id,
      currentKarma: currentKarma,
      createdAt: createdAt.toDate(),
    );
  }

  /// Legacy: UserSessionエンティティに変換（移行期間後に削除）
  UserSession toUserSession() {
    return UserSession(
      id: id,
      isAnonymous: true, // 匿名認証のみサポート
      createdAt: createdAt.toDate(),
    );
  }
}
