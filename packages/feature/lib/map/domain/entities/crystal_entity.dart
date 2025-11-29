import 'package:equatable/equatable.dart';

/// Emotion types that classify the crystal's visual appearance and energy
enum EmotionType {
  /// Red color - Represents passion, excitement, love
  passion,

  /// Blue color - Represents silence, calm, introspection
  silence,

  /// Yellow color - Represents joy, happiness, optimism
  joy,

  /// Green color - Represents healing, growth, nature
  healing,
}

/// Extension to get visual properties for emotion types
extension EmotionTypeExtension on EmotionType {
  /// Get the color code for map visualization
  int get colorValue {
    switch (this) {
      case EmotionType.passion:
        return 0xFFE53935; // Red
      case EmotionType.silence:
        return 0xFF1E88E5; // Blue
      case EmotionType.joy:
        return 0xFFFFB300; // Yellow
      case EmotionType.healing:
        return 0xFF43A047; // Green
    }
  }

  /// Get the display name in Japanese
  String get displayName {
    switch (this) {
      case EmotionType.passion:
        return '情熱';
      case EmotionType.silence:
        return '静寂';
      case EmotionType.joy:
        return '歓喜';
      case EmotionType.healing:
        return '癒し';
    }
  }
}

/// Represents a buried memory crystal in the 地脈 (earth vein) system.
///
/// Each crystal contains a user's memory that has been transformed into
/// a unique visual artifact and placed at a specific location.
class CrystalEntity extends Equatable {
  /// Unique identifier for the crystal
  final String id;

  /// The memory text content stored in the crystal
  final String memoryText;

  /// Classification of the crystal's emotion
  final EmotionType emotionType;

  /// URL to the AI-generated crystal image
  final String imageUrl;

  /// User ID of the creator who buried this crystal
  final String creatorId;

  /// Current latitude coordinate (updates when respawned)
  final double latitude;

  /// Current longitude coordinate (updates when respawned)
  final double longitude;

  /// Timestamp when the crystal was originally created
  final DateTime createdAt;

  /// Number of times this crystal has been mined
  final int miningCount;

  const CrystalEntity({
    required this.id,
    required this.memoryText,
    required this.emotionType,
    required this.imageUrl,
    required this.creatorId,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.miningCount = 0,
  });

  @override
  List<Object?> get props => [
        id,
        memoryText,
        emotionType,
        imageUrl,
        creatorId,
        latitude,
        longitude,
        createdAt,
        miningCount,
      ];
}
