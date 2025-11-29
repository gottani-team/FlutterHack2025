import 'package:core/domain/repositories/base_repository.dart';
import 'package:feature/home/domain/entities/home_entity.dart';

/// ホーム機能のリポジトリインターフェース
abstract class HomeRepository extends BaseRepository {
  /// ホームデータを取得
  Future<HomeEntity> getHomeData();

  /// ホームデータを更新
  Future<HomeEntity> updateHomeData(HomeEntity entity);
}

