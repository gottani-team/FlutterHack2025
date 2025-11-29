import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Domain Repositories
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/crystal_repository.dart';
import '../domain/repositories/decipherment_repository.dart';
import '../domain/repositories/journal_repository.dart';
import '../domain/repositories/sublimation_repository.dart';
import '../domain/repositories/user_repository.dart';

// Data Sources
import 'datasources/firebase_auth_service.dart';

// Repository Implementations
import 'repositories/auth_repository_impl.dart';
import 'repositories/crystal_repository_impl.dart';
import 'repositories/decipherment_repository_impl.dart';
import 'repositories/journal_repository_impl.dart';
import 'repositories/sublimation_repository_impl.dart';
import 'repositories/user_repository_impl.dart';

/// Firestore インスタンス Provider
///
/// アプリ全体で共有されるFirestoreインスタンス。
/// テスト時はこのプロバイダーをオーバーライドしてモックに差し替える。
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Firebase Authentication インスタンス Provider
///
/// アプリ全体で共有されるFirebase Authインスタンス。
/// テスト時はこのプロバイダーをオーバーライドしてモックに差し替える。
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// ========== Authentication ==========

/// FirebaseAuthService Provider
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});

/// AuthRepository Provider
///
/// Feature層はこのプロバイダーを使用して認証機能にアクセスする。
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    authService: ref.watch(firebaseAuthServiceProvider),
  );
});

// ========== User ==========

/// UserRepository Provider
///
/// Feature層はこのプロバイダーを使用してユーザー情報とカルマ管理機能にアクセスする。
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(firestoreProvider));
});

// ========== Sublimation (昇華) ==========

/// SublimationRepository Provider
///
/// Feature層はこのプロバイダーを使用して昇華（秘密→クリスタル変換）機能にアクセスする。
final sublimationRepositoryProvider = Provider<SublimationRepository>((ref) {
  return SublimationRepositoryImpl(ref.watch(firestoreProvider));
});

// ========== Crystal ==========

/// CrystalRepository Provider
///
/// Feature層はこのプロバイダーを使用してクリスタル取得機能にアクセスする。
final crystalRepositoryProvider = Provider<CrystalRepository>((ref) {
  return CrystalRepositoryImpl(ref.watch(firestoreProvider));
});

// ========== Decipherment (解読) ==========

/// DeciphermentRepository Provider
///
/// Feature層はこのプロバイダーを使用してクリスタル解読機能にアクセスする。
final deciphermentRepositoryProvider = Provider<DeciphermentRepository>((ref) {
  return DeciphermentRepositoryImpl(ref.watch(firestoreProvider));
});

// ========== Journal ==========

/// JournalRepository Provider
///
/// Feature層はこのプロバイダーを使用してジャーナル（収集クリスタル）管理機能にアクセスする。
final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepositoryImpl(ref.watch(firestoreProvider));
});
