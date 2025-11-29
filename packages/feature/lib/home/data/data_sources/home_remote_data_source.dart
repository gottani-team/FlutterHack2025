import 'package:core/data/data_sources/remote_data_source.dart';
import 'package:feature/home/data/models/home_model.dart';

/// ホーム機能のリモートデータソース
abstract class HomeRemoteDataSource {
  /// ホームデータを取得
  Future<HomeModel> getHomeData();
}

/// ホーム機能のリモートデータソース実装
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  const HomeRemoteDataSourceImpl(this._remoteDataSource);

  // ignore: unused_field
  final RemoteDataSource _remoteDataSource;

  @override
  Future<HomeModel> getHomeData() async {
    // TODO: 実際のAPI呼び出しを実装
    // final response = await _remoteDataSource.get('/home');
    // return HomeModel.fromJson(response);

    // サンプルデータを返す
    return const HomeModel(
      id: '1',
      title: 'Welcome to Flutter App Template',
      description: 'Start building your app from here!',
    );
  }
}

