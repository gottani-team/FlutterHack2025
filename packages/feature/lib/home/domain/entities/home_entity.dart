import 'package:core/domain/entities/base_entity.dart';

/// ホーム機能のエンティティ
class HomeEntity extends BaseEntity {
  const HomeEntity({
    required this.id,
    required this.title,
    this.description,
  });

  final String id;
  final String title;
  final String? description;

  @override
  List<Object?> get props => [id, title, description];
}

