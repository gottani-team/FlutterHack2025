# Feature Specification: Chimyaku (地脈) - Memory Crystal Location-Based Experience

**Feature Branch**: `001-chimyaku-app`
**Created**: 2025-11-29
**Status**: Draft
**Input**: User description: "@docs/IDEA.md のアプリケーションを開発します。仕様を策定し、画面設計や仕様、利用技術について詰めてください。"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Memory Burial and Crystallization (Priority: P1)

A user wants to preserve their personal memory by transforming it into a unique crystal and embedding it into the world's energy flow (地脈) at their current location.

**Why this priority**: This is the core content creation mechanism that enables the entire experience. Without user-generated memories, there are no crystals to discover. This creates the foundational value proposition and generates content for all other features.

**Independent Test**: Can be fully tested by having a user input memory text, generate a crystal with AI, and successfully save it to their current location. Delivers immediate value as users can see their memory transformed into a unique visual artifact.

**Acceptance Scenarios**:

1. **Given** a user is at the Memory Burial screen, **When** they enter memory text (minimum 10 characters) and tap the crystallization button, **Then** the system displays a magical particle animation and generates a unique crystal image with an emotion type classification
2. **Given** a crystal has been generated successfully, **When** the user reviews the crystal image and emotion type, **Then** they can confirm burial by long-pressing the "Return to 地脈" button
3. **Given** the user confirms burial, **When** the long-press action completes, **Then** the system saves the crystal data with current GPS coordinates and displays a success animation
4. **Given** the user has buried a crystal, **When** they return to the map screen, **Then** the newly buried crystal appears as a glowing crystallization area at that location

---

### User Story 2 - Crystal Discovery and Proximity Detection (Priority: P1)

A user explores the map to find crystallization areas where others have buried their memories, experiencing increasing sensory feedback as they approach each crystal.

**Why this priority**: This is the primary exploration mechanic that drives user engagement and movement in the physical world. It transforms mundane locations into discovery opportunities and creates anticipation through progressive sensory feedback.

**Independent Test**: Can be fully tested by placing test crystals on a map, having a user navigate toward them, and verifying that visual/haptic/audio feedback intensifies as distance decreases. Delivers core gameplay value without requiring other features.

**Acceptance Scenarios**:

1. **Given** a user opens the map screen, **When** crystals exist within visible range, **Then** they appear as pulsing light vortexes with colors representing emotion types (red: passion, blue: silence, yellow: joy, green: healing)
2. **Given** a user is within 100m of a crystal, **When** they enter the proximity zone, **Then** the screen edges begin pulsing with the crystal's color in a heartbeat rhythm
3. **Given** a user is approaching a crystal, **When** their distance decreases, **Then** haptic vibration intensity and frequency increase, synchronized with visual pulsing
4. **Given** a user reaches within 25m of a crystal, **When** they cross this threshold, **Then** the screen is enveloped in light and automatically transitions to the Mining screen

---

### User Story 3 - Crystal Mining and Memory Reading (Priority: P1)

A user physically arrives at a crystal location, performs mining actions to shatter the crystal, and immediately reads the revealed memory in the same unified experience. Once mined, the crystal disappears from that location and reappears elsewhere in the world.

**Why this priority**: This completes the core experience loop by providing the reward mechanism for exploration. Users need immediate gratification for their exploration efforts to maintain engagement. The mining and reading flow is seamless, keeping users immersed in the experience.

**Independent Test**: Can be fully tested by triggering the mining screen, having a user tap to mine a crystal, successfully unlocking and reading the memory text, and verifying the crystal respawns at a new location. Delivers complete value of "discover someone's story" without requiring collection features.

**Acceptance Scenarios**:

