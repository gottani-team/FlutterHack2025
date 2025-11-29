# Tasks: Chimyaku Map View - Crystal Discovery & Proximity Detection

**Input**: Design documents from `/specs/001-chimyaku-app/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, quickstart.md ✅
**Focus**: User Story 2 - Crystal Discovery and Proximity Detection (P1)
**Scope Note**: Firestoreとの繋ぎ込みはスコープ外。モックデータで実装。

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US2)
- Include exact file paths in descriptions

## Existing Work (Already Completed) ✅

以下のファイルは既に作成済み:
- `packages/feature/lib/map/domain/entities/crystal_entity.dart`
- `packages/feature/lib/map/domain/entities/crystallization_area_entity.dart`
- `packages/feature/lib/map/domain/entities/user_location_entity.dart`
- `packages/feature/lib/map/domain/repositories/map_repository.dart`
- `packages/feature/lib/map/data/data_sources/crystal_mock_data_source.dart`
- `packages/feature/lib/map/presentation/state/map_view_state.dart`
- `packages/feature/lib/map/presentation/view_model/map_view_model.dart`
- `packages/feature/lib/map/presentation/providers/map_providers.dart`

---

## Phase 1: Setup (Dependencies & Configuration) ✅ COMPLETE

**Purpose**: プロジェクト依存関係とプラットフォーム設定

- [x] T001 Add mapbox_maps_flutter, geolocator, permission_handler, audioplayers to `packages/feature/pubspec.yaml`
- [x] T002 [P] Configure iOS location permissions in `app/ios/Runner/Info.plist`
- [x] T003 [P] Configure Android location permissions in `app/android/app/src/main/AndroidManifest.xml`
- [x] T004 [P] Add Mapbox access token configuration for iOS in `app/ios/Runner/Info.plist`
- [x] T005 [P] Add Mapbox access token configuration for Android in `app/android/app/src/main/AndroidManifest.xml`
- [x] T006 Run `flutter pub get` in packages/feature to install dependencies
- [x] T007 Run `flutter pub run build_runner build` to regenerate freezed/riverpod files

**Checkpoint**: ✅ Dependencies installed and platform configured

---

## Phase 2: Foundational (Core Services) ✅ COMPLETE

**Purpose**: User Story 2 の実装に必要な基盤サービス

**⚠️ CRITICAL**: Phase 2 完了まで US2 実装は開始不可

- [x] T008 [P] Create HapticService for haptic feedback in `packages/core/lib/domain/services/haptic_service.dart`
- [x] T009 [P] Create AudioPlayerService for sound effects in `packages/core/lib/presentation/utils/audio_player_service.dart`
- [x] T010 Create LocationDataSource interface and implementation using geolocator in `packages/feature/lib/map/data/data_sources/location_data_source.dart`
- [x] T011 Implement MapRepositoryImpl using mock data and location service in `packages/feature/lib/map/data/repositories/map_repository_impl.dart`
- [x] T012 Register MapRepository provider in `packages/feature/lib/map/presentation/providers/map_providers.dart`
- [x] T013 Add resonance sound asset file to `app/assets/sounds/` (placeholder created)

**Checkpoint**: ✅ Foundation ready - US2 implementation can begin

---

## Phase 3: User Story 2 - Crystal Discovery & Proximity Detection (P1) 🎯 MVP ✅ COMPLETE

**Goal**: ユーザーがマップ上で結晶化エリアを発見し、接近時に視覚・触覚・聴覚フィードバックを体験

**Independent Test**: モック結晶をマップに配置し、接近時のフィードバック強度変化を確認

**Acceptance Criteria**:
1. マップ上に感情タイプ別の色で結晶エリアが表示される
2. 100m以内で画面端のパルスエフェクト開始
3. 距離に応じて触覚・視覚の強度が変化
4. 25m以内でMining画面遷移トリガー

### 3.1 Map Page Core (マップ基盤)

- [x] T014 [US2] Create MapPage widget with Mapbox integration in `packages/feature/lib/map/presentation/pages/map_page.dart`
- [x] T015 [US2] Configure dark fantasy map style (use Mapbox default dark or custom style URL) in MapPage
- [x] T016 [US2] Implement user location layer with custom marker in MapPage
- [x] T017 [US2] Register MapPage route '/map' in `app/lib/core/presentation/router/app_router.dart`

### 3.2 Crystal Visualization (結晶表示)

- [x] T018 [P] [US2] Create CrystalMarkerLayer widget for displaying crystallization areas in `packages/feature/lib/map/presentation/widgets/crystal_marker_layer.dart`
- [x] T019 [US2] Implement pulsing circle animation for crystal markers (color by emotion type)
- [x] T020 [US2] Connect crystal markers to MapViewModel's visibleCrystallizationAreas

### 3.3 Proximity Feedback UI (接近フィードバック)

- [x] T021 [P] [US2] Create HeartbeatOverlay widget for screen edge pulsing in `packages/feature/lib/map/presentation/widgets/heartbeat_overlay.dart`
- [x] T022 [US2] Implement color animation based on emotion type in HeartbeatOverlay
- [x] T023 [US2] Implement pulse frequency animation based on distance (intensity 0.0-1.0)
- [x] T024 [US2] Integrate HeartbeatOverlay with MapViewModel's pulseIntensity and approachingCrystalColor

### 3.4 Sensory Feedback Integration (多感覚同期)

- [x] T025 [US2] Integrate HapticService into MapViewModel for synchronized haptic pulses
- [x] T026 [US2] Integrate AudioPlayerService into MapViewModel for synchronized sound pulses
- [x] T027 [US2] Implement _triggerPulse() method with visual+haptic+audio synchronization

### 3.5 Permission & Error Handling UI

- [x] T028 [P] [US2] Create PermissionDialog widget for location permission request in `packages/feature/lib/map/presentation/pages/map_page.dart` (inline)
- [x] T029 [P] [US2] Create GpsWarningBanner widget in `packages/feature/lib/map/presentation/widgets/gps_warning_banner.dart`
- [x] T030 [P] [US2] Create ErrorBanner widget for error display in `packages/feature/lib/map/presentation/widgets/error_banner.dart`
- [x] T031 [US2] Connect permission/warning/error widgets to MapViewModel state

### 3.6 Mining Transition (採掘画面遷移)

- [x] T032 [US2] Implement light enveloping animation for mining transition in MapPage (placeholder)
- [x] T033 [US2] Add navigation to Mining screen when proximityPhase == imminent
- [x] T034 [US2] Pass approaching crystal data to Mining screen via navigation arguments (placeholder)

**Checkpoint**: ✅ User Story 2 core implementation complete - map displays, proximity detection works, sensory feedback integrated

---

## Phase 4: Polish & Integration ✅ COMPLETE

**Purpose**: 品質向上と統合確認

- [x] T035 [P] Update MapViewModel to use actual geolocator stream instead of mock location
- [x] T036 [P] Add loading state with magical particle animation (world-immersion compliant)
- [x] T037 Add recenter button functionality in MapPage
- [x] T038 Implement map camera movement handling (onMapCameraMoved)
- [x] T039 Add app lifecycle handling for background mode in MapViewModel
- [x] T040 Run quickstart.md validation checklist
- [x] T041 Fix any linter errors and code cleanup

**Checkpoint**: ✅ All Phase 4 tasks complete - ready for device testing

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1: Setup
    ↓
Phase 2: Foundational (BLOCKS US2)
    ↓
Phase 3: User Story 2
    ↓
Phase 4: Polish
```

