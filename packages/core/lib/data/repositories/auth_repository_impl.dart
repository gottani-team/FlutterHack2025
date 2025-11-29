import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/common/result.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/failures/core_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_service.dart';

/// 認証リポジトリの実装
///
/// FirebaseAuthServiceを使用して認証機能を提供する。
/// エラーハンドリングを行い、Result型で結果を返す。
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required FirebaseAuthService authService,
  }) : _authService = authService;
  final FirebaseAuthService _authService;

  @override
  Future<Result<UserSession>> signInAnonymously() async {
    try {
      final userModel = await _authService.signInAnonymously();
      return Result.success(userModel.toEntity());
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Result.failure(
        CoreFailure.auth(
          message: e.message ?? 'Firebase Authentication failed',
          code: e.code,
        ),
      );
    } on FirebaseException catch (e) {
      return Result.failure(
        CoreFailure.network(
          message: e.message ?? 'Failed to save user to Firestore',
          code: e.code,
        ),
      );
    } catch (e) {
      return Result.failure(
        CoreFailure.unknown(
          message: 'Unexpected error during sign in: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<UserSession>> getCurrentSession() async {
    try {
      final userModel = await _authService.getCurrentUser();
      return Result.success(userModel.toEntity());
    } on StateError {
      return Result.failure(
        const CoreFailure.auth(
          message: 'No authenticated user',
        ),
      );
    } catch (e) {
      return Result.failure(
        CoreFailure.unknown(
          message: 'Failed to get current session: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Stream<Result<UserSession?>> authStateChanges() {
    try {
      return _authService
          .authStateChanges()
          .map<Result<UserSession?>>((userModel) {
        if (userModel == null) {
          return Result.success(null);
        }
        return Result.success(userModel.toEntity());
      }).handleError((error) {
        return Result.failure(
          CoreFailure.unknown(
            message: 'Auth state stream error: ${error.toString()}',
          ),
        );
      });
    } catch (e) {
      return Stream.value(
        Result.failure(
          CoreFailure.unknown(
            message: 'Failed to create auth state stream: ${e.toString()}',
          ),
        ),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _authService.signOut();
      return Result.success(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Result.failure(
        CoreFailure.auth(
          message: e.message ?? 'Sign out failed',
          code: e.code,
        ),
      );
    } catch (e) {
      return Result.failure(
        CoreFailure.unknown(
          message: 'Unexpected error during sign out: ${e.toString()}',
        ),
      );
    }
  }
}
