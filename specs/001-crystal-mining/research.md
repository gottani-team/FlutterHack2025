# Research: Crystal Mining and Memory Reading Screen

**Feature**: 001-crystal-mining
**Date**: 2025-11-29
**Scope**: UI/Presentation layer only

## Research Areas

### 1. Crystal Shake Animation

**Decision**: Use Flutter's built-in `AnimationController` with `Transform.translate`

**Rationale**:
- Simple shake effect using random offset values
- No external packages needed
- Easy to trigger on each tap

**Implementation**:
```dart
// On tap: animate crystal with small random X/Y offsets
// Duration: ~100-200ms
// Return to center position
```

### 2. Audio Playback

**Decision**: Use `audioplayers` package (^6.0.0)

**Rationale**:
- Lightweight, well-maintained
- Simple API for short sound effects
- Good performance for synchronized feedback

### 3. Haptic Feedback

**Decision**: Use Flutter's built-in `HapticFeedback.mediumImpact()`

**Rationale**:
- No external package needed
- Graceful degradation on unsupported devices

### 4. UI State Management

**Decision**: Use Riverpod `StateNotifier` with local UI state

**Rationale**:
- Project already uses Riverpod 3.0
- StateNotifier fits phase-based state (tapping → revealing → reading)
- Clean separation of UI state

**State Design**:
```dart
enum MiningPhase { tapping, revealing, reading }

class MiningUIState {
  final MiningPhase phase;
  final int tapCount;
  final int tapThreshold; // 5-10 taps to reveal
}
```

### 5. Crystal Image Display

**Decision**: Use `cached_network_image` (already in dependencies)

**Rationale**:
- Already in packages/feature/pubspec.yaml
- Handles caching, loading states, error fallbacks

### 6. Text Rising Animation

**Decision**: Use `SlideTransition` with `AnimationController`

**Implementation**:
```dart
// Text starts below screen (offset Y = 1.0)
// Animates up to final position (offset Y = 0.0)
// Duration: 2-3 seconds
// Curve: Curves.easeOutCubic for smooth deceleration
```

## Dependencies to Add

```yaml
# packages/feature/pubspec.yaml
dependencies:
  audioplayers: ^6.0.0
```

## Technical Risks

| Risk | Mitigation |
|------|------------|
| Audio latency | Pre-load sounds on screen mount |
| Haptic unavailable | Graceful degradation to visual-only |