### Task Dependencies Within Phase 3

```
T014 (MapPage) → T015, T016, T017
T018 (CrystalMarkerLayer) → T019 → T020
T021 (HeartbeatOverlay) → T022 → T023 → T024
T025, T026 → T027 (Sensory sync)
T028, T029, T030 → T031 (Error handling)
T032 → T033 → T034 (Mining transition)
```

### Parallel Opportunities

```bash
# Phase 1: Platform configs can run in parallel
T002, T003, T004, T005  # All platform configs

# Phase 2: Core services can run in parallel
T008, T009  # HapticService, AudioPlayerService

# Phase 3: Independent widget creation
T018, T021, T028, T029, T030  # All marked [P]
```

---

## Parallel Example: Phase 3 Widgets

```bash
# Launch all independent widget tasks together:
Task T018: "Create CrystalMarkerLayer widget"
Task T021: "Create HeartbeatOverlay widget"
Task T028: "Create PermissionDialog widget"
Task T029: "Create GpsWarningBanner widget"
Task T030: "Create ErrorBanner widget"

# After widgets complete, integrate:
Task T019, T022-T024, T031  # Sequential integration tasks
```

---

## Implementation Strategy

### MVP Delivery (User Story 2 Only)

1. ✅ Phase 1: Setup - Dependencies and platform config
2. ✅ Phase 2: Foundational - Core services
3. ✅ Phase 3: User Story 2 - Map view with proximity detection
4. **STOP and VALIDATE**: Test on real device with GPS
5. Deploy/Demo if ready

### Incremental Checkpoints

| Checkpoint | Deliverable | Validation |
|------------|-------------|------------|
| After T007 | Dependencies ready | `flutter pub get` succeeds |
| After T013 | Foundation ready | Services instantiate without error |
| After T020 | Map displays crystals | See colored markers on map |
| After T027 | Proximity feedback works | Feel haptic, hear sound on approach |
| After T034 | Mining transition works | Auto-navigate at 25m |
| After T041 | Polish complete | No linter errors |

---

## Task Summary

| Phase | Task Count | Parallel Tasks |
|-------|------------|----------------|
| Phase 1: Setup | 7 | 4 |
| Phase 2: Foundational | 6 | 2 |
| Phase 3: User Story 2 | 21 | 6 |
| Phase 4: Polish | 7 | 2 |
| **Total** | **41** | **14** |

### FR Coverage (User Story 2)

| FR | Description | Tasks |
|----|-------------|-------|
| FR-001 | Dark fantasy map | T014, T015 |
| FR-002 | Real-time location | T010, T016, T035 |
| FR-004 | Crystal areas display | T018-T020 |
| FR-005 | Approximate location | Already in mock data source |
| FR-006 | 100m detection | T021-T024, MapViewModel |
| FR-007 | Visual pulsing | T021-T024 |
| FR-008 | Haptic pulses | T008, T025, T027 |
| FR-009 | Sound effects | T009, T013, T026, T027 |
| FR-010 | Intensity scaling | T023, MapViewModel |
| FR-011 | 25m auto-transition | T032-T034 |
| FR-012 | Multiple crystals | MapViewModel (already implemented) |

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- [US2] label = User Story 2: Crystal Discovery & Proximity Detection
- Firestoreはスコープ外 - モックデータで実装
- Feature層エンティティは永続化層と独立
- 実機テスト推奨（シミュレータのGPSは不安定）
- Mapbox Access Token は本番用を取得必要

