import 'package:core/domain/errors/app_exception.dart';
import 'package:feature/home/domain/entities/home_entity.dart';
import 'package:feature/home/domain/repositories/home_repository.dart';
import 'package:feature/home/data/data_sources/home_remote_data_source.dart';

/// ホーム機能のリポジトリ実装
class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._remoteDataSource);

  final HomeRemoteDataSource _remoteDataSource;

  @override
  Future<HomeEntity> getHomeData() async {
    try {
      final model = await _remoteDataSource.getHomeData();
      return model.toEntity();
    } catch (e) {
      throw ServerException(
        message: 'Failed to get home data: ${e.toString()}',
      );
    }
  }

  @override
  Future<HomeEntity> updateHomeData(HomeEntity entity) async {
    try {
      // TODO: 実際の更新処理を実装
      return entity;
    } catch (e) {
      throw ServerException(
        message: 'Failed to update home data: ${e.toString()}',
      );
    }
  }
}

