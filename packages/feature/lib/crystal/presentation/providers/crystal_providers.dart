import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'crystal_providers.g.dart';

/// Mock image URL for crystal (will be replaced with real data later)
const mockCrystalImageUrl = 'assets/images/test-crystal.png';

/// Provider that fetches crystal data by ID
/// Currently returns mock data, will be replaced with real API call later
@riverpod
Future<Crystal> crystal(Ref ref, String crystalId) async {
  final repo = ref.read(crystalRepositoryProvider);
  final result = await repo.getCrystal(crystalId);
  switch (result) {
    case Success(value: final crystal):
      if (crystal == null) {
        throw Exception('Crystal not found');
      }
      return crystal;
    case Failure():
      throw Exception('Failed to fetch crystal: ${result.error.message}');
  }
}
