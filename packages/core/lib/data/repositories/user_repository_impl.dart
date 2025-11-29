import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/common/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/failures/core_failure.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

/// ユーザーリポジトリの実装
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  @override
  Future<Result<User?>> getUser(String userId) async {
    try {
      final doc = await _usersRef.doc(userId).get();
      if (!doc.exists) {
        return Result.success(null);
      }
      final model = UserModel.fromFirestore(doc);
      return Result.success(model.toEntity());
    } on FirebaseException catch (e) {
      return Result.failure(
        CoreFailure.network(
          message: e.message ?? 'Failed to get user',
          code: e.code,
        ),
      );
    } catch (e) {
      return Result.failure(
        CoreFailure.unknown(
          message: 'Failed to get user: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<User>> createUser({
    required String userId,
    int initialKarma = 0,
  }) async {
    try {
      final now = Timestamp.now();
      final model = UserModel(
        id: userId,
        currentKarma: initialKarma,
        createdAt: now,
      );

      await _usersRef.doc(userId).set(model.toFirestore());

      return Result.success(model.toEntity());
    } on FirebaseException catch (e) {
      return Result.failure(
        CoreFailure.network(
          message: e.message ?? 'Failed to create user',
          code: e.code,
        ),
      );
    } catch (e) {
      return Result.failure(
        CoreFailure.unknown(
          message: 'Failed to create user: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<User>> getOrCreateUser({
    required String userId,
    int initialKarma = 0,
  }) async {
    final getResult = await getUser(userId);

    switch (getResult) {
      case Success(value: final user):
        if (user != null) {
          return Result.success(user);
        }
        return createUser(userId: userId, initialKarma: initialKarma);
      case Failure(error: final failure):
        return Result.failure(failure);
    }
  }

  @override
  Future<Result<int>> getKarma(String userId) async {
    final result = await getUser(userId);

    switch (result) {
      case Success(value: final user):
        if (user == null) {
          return Result.failure(
            const CoreFailure.notFound(
              message: 'User not found',
            ),
          );
        }
        return Result.success(user.currentKarma);
      case Failure(error: final failure):
        return Result.failure(failure);
    }
  }

  @override
  Future<Result<int>> addKarma({
    required String userId,
    required int amount,
  }) async {
    try {
      final docRef = _usersRef.doc(userId);

      return await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);

        if (!doc.exists) {
          throw const CoreFailure.notFound(message: 'User not found');
        }

        final currentKarma = (doc.data()?['current_karma'] as num?)?.toInt() ?? 0;
        final newKarma = currentKarma + amount;

        transaction.update(docRef, {'current_karma': newKarma});

        return Result.success(newKarma);
      });
    } on CoreFailure catch (e) {
      return Result.failure(e);
    } on FirebaseException catch (e) {
      return Result.failure(
        CoreFailure.network(
          message: e.message ?? 'Failed to add karma',
          code: e.code,
        ),
      );
    } catch (e) {
      return Result.failure(
        CoreFailure.unknown(
          message: 'Failed to add karma: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<int>> subtractKarma({
    required String userId,
    required int amount,
  }) async {
    try {
      final docRef = _usersRef.doc(userId);

      return await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);

        if (!doc.exists) {
          throw const CoreFailure.notFound(message: 'User not found');
        }

        final currentKarma = (doc.data()?['current_karma'] as num?)?.toInt() ?? 0;

        if (currentKarma < amount) {
          throw CoreFailure.insufficientKarma(
            message: 'Insufficient karma',
            required: amount,
            available: currentKarma,
          );
        }

        final newKarma = currentKarma - amount;

        transaction.update(docRef, {'current_karma': newKarma});

        return Result.success(newKarma);
      });
    } on CoreFailure catch (e) {
      return Result.failure(e);
    } on FirebaseException catch (e) {
      return Result.failure(
        CoreFailure.network(
          message: e.message ?? 'Failed to subtract karma',
          code: e.code,
        ),
      );
    } catch (e) {
      return Result.failure(
        CoreFailure.unknown(
          message: 'Failed to subtract karma: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Stream<Result<User?>> watchUser(String userId) {
    return _usersRef.doc(userId).snapshots().map((doc) {
      if (!doc.exists) {
        return Result.success(null);
      }
      final model = UserModel.fromFirestore(doc);
      return Result.success(model.toEntity());
    }).handleError((error) {
      if (error is FirebaseException) {
        return Result.failure(
          CoreFailure.network(
            message: error.message ?? 'Failed to watch user',
            code: error.code,
          ),
        );
      }
      return Result.failure(
        CoreFailure.unknown(
          message: 'Failed to watch user: ${error.toString()}',
        ),
      );
    });
  }
}
