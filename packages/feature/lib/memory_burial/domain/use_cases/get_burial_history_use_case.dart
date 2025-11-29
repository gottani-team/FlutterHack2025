import 'package:core/domain/use_cases/base_use_case.dart';

import '../entities/memory_burial_entity.dart';
import '../repositories/memory_burial_repository.dart';

/// 埋葬履歴を取得するユースケース
class GetBurialHistoryUseCase
    implements UseCase<List<MemoryBurialEntity>, String> {
  GetBurialHistoryUseCase(this._repository);

  final MemoryBurialRepository _repository;

  @override
  Future<List<MemoryBurialEntity>> call(String userId) async {
    return await _repository.getBurialHistory(
      userId: userId,
      limit: 20,
    );
  }
}
