import 'package:core/domain/repositories/location_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/geo_location.dart';
import '../../domain/entities/memory_burial_entity.dart';
import '../../domain/use_cases/bury_memory_use_case.dart';

/// 埋葬処理の状態
enum MemoryBurialStatus {
  /// 初期状態（入力待ち）
  initial,

  /// 処理中（アニメーション＋API呼び出し）
  processing,

  /// 成功
  success,

  /// エラー
  error,
}

/// 埋葬処理の状態クラス
class MemoryBurialState extends Equatable {
  const MemoryBurialState({
    this.status = MemoryBurialStatus.initial,
    this.result,
    this.errorMessage,
  });

  final MemoryBurialStatus status;
  final MemoryBurialEntity? result;
  final String? errorMessage;

  MemoryBurialState copyWith({
    MemoryBurialStatus? status,
    MemoryBurialEntity? result,
    String? errorMessage,
  }) {
    return MemoryBurialState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, result, errorMessage];
}

/// 埋葬処理の状態管理Notifier
class MemoryBurialNotifier extends Notifier<MemoryBurialState> {
  @override
  MemoryBurialState build() {
    return const MemoryBurialState();
  }

  /// 記憶を埋葬する
  Future<void> buryMemory(
    String memoryText,
    BuryMemoryUseCase buryMemoryUseCase,
    LocationRepository locationRepository,
  ) async {
    // 処理中に設定
    state = state.copyWith(status: MemoryBurialStatus.processing);

    try {
      // 位置情報を取得
      final coreLocation = await locationRepository.getCurrentLocation();

      // CoreのGeoLocationをFeatureのGeoLocationに変換
      final location = GeoLocation(
        latitude: coreLocation.latitude,
        longitude: coreLocation.longitude,
      );

      // 埋葬処理を実行
      final result = await buryMemoryUseCase.call(
        BuryMemoryParams(
          memoryText: memoryText,
          location: location,
        ),
      );

      // 成功状態に設定
      state = state.copyWith(
        status: MemoryBurialStatus.success,
        result: result,
        errorMessage: null,
      );
    } catch (e) {
      // エラー状態に設定
      state = state.copyWith(
        status: MemoryBurialStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 状態をリセット
  void reset() {
    state = const MemoryBurialState();
  }
}

/// MemoryBurialNotifierのProvider
final memoryBurialNotifierProvider =
    NotifierProvider<MemoryBurialNotifier, MemoryBurialState>(
  MemoryBurialNotifier.new,
);
