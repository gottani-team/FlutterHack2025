import 'package:core/data/data_sources/remote_data_source.dart';
import 'package:feature/haiku/data/data_sources/haiku_remote_data_source.dart';
import 'package:feature/haiku/data/models/haiku_model.dart';
import 'package:feature/haiku/data/repositories/haiku_repository_impl.dart';
import 'package:feature/haiku/domain/repositories/haiku_repository.dart';
import 'package:feature/haiku/domain/use_cases/get_haiku_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'haiku_providers.g.dart';

// Data Sources
final haikuRemoteDataSourceProvider = Provider<HaikuRemoteDataSource>((ref) {
  return HaikuRemoteDataSourceImpl(const RemoteDataSourceImpl());
});

// Repositories
final haikuRepositoryProvider = Provider<HaikuRepository>((ref) {
  final remoteDataSource = ref.watch(haikuRemoteDataSourceProvider);
  return HaikuRepositoryImpl(remoteDataSource);
});

// Use Cases
final generateHaikuUseCaseProvider = Provider<GenerateHaikuUseCase>((ref) {
  final repository = ref.watch(haikuRepositoryProvider);
  return GenerateHaikuUseCase(repository);
});

// Presentation Providers
@riverpod
Stream<HaikuModel> generateHaikuStream(Ref ref, String theme) {
  if (theme.isEmpty) {
    return const Stream.empty();
  }

  final useCase = ref.watch(generateHaikuUseCaseProvider);
  return useCase.call(theme);
}

@riverpod
Future<String> getHeaderImageUrl(Ref ref) async {
  final repository = ref.watch(haikuRepositoryProvider);
  return await repository.loadImageUrl();
}
