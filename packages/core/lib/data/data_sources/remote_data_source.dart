import 'package:core/domain/errors/app_exception.dart';

/// リモートデータソースの基底インターフェース
abstract class RemoteDataSource {
  const RemoteDataSource();

  /// GETリクエスト
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  });

  /// POSTリクエスト
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  });

  /// PUTリクエスト
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  });

  /// DELETEリクエスト
  Future<void> delete(String endpoint);
}

/// リモートデータソースの実装例
class RemoteDataSourceImpl implements RemoteDataSource {
  const RemoteDataSourceImpl();

  @override
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    // TODO: 実際のHTTPクライアント実装
    throw const NetworkException(message: 'Not implemented');
  }

  @override
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    // TODO: 実際のHTTPクライアント実装
    throw const NetworkException(message: 'Not implemented');
  }

  @override
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    // TODO: 実際のHTTPクライアント実装
    throw const NetworkException(message: 'Not implemented');
  }

  @override
  Future<void> delete(String endpoint) async {
    // TODO: 実際のHTTPクライアント実装
    throw const NetworkException(message: 'Not implemented');
  }
}

