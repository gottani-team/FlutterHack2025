import 'dart:math';

import '../entities/crystal_entity.dart';
import '../entities/crystallization_area_entity.dart';

/// Use case for scanning and generating crystals in a visible area.
///
/// This mock implementation generates random crystals within
/// the specified bounds for development and testing purposes.
class ScanCrystalsUseCase {
  ScanCrystalsUseCase();

  final Random _random = Random();

  // Emotion types with their weights (more common emotions have higher weights)
  static final Map<EmotionType, int> _emotionWeights = {
    EmotionType.joy: 30,
    EmotionType.healing: 25,
    EmotionType.silence: 25,
    EmotionType.passion: 20,
  };

  /// Scan the visible area and return crystals within bounds.
  ///
  /// [minLat], [maxLat], [minLng], [maxLng] define the visible bounding box.
  /// [count] is the number of crystals to generate (default: 3-7 random).
  List<CrystallizationAreaEntity> execute({
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
    int? count,
  }) {
    // Generate random count between 3-7 if not specified
    final crystalCount = count ?? (_random.nextInt(5) + 3);

    final crystals = <CrystallizationAreaEntity>[];

    for (int i = 0; i < crystalCount; i++) {
      // Generate random position within bounds
      final lat = minLat + _random.nextDouble() * (maxLat - minLat);
      final lng = minLng + _random.nextDouble() * (maxLng - minLng);

      // Generate random emotion type based on weights
      final emotionType = _getRandomEmotionType();

      // Generate unique ID
      final id = 'crystal_${DateTime.now().millisecondsSinceEpoch}_$i';

      crystals.add(
        CrystallizationAreaEntity(
          crystalId: id,
          approximateLatitude: lat,
          approximateLongitude: lng,
          emotionType: emotionType,
          status: CrystallizationAreaStatus.active,
        ),
      );
    }

    return crystals;
  }

  /// Get a random emotion type based on configured weights
  EmotionType _getRandomEmotionType() {
    final totalWeight = _emotionWeights.values.reduce((a, b) => a + b);
    var randomValue = _random.nextInt(totalWeight);

    for (final entry in _emotionWeights.entries) {
      randomValue -= entry.value;
      if (randomValue < 0) {
        return entry.key;
      }
    }

    return EmotionType.joy; // Fallback
  }
}

