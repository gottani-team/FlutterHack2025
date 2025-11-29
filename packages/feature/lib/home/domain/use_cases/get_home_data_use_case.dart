import 'package:core/domain/use_cases/base_use_case.dart';
import 'package:feature/home/domain/entities/home_entity.dart';
import 'package:feature/home/domain/repositories/home_repository.dart';

/// ホームデータを取得するユースケース
class GetHomeDataUseCase implements UseCaseNoParams<HomeEntity> {
  const GetHomeDataUseCase(this._repository);

  final HomeRepository _repository;

  @override
  Future<HomeEntity> call() async {
    return await _repository.getHomeData();
  }
}

