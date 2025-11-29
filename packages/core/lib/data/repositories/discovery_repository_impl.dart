import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/common/result.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/memory_crystal.dart';
import '../../domain/failures/core_failure.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../datasources/firestore_discovery_service.dart';

/// DiscoveryRepository の実装
///
/// Firestore Discovery Service を使用してクリスタル発見機能を提供する。
/// エラーハンドリングとデータ変換のロジックを担当。
class DiscoveryRepositoryImpl implements DiscoveryRepository {
  DiscoveryRepositoryImpl(this._discoveryService);
  final FirestoreDiscoveryService _discoveryService;

  @override
  Future<Result<List<MemoryCrystal>>> discoverNearby({
    required Location location,
    double radiusKm = 1.0,
    int limit = 50,
  }) async {
    try {
      final models = await _discoveryService.findNearby(
        location: location,
        radiusKm: radiusKm,
        limit: limit,
      );

      final entities = models.map((model) => model.toEntity()).toList();

      return Result.success(entities);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Result.failure(
          CoreFailure.permission(
            message: 'No permission to read crystals: ${e.message ?? ""}',
          ),
        );
      }

      return Result.failure(
        CoreFailure.network(
          message: 'Failed to discover crystals: ${e.message ?? ""}',
          code: e.code,
        ),
      );
    } catch (e, stackTrace) {
      return Result.failure(
        CoreFailure.unknown(
          message: 'Unexpected error during discovery: $e\n$stackTrace',
        ),
      );
    }
  }

  @override
  Future<Result<MemoryCrystal>> getCrystalById(String id) async {
    try {
      final model = await _discoveryService.getCrystalById(id);
      return Result.success(model.toEntity());
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return Result.failure(
          CoreFailure.notFound(
            message: 'Crystal with id $id not found',
          ),
        );
      }

      if (e.code == 'permission-denied') {
        return Result.failure(
          CoreFailure.permission(
            message: 'No permission to read crystal: ${e.message ?? ""}',
          ),
        );
      }

      return Result.failure(
        CoreFailure.network(
          message: 'Failed to get crystal: ${e.message ?? ""}',
          code: e.code,
        ),
      );
    } catch (e, stackTrace) {
      return Result.failure(
        CoreFailure.unknown(
          message: 'Unexpected error getting crystal: $e\n$stackTrace',
        ),
      );
    }
  }

  @override
  Stream<Result<List<MemoryCrystal>>> watchNearby({
    required Location location,
    double radiusKm = 1.0,
    int limit = 50,
  }) async* {
    try {
      final stream = await _discoveryService.watchNearby(
        location: location,
        radiusKm: radiusKm,
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
                message:
                    'No permission to watch crystals: ${error.message ?? ""}',
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
