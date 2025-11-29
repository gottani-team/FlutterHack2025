import 'package:core/domain/use_cases/base_use_case.dart';
import 'package:feature/haiku/data/models/haiku_model.dart';
import 'package:feature/haiku/domain/repositories/haiku_repository.dart';

class GenerateHaikuUseCase {
  final HaikuRepository _repository;

  GenerateHaikuUseCase(this._repository);

  Stream<HaikuModel> call(String theme) {
    return _repository.generateHaiku(theme);
  }
}

class LoadImageUrlUseCase implements UseCaseNoParams<String> {
  final HaikuRepository _repository;

  LoadImageUrlUseCase(this._repository);

  @override
  Future<String> call() async {
    return await _repository.loadImageUrl();
  }
}
