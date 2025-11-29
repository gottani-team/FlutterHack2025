import 'dart:developer' as dev;

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
    dev.log('[AuthRepo] signInAnonymously: Starting anonymous sign in');
    try {
      final userModel = await _authService.signInAnonymously();
      dev.log('[AuthRepo] signInAnonymously: Success, userId=${userModel.id}');
      return Result.success(userModel.toUserSession());
    } on firebase_auth.FirebaseAuthException catch (e) {
      dev.log('[AuthRepo] signInAnonymously: FirebaseAuthException code=${e.code}, message=${e.message}');
      return Result.failure(
        CoreFailure.auth(
          message: e.message ?? 'Firebase Authentication failed',
          code: e.code,
        ),
      );
    } on FirebaseException catch (e) {
      dev.log('[AuthRepo] signInAnonymously: FirebaseException code=${e.code}, message=${e.message}');
      return Result.failure(
        CoreFailure.network(
          message: e.message ?? 'Failed to save user to Firestore',
          code: e.code,
        ),
      );
    } catch (e) {
      dev.log('[AuthRepo] signInAnonymously: Unknown error: $e');
      return Result.failure(
        CoreFailure.unknown(
          message: 'Unexpected error during sign in: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<UserSession>> getCurrentSession() async {
    dev.log('[AuthRepo] getCurrentSession: Getting current session');
    try {
      final userModel = await _authService.getCurrentUser();
      dev.log('[AuthRepo] getCurrentSession: Success, userId=${userModel.id}');
      return Result.success(userModel.toUserSession());
    } on StateError {
      dev.log('[AuthRepo] getCurrentSession: No authenticated user');
      return Result.failure(
        const CoreFailure.auth(
          message: 'No authenticated user',
        ),
      );
    } catch (e) {
      dev.log('[AuthRepo] getCurrentSession: Unknown error: $e');
      return Result.failure(
        CoreFailure.unknown(
          message: 'Failed to get current session: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Stream<Result<UserSession?>> authStateChanges() {
    dev.log('[AuthRepo] authStateChanges: Starting auth state stream');
    try {
      return _authService
          .authStateChanges()
          .map<Result<UserSession?>>((userModel) {
        if (userModel == null) {
          dev.log('[AuthRepo] authStateChanges: User signed out');
          return Result.success(null);
        }
        dev.log('[AuthRepo] authStateChanges: User signed in, userId=${userModel.id}');
        return Result.success(userModel.toUserSession());
      }).handleError((error) {
        dev.log('[AuthRepo] authStateChanges: Stream error: $error');
        return Result.failure(
          CoreFailure.unknown(
            message: 'Auth state stream error: ${error.toString()}',
          ),
        );
      });
    } catch (e) {
      dev.log('[AuthRepo] authStateChanges: Failed to create stream: $e');
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
    dev.log('[AuthRepo] signOut: Starting sign out');
    try {
      await _authService.signOut();
      dev.log('[AuthRepo] signOut: Success');
      return Result.success(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      dev.log('[AuthRepo] signOut: FirebaseAuthException code=${e.code}, message=${e.message}');
      return Result.failure(
        CoreFailure.auth(
          message: e.message ?? 'Sign out failed',
          code: e.code,
        ),
      );
    } catch (e) {
      dev.log('[AuthRepo] signOut: Unknown error: $e');
      return Result.failure(
        CoreFailure.unknown(
          message: 'Unexpected error during sign out: ${e.toString()}',
        ),
      );
    }
  }
}