1. **Given** a user enters the Mining screen, **When** the screen loads, **Then** a large AI-generated crystal image is displayed in an abstract space with subtle ambient effects
2. **Given** the crystal is displayed, **When** the user taps on it, **Then** spark effects appear, a metallic sound plays, strong haptic feedback triggers, and visible cracks appear on the crystal
3. **Given** the user continues tapping, **When** the crystal's durability reaches zero (approximately 5-10 taps), **Then** the crystal shatters with an explosive animation
4. **Given** the crystal has shattered, **When** the shattering animation completes, **Then** the background transitions to a serene state, ambient sound plays, and the memory text gradually appears with an ink-floating effect on the same screen
5. **Given** the memory text is fully visible, **When** the user finishes reading and taps the dismiss button, **Then** the crystal is marked as collected, added to their Journal, removed from the original map location, and respawned at a new random location for other users to discover

---

### User Story 4 - Crystal Journal Collection (Priority: P3)

A user reviews all crystals they have previously mined in a personal collection gallery, revisiting memories and tracking discovery progress.

**Why this priority**: This adds long-term engagement and collection mechanics but is not essential for the core discovery experience. Users can enjoy exploration and memory discovery without needing to review past finds.

**Independent Test**: Can be fully tested by populating test data of mined crystals and verifying display, sorting, and detail viewing work correctly. Delivers collection satisfaction independently.

**Acceptance Scenarios**:

1. **Given** a user has mined at least one crystal, **When** they open the Journal screen, **Then** all mined crystals are displayed in a grid with their AI-generated thumbnail images
2. **Given** crystals are displayed in the Journal, **When** the user taps on a crystal thumbnail, **Then** the detail view opens showing the crystal image, memory text, discovery date, and discovery location name
3. **Given** a user has not mined any crystals yet, **When** they open the Journal screen, **Then** an empty state message encourages them to explore the map

---

### Edge Cases

- What happens when a user tries to bury a memory without location permissions enabled?
- How does the system handle AI generation failures or timeouts during crystal creation?
- What happens when a user enters the proximity zone of multiple crystals simultaneously?
- How does the system behave when GPS accuracy is poor (>50m error)?
- What happens if a user loses network connectivity during crystal burial or mining?
- How does the system handle memory text containing inappropriate content?
- What happens when a user mines a crystal they previously buried themselves? (They can mine it like any other crystal)
- How does the app behave when running in the background during proximity detection?
- What happens when device battery is critically low during active exploration?
- What happens when two users try to mine the same crystal at the exact same time?
- How does the system determine where to respawn a crystal after it's been mined?
- What happens if there are no suitable locations available for crystal respawning?
- How does the system prevent crystals from respawning in the same location they were just mined from?

## Requirements *(mandatory)*

### Functional Requirements

#### Map and Location Features

- **FR-001**: System MUST display a dark-themed fantasy-style map centered on the user's current GPS location
- **FR-002**: System MUST continuously track user's real-time location and update map position accordingly
- **FR-003**: System MUST visualize 地脈 energy flow as slowly flowing blue-white particle effects along map features (roads, terrain)
- **FR-004**: System MUST display crystallization areas as pulsing light vortexes colored by emotion type within visible map range (up to 1km radius)
- **FR-005**: System MUST NOT display exact pin locations for crystals, only approximate glowing areas

#### Proximity and Sensory Feedback

- **FR-006**: System MUST detect when user enters 100m radius of any crystal and trigger the "heartbeat phase"
- **FR-007**: System MUST generate visual pulsing effects at screen edges matching the crystal's emotion color during heartbeat phase
- **FR-008**: System MUST trigger synchronized haptic vibration pulses (heavy impact) matching the visual heartbeat rhythm
- **FR-009**: System MUST play resonance sound effects synchronized with visual and haptic pulses
- **FR-010**: System MUST increase pulse frequency and intensity as user distance decreases from 100m to 25m
- **FR-011**: System MUST automatically transition to Mining screen when user is within 25m of crystal center
- **FR-012**: System MUST handle proximity detection for multiple nearby crystals by prioritizing the closest one

#### Memory Burial Flow

