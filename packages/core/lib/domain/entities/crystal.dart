import 'package:freezed_annotation/freezed_annotation.dart';

import 'ai_metadata.dart';
import 'crystal_status.dart';

part 'crystal.freezed.dart';

/// 想晶（クリスタル）エンティティ
///
/// 昇華された秘密が結晶化したもの。
/// 解読されるまで地図上に存在し、カルマを支払うことで中身を見ることができる。
@freezed
abstract class Crystal with _$Crystal {
  /// クリスタルを作成
  ///
  /// [id]: Firestore ドキュメント ID
  /// [status]: 状態（available/taken）
  /// [karmaValue]: カルマ値（解読に必要なコスト、0-100）
  /// [aiMetadata]: AI解析メタデータ
  /// [createdAt]: 作成日時
  /// [createdBy]: 作成者ID
  /// [creatorNickname]: 作成者のニックネーム
  /// [secretText]: 秘密テキスト（解読後のみ表示）
  /// [decipheredBy]: 解読者ID（解読後のみ）
  /// [decipheredAt]: 解読日時（解読後のみ）
  const factory Crystal({
    required String id,
    required CrystalStatus status,
    required int karmaValue,
    required AIMetadata aiMetadata,
    required DateTime createdAt,
    required String createdBy,
    required String creatorNickname,
    String? secretText,
    String? decipheredBy,
    DateTime? decipheredAt,
  }) = _Crystal;

  const Crystal._();

  /// クリスタルが解読可能かチェック
  ///
  /// - 利用可能（available）状態のみ解読可能
  /// - 自分が作成したクリスタルも解読可能（制限なし）
  bool get canDecipher => status == CrystalStatus.available;

  /// 特定ユーザーが解読可能かチェック（カルマ残高考慮）
  bool canDecipherWithKarma(int userKarma) {
    return canDecipher && userKarma >= karmaValue;
  }

  /// クリスタルの表示テキストを取得
  ///
  /// 解読済みなら実際のテキスト、未解読なら「???」
  String get displayText {
    return status == CrystalStatus.taken && secretText != null
        ? secretText!
        : '???';
  }

  /// クリスタルが特定ユーザーに解読されたかチェック
  bool isDecipheredBy(String userId) {
    return status == CrystalStatus.taken && decipheredBy == userId;
  }

  /// 感情タイプの表示名を取得
  String get emotionDisplayName => aiMetadata.emotionType.displayName;
}
