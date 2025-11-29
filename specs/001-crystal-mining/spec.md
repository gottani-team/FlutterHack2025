# Feature Specification: Crystal Mining and Memory Reading Screen

**Feature Branch**: `001-crystal-mining`
**Created**: 2025-11-29
**Status**: Draft
**Input**: User description: "I want to make a Crystal Mining and Memory Reading screen"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Crystal Mining and Memory Reveal (Priority: P1)

A user who has arrived at a crystal location experiences a unified flow: they see a crystal on screen, tap it repeatedly causing it to shake, and after a few taps the memory text rises up from the bottom of the screen.

**Why this priority**: This is the complete core experience that provides the reward for exploration. The seamless flow from tapping to memory reveal creates emotional investment through anticipation (tapping/shaking) and payoff (reading the memory).

**Independent Test**: Can be fully tested by displaying a test crystal, having a user tap until text appears from the bottom. Delivers the complete discovery experience.

**Acceptance Scenarios**:

1. **Given** a user arrives at a crystal location, **When** the Mining screen opens, **Then** a large AI-generated crystal image is displayed centered on screen with a dark background
2. **Given** the crystal is displayed, **When** the user taps on the crystal, **Then** the crystal shakes/moves, haptic feedback triggers, and a tap sound plays
3. **Given** the user continues tapping, **When** the tap count reaches the threshold (5-10 taps), **Then** the memory text begins rising from the bottom of the screen
4. **Given** the memory text is appearing, **When** the animation completes, **Then** the full text is visible and readable
5. **Given** the memory text is fully visible, **When** the user taps the dismiss button, **Then** the crystal is marked as collected and the screen closes

---

### User Story 2 - Data Persistence and Session Completion (Priority: P2)

A user who has finished reading the memory expects their discovery to be saved, the crystal to be added to their collection, and the map to reflect the mined crystal's removal.

**Why this priority**: This ensures proper data persistence and smooth transition back to the exploration loop. Important for long-term engagement but the core visual/interactive experience is complete without it.

**Independent Test**: Can be fully tested by completing a mining session, verifying the discovery record is created with correct metadata, and confirming the crystal is removed from the map.

**Acceptance Scenarios**:

1. **Given** a user dismisses the memory reading view, **When** the session ends, **Then** a discovery record is created with timestamp and location data
2. **Given** the discovery record is created, **When** the user returns to the map, **Then** the crystal no longer appears at its previous location
3. **Given** the crystal has been mined, **When** the system processes the completion, **Then** the crystal respawns at a new random location at least 100m away

---

### Edge Cases

- What happens if the user receives a phone call during the mining animation?
- How does the system handle rapid multi-touch taps on the crystal?
- What happens if the app is backgrounded during the memory reading state?
- How does the system behave if the user force-closes the app mid-mining?
- What happens if network connectivity is lost before the mining result can be saved?
- How does the system handle extremely long memory text that doesn't fit on screen?
- What happens if the user attempts to mine the same crystal a second time (after it respawned)?
- How does the system behave on devices that don't support haptic feedback?

## Requirements *(mandatory)*

### Functional Requirements

#### Mining Screen Display

- **FR-001**: System MUST display the Mining screen with a centered AI-generated crystal image occupying approximately 60% of the screen height
- **FR-002**: System MUST render an abstract dark background with subtle ambient particle effects around the crystal
- **FR-003**: System MUST display the crystal's emotion type color as a subtle glow effect (red: passion, blue: silence, yellow: joy, green: healing)

#### Tap Interaction and Feedback

- **FR-004**: System MUST detect tap gestures anywhere on the crystal image
- **FR-005**: System MUST animate the crystal with a shake/move effect on each tap
- **FR-006**: System MUST play a tap sound effect synchronized with each tap
- **FR-007**: System MUST trigger haptic feedback with each tap
- **FR-008**: System MUST gracefully degrade to visual-only feedback on devices without haptic support
- **FR-009**: System MUST track tap count to determine when to reveal the memory text

#### Memory Text Reveal

- **FR-010**: System MUST trigger text reveal when tap count reaches threshold (5-10 taps)
- **FR-011**: System MUST animate memory text rising from the bottom of the screen
- **FR-012**: System MUST complete the text reveal animation within 2-3 seconds
- **FR-013**: System MUST display memory text in a readable font size (minimum 16pt equivalent)
- **FR-014**: System MUST support scrolling for memory text longer than the visible area
- **FR-015**: System MUST display a dismiss button after the text is fully revealed

#### Session Completion

- **FR-016**: System MUST mark the crystal as "discovered" in the user's collection when dismissed
- **FR-017**: System MUST create a discovery record with timestamp and GPS location where mining occurred
- **FR-018**: System MUST remove the crystal from its current map location after successful mining
- **FR-019**: System MUST handle mining result saving failures by queuing for retry

#### Concurrency and Data Integrity

- **FR-020**: System MUST handle concurrent mining attempts by allowing only the first user to complete the mining
- **FR-021**: System MUST display an appropriate message if the crystal was already mined by another user

### Key Entities

- **Crystal**: The memory artifact being mined. Contains AI-generated image URL, emotion type, memory text content, current location coordinates, and unique identifier.

- **Mining Session**: Represents the current state within the unified screen. Contains crystal ID, user ID, tap count, and screen phase (tapping/revealing/reading).

- **Discovery Record**: Created upon successful mining completion. Contains crystal ID, user ID, discovery timestamp, GPS coordinates where mining occurred, and the crystal's original location.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users complete the mining interaction (first tap to text reveal) within 10 seconds of entering the Mining screen
- **SC-002**: Each tap provides visual, audio, and haptic feedback within 100 milliseconds of touch input
- **SC-003**: Memory text is fully readable within 5 seconds of text reveal starting
- **SC-004**: 95% of mining sessions complete successfully without errors or data loss
- **SC-005**: Users report the mining experience as satisfying (rating above 4.0/5.0 for "satisfying interaction")
- **SC-006**: Memory text presentation is rated as readable (above 4.0/5.0 for "reading experience")
- **SC-007**: Screen maintains smooth performance (60fps) during all animations
- **SC-008**: Mining session data is persisted correctly in 99% of cases even when network is intermittent

### Assumptions

- The Mining screen is entered after the user reaches within 25m of a crystal location (handled by proximity detection feature)
- Crystal data including AI-generated image and memory text is already fetched when the Mining screen opens
- The device supports basic audio playback for sound effects
- GPS location is available when the Mining screen opens for recording discovery location
- The app has appropriate permissions for haptic feedback on supported devices
- Memory text length is constrained to 500 characters maximum (enforced during burial)
- The crystal image is already cached or can be loaded quickly when the screen opens
