import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/common/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/failures/core_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

/// ユーザーリポジトリの実装
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._firestore, {required AuthRepository authRepository})
      : _authRepository = authRepository;

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  // ========== 内部ヘルパー ==========

  /// 内部用: ユーザー情報を取得（userIdを指定）
  Future<Result<User?>> _getUser(String userId) async {
    dev.log('[UserRepo] _getUser: userId=$userId');
    try {
      final doc = await _usersRef.doc(userId).get();
      if (!doc.exists) {
        dev.log('[UserRepo] _getUser: User not found');
        return Result.success(null);
      }
      final model = UserModel.fromFirestore(doc);
      dev.log('[UserRepo] _getUser: Found user, karma=${model.currentKarma}');
      return Result.success(model.toEntity());
    } on FirebaseException catch (e) {
      dev.log(
        '[UserRepo] _getUser: FirebaseException code=${e.code}, message=${e.message}',
      );
      return Result.failure(
        CoreFailure.network(
          message: e.message ?? 'Failed to get user',
          code: e.code,
        ),
      );
    } catch (e) {
      dev.log('[UserRepo] _getUser: Unknown error: $e');
      return Result.failure(
        CoreFailure.unknown(
          message: 'Failed to get user: ${e.toString()}',
        ),
      );
    }
  }

  /// 内部用: ユーザーを作成（userIdを指定）
  Future<Result<User>> _createUser({
    required String userId,
    int initialKarma = 0,
  }) async {
    dev.log(
      '[UserRepo] _createUser: userId=$userId, initialKarma=$initialKarma',
    );
    try {
      final now = Timestamp.now();
      final model = UserModel(
        id: userId,
        currentKarma: initialKarma,
        createdAt: now,
      );

      await _usersRef.doc(userId).set(model.toFirestore());

      dev.log('[UserRepo] _createUser: Success');
      return Result.success(model.toEntity());
    } on FirebaseException catch (e) {
      dev.log(
        '[UserRepo] _createUser: FirebaseException code=${e.code}, message=${e.message}',
      );
      return Result.failure(
        CoreFailure.network(
          message: e.message ?? 'Failed to create user',
          code: e.code,
        ),
      );
    } catch (e) {
      dev.log('[UserRepo] _createUser: Unknown error: $e');
      return Result.failure(
        CoreFailure.unknown(
          message: 'Failed to create user: ${e.toString()}',
        ),
      );
    }
  }

  // ========== パブリックAPI ==========

  @override
  Future<Result<User?>> getCurrentUser() async {
    final userIdResult = await _authRepository.requireUserId();
    switch (userIdResult) {
      case Success(value: final userId):
        return _getUser(userId);
      case Failure(error: final failure):
        return Result.failure(failure);
    }
  }

  @override
  Future<Result<User>> getOrCreateCurrentUser({
    int initialKarma = 0,
  }) async {
    final userIdResult = await _authRepository.requireUserId();
    switch (userIdResult) {
      case Success(value: final userId):
        dev.log(
          '[UserRepo] getOrCreateCurrentUser: userId=$userId, initialKarma=$initialKarma',
        );
        final getResult = await _getUser(userId);

        switch (getResult) {
          case Success(value: final user):
            if (user != null) {
              dev.log('[UserRepo] getOrCreateCurrentUser: User exists');
              return Result.success(user);
            }
            dev.log('[UserRepo] getOrCreateCurrentUser: Creating new user');
            return _createUser(userId: userId, initialKarma: initialKarma);
          case Failure(error: final failure):
            dev.log('[UserRepo] getOrCreateCurrentUser: Failed to get user');
            return Result.failure(failure);
        }
      case Failure(error: final failure):
        return Result.failure(failure);
    }
  }

  @override
  Future<Result<int>> getKarma() async {
    final userIdResult = await _authRepository.requireUserId();
    switch (userIdResult) {
      case Success(value: final userId):
        dev.log('[UserRepo] getKarma: userId=$userId');
        final result = await _getUser(userId);

        switch (result) {
          case Success(value: final user):
            if (user == null) {
              dev.log('[UserRepo] getKarma: User not found');
              return Result.failure(
                const CoreFailure.notFound(
                  message: 'User not found',
                ),
              );
            }
            dev.log('[UserRepo] getKarma: karma=${user.currentKarma}');
            return Result.success(user.currentKarma);
          case Failure(error: final failure):
            dev.log('[UserRepo] getKarma: Failed');
            return Result.failure(failure);
        }
      case Failure(error: final failure):
        return Result.failure(failure);
    }
  }

  @override
  Future<Result<int>> addKarma({
    required int amount,
  }) async {
    final userIdResult = await _authRepository.requireUserId();
    switch (userIdResult) {
      case Success(value: final userId):
        dev.log('[UserRepo] addKarma: userId=$userId, amount=$amount');
        try {
          final docRef = _usersRef.doc(userId);

          return await _firestore.runTransaction((transaction) async {
            final doc = await transaction.get(docRef);

            if (!doc.exists) {
              dev.log('[UserRepo] addKarma: User not found');
              throw const CoreFailure.notFound(message: 'User not found');
            }

            final currentKarma =
                (doc.data()?['current_karma'] as num?)?.toInt() ?? 0;
            final newKarma = currentKarma + amount;

            dev.log('[UserRepo] addKarma: $currentKarma + $amount = $newKarma');
            transaction.update(docRef, {'current_karma': newKarma});

            return Result.success(newKarma);
          });
        } on CoreFailure catch (e) {
          return Result.failure(e);
        } on FirebaseException catch (e) {
          dev.log(
            '[UserRepo] addKarma: FirebaseException code=${e.code}, message=${e.message}',
          );
          return Result.failure(
            CoreFailure.network(
              message: e.message ?? 'Failed to add karma',
              code: e.code,
            ),
          );
        } catch (e) {
          dev.log('[UserRepo] addKarma: Unknown error: $e');
          return Result.failure(
            CoreFailure.unknown(
              message: 'Failed to add karma: ${e.toString()}',
            ),
          );
        }
      case Failure(error: final failure):
        return Result.failure(failure);
    }
  }

  @override
  Future<Result<int>> subtractKarma({
    required int amount,
  }) async {
    final userIdResult = await _authRepository.requireUserId();
    switch (userIdResult) {
      case Success(value: final userId):
        dev.log('[UserRepo] subtractKarma: userId=$userId, amount=$amount');
        try {
          final docRef = _usersRef.doc(userId);

          return await _firestore.runTransaction((transaction) async {
            final doc = await transaction.get(docRef);

            if (!doc.exists) {
              dev.log('[UserRepo] subtractKarma: User not found');
              throw const CoreFailure.notFound(message: 'User not found');
            }

            final currentKarma =
                (doc.data()?['current_karma'] as num?)?.toInt() ?? 0;

            if (currentKarma < amount) {
              dev.log(
                '[UserRepo] subtractKarma: Insufficient karma ($currentKarma < $amount)',
              );
              throw CoreFailure.insufficientKarma(
                message: 'Insufficient karma',
                required: amount,
                available: currentKarma,
              );
            }

            final newKarma = currentKarma - amount;

            dev.log(
              '[UserRepo] subtractKarma: $currentKarma - $amount = $newKarma',
            );
            transaction.update(docRef, {'current_karma': newKarma});

            return Result.success(newKarma);
          });
        } on CoreFailure catch (e) {
          return Result.failure(e);
        } on FirebaseException catch (e) {
          dev.log(
            '[UserRepo] subtractKarma: FirebaseException code=${e.code}, message=${e.message}',
          );
          return Result.failure(
            CoreFailure.network(
              message: e.message ?? 'Failed to subtract karma',
              code: e.code,
            ),
          );
        } catch (e) {
          dev.log('[UserRepo] subtractKarma: Unknown error: $e');
          return Result.failure(
            CoreFailure.unknown(
              message: 'Failed to subtract karma: ${e.toString()}',
            ),
          );
        }
      case Failure(error: final failure):
        return Result.failure(failure);
    }
  }

  @override
  Future<Result<int>> setKarma({
    required int amount,
  }) async {
    final userIdResult = await _authRepository.requireUserId();
    switch (userIdResult) {
      case Success(value: final userId):
        dev.log('[UserRepo] setKarma: userId=$userId, amount=$amount');
        try {
          final docRef = _usersRef.doc(userId);

          return await _firestore.runTransaction((transaction) async {
            final doc = await transaction.get(docRef);

            if (!doc.exists) {
              dev.log('[UserRepo] setKarma: User not found');
              throw const CoreFailure.notFound(message: 'User not found');
            }

            dev.log('[UserRepo] setKarma: Setting karma to $amount');
            transaction.update(docRef, {'current_karma': amount});

            return Result.success(amount);
          });
        } on CoreFailure catch (e) {
          return Result.failure(e);
        } on FirebaseException catch (e) {
          dev.log(
            '[UserRepo] setKarma: FirebaseException code=${e.code}, message=${e.message}',
          );
          return Result.failure(
            CoreFailure.network(
              message: e.message ?? 'Failed to set karma',
              code: e.code,
            ),
          );
        } catch (e) {
          dev.log('[UserRepo] setKarma: Unknown error: $e');
          return Result.failure(
            CoreFailure.unknown(
              message: 'Failed to set karma: ${e.toString()}',
            ),
          );
        }
      case Failure(error: final failure):
        return Result.failure(failure);
    }
  }

  @override
  Stream<Result<User?>> watchCurrentUser() {
    // キャッシュされたユーザーIDを使用（Streamなので同期的にアクセス）
    final userId = _authRepository.cachedUserId;
    if (userId == null) {
      dev.log('[UserRepo] watchCurrentUser: No cached userId');
      return Stream.value(
        Result.failure(const CoreFailure.auth(message: 'Not authenticated')),
      );
    }

    dev.log('[UserRepo] watchCurrentUser: Starting stream, userId=$userId');
    return _usersRef.doc(userId).snapshots().map((doc) {
      if (!doc.exists) {
        dev.log('[UserRepo] watchCurrentUser: User not found');
        return Result.success(null);
      }
      final model = UserModel.fromFirestore(doc);
      dev.log(
        '[UserRepo] watchCurrentUser: Received update, karma=${model.currentKarma}',
      );
      return Result.success(model.toEntity());
    }).handleError((error) {
      dev.log('[UserRepo] watchCurrentUser: Stream error: $error');
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
