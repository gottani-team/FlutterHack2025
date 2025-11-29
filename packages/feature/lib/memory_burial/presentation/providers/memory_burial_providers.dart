import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_sources/memory_burial_remote_data_source.dart';
import '../../data/repositories/memory_burial_repository_impl.dart';
import '../../domain/repositories/memory_burial_repository.dart';
import '../../domain/use_cases/bury_memory_use_case.dart';
import '../../domain/use_cases/get_burial_history_use_case.dart';

// Firebase インスタンス
final firebaseFunctionsProvider = Provider<FirebaseFunctions>((ref) {
  return FirebaseFunctions.instanceFor(region: 'asia-northeast1');
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Data Sources
/// モックモードを使用するかどうか（開発中はtrue）
const bool _useMockDataSource = true;

final memoryBurialRemoteDataSourceProvider =
    Provider<MemoryBurialRemoteDataSource>((ref) {
  if (_useMockDataSource) {
    // モック実装を使用
    return MockMemoryBurialRemoteDataSource();
  }

  // 本番実装を使用
  final functions = ref.watch(firebaseFunctionsProvider);
  final firestore = ref.watch(firestoreProvider);
  return MemoryBurialRemoteDataSourceImpl(
    functions: functions,
    firestore: firestore,
  );
});

// Repositories
final memoryBurialRepositoryProvider = Provider<MemoryBurialRepository>((ref) {
  final remoteDataSource = ref.watch(memoryBurialRemoteDataSourceProvider);
  return MemoryBurialRepositoryImpl(remoteDataSource);
});

// Use Cases
final buryMemoryUseCaseProvider = Provider<BuryMemoryUseCase>((ref) {
  final memoryBurialRepository = ref.watch(memoryBurialRepositoryProvider);
  return BuryMemoryUseCase(
    memoryBurialRepository: memoryBurialRepository,
  );
});

final getBurialHistoryUseCaseProvider =
    Provider<GetBurialHistoryUseCase>((ref) {
  final repository = ref.watch(memoryBurialRepositoryProvider);
  return GetBurialHistoryUseCase(repository);
});

// State Providers
/// ニックネームの状態管理Notifier
class NicknameNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String text) {
    state = text;
  }

  void clear() {
    state = '';
  }
}

/// ニックネームのProvider
final nicknameProvider = NotifierProvider<NicknameNotifier, String>(
  NicknameNotifier.new,
);

/// 記憶テキストの状態管理Notifier
class MemoryTextNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String text) {
    state = text;
  }

  void clear() {
    state = '';
  }
}

/// 記憶テキストのProvider
final memoryTextProvider = NotifierProvider<MemoryTextNotifier, String>(
  MemoryTextNotifier.new,
);

/// ボタン有効化の状態（ニックネーム必須 + テキスト10文字以上250文字以内）
final isButtonEnabledProvider = Provider<bool>((ref) {
  final nickname = ref.watch(nicknameProvider);
  final text = ref.watch(memoryTextProvider);
  return nickname.isNotEmpty && text.length >= 10 && text.length <= 250;
});
