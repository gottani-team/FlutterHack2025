import 'package:core/domain/entities/base_entity.dart';

import 'geo_location.dart';

/// 埋葬する記憶の情報を表現するドメインエンティティ
class MemoryBurialEntity extends BaseEntity {
  const MemoryBurialEntity({
    required this.id,
    required this.memoryText,
    required this.location,
    required this.buriedAt,
    this.crystalColor,
    this.emotionType,
  });

  /// クリスタルID（UUID）
  final String id;

  /// 記憶テキスト（10～500文字）
  final String memoryText;

  /// 埋葬位置
  final GeoLocation location;

  /// 埋葬日時
  final DateTime buriedAt;

  /// クリスタルの色（サーバーから返されるが表示しない）
  final String? crystalColor;

  /// 感情タイプ（サーバーから返されるが表示しない）
  final String? emotionType;

  @override
  List<Object?> get props => [
        id,
        memoryText,
        location,
        buriedAt,
        crystalColor,
        emotionType,
      ];

  /// copyWithメソッド
  MemoryBurialEntity copyWith({
    String? id,
    String? memoryText,
    GeoLocation? location,
    DateTime? buriedAt,
    String? crystalColor,
    String? emotionType,
  }) {
    return MemoryBurialEntity(
      id: id ?? this.id,
      memoryText: memoryText ?? this.memoryText,
      location: location ?? this.location,
      buriedAt: buriedAt ?? this.buriedAt,
      crystalColor: crystalColor ?? this.crystalColor,
      emotionType: emotionType ?? this.emotionType,
    );
  }
}
