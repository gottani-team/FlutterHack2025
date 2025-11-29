import 'package:core/domain/errors/app_exception.dart';
import 'package:feature/haiku/data/data_sources/haiku_remote_data_source.dart';
import 'package:feature/haiku/data/models/haiku_model.dart';
import 'package:feature/haiku/domain/repositories/haiku_repository.dart';

class HaikuRepositoryImpl implements HaikuRepository {
  final HaikuRemoteDataSource _remoteDataSource;

  HaikuRepositoryImpl(this._remoteDataSource);

  @override
  Stream<HaikuModel> generateHaiku(String theme) {
    return _remoteDataSource.generateHaiku(theme).handleError((error) {
      throw ServerException(
        message: '俳句の生成に失敗しました: ${error.toString()}',
      );
    });
  }

  @override
  Future<String> loadImageUrl() async {
    return await _remoteDataSource.loadImageUrl();
  }
}
