import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
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
import 'datasources/karma_evaluation_service.dart';
import 'datasources/secret_text_generator_service.dart';

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

/// Firebase Remote Config Provider
///
/// カルマ評価プロンプトなどの設定値を取得するためのRemote Configインスタンス。
final remoteConfigProvider = Provider<FirebaseRemoteConfig>((ref) {
  return FirebaseRemoteConfig.instance;
});

/// KarmaEvaluationService Provider
///
/// Firebase AI Logic を使用してテキストを評価するサービス。
final karmaEvaluationServiceProvider = Provider<KarmaEvaluationService>((ref) {
  return KarmaEvaluationService(
    remoteConfig: ref.watch(remoteConfigProvider),
  );
});

/// SublimationRepository Provider
///
/// Feature層はこのプロバイダーを使用して昇華（秘密→クリスタル変換）機能にアクセスする。
final sublimationRepositoryProvider = Provider<SublimationRepository>((ref) {
  return SublimationRepositoryImpl(
    ref.watch(firestoreProvider),
    karmaEvaluationService: ref.watch(karmaEvaluationServiceProvider),
  );
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

// ========== Debug Services ==========

/// SecretTextGeneratorService Provider
///
/// デバッグ用: 指定した感情とカルマ値に基づいて秘密テキストを生成する。
final secretTextGeneratorServiceProvider =
    Provider<SecretTextGeneratorService>((ref) {
  return SecretTextGeneratorService();
});
