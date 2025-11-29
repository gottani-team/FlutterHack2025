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
    try {
      final doc = await _crystalsRef.doc(crystalId).get();

      if (!doc.exists) {
        return Result.success(null);
      }

      final crystal = CrystalModel.fromFirestore(doc).toEntity();
      return Result.success(crystal);
    } on FirebaseException catch (e) {
      return Result.failure(
        CoreFailure.network(
          message: e.message ?? 'Failed to get crystal',
          code: e.code,
        ),
      );
    } catch (e) {
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
    try {
      // Note: Firestoreフィールドはsnake_case
      final snapshot = await _crystalsRef
          .where('created_by', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      final crystals = snapshot.docs.map((doc) {
        return CrystalModel.fromFirestore(doc).toEntity();
      }).toList();

      return Result.success(crystals);
    } on FirebaseException catch (e) {
      return Result.failure(
        CoreFailure.network(
          message: e.message ?? 'Failed to get created crystals',
          code: e.code,
        ),
      );
    } catch (e) {
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
    // Note: Firestoreフィールドはsnake_case
    return _crystalsRef
        .where('status', isEqualTo: 'available')
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final crystals = snapshot.docs.map((doc) {
        return CrystalModel.fromFirestore(doc).toEntity();
      }).toList();
      return Result.success(crystals);
    }).handleError((error) {
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
