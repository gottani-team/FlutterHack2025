import 'package:json_annotation/json_annotation.dart';
import 'package:feature/haiku/domain/entities/haiku_entity.dart';

part 'haiku_model.g.dart';

@JsonSerializable()
class HaikuModel {
  final String id;
  final String theme;
  final String content;
  final DateTime createdAt;

  const HaikuModel({
    required this.id,
    required this.theme,
    required this.content,
    required this.createdAt,
  });

  factory HaikuModel.fromJson(Map<String, dynamic> json) =>
      _$HaikuModelFromJson(json);

  Map<String, dynamic> toJson() => _$HaikuModelToJson(this);

  HaikuEntity toEntity() {
    return HaikuEntity(
      id: id,
      theme: theme,
      content: content,
      createdAt: createdAt,
    );
  }
}

