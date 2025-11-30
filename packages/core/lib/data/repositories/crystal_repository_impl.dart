import 'dart:developer' as dev;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/common/result.dart';
import '../../domain/entities/crystal.dart';
import '../../domain/failures/core_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/crystal_repository.dart';
import '../models/crystal_model.dart';

/// クリスタルリポジトリの実装
class CrystalRepositoryImpl implements CrystalRepository {
  CrystalRepositoryImpl(
    this._firestore, {
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  CollectionReference<Map<String, dynamic>> get _crystalsRef =>
      _firestore.collection('crystals');

  @override
  Future<Result<List<Crystal>>> getRandomAvailableCrystals({
    int limit = 20,
  }) async {
    try {
      dev.log('[CrystalRepo] getRandomAvailableCrystals: limit=$limit');

      if (_authRepository.cachedUserId == null) {
        await _authRepository.getCurrentSession();
      }

      // Note: Firestoreフィールドはsnake_case
      // 全ての利用可能なクリスタルを取得してランダムに選択
      // - 自分が作成したもの以外
      final snapshot = await _crystalsRef
          .where('status', isEqualTo: 'available')
          .where('created_by', isNotEqualTo: _authRepository.cachedUserId!)
          .get();

      dev.log(
        '[CrystalRepo] getRandomAvailableCrystals: Found ${snapshot.docs.length} total crystals',
      );

      final allCrystals = snapshot.docs.map((doc) {
        return CrystalModel.fromFirestore(doc).toEntity();
      }).toList();

      // ランダムにシャッフルして指定件数を取得
      allCrystals.shuffle(Random());
      final crystals = allCrystals.take(limit).toList();

      dev.log(
        '[CrystalRepo] getRandomAvailableCrystals: Returning ${crystals.length} random crystals',
      );

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
      dev.log(
        '[CrystalRepo] getCrystal: Found crystal, status=${crystal.status}',
      );
      return Result.success(crystal);
    } on FirebaseException catch (e) {
      dev.log(
        '[CrystalRepo] getCrystal: FirebaseException code=${e.code}, message=${e.message}',
      );
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
    int limit = 50,
  }) async {
    final userIdResult = await _authRepository.requireUserId();
    switch (userIdResult) {
      case Failure(error: final failure):
        return Result.failure(failure);
      case Success(value: final userId):
        dev.log(
          '[CrystalRepo] getCreatedCrystals: userId=$userId, limit=$limit',
        );
        try {
          // Note: Firestoreフィールドはsnake_case
          final snapshot = await _crystalsRef
              .where('created_by', isEqualTo: userId)
              .orderBy('created_at', descending: true)
              .limit(limit)
              .get();

          dev.log(
            '[CrystalRepo] getCreatedCrystals: Found ${snapshot.docs.length} crystals',
          );

          final crystals = snapshot.docs.map((doc) {
            return CrystalModel.fromFirestore(doc).toEntity();
          }).toList();

          return Result.success(crystals);
        } on FirebaseException catch (e) {
          dev.log(
            '[CrystalRepo] getCreatedCrystals: FirebaseException code=${e.code}, message=${e.message}',
          );
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
  }

  @override
  Stream<Result<List<Crystal>>> watchRandomAvailableCrystals({
    int limit = 20,
  }) {
    dev.log(
      '[CrystalRepo] watchRandomAvailableCrystals: Starting stream, limit=$limit',
    );
    // Note: Firestoreフィールドはsnake_case
    // 全件取得してランダムに選択
    return _crystalsRef
        .where('status', isEqualTo: 'available')
        .snapshots()
        .map((snapshot) {
      dev.log(
        '[CrystalRepo] watchRandomAvailableCrystals: Received ${snapshot.docs.length} total crystals',
      );
      final allCrystals = snapshot.docs.map((doc) {
        return CrystalModel.fromFirestore(doc).toEntity();
      }).toList();

      // ランダムにシャッフルして指定件数を取得
      allCrystals.shuffle(Random());
      final crystals = allCrystals.take(limit).toList();

      dev.log(
        '[CrystalRepo] watchRandomAvailableCrystals: Returning ${crystals.length} random crystals',
      );
      return Result.success(crystals);
    }).handleError((error) {
      dev.log(
        '[CrystalRepo] watchRandomAvailableCrystals: Stream error: $error',
      );
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
