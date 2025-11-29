import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

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
    required this.isAnonymous,
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

  /// UserSessionエンティティからUserModelを作成
  factory UserModel.fromEntity(UserSession entity) {
    return UserModel(
      id: entity.id,
      isAnonymous: entity.isAnonymous,
      createdAt: Timestamp.fromDate(entity.createdAt),
    );
  }
  final String id;
  final bool isAnonymous;
  @TimestampConverter()
  final Timestamp createdAt;

  /// UserModelをJSONに変換
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// FirestoreへのMap形式に変換（idは除外）
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // Firestore document ID is separate
    return json;
  }

  /// Domain EntityのUserSessionに変換
  UserSession toEntity() {
    return UserSession(
      id: id,
      isAnonymous: isAnonymous,
      createdAt: createdAt.toDate(),
    );
  }
}
