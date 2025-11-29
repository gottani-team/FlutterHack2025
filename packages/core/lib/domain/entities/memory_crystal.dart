import 'package:freezed_annotation/freezed_annotation.dart';
import 'emotion_type.dart';
import 'location.dart';

part 'memory_crystal.freezed.dart';

/// メモリークリスタルエンティティ
///
/// 位置に埋められた記憶データを表現する。
/// 採掘されるまでテキスト内容は不明（isExcavated = false）。
@freezed
abstract class MemoryCrystal with _$MemoryCrystal {
  /// メモリークリスタルを作成
  ///
  /// [id]: Firestore ドキュメント ID
  /// [location]: GPS位置情報
  /// [emotion]: 感情タイプ（AI分析結果）
  /// [creatorId]: 作成者のユーザーID
  /// [createdAt]: 作成日時
  /// [isExcavated]: 採掘済みフラグ
  /// [text]: 記憶テキスト（採掘後のみ表示）
  /// [excavatedBy]: 採掘者ID（採掘後のみ）
  /// [excavatedAt]: 採掘日時（採掘後のみ）
  const factory MemoryCrystal({
    required String id,
    required Location location,
    required EmotionType emotion,
    required String creatorId,
    required DateTime createdAt,
    @Default(false) bool isExcavated,
    String? text,
    String? excavatedBy,
    DateTime? excavatedAt,
  }) = _MemoryCrystal;

  const MemoryCrystal._();

  /// クリスタルが採掘可能かチェック
  ///
  /// - 自分が作成したクリスタルは採掘不可
  /// - すでに採掘済みのクリスタルは採掘不可
  bool canExcavate(String userId) {
    return !isExcavated && creatorId != userId;
  }

  /// クリスタルの表示テキストを取得
  ///
  /// 採掘済みなら実際のテキスト、未採掘なら「???」
  String get displayText {
    return isExcavated && text != null ? text! : '???';
  }

  /// クリスタルが特定ユーザーに採掘されたかチェック
  bool isExcavatedBy(String userId) {
    return isExcavated && excavatedBy == userId;
  }
}
