# Map View Implementation Checklist: Crystal Discovery & Proximity Detection

**Purpose**: Track implementation progress for User Story 2 - Map View with Mapbox
**Created**: 2025-11-29
**Feature**: Crystal Discovery and Proximity Detection
**Spec Reference**: [spec.md](../../../specs/spec.md) - User Story 2

## Overview

This checklist covers the implementation of the map view screen using Mapbox Flutter SDK,
implementing proximity detection, and sensory feedback for crystal discovery.

---

## Phase 1: Foundation Setup

### 1.1 Dependencies & Configuration

- [x] Add `mapbox_maps_flutter` package to `packages/feature/pubspec.yaml`
- [x] Add `geolocator` package for location services
- [ ] Add `flutter_local_notifications` for background proximity alerts (optional)
- [x] Add `haptic_feedback` or use `HapticFeedback` from flutter services
- [x] Configure Mapbox access token in environment/secrets
- [x] Add iOS location permission descriptions in `Info.plist`
- [x] Add Android location permissions in `AndroidManifest.xml`
- [ ] Configure iOS background location capability (if needed)

### 1.2 Code Generation

- [x] Run `dart run build_runner build` to generate freezed files
- [x] Verify `map_view_state.freezed.dart` is generated
- [x] Run `dart run build_runner build` to generate riverpod files
- [x] Verify `map_view_model.g.dart` is generated

---

## Phase 2: Domain Layer

### 2.1 Entities (Completed ✅)

- [x] Create `CrystalEntity` with emotion types and properties
- [x] Create `CrystallizationAreaEntity` for map display
- [x] Create `UserLocationEntity` for GPS data

### 2.2 Repositories

- [x] Define `MapRepository` interface in domain layer
- [x] Add method: `Stream<UserLocationEntity> watchUserLocation()`
- [x] Add method: `Future<List<CrystallizationAreaEntity>> getCrystalsInBounds()`
- [x] Add method: `Future<void> requestLocationPermission()`
- [x] Add method: `Future<LocationPermissionStatus> checkLocationPermission()`

### 2.3 Use Cases

- [ ] Create `WatchUserLocationUseCase`
- [ ] Create `GetNearbyCrystalsUseCase`
- [ ] Create `CheckCrystalProximityUseCase`

---

## Phase 3: Data Layer

> **Note**: Firestoreとの繋ぎ込みはスコープ外。モックデータで実装。

### 3.1 Data Sources

- [x] Create `LocationDataSource` for GPS services (using geolocator)
- [x] Create `CrystalMockDataSource` for mock crystal data (Firestoreはスコープ外)
- [x] Sample crystals with various emotion types

### 3.2 Repository Implementation

- [x] Implement `MapRepositoryImpl` using mock data source
- [x] Coordinate transformation for approximate locations (in mock data source)

---

## Phase 4: Presentation Layer

### 4.1 State & ViewModel (Completed ✅)

- [x] Create `MapViewState` with freezed
- [x] Create `MapViewModel` with riverpod
- [x] Create `map_providers.dart` with derived providers

### 4.2 Map Page Widget

- [ ] Create `MapPage` StatelessWidget with ConsumerWidget
- [ ] Integrate Mapbox `MapWidget`
- [ ] Configure dark fantasy map style (custom Mapbox style)
- [ ] Add user location layer with custom marker
- [ ] Add crystallization areas layer with pulsing circles

### 4.3 Map Styling & Visualization

- [ ] Create/obtain dark fantasy Mapbox style JSON
- [ ] Implement 地脈 (earth vein) particle effect layer
- [ ] Implement pulsing light vortex effect for crystals
- [ ] Color-code crystals by emotion type (red/blue/yellow/green)
- [ ] Add glow/bloom effect to crystal markers

### 4.4 Proximity Feedback UI

- [ ] Create `HeartbeatOverlay` widget for screen edge pulsing
- [ ] Implement color animation based on emotion type
- [ ] Implement pulse frequency based on distance
- [ ] Add pulse intensity animation (0.0 - 1.0)
- [ ] Create smooth transition when entering/exiting proximity zone

