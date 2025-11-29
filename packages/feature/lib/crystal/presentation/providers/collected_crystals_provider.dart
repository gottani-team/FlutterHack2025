import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'collected_crystals_provider.g.dart';

/// Provider that fetches collected crystals for the current user
@riverpod
Future<List<CollectedCrystal>> collectedCrystals(Ref ref) async {
  // Get current user session
  final authRepo = ref.read(authRepositoryProvider);
  final sessionResult = await authRepo.getCurrentSession();

  switch (sessionResult) {
    case Success(value: final session):
      // Fetch collected crystals for the user
      final journalRepo = ref.read(journalRepositoryProvider);
      final crystalsResult = await journalRepo.getCollectedCrystals(
        userId: session.id,
      );

      switch (crystalsResult) {
        case Success(value: final crystals):
          return crystals;
        case Failure():
          throw Exception(
            'Failed to fetch collected crystals: ${crystalsResult.error.message}',
          );
      }
    case Failure():
      throw Exception('Not authenticated: ${sessionResult.error.message}');
  }
}