- **FR-013**: System MUST provide a text input area for memory description with minimum 10 characters and maximum 500 characters
- **FR-014**: System MUST validate memory text length before allowing crystallization to proceed
- **FR-015**: System MUST display magical particle condensation animation during AI generation process
- **FR-016**: System MUST call AI service to analyze memory text and classify emotion type (passion/silence/joy/healing)
- **FR-017**: System MUST call AI service to generate a unique crystal image based on memory text and emotion analysis
- **FR-018**: System MUST display generation progress indicator with estimated wait time during AI processing
- **FR-019**: System MUST show generated crystal image and emotion type name to user for confirmation
- **FR-020**: System MUST require long-press gesture (minimum 2 seconds) on "Return to 地脈" button to confirm burial
- **FR-021**: System MUST save crystal data including memory text, emotion type, image URL, creator ID, GPS coordinates, and timestamp
- **FR-022**: System MUST display light absorption animation when burial is confirmed
- **FR-023**: System MUST prevent duplicate burial if user accidentally triggers burial action multiple times

#### Crystal Mining and Memory Reading Flow (Unified Screen)

- **FR-024**: System MUST display the Mining screen with centered AI-generated crystal image in abstract space
- **FR-025**: System MUST detect tap gestures on the crystal image
- **FR-026**: System MUST display spark effects, play metallic sound, and trigger strong haptic feedback for each tap
- **FR-027**: System MUST visually show progressive crack damage on crystal with each tap
- **FR-028**: System MUST track crystal durability and reduce it with each tap
- **FR-029**: System MUST trigger shattering animation when durability reaches zero (after 5-10 taps)
- **FR-030**: System MUST transition the same screen to a serene reading state after shattering animation completes (no screen transition)
- **FR-031**: System MUST blur background and play ambient sound when entering reading state
- **FR-032**: System MUST animate memory text appearance with ink-floating effect (gradual reveal) on the same screen
- **FR-033**: System MUST display complete memory text in readable format
- **FR-034**: System MUST provide dismiss/close button to exit the unified Mining/Reading screen
- **FR-035**: System MUST mark crystal as "discovered" in user's collection upon closing the screen
- **FR-036**: System MUST save discovery timestamp and location when adding to collection
- **FR-037**: System MUST remove the crystal from its original map location immediately after it is successfully mined
- **FR-038**: System MUST respawn the crystal at a new random location after it has been mined
- **FR-039**: System MUST ensure respawned crystal location is at least 100m away from the original mining location
- **FR-040**: System MUST handle concurrent mining attempts by allowing only the first user to successfully mine the crystal
- **FR-041**: System MUST allow users to mine crystals they previously buried themselves (no creator restrictions)

#### Crystal Journal

- **FR-042**: System MUST display grid layout of all mined crystals using their AI-generated thumbnail images
- **FR-043**: System MUST sort crystals by discovery date (most recent first) by default
- **FR-044**: System MUST open crystal detail view when user taps on a thumbnail
- **FR-045**: System MUST display crystal image, memory text, discovery date, and discovery location name in detail view
- **FR-046**: System MUST show empty state message when user has not mined any crystals yet
- **FR-047**: System MUST allow users to navigate back to map from Journal screen

#### User Authentication and Data Management

- **FR-048**: System MUST authenticate users and assign unique user IDs
- **FR-049**: System MUST associate each buried crystal with the creator's user ID
- **FR-050**: System MUST persist all crystal data (buried and discovered) in cloud storage
- **FR-051**: System MUST persist user discovery history and collection data
- **FR-052**: System MUST track mining history to prevent duplicate mining of the same crystal by the same user

#### Performance and Error Handling

