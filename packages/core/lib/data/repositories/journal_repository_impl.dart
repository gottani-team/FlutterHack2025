import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/common/result.dart';
import '../../domain/entities/collected_crystal.dart';
import '../../domain/failures/core_failure.dart';
import '../../domain/repositories/journal_repository.dart';
import '../models/collected_crystal_model.dart';

/// ジャーナルリポジトリの実装
class JournalRepositoryImpl implements JournalRepository {
  JournalRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collectedCrystalsRef(
    String userId,
  ) =>
      _firestore
          .collection('users')
          .doc(userId)
          .collection('collected_crystals');

  @override
  Future<Result<List<CollectedCrystal>>> getCollectedCrystals({
    required String userId,
    int limit = 50,
  }) async {
    try {
      dev.log('[JournalRepo] getCollectedCrystals: userId=$userId, limit=$limit');

      // Note: Firestoreのフィールド名はsnake_case
      final snapshot = await _collectedCrystalsRef(userId)
          .orderBy('deciphered_at', descending: true)
          .limit(limit)
          .get();

      dev.log('[JournalRepo] getCollectedCrystals: Found ${snapshot.docs.length} crystals');

      final crystals = snapshot.docs.map((doc) {
        dev.log('[JournalRepo] getCollectedCrystals: Processing doc ${doc.id}, data=${doc.data()}');
        return CollectedCrystalModel.fromFirestore(doc).toEntity();
      }).toList();

      dev.log('[JournalRepo] getCollectedCrystals: Success with ${crystals.length} crystals');
      return Result.success(crystals);
    } on FirebaseException catch (e) {
      return Result.failure(
        CoreFailure.network(
          message: e.message ?? 'Failed to get collected crystals',
          code: e.code,
        ),
      );
    } catch (e) {
      return Result.failure(
        CoreFailure.unknown(
          message: 'Failed to get collected crystals: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<CollectedCrystal?>> getCollectedCrystal({
    required String userId,
    required String crystalId,
  }) async {
    try {
      final doc =
          await _collectedCrystalsRef(userId).doc(crystalId).get();

      if (!doc.exists) {
        return Result.success(null);
      }

      final crystal = CollectedCrystalModel.fromFirestore(doc).toEntity();
      return Result.success(crystal);
    } on FirebaseException catch (e) {
      return Result.failure(
        CoreFailure.network(
          message: e.message ?? 'Failed to get collected crystal',
          code: e.code,
        ),
      );
    } catch (e) {
      return Result.failure(
        CoreFailure.unknown(
          message: 'Failed to get collected crystal: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<int>> getCollectedCount({
    required String userId,
  }) async {
    try {
      dev.log('[JournalRepo] getCollectedCount: userId=$userId');

      final snapshot =
          await _collectedCrystalsRef(userId).count().get();

      dev.log('[JournalRepo] getCollectedCount: count=${snapshot.count}');
      return Result.success(snapshot.count ?? 0);
    } on FirebaseException catch (e) {
      return Result.failure(
        CoreFailure.network(
          message: e.message ?? 'Failed to get collected count',
          code: e.code,
        ),
      );
    } catch (e) {
      return Result.failure(
        CoreFailure.unknown(
          message: 'Failed to get collected count: ${e.toString()}',
        ),
      );
    }
  }
}
