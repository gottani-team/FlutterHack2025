# Implementation Plan: Crystal Mining and Memory Reading Screen

**Branch**: `001-crystal-mining` | **Date**: 2025-11-29 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-crystal-mining/spec.md`

## Summary

Implement the **UI/presentation layer** for the crystal mining and memory reading screen. This includes tap effects, crack animations, shatter effects, and memory text display. The presentation layer will **call into the core package** for business logic (e.g., completing mining, saving discovery records).

**Key Technical Approach**:
- Presentation layer in packages/feature/lib/mining/presentation/
- Calls core package repositories/use cases for business logic
- Local UI state for screen phases (tapping → revealing → reading)
- Custom animations (crystal shake, text rise from bottom)
- HapticFeedback + audio for multi-sensory feedback

## Technical Context

**Language/Version**: Dart SDK >=3.5.0 <4.0.0 / Flutter 3.38.1
**Primary Dependencies**:
- flutter_riverpod: ^3.0.3 (UI state management)
- hooks_riverpod: ^3.0.3 (UI hooks)
- cached_network_image: ^3.4.1 (crystal image display)
- audioplayers: ^6.0.0 (sound effects)

**Storage**: Via core package (feature calls core repositories for Firestore operations)
**Testing**: flutter_test (widget tests)
**Target Platform**: iOS / Android
**Project Type**: mobile (Flutter Monorepo - app/packages structure)
**Performance Goals**: 60fps (all animations), tap feedback within 100ms
**Constraints**: Shatter animation within 2 seconds, text reveal 3-5 seconds
**Scale/Scope**: 1 screen (presentation layer only)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. WORLD_IMMERSION | ✅ PASS | Dark fantasy aesthetic, mystical particle effects |
| II. SENSORY_EXPERIENCE | ✅ PASS | Visual + Haptic + Audio synchronized |
| III. AI_UNIQUENESS | ✅ PASS | Displays AI-generated crystal image |
| IV. ARCHITECTURE | ✅ PASS | Presentation layer only; domain/data in core package later |
| V. MVP_PRIORITY | ✅ PASS | P1 core loop component |
| VI. JAPANESE_FIRST | ⚠️ OVERRIDE | User requested English |

## Project Structure

### Documentation (this feature)

```text
specs/001-crystal-mining/
├── spec.md              # Feature specification
├── plan.md              # This file (implementation plan)
├── research.md          # Phase 0 output (technical research)
└── tasks.md             # Phase 2 output (task list)
```

### Source Code (repository root)

```text
packages/feature/lib/
└── mining/                              # Mining feature (UI only)
    └── presentation/                    # Presentation layer
        ├── pages/
        │   └── mining_page.dart         # Mining screen (main)
        ├── widgets/
        │   ├── crystal_display_widget.dart # Crystal display with glow
        │   ├── crystal_shake_widget.dart # Shake animation on tap
        │   └── memory_text_widget.dart  # Text rising from bottom
        ├── providers/
        │   └── mining_providers.dart    # UI state providers
        └── state/
            └── mining_state.dart        # Local UI state (phase, tap count)

app/lib/core/presentation/router/
└── app_router.dart                      # Add mining screen route

app/assets/
└── sounds/
    └── tap_impact.mp3                   # Tap sound effect
```

**Structure Decision**: Presentation layer under packages/feature/lib/mining/presentation/. This layer depends on packages/core for domain logic (repositories, use cases). The feature package imports and calls core package APIs for business operations like completing mining and saving discovery records.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| VI. JAPANESE_FIRST override | User explicitly requested English | - |
