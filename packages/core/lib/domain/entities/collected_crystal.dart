import 'package:freezed_annotation/freezed_annotation.dart';

import 'ai_metadata.dart';
import 'crystal_tier.dart';

part 'collected_crystal.freezed.dart';

/// 収集されたクリスタル（ジャーナル用）
///
/// ユーザーが解読したクリスタルのコピー。
/// ジャーナル画面で過去に解読した秘密を閲覧するために使用。
@freezed
abstract class CollectedCrystal with _$CollectedCrystal {
  /// 収集されたクリスタルを作成
  ///
  /// [id]: ドキュメント ID（元のcrystalIdと同じ）
  /// [secretText]: 明かされた秘密
  /// [karmaCost]: 支払ったカルマ
  /// [aiMetadata]: AI解析メタデータ
  /// [decipheredAt]: 解読日時
  /// [originalCreatorId]: 元の作成者ID
  /// [originalCreatorNickname]: 元の作成者のニックネーム
  const factory CollectedCrystal({
    required String id,
    required String secretText,
    required int karmaCost,
    required AIMetadata aiMetadata,
    required DateTime decipheredAt,
    required String originalCreatorId,
    required String originalCreatorNickname,
  }) = _CollectedCrystal;

  const CollectedCrystal._();

  /// 感情タイプの表示名を取得
  String get emotionDisplayName => aiMetadata.emotionType.displayName;

  /// カルマ値に基づくTierを取得
  CrystalTier get tier => aiMetadata.tier;
}
