import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'collected_crystals_provider.g.dart';

/// Provider that fetches collected crystals for the current user
@riverpod
Future<List<CollectedCrystal>> collectedCrystals(Ref ref) async {
  final journalRepo = ref.read(journalRepositoryProvider);
  final crystalsResult = await journalRepo.getAllCollectedCrystals();

  switch (crystalsResult) {
    case Success(value: final crystals):
      return crystals;
    case Failure():
      throw Exception(
        'Failed to fetch collected crystals: ${crystalsResult.error.message}',
      );
  }
}
