# Tasks: Crystal Mining and Memory Reading Screen

**Input**: Design documents from `/specs/001-crystal-mining/`
**Prerequisites**: plan.md (required), spec.md (required), research.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

## Path Conventions

- **Feature package**: `packages/feature/lib/mining/`
- **App assets**: `app/assets/`
- **App router**: `app/lib/core/presentation/router/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and directory structure

- [ ] T001 Create mining feature directory structure at packages/feature/lib/mining/presentation/
- [ ] T002 Add audioplayers dependency (^6.0.0) to packages/feature/pubspec.yaml
- [ ] T003 [P] Create tap_impact.mp3 placeholder or source audio file in app/assets/sounds/

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T004 Create MiningPhase enum and MiningUIState class in packages/feature/lib/mining/presentation/state/mining_state.dart
- [ ] T005 Create MiningNotifier (StateNotifier) with tap tracking logic in packages/feature/lib/mining/presentation/providers/mining_providers.dart
- [ ] T006 [P] Register assets folder in app/pubspec.yaml (sounds)
- [ ] T007 Add mining route to app/lib/core/presentation/router/app_router.dart

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Crystal Mining and Memory Reveal (Priority: P1) 🎯 MVP

**Goal**: Display crystal, tap to shake, reveal memory text from bottom after enough taps

**Independent Test**: Display test crystal, tap until text appears from bottom, verify complete flow

### Implementation for User Story 1

- [ ] T008 [P] [US1] Create CrystalDisplayWidget with glow effect in packages/feature/lib/mining/presentation/widgets/crystal_display_widget.dart
- [ ] T009 [P] [US1] Create CrystalShakeWidget with AnimationController shake animation in packages/feature/lib/mining/presentation/widgets/crystal_shake_widget.dart
- [ ] T010 [P] [US1] Create MemoryTextWidget with SlideTransition rise animation in packages/feature/lib/mining/presentation/widgets/memory_text_widget.dart
- [ ] T011 [US1] Create MiningPage composing all widgets with dark background in packages/feature/lib/mining/presentation/pages/mining_page.dart
- [ ] T012 [US1] Implement tap detection with HapticFeedback.mediumImpact() in MiningPage
- [ ] T013 [US1] Implement audio playback for tap sound using audioplayers in MiningPage
- [ ] T014 [US1] Wire tap count state to trigger text reveal animation when threshold reached
- [ ] T015 [US1] Add dismiss button that appears after text animation completes

**Checkpoint**: User Story 1 should be fully functional - tap crystal, shake, text rises from bottom

---

## Phase 4: User Story 2 - Data Persistence and Session Completion (Priority: P2)

**Goal**: Save discovery record and mark crystal as collected when user dismisses

**Independent Test**: Complete mining flow, verify callback fires with crystal ID and location data

### Implementation for User Story 2

- [ ] T016 [US2] Add onComplete callback parameter to MiningPage for core package integration
- [ ] T017 [US2] Pass crystal data (id, location, timestamp) to onComplete callback on dismiss
- [ ] T018 [US2] Add loading state UI while completion callback processes
- [ ] T019 [US2] Handle completion errors with retry UI or error message

**Checkpoint**: User Story 2 complete - dismiss triggers callback with mining result data

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T020 [P] Add emotion type glow colors (red/blue/yellow/green) to CrystalDisplayWidget
- [ ] T021 [P] Add scrolling support for long memory text in MemoryTextWidget
- [ ] T022 Handle edge case: graceful degradation when haptic feedback unavailable
- [ ] T023 Handle edge case: app backgrounded during mining (preserve state)
- [ ] T024 Optimize animations to maintain 60fps target

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational phase completion
- **User Story 2 (Phase 4)**: Can start after Phase 3 (builds on MiningPage)
- **Polish (Phase 5)**: Depends on User Story 1 being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Depends on User Story 1 (adds callback to existing MiningPage)

### Within Each User Story

- Widgets can be created in parallel (different files)
- MiningPage composition depends on widgets being complete
- Interaction wiring depends on MiningPage structure

### Parallel Opportunities

**Phase 1 Setup:**
```
T001, T002, T003 can run sequentially (quick setup tasks)
```

**Phase 3 User Story 1 (best parallelization):**
```
# Launch all widgets in parallel:
Task: T008 "Create CrystalDisplayWidget..."
Task: T009 "Create CrystalShakeWidget..."
Task: T010 "Create MemoryTextWidget..."

# Then sequentially:
T011 → T012 → T013 → T014 → T015
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T003)
2. Complete Phase 2: Foundational (T004-T007)
3. Complete Phase 3: User Story 1 (T008-T015)
4. **STOP and VALIDATE**: Test crystal tap → shake → text reveal flow
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Demo (MVP!)
3. Add User Story 2 → Test callback integration → Demo
4. Add Polish → Performance and edge cases

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Feature package calls core package for business logic (not implemented here)
- Test on both iOS and Android for haptic feedback differences
- Commit after each task or logical group
