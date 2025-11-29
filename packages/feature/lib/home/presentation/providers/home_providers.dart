import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/data/data_sources/remote_data_source.dart';
import 'package:core/data/data_sources/local_data_source.dart';
import 'package:feature/home/data/data_sources/home_remote_data_source.dart';
import 'package:feature/home/data/repositories/home_repository_impl.dart';
import 'package:feature/home/domain/repositories/home_repository.dart';
import 'package:feature/home/domain/use_cases/get_home_data_use_case.dart';
import 'package:feature/home/domain/entities/home_entity.dart';

// Data Sources
final remoteDataSourceProvider = Provider<RemoteDataSource>((ref) {
  return const RemoteDataSourceImpl();
});

final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return const LocalDataSourceImpl();
});

// Feature-specific Data Sources
final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  final remoteDataSource = ref.watch(remoteDataSourceProvider);
  return HomeRemoteDataSourceImpl(remoteDataSource);
});

// Repositories
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final remoteDataSource = ref.watch(homeRemoteDataSourceProvider);
  return HomeRepositoryImpl(remoteDataSource);
});

// Use Cases
final getHomeDataUseCaseProvider = Provider<GetHomeDataUseCase>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return GetHomeDataUseCase(repository);
});

// State Providers
final homeDataProvider = FutureProvider<HomeEntity>((ref) async {
  final useCase = ref.watch(getHomeDataUseCaseProvider);
  return await useCase.call();
});
