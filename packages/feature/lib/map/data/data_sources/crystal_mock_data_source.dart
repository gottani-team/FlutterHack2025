import '../../domain/entities/crystal_entity.dart';
import '../../domain/entities/crystallization_area_entity.dart';

/// Mock data source for crystal data.
///
/// Provides sample crystal data for development and testing.
/// Firestore integration is out of scope for MVP.
class CrystalMockDataSource {
  CrystalMockDataSource._();

  static final CrystalMockDataSource instance = CrystalMockDataSource._();

  /// Sample crystals for testing proximity detection and map display.
  /// Locations are around Tokyo Station area.
  final List<CrystalEntity> _mockCrystals = [
    CrystalEntity(
      id: 'crystal_001',
      memoryText: '桜の下で出会った友人との大切な時間。あの日の温かさは今でも心に残っている。',
      emotionType: EmotionType.joy,
      imageUrl: 'https://example.com/crystals/joy_001.png',
      creatorId: 'user_mock_001',
      latitude: 35.6812,
      longitude: 139.7671,
      createdAt: DateTime(2025, 11, 1),
      miningCount: 3,
    ),
    CrystalEntity(
      id: 'crystal_002',
      memoryText: '静かな夜、一人で見上げた星空。言葉にできない感情が溢れた瞬間。',
      emotionType: EmotionType.silence,
      imageUrl: 'https://example.com/crystals/silence_001.png',
      creatorId: 'user_mock_002',
      latitude: 35.6825,
      longitude: 139.7690,
      createdAt: DateTime(2025, 11, 5),
      miningCount: 1,
    ),
    CrystalEntity(
      id: 'crystal_003',
      memoryText: '初めて好きな人に告白した日。心臓が破裂しそうだった。',
      emotionType: EmotionType.passion,
      imageUrl: 'https://example.com/crystals/passion_001.png',
      creatorId: 'user_mock_003',
      latitude: 35.6800,
      longitude: 139.7650,
      createdAt: DateTime(2025, 11, 10),
      miningCount: 5,
    ),
    CrystalEntity(
      id: 'crystal_004',
      memoryText: '祖母の庭で過ごした夏休み。あの匂いと風を今でも覚えている。',
      emotionType: EmotionType.healing,
      imageUrl: 'https://example.com/crystals/healing_001.png',
      creatorId: 'user_mock_004',
      latitude: 35.6835,
      longitude: 139.7660,
      createdAt: DateTime(2025, 11, 15),
      miningCount: 2,
    ),
    CrystalEntity(
      id: 'crystal_005',
      memoryText: '長年の夢が叶った瞬間。涙が止まらなかった。',
      emotionType: EmotionType.joy,
      imageUrl: 'https://example.com/crystals/joy_002.png',
      creatorId: 'user_mock_005',
      latitude: 35.6790,
      longitude: 139.7700,
      createdAt: DateTime(2025, 11, 20),
      miningCount: 0,
    ),
  ];

  /// Get all mock crystals
  List<CrystalEntity> getAllCrystals() => List.unmodifiable(_mockCrystals);

  /// Get crystals within a bounding box (simulates geo-query)
  List<CrystalEntity> getCrystalsInBounds({
    required double minLatitude,
    required double maxLatitude,
    required double minLongitude,
    required double maxLongitude,
  }) {
    return _mockCrystals.where((crystal) {
      return crystal.latitude >= minLatitude &&
          crystal.latitude <= maxLatitude &&
          crystal.longitude >= minLongitude &&
          crystal.longitude <= maxLongitude;
    }).toList();
  }

  /// Convert crystals to crystallization areas for map display
  List<CrystallizationAreaEntity> getCrystallizationAreas({
    required double minLatitude,
    required double maxLatitude,
    required double minLongitude,
    required double maxLongitude,
  }) {
    final crystals = getCrystalsInBounds(
      minLatitude: minLatitude,
      maxLatitude: maxLatitude,
      minLongitude: minLongitude,
      maxLongitude: maxLongitude,
    );

    return crystals.map((crystal) {
      // Add slight randomization to hide exact location (±20m approx)
      final latOffset = (crystal.id.hashCode % 100 - 50) * 0.0002;
      final lonOffset = (crystal.id.hashCode % 77 - 38) * 0.0002;

      return CrystallizationAreaEntity(
        crystalId: crystal.id,
        approximateLatitude: crystal.latitude + latOffset,
        approximateLongitude: crystal.longitude + lonOffset,
        emotionType: crystal.emotionType,
        status: CrystallizationAreaStatus.active,
      );
    }).toList();
  }

  /// Get a specific crystal by ID
  CrystalEntity? getCrystalById(String id) {
    try {
      return _mockCrystals.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