- **FR-053**: System MUST request and verify location permissions before allowing map access
- **FR-054**: System MUST display appropriate error message if location permissions are denied
- **FR-055**: System MUST handle AI generation failures gracefully with retry option and clear error messaging
- **FR-056**: System MUST cache map tiles for offline viewing of previously loaded areas
- **FR-057**: System MUST queue burial actions for retry if network is unavailable
- **FR-058**: System MUST validate GPS accuracy and warn user if accuracy exceeds 50 meters
- **FR-059**: System MUST continue proximity detection when app is running in background (within platform limitations)
- **FR-060**: System MUST handle low battery situations by reducing animation frame rates and haptic intensity
- **FR-061**: System MUST implement crystal respawn location selection algorithm that distributes crystals across available geographic areas
- **FR-062**: System MUST prevent crystal respawning in restricted areas (water bodies, private property when detectable)

### Key Entities

- **Crystal**: Represents a buried memory that can exist at different locations over time. Contains memory text content, emotion type classification (passion/silence/joy/healing), AI-generated image URL, creator user ID, current GPS coordinates (latitude/longitude that updates when respawned), creation timestamp, unique identifier, mining count (how many times it has been mined), and respawn history.

- **User**: Represents a person using the app. Contains unique user ID, authentication credentials, discovery history (list of mined crystal IDs with timestamps and locations where they mined them), burial history (list of created crystal IDs), and mining history (prevents duplicate mining of same crystal).

- **Crystallization Area**: Represents a discoverable location on the map. Derived from Crystal entity's current location. Includes approximate location (not exact coordinates shown on map), visual appearance (pulsing light color based on emotion type), proximity detection radius (100m outer, 25m inner), and current status (active/being-mined/respawning).

- **Discovery Record**: Represents a user's successful mining of a crystal at a specific time and place. Contains crystal ID, user ID who discovered it, discovery timestamp, discovery GPS location (where the user was when they mined it, for journal display), and the crystal's location at the time of mining.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can complete the full burial flow (text input → AI generation → confirmation) in under 90 seconds for a typical memory (100-200 characters)
- **SC-002**: Users experience proximity feedback (visual/haptic/audio) within 2 seconds of entering the 100m detection radius
- **SC-003**: Crystal mining interaction completes (shattering animation → memory reveal) within 15 seconds of entering the Mining screen
- **SC-004**: AI crystal generation succeeds for 95% of memory burial attempts within 30 seconds
- **SC-005**: Users can navigate the map, view crystal locations, and move around without noticeable lag (60fps maintained on target devices)
- **SC-006**: 80% of users successfully mine their first crystal within 5 minutes of starting exploration
- **SC-007**: Proximity detection accuracy correctly identifies when users are within 25m of crystals with less than 10% false positives
- **SC-008**: Users report feeling immersed in the fantasy atmosphere (measured by post-experience survey rating above 4.0/5.0)
- **SC-009**: Memory text is readable and presentation effects enhance rather than obstruct reading (reading comprehension rate above 90%)
- **SC-010**: App handles 1000 concurrent users exploring and burying crystals without service degradation

### Assumptions

- Users will grant location permissions willingly when they understand the app's core purpose
- Target devices support haptic feedback (iPhone 6S+ or Android devices with vibration motors)
- Users have network connectivity during burial and mining actions (offline exploration is acceptable)
- AI image generation service can produce suitable crystal-like imagery from text prompts
- GPS accuracy will be sufficient (under 20m) in most outdoor exploration scenarios
- Users will primarily use the app while walking outdoors, not while driving
- Memory text will be primarily in Japanese, but the system should support any language
- Crystal density will naturally distribute through both initial burial and respawning mechanism
- Crystal respawning will create sustainable exploration opportunities, preventing crystal scarcity in any given area
- Users will find value in mining the same crystal multiple times as it appears in different locations (each mining is a unique discovery experience)
- The respawn algorithm will maintain balanced crystal distribution across geographic areas
- Users will not abuse the system by burying inappropriate content (content moderation may be needed post-MVP)
- Map tiles and location services are available for the target geographic regions (Japan initially assumed)
- Concurrent mining conflicts will be rare enough that simple first-come-first-served resolution is acceptable
