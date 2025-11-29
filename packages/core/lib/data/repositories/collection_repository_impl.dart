import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/common/result.dart';
import '../../domain/entities/memory_crystal.dart';
import '../../domain/failures/core_failure.dart';
import '../../domain/repositories/collection_repository.dart';
import '../datasources/firestore_collection_service.dart';

/// CollectionRepository の実装
///
/// Firestore Collection Service を使用してコレクション管理機能を提供する。
/// 統計情報の計算とエラーハンドリングを担当。
class CollectionRepositoryImpl implements CollectionRepository {
  final FirestoreCollectionService _collectionService;

  CollectionRepositoryImpl(this._collectionService);

  @override
  Future<Result<List<MemoryCrystal>>> getExcavatedCrystals({
    required String userId,
    int limit = 50,
  }) async {
    try {
      final models = await _collectionService.getExcavatedCrystals(
        userId: userId,
        limit: limit,
      );

      final entities = models.map((model) => model.toEntity()).toList();

      return Result.success(entities);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Result.failure(
          CoreFailure.permission(
            message: 'No permission to read collection: ${e.message ?? ""}',
          ),
        );
      }

      if (e.code == 'unauthenticated') {
        return Result.failure(
          CoreFailure.auth(
            message: 'User is not authenticated: ${e.message ?? ""}',
            code: e.code,
          ),
        );
      }

      return Result.failure(
        CoreFailure.network(
          message: 'Failed to get excavated crystals: ${e.message ?? ""}',
          code: e.code,
        ),
      );
    } catch (e, stackTrace) {
      return Result.failure(
        CoreFailure.unknown(
          message: 'Unexpected error getting excavated crystals: $e\n$stackTrace',
        ),
      );
    }
  }

  @override
  Future<Result<CollectionStats>> getCollectionStats({
    required String userId,
  }) async {
    try {
      // 全採掘済みクリスタルを取得（limitなし）
      final models = await _collectionService.getExcavatedCrystals(
        userId: userId,
        limit: 1000, // 十分大きな値
      );

      if (models.isEmpty) {
        return Result.success(CollectionStats.empty());
      }

      // 感情タイプごとにカウント
      final emotionCounts = <String, int>{};
      DateTime? firstExcavatedAt;
      DateTime? latestExcavatedAt;

      for (final model in models) {
        // 感情カウント
        final emotionKey = model.emotion.name;
        emotionCounts[emotionKey] = (emotionCounts[emotionKey] ?? 0) + 1;

        // 採掘日時
        if (model.excavatedAt != null) {
          final excavatedAt = model.excavatedAt!.toDate();

          if (firstExcavatedAt == null || excavatedAt.isBefore(firstExcavatedAt)) {
            firstExcavatedAt = excavatedAt;
          }

          if (latestExcavatedAt == null || excavatedAt.isAfter(latestExcavatedAt)) {
            latestExcavatedAt = excavatedAt;
          }
        }
      }

      final stats = CollectionStats(
        totalCount: models.length,
        emotionCounts: emotionCounts,
        firstExcavatedAt: firstExcavatedAt,
        latestExcavatedAt: latestExcavatedAt,
      );

      return Result.success(stats);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Result.failure(
          CoreFailure.permission(
            message: 'No permission to read collection: ${e.message ?? ""}',
          ),
        );
      }

      if (e.code == 'unauthenticated') {
        return Result.failure(
          CoreFailure.auth(
            message: 'User is not authenticated: ${e.message ?? ""}',
            code: e.code,
          ),
        );
      }

      return Result.failure(
        CoreFailure.network(
          message: 'Failed to get collection stats: ${e.message ?? ""}',
          code: e.code,
        ),
      );
    } catch (e, stackTrace) {
      return Result.failure(
        CoreFailure.unknown(
          message: 'Unexpected error getting collection stats: $e\n$stackTrace',
        ),
      );
    }
  }

  @override
  Stream<Result<List<MemoryCrystal>>> watchExcavatedCrystals({
    required String userId,
    int limit = 50,
  }) async* {
    try {
      final stream = await _collectionService.watchExcavatedCrystals(
        userId: userId,
        limit: limit,
      );

      yield* stream.map((models) {
        final entities = models.map((model) => model.toEntity()).toList();
        return Result.success(entities);
      }).handleError((error, stackTrace) {
        if (error is FirebaseException) {
          if (error.code == 'permission-denied') {
            return Result<List<MemoryCrystal>>.failure(
              CoreFailure.permission(
                message: 'No permission to watch collection: ${error.message ?? ""}',
              ),
            );
          }

          if (error.code == 'unauthenticated') {
            return Result<List<MemoryCrystal>>.failure(
              CoreFailure.auth(
                message: 'User is not authenticated: ${error.message ?? ""}',
                code: error.code,
              ),
            );
          }

          return Result<List<MemoryCrystal>>.failure(
            CoreFailure.network(
              message: 'Stream error: ${error.message ?? ""}',
              code: error.code,
            ),
          );
        }

        return Result<List<MemoryCrystal>>.failure(
          CoreFailure.unknown(
            message: 'Unexpected stream error: $error\n$stackTrace',
          ),
        );
      });
    } catch (e, stackTrace) {
      // Initial stream setup error
      yield Result.failure(
        CoreFailure.unknown(
          message: 'Failed to setup watch stream: $e\n$stackTrace',
        ),
      );
    }
  }
}
