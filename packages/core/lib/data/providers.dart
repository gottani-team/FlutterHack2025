import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/collection_repository.dart';
import '../domain/repositories/creation_repository.dart';
import '../domain/repositories/discovery_repository.dart';
import '../domain/repositories/excavation_repository.dart';
import 'datasources/firebase_auth_service.dart';
import 'datasources/firestore_collection_service.dart';
import 'datasources/firestore_creation_service.dart';
import 'datasources/firestore_discovery_service.dart';
import 'datasources/firestore_excavation_service.dart';
import 'repositories/auth_repository_impl.dart';
import 'repositories/collection_repository_impl.dart';
import 'repositories/creation_repository_impl.dart';
import 'repositories/discovery_repository_impl.dart';
import 'repositories/excavation_repository_impl.dart';

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

// ========== Authentication (User Story 1) ==========

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

// ========== Discovery (User Story 2) ==========

/// FirestoreDiscoveryService Provider
final firestoreDiscoveryServiceProvider =
    Provider<FirestoreDiscoveryService>((ref) {
  return FirestoreDiscoveryService(ref.watch(firestoreProvider));
});

/// DiscoveryRepository Provider
///
/// Feature層はこのプロバイダーを使用してクリスタル発見機能にアクセスする。
final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  return DiscoveryRepositoryImpl(
    ref.watch(firestoreDiscoveryServiceProvider),
  );
});

// ========== Creation (User Story 3) ==========

/// FirestoreCreationService Provider
final firestoreCreationServiceProvider =
    Provider<FirestoreCreationService>((ref) {
  return FirestoreCreationService(ref.watch(firestoreProvider));
});

/// CreationRepository Provider
///
/// Feature層はこのプロバイダーを使用してクリスタル作成機能にアクセスする。
final creationRepositoryProvider = Provider<CreationRepository>((ref) {
  return CreationRepositoryImpl(
    ref.watch(firestoreCreationServiceProvider),
  );
});

// ========== Excavation (User Story 4) ==========

/// FirestoreExcavationService Provider
final firestoreExcavationServiceProvider =
    Provider<FirestoreExcavationService>((ref) {
  return FirestoreExcavationService(ref.watch(firestoreProvider));
});

/// ExcavationRepository Provider
///
/// Feature層はこのプロバイダーを使用してクリスタル採掘機能にアクセスする。
final excavationRepositoryProvider = Provider<ExcavationRepository>((ref) {
  return ExcavationRepositoryImpl(
    ref.watch(firestoreExcavationServiceProvider),
  );
});

// ========== Collection (User Story 5) ==========

/// FirestoreCollectionService Provider
final firestoreCollectionServiceProvider =
    Provider<FirestoreCollectionService>((ref) {
  return FirestoreCollectionService(ref.watch(firestoreProvider));
});

/// CollectionRepository Provider
///
/// Feature層はこのプロバイダーを使用してコレクション管理機能にアクセスする。
final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  return CollectionRepositoryImpl(
    ref.watch(firestoreCollectionServiceProvider),
  );
});
