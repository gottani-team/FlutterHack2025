import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/common/result.dart';
import '../../domain/entities/collected_crystal.dart';
import '../../domain/failures/core_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/journal_repository.dart';
import '../models/collected_crystal_model.dart';

/// ジャーナルリポジトリの実装
class JournalRepositoryImpl implements JournalRepository {
  JournalRepositoryImpl(
    this._firestore, {
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  CollectionReference<Map<String, dynamic>> _collectedCrystalsRef(
    String userId,
  ) =>
      _firestore
          .collection('users')
          .doc(userId)
          .collection('collected_crystals');

  @override
  Future<Result<List<CollectedCrystal>>> getAllCollectedCrystals() async {
    final userIdResult = await _authRepository.requireUserId();
    switch (userIdResult) {
      case Failure(error: final failure):
        return Result.failure(failure);
      case Success(value: final userId):
        try {
          dev.log(
            '[JournalRepo] getAllCollectedCrystals: userId=$userId',
          );

          // Note: Firestoreのフィールド名はsnake_case
          // ページングなしで全件取得
          final snapshot = await _collectedCrystalsRef(userId)
              .orderBy('deciphered_at', descending: true)
              .get();

          dev.log(
            '[JournalRepo] getAllCollectedCrystals: Found ${snapshot.docs.length} crystals',
          );

          final crystals = snapshot.docs.map((doc) {
            dev.log(
              '[JournalRepo] getAllCollectedCrystals: Processing doc ${doc.id}, data=${doc.data()}',
            );
            return CollectedCrystalModel.fromFirestore(doc).toEntity();
          }).toList();

          dev.log(
            '[JournalRepo] getAllCollectedCrystals: Success with ${crystals.length} crystals',
          );
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
  }

  @override
  Future<Result<CollectedCrystal?>> getCollectedCrystal({
    required String crystalId,
  }) async {
    final userIdResult = await _authRepository.requireUserId();
    switch (userIdResult) {
      case Failure(error: final failure):
        return Result.failure(failure);
      case Success(value: final userId):
        try {
          final doc = await _collectedCrystalsRef(userId).doc(crystalId).get();

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
  }

  @override
  Future<Result<int>> getCollectedCount() async {
    final userIdResult = await _authRepository.requireUserId();
    switch (userIdResult) {
      case Failure(error: final failure):
        return Result.failure(failure);
      case Success(value: final userId):
        try {
          dev.log('[JournalRepo] getCollectedCount: userId=$userId');

          final snapshot = await _collectedCrystalsRef(userId).count().get();

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
}
