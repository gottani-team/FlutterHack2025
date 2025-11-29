import 'package:core/domain/entities/base_entity.dart';

/// すべてのモデルの基底クラス
/// モデルはエンティティに変換可能である必要がある
abstract class BaseModel<T extends BaseEntity> {
  const BaseModel();

  /// エンティティに変換
  T toEntity();
}

