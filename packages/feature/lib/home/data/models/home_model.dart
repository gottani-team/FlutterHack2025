import 'package:core/data/models/base_model.dart';
import 'package:feature/home/domain/entities/home_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_model.g.dart';

/// ホーム機能のデータモデル
@JsonSerializable()
class HomeModel extends BaseModel<HomeEntity> {
  const HomeModel({
    required this.id,
    required this.title,
    this.description,
  });

  final String id;
  final String title;
  final String? description;

  /// JSONからモデルを作成
  factory HomeModel.fromJson(Map<String, dynamic> json) =>
      _$HomeModelFromJson(json);

  /// モデルをJSONに変換
  Map<String, dynamic> toJson() => _$HomeModelToJson(this);

  @override
  HomeEntity toEntity() {
    return HomeEntity(
      id: id,
      title: title,
      description: description,
    );
  }
}
