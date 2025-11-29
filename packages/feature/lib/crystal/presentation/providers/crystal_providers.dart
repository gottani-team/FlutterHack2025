import 'package:core/domain/entities/emotion_type.dart';
import 'package:core/domain/entities/location.dart';
import 'package:core/domain/entities/memory_crystal.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'crystal_providers.g.dart';

/// Mock image URL for crystal (will be replaced with real data later)
const mockCrystalImageUrl = 'assets/images/test-crystal.png';

/// Get color for emotion type
Color getEmotionColor(EmotionType emotion) {
  switch (emotion) {
    case EmotionType.passion:
      return const Color(0xFFE53935); // Red
    case EmotionType.silence:
      return const Color(0xFF1E88E5); // Blue
    case EmotionType.joy:
      return const Color(0xFFFDD835); // Yellow
    case EmotionType.healing:
      return const Color(0xFF43A047); // Green
  }
}

/// Provider that fetches crystal data by ID
/// Currently returns mock data, will be replaced with real API call later
@riverpod
Future<MemoryCrystal> crystal(Ref ref, String crystalId) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 500));

  // Mock data - replace with real API call later
  return MemoryCrystal(
    id: crystalId,
    location: const Location(
      latitude: 35.6762,
      longitude: 139.6503,
    ),
    emotion: EmotionType.joy,
    creatorId: 'mock-user-001',
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
    isExcavated: true,
    text:
        '深夜の公園で、過去の過ちを独りごちた。誰にも聞かれたくない、心の奥底の叫び。月明かりだけが、その秘密を知っている。後悔と自責の念が、胸を締め付ける。',
    excavatedBy: 'current-user',
    excavatedAt: DateTime.now(),
  );
}
