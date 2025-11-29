import 'package:equatable/equatable.dart';

import 'crystal_entity.dart';

/// Status of a crystallization area on the map
enum CrystallizationAreaStatus {
  /// Crystal is active and available for discovery
  active,

  /// Crystal is currently being mined by another user
  beingMined,

  /// Crystal is respawning after being mined
  respawning,
}

/// Represents a discoverable crystal location on the map.
///
/// This is a derived visualization entity from [CrystalEntity] that contains
/// the display properties for the map without exposing exact coordinates
/// or memory content until discovered.
class CrystallizationAreaEntity extends Equatable {
  /// Reference to the underlying crystal
  final String crystalId;

  /// Approximate center latitude (slightly randomized from actual)
  final double approximateLatitude;

  /// Approximate center longitude (slightly randomized from actual)
  final double approximateLongitude;

  /// Emotion type determines the pulsing light color
  final EmotionType emotionType;

  /// Current status of this area
  final CrystallizationAreaStatus status;

  /// Outer detection radius in meters (triggers heartbeat phase)
  static const double outerDetectionRadius = 100.0;

  /// Inner detection radius in meters (triggers mining screen)
  static const double innerDetectionRadius = 25.0;

  const CrystallizationAreaEntity({
    required this.crystalId,
    required this.approximateLatitude,
    required this.approximateLongitude,
    required this.emotionType,
    this.status = CrystallizationAreaStatus.active,
  });

  @override
  List<Object?> get props => [
        crystalId,
        approximateLatitude,
        approximateLongitude,
        emotionType,
        status,
      ];
}
