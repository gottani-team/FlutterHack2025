import 'package:core/domain/errors/app_exception.dart';

/// ローカルデータソースの基底インターフェース
abstract class LocalDataSource {
  const LocalDataSource();

  /// データを保存
  Future<void> save(String key, String value);

  /// データを取得
  Future<String?> get(String key);

  /// データを削除
  Future<void> delete(String key);

  /// すべてのデータをクリア
  Future<void> clear();
}

/// ローカルデータソースの実装例（SharedPreferencesを使用）
class LocalDataSourceImpl implements LocalDataSource {
  const LocalDataSourceImpl();

  @override
  Future<void> save(String key, String value) async {
    // TODO: SharedPreferences実装
    throw const CacheException(message: 'Not implemented');
  }

  @override
  Future<String?> get(String key) async {
    // TODO: SharedPreferences実装
    throw const CacheException(message: 'Not implemented');
  }

  @override
  Future<void> delete(String key) async {
    // TODO: SharedPreferences実装
    throw const CacheException(message: 'Not implemented');
  }

  @override
  Future<void> clear() async {
    // TODO: SharedPreferences実装
    throw const CacheException(message: 'Not implemented');
  }
}

