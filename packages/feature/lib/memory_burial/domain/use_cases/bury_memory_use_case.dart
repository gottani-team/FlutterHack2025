import 'package:core/domain/use_cases/base_use_case.dart';

import '../entities/geo_location.dart';
import '../entities/memory_burial_entity.dart';
import '../repositories/memory_burial_repository.dart';

/// 記憶を埋葬するユースケース
class BuryMemoryUseCase
    implements UseCase<MemoryBurialEntity, BuryMemoryParams> {
  BuryMemoryUseCase({
    required MemoryBurialRepository memoryBurialRepository,
  }) : _memoryBurialRepository = memoryBurialRepository;

  final MemoryBurialRepository _memoryBurialRepository;

  @override
  Future<MemoryBurialEntity> call(BuryMemoryParams params) async {
    // 記憶を埋葬
    final result = await _memoryBurialRepository.buryMemory(
      memoryText: params.memoryText,
      location: params.location,
    );

    return result;
  }
}

/// BuryMemoryUseCaseのパラメータ
class BuryMemoryParams extends Params {
  const BuryMemoryParams({
    required this.memoryText,
    required this.location,
  });

  final String memoryText;
  final GeoLocation location;

  @override
  List<Object?> get props => [memoryText, location];
}