### 4.5 Haptic Feedback

- [ ] Implement haptic pulse synchronized with visual heartbeat
- [ ] Vary haptic intensity based on proximity
- [ ] Use `HapticFeedback.heavyImpact()` for strong feedback
- [ ] Handle devices without haptic support gracefully

### 4.6 Audio Feedback

- [ ] Add resonance sound effect assets
- [ ] Implement audio playback synchronized with pulse
- [ ] Adjust volume based on proximity
- [ ] Handle audio focus/interruption gracefully

### 4.7 GPS Warning UI

- [ ] Create GPS accuracy warning banner widget
- [ ] Show warning when accuracy > 50m
- [ ] Provide guidance to improve GPS signal

### 4.8 Permission Handling UI

- [ ] Create permission request dialog/screen
- [ ] Handle permission denied state with explanation
- [ ] Handle permanently denied state with settings redirect

---

## Phase 5: Navigation & Integration

### 5.1 Mining Screen Transition

- [ ] Implement automatic transition when distance <= 25m
- [ ] Add enveloping light animation for transition
- [ ] Pass crystal data to Mining screen
- [ ] Handle transition cancellation if user moves away

### 5.2 App Navigation

- [ ] Register MapPage route in app router
- [ ] Add navigation from Home screen
- [ ] Handle deep linking (optional)

---

## Phase 6: Testing

### 6.1 Unit Tests

- [ ] Test `MapViewModel` state transitions
- [ ] Test proximity calculation (Haversine formula)
- [ ] Test pulse intensity calculation
- [ ] Test GPS accuracy level determination

### 6.2 Widget Tests

- [ ] Test `HeartbeatOverlay` animation
- [ ] Test permission dialog display
- [ ] Test GPS warning banner

### 6.3 Integration Tests

- [ ] Test location tracking flow
- [ ] Test crystal loading and display
- [ ] Test proximity detection end-to-end

---

## Phase 7: Performance & Polish

### 7.1 Performance Optimization

- [ ] Optimize crystal rendering for large numbers
- [ ] Implement efficient geo-query with proper indexing
- [ ] Cache map tiles for offline viewing
- [ ] Reduce battery consumption in background mode

### 7.2 Error Handling

- [ ] Handle network errors gracefully
- [ ] Handle GPS timeout
- [ ] Handle Mapbox initialization errors
- [ ] Implement retry mechanisms

### 7.3 Accessibility

- [ ] Add screen reader support for proximity feedback
- [ ] Provide audio cues for visually impaired users
- [ ] Ensure color-blind friendly crystal indicators

---

## Technical Notes

### Key Dependencies

```yaml
dependencies:
  mapbox_maps_flutter: ^2.4.0
  geolocator: ^13.0.1
  permission_handler: ^11.3.1
```

### Mapbox Configuration

- Access token should be stored securely (not in version control)
- Custom style required for dark fantasy theme
- Consider using Mapbox Studio for style creation

### Functional Requirements Coverage

| FR Code | Description | Status |
|---------|-------------|--------|
| FR-001 | Dark-themed fantasy-style map | Pending |
| FR-002 | Real-time location tracking | Pending |
| FR-003 | 地脈 particle effects | Pending |
| FR-004 | Crystallization area display | Pending |
| FR-005 | Approximate location only | Pending |
| FR-006 | 100m radius detection | Pending |
| FR-007 | Visual pulsing effects | Pending |
| FR-008 | Haptic vibration pulses | Pending |
| FR-009 | Resonance sound effects | Pending |
| FR-010 | Intensity based on distance | Pending |
| FR-011 | Auto-transition at 25m | Pending |
| FR-012 | Multiple crystal handling | Pending |

---

## Notes

- Mapbox style design may require design collaboration
- 地脈 particle effects may need custom shader or animation
- Background location tracking has platform limitations
- Consider battery impact of continuous GPS tracking

