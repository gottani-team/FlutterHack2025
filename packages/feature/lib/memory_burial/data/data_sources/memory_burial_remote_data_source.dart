import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:core/domain/errors/app_exception.dart';

import '../../domain/errors/memory_burial_exceptions.dart';
import '../models/geo_location_model.dart';
import '../models/memory_burial_model.dart';

/// Memory Burialのリモートデータソース（Cloud Functions + Firestore）
abstract class MemoryBurialRemoteDataSource {
  /// 記憶を埋葬する（Cloud Functions呼び出し）
  Future<MemoryBurialModel> buryMemory({
    required String memoryText,
    required double latitude,
    required double longitude,
  });

  /// 埋葬履歴を取得する（Firestore直接アクセス）
  Future<List<MemoryBurialModel>> getBurialHistory({
    required String userId,
    int limit = 20,
  });

  /// 特定のクリスタルを取得する（Firestore直接アクセス）
  Future<MemoryBurialModel> getCrystal(String crystalId);
}

/// モック実装（開発・テスト用）
class MockMemoryBurialRemoteDataSource implements MemoryBurialRemoteDataSource {
  @override
  Future<MemoryBurialModel> buryMemory({
    required String memoryText,
    required double latitude,
    required double longitude,
  }) async {
    // 2秒の遅延をシミュレート（アニメーション時間に合わせる）
    await Future.delayed(const Duration(seconds: 2));

    // モックレスポンスを返す
    return MemoryBurialModel(
      id: 'mock_crystal_${DateTime.now().millisecondsSinceEpoch}',
      memoryText: memoryText,
      location: GeoLocationModel(
        latitude: latitude,
        longitude: longitude,
      ),
      buriedAt: DateTime.now(),
      crystalColor: '#9B7ED9', // 紫色
      emotionType: 'nostalgia',
    );
  }

  @override
  Future<List<MemoryBurialModel>> getBurialHistory({
    required String userId,
    int limit = 20,
  }) async {
    // モックデータを返す
    return [];
  }

  @override
  Future<MemoryBurialModel> getCrystal(String crystalId) async {
    // モックデータを返す
    return MemoryBurialModel(
      id: crystalId,
      memoryText: 'モックの記憶テキスト',
      location: const GeoLocationModel(
        latitude: 35.6812,
        longitude: 139.7671,
      ),
      buriedAt: DateTime.now(),
      crystalColor: '#9B7ED9',
      emotionType: 'nostalgia',
    );
  }
}

/// MemoryBurialRemoteDataSourceの実装
class MemoryBurialRemoteDataSourceImpl implements MemoryBurialRemoteDataSource {
  MemoryBurialRemoteDataSourceImpl({
    required FirebaseFunctions functions,
    required FirebaseFirestore firestore,
  })  : _functions = functions,
        _firestore = firestore;

  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;

  @override
  Future<MemoryBurialModel> buryMemory({
    required String memoryText,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final callable = _functions.httpsCallable('buryMemory');

      final result = await callable.call({
        'memoryText': memoryText,
        'location': {
          'latitude': latitude,
          'longitude': longitude,
        },
      }).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw const MemoryBurialTimeoutException(),
      );

      final data = result.data as Map<String, dynamic>;

      if (data['success'] != true) {
        throw MemoryBurialServerException(
          data['error']?['message'] as String? ?? 'サーバーエラー',
        );
      }

      // Cloud Functionsのレスポンスから直接Modelを構築
      return MemoryBurialModel(
        id: data['crystalId'] as String,
        memoryText: memoryText,
        location: GeoLocationModel(
          latitude: latitude,
          longitude: longitude,
        ),
        buriedAt: DateTime.parse(data['buriedAt'] as String),
        crystalColor: data['crystalColor'] as String?,
        emotionType: data['emotionType'] as String?,
      );
    } on FirebaseFunctionsException catch (e) {
      throw _mapFirebaseFunctionsException(e);
    } on MemoryBurialTimeoutException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw const MemoryBurialNetworkException();
    }
  }

  @override
  Future<List<MemoryBurialModel>> getBurialHistory({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('crystals')
          .where('creatorUserId', isEqualTo: userId)
          .orderBy('buriedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        // GeoPointをGeoLocationModelに変換
        final geoPoint = data['location'] as GeoPoint;
        final modifiedData = {
          ...data,
          'location': {
            'latitude': geoPoint.latitude,
            'longitude': geoPoint.longitude,
          },
        };
        return MemoryBurialModel.fromJson(modifiedData);
      }).toList();
    } catch (e) {
      throw const MemoryBurialServerException('埋葬履歴の取得に失敗しました');
    }
  }

  @override
  Future<MemoryBurialModel> getCrystal(String crystalId) async {
    try {
      final doc = await _firestore.collection('crystals').doc(crystalId).get();

      if (!doc.exists) {
        throw const NotFoundException('クリスタルが見つかりませんでした');
      }

      final data = doc.data()!;
      // GeoPointをGeoLocationModelに変換
      final geoPoint = data['location'] as GeoPoint;
      final modifiedData = {
        ...data,
        'location': {
          'latitude': geoPoint.latitude,
          'longitude': geoPoint.longitude,
        },
      };
      return MemoryBurialModel.fromJson(modifiedData);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw const MemoryBurialServerException('クリスタルの取得に失敗しました');
    }
  }

  /// FirebaseFunctionsExceptionをアプリケーション例外に変換
  Exception _mapFirebaseFunctionsException(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return const UnauthorizedException('認証が必要です');
      case 'invalid-argument':
        return InvalidMemoryTextException(e.message ?? '入力値が不正です');
      case 'deadline-exceeded':
        return const MemoryBurialTimeoutException();
      case 'resource-exhausted':
        return const RateLimitException('リクエスト制限を超過しました');
      case 'internal':
      default:
        return MemoryBurialServerException(
          e.message ?? 'サーバーエラーが発生しました',
        );
    }
  }
}
