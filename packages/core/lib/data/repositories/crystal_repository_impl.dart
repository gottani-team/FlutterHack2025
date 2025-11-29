import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/common/result.dart';
import '../../domain/entities/crystal.dart';
import '../../domain/failures/core_failure.dart';
import '../../domain/repositories/crystal_repository.dart';
import '../models/crystal_model.dart';

/// クリスタルリポジトリの実装
class CrystalRepositoryImpl implements CrystalRepository {
  CrystalRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _crystalsRef =>
      _firestore.collection('crystals');

  @override
  Future<Result<List<Crystal>>> getAvailableCrystals({
    int limit = 20,
  }) async {
    try {
      dev.log('[CrystalRepo] getAvailableCrystals: limit=$limit');

      // Note: Firestoreフィールドはsnake_case
      final snapshot = await _crystalsRef
          .where('status', isEqualTo: 'available')
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      dev.log('[CrystalRepo] getAvailableCrystals: Found ${snapshot.docs.length} crystals');

      final crystals = snapshot.docs.map((doc) {
        return CrystalModel.fromFirestore(doc).toEntity();
      }).toList();

      return Result.success(crystals);
    } on FirebaseException catch (e) {
      return Result.failure(
        CoreFailure.network(
          message: e.message ?? 'Failed to get available crystals',
          code: e.code,
        ),
      );
    } catch (e) {
      return Result.failure(
        CoreFailure.unknown(
          message: 'Failed to get available crystals: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<Crystal?>> getCrystal(String crystalId) async {
    dev.log('[CrystalRepo] getCrystal: crystalId=$crystalId');
    try {
      final doc = await _crystalsRef.doc(crystalId).get();

      if (!doc.exists) {
        dev.log('[CrystalRepo] getCrystal: Crystal not found');
        return Result.success(null);
      }

      final crystal = CrystalModel.fromFirestore(doc).toEntity();
      dev.log('[CrystalRepo] getCrystal: Found crystal, status=${crystal.status}');
      return Result.success(crystal);
    } on FirebaseException catch (e) {
      dev.log('[CrystalRepo] getCrystal: FirebaseException code=${e.code}, message=${e.message}');
      return Result.failure(
        CoreFailure.network(
          message: e.message ?? 'Failed to get crystal',
          code: e.code,
        ),
      );
    } catch (e) {
      dev.log('[CrystalRepo] getCrystal: Unknown error: $e');
      return Result.failure(
        CoreFailure.unknown(
          message: 'Failed to get crystal: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<List<Crystal>>> getCreatedCrystals({
    required String userId,
    int limit = 50,
  }) async {
    dev.log('[CrystalRepo] getCreatedCrystals: userId=$userId, limit=$limit');
    try {
      // Note: Firestoreフィールドはsnake_case
      final snapshot = await _crystalsRef
          .where('created_by', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      dev.log('[CrystalRepo] getCreatedCrystals: Found ${snapshot.docs.length} crystals');

      final crystals = snapshot.docs.map((doc) {
        return CrystalModel.fromFirestore(doc).toEntity();
      }).toList();

      return Result.success(crystals);
    } on FirebaseException catch (e) {
      dev.log('[CrystalRepo] getCreatedCrystals: FirebaseException code=${e.code}, message=${e.message}');
      return Result.failure(
        CoreFailure.network(
          message: e.message ?? 'Failed to get created crystals',
          code: e.code,
        ),
      );
    } catch (e) {
      dev.log('[CrystalRepo] getCreatedCrystals: Unknown error: $e');
      return Result.failure(
        CoreFailure.unknown(
          message: 'Failed to get created crystals: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Stream<Result<List<Crystal>>> watchAvailableCrystals({
    int limit = 20,
  }) {
    dev.log('[CrystalRepo] watchAvailableCrystals: Starting stream, limit=$limit');
    // Note: Firestoreフィールドはsnake_case
    return _crystalsRef
        .where('status', isEqualTo: 'available')
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      dev.log('[CrystalRepo] watchAvailableCrystals: Received ${snapshot.docs.length} crystals');
      final crystals = snapshot.docs.map((doc) {
        return CrystalModel.fromFirestore(doc).toEntity();
      }).toList();
      return Result.success(crystals);
    }).handleError((error) {
      dev.log('[CrystalRepo] watchAvailableCrystals: Stream error: $error');
      if (error is FirebaseException) {
        return Result.failure(
          CoreFailure.network(
            message: error.message ?? 'Failed to watch available crystals',
            code: error.code,
          ),
        );
      }
      return Result.failure(
        CoreFailure.unknown(
          message: 'Failed to watch available crystals: ${error.toString()}',
        ),
      );
    });
  }
}
