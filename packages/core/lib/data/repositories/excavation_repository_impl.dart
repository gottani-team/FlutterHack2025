import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/common/result.dart';
import '../../domain/entities/memory_crystal.dart';
import '../../domain/failures/core_failure.dart';
import '../../domain/repositories/excavation_repository.dart';
import '../datasources/firestore_excavation_service.dart';

/// ExcavationRepository の実装
///
/// Firestore Excavation Service を使用してクリスタル採掘機能を提供する。
/// エラーハンドリングとビジネスロジックのマッピングを担当。
class ExcavationRepositoryImpl implements ExcavationRepository {
  final FirestoreExcavationService _excavationService;

  ExcavationRepositoryImpl(this._excavationService);

  @override
  Future<Result<MemoryCrystal>> excavateCrystal({
    required String crystalId,
    required String userId,
  }) async {
    try {
      final model = await _excavationService.excavateCrystal(
        crystalId: crystalId,
        userId: userId,
      );

      return Result.success(model.toEntity());
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return Result.failure(
          CoreFailure.notFound(
            message: 'Crystal with id $crystalId not found',
          ),
        );
      }

      if (e.code == 'permission-denied') {
        return Result.failure(
          CoreFailure.permission(
            message: 'No permission to excavate crystals: ${e.message ?? ""}',
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
          message: 'Failed to excavate crystal: ${e.message ?? ""}',
          code: e.code,
        ),
      );
    } on Exception catch (e) {
      final errorMessage = e.toString();

      // ビジネスルール違反のエラーをマッピング
      if (errorMessage.contains('Cannot excavate own crystal')) {
        return Result.failure(
          CoreFailure.permission(
            message: 'Cannot excavate your own crystal',
          ),
        );
      }

      if (errorMessage.contains('already excavated')) {
        return Result.failure(
          CoreFailure.duplicate(
            message: 'Crystal has already been excavated',
          ),
        );
      }

      return Result.failure(
        CoreFailure.unknown(
          message: 'Unexpected error during excavation: $e',
        ),
      );
    } catch (e, stackTrace) {
      return Result.failure(
        CoreFailure.unknown(
          message: 'Unexpected error during excavation: $e\n$stackTrace',
        ),
      );
    }
  }

  @override
  Future<Result<bool>> canExcavateCrystal({
    required String crystalId,
    required String userId,
  }) async {
    try {
      final canExcavate = await _excavationService.canExcavateCrystal(
        crystalId: crystalId,
        userId: userId,
      );

      return Result.success(canExcavate);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return Result.failure(
          CoreFailure.notFound(
            message: 'Crystal with id $crystalId not found',
          ),
        );
      }

      if (e.code == 'permission-denied') {
        return Result.failure(
          CoreFailure.permission(
            message: 'No permission to read crystals: ${e.message ?? ""}',
          ),
        );
      }

      return Result.failure(
        CoreFailure.network(
          message: 'Failed to check excavation status: ${e.message ?? ""}',
          code: e.code,
        ),
      );
    } catch (e, stackTrace) {
      return Result.failure(
        CoreFailure.unknown(
          message: 'Unexpected error checking excavation status: $e\n$stackTrace',
        ),
      );
    }
  }
}
