# Feature Specification: Chimyaku (地脈) - Dark Fantasy Location-Based Secret Exchange

**Feature Branch**: `001-chimyaku-app`
**Created**: 2025-11-29
**Updated**: 2025-11-29
**Status**: Draft

## Theme

**「文脈を地脈へ、そして金脈へ」**

人間の誰にも言えない「文脈（秘密の記憶）」は、エネルギーとなって「地脈」を流れ、やがて価値ある「金脈（想晶）」となって地表に現れる。

これは、自らの秘密を「カルマ（業）」という通貨に変え、そのカルマを使って他者の秘密を暴く、**背徳のダークファンタジー位置情報ゲーム**である。

## Core Game Loop

1. **昇華 (Sublimate):** 墓場まで持っていくような秘密をアプリに吐き出す。AIがその「重さ」を判定し、対価として「カルマ（ポイント）」が付与される。
2. **流転 (Flow):** 吐き出された秘密は「想晶（メモリ・クリスタル）」となり、地図上の地脈に沿ってランダムに移動し続ける。
3. **探索 (Hunt):** プレイヤーは地図と鼓動（ハプティクス）を頼りに、高カルマの想晶を探し回る。
4. **解読 (Decipher):** 発見した想晶に貯めたカルマを支払うことで、封印を解き、中身の秘密を覗き見る。一度解読された想晶は消滅する（早い者勝ち）。

## Terminology (World Building)

| 元の表現 | ブラッシュアップ後 | 意味・意図 |
|---------|------------------|-----------|
| 秘密/記憶 | **想念 (ノエシス)** | 生々しい感情エネルギーの塊 |
| 金脈/クリスタル | **想晶 (ソウショウ)** | 想念が地表で結晶化したもの。価値を持つ |
| ポイント/金策 | **カルマ (業)** | この世界における通貨。秘密の重さそのもの |
| 埋める/流す | **昇華 (ショウカ)** | 秘密を手放し、カルマに変える儀式 |
| 掘る/見る | **解読 (カイドク)** | カルマを消費して他者の秘密を暴く行為 |

---

## User Scenarios & Testing

### User Story 1 - Sublimation (昇華) - Secret to Karma (Priority: P1)

A user wants to convert their deepest secret into Karma currency by submitting it to the system for AI evaluation. The user can preview the evaluation result before deciding to actually bury the secret.

**Why this priority**: This is the core content creation mechanism that generates both the in-game currency (Karma) and the discoverable content (Crystals). Without user-generated secrets, there's nothing to hunt.

**Independent Test**: Can be fully tested by having a user input secret text, triggering AI analysis, previewing the result, then confirming to receive Karma and create the crystal.

**Two-Step Flow**:
1. **Evaluate (評価)**: User enters secret text → AI analyzes → Preview result shown (emotion type, rarity, Karma to earn)
2. **Confirm (確定)**: User reviews preview → Decides to bury or cancel → If confirmed, crystal is created and Karma is awarded

**Acceptance Scenarios**:

1. **Given** a user is at the Sublimation screen, **When** they enter secret text and tap "Evaluate", **Then** the text swirls into a condensing light orb animation while AI analyzes in background
2. **Given** AI analysis completes, **When** the evaluation result is ready, **Then** the system displays a preview: crystal type (color based on emotion, size based on rarity), emotion name, rarity tier, and Karma amount to be earned
3. **Given** evaluation preview is displayed, **When** user taps "Bury This Secret", **Then** the crystal is created in Firestore and user's Karma balance increases with satisfying coin-drop sound effects
4. **Given** evaluation preview is displayed, **When** user taps "Cancel" or back button, **Then** the secret is NOT saved and user returns to input screen (no Karma earned)
5. **Given** a high-score secret (90+), **When** preview displays, **Then** screen flashes with particle effects and S-Rare crystal animation plays as preview

---

### User Story 2 - Exploration Map (探索) - Hunting Crystals (Priority: P1)

A user explores the dark fantasy map to find pulsating crystals, experiencing intensifying heartbeat feedback as they approach high-value targets.

**Why this priority**: This is the primary exploration mechanic that drives physical movement and creates anticipation through sensory feedback differentiated by crystal value.

**Demo Specification**: For the hackathon demo, crystals do NOT use real-time position tracking. Instead:
- Fetch available crystals from Firestore
- Assign random coordinates near the demo venue on the client side
- Refresh/randomize positions on app restart or manual refresh to simulate "movement"

**Acceptance Scenarios**:

1. **Given** a user opens the map screen, **When** crystals exist, **Then** they appear as pulsing light points along the dark map's energy flow (地脈) visualization
2. **Given** crystals have different Karma values, **When** displayed on map, **Then** higher-value crystals pulse stronger and larger
3. **Given** a user approaches a crystal (within 100m), **When** they enter the proximity zone, **Then** the "Bio-Sensor" gauge activates and device begins heartbeat vibrations
4. **Given** approaching a high-Karma crystal, **When** getting closer, **Then** vibrations become heavier and more intense (HapticFeedback.heavyImpact)
5. **Given** a user reaches within 25m, **When** threshold crossed, **Then** screen seamlessly transitions to Mining screen

---

### User Story 3 - Mining and Deciphering (採掘・解読) - Revealing Secrets (Priority: P1)

A user physically arrives at a crystal location, performs mining actions to shatter the crystal, pays Karma to decipher, and reads the revealed secret. First-come-first-served - once deciphered, the crystal is gone.

**Why this priority**: This completes the core loop by providing the reward mechanism. The tension of "will someone else get it first?" and the reveal of a stranger's secret creates the core engagement.

**Acceptance Scenarios**:

1. **Given** a user enters the Mining screen, **When** screen loads, **Then** a large crystal (asset based on emotion type and rarity) displays with pulsing animation
2. **Given** the crystal is displayed, **When** user taps it, **Then** sparks fly, metallic sounds play, strong haptic feedback triggers, and visible cracks appear
3. **Given** user continues tapping, **When** crystal durability reaches zero (5-10 taps), **Then** crystal shatters with explosive animation
4. **Given** crystal is shattered, **When** animation completes, **Then** transaction dialog appears: "Decipher this crystal? Required Karma: X (You have: Y)"
5. **Given** user confirms and has sufficient Karma, **When** approved, **Then** Karma deducts, crystal explodes into particles, and secret text floats up from the light
6. **Given** user doesn't have enough Karma, **When** they try to confirm, **Then** error message displays explaining Karma shortage
7. **Given** successful decipherment, **When** user closes the screen, **Then** crystal is removed from map (unavailable to others) and added to user's Journal

---

### User Story 4 - Journal Collection (Priority: P3)

A user reviews all secrets they have deciphered in a personal collection gallery, tracking their Karma and discovered secrets.

**Why this priority**: Adds long-term engagement and collection mechanics but not essential for core loop demonstration.

**Acceptance Scenarios**:

1. **Given** a user opens the Journal, **When** they have deciphered crystals, **Then** a grid displays crystal thumbnails with emotion-type colors
2. **Given** crystals in Journal, **When** user taps one, **Then** detail view shows crystal image, secret text, Karma cost paid, and decipher date
3. **Given** user has no deciphered crystals, **When** opening Journal, **Then** empty state encourages exploration
4. **Given** Journal header, **When** displayed, **Then** shows current total Karma balance prominently

---

### Edge Cases

- What happens when a user tries to sublimate without network connectivity?
- How does the system handle AI analysis failures or timeouts?
- What happens if two users try to decipher the same crystal simultaneously? (First transaction wins)
- How does the system behave when GPS accuracy is poor?
- What happens if a user has 0 Karma and finds a crystal?
- How does the system handle inappropriate secret content? (Post-MVP moderation)
- What happens when user tries to decipher their own crystal? (Allowed - no restrictions)

---

## Requirements

### Functional Requirements

#### Map and Location Features

- **FR-001**: System MUST display a dark-themed fantasy-style map with 地脈 (energy flow) visualization as blue-white flowing particles
- **FR-002**: System MUST display crystals as pulsing light points, NOT fixed pins, with pulse intensity based on Karma value
- **FR-003**: System MUST fetch available crystals from Firestore and assign random nearby coordinates (demo mode)
- **FR-004**: System MUST provide refresh mechanism to re-randomize crystal positions (simulating movement)
- **FR-005**: System MUST NOT display exact crystal locations, only approximate glowing areas

#### Proximity and Sensory Feedback (Bio-Sensor)

- **FR-006**: System MUST detect when user enters 100m radius of any crystal
- **FR-007**: System MUST activate "Bio-Sensor" heartbeat gauge on proximity detection
- **FR-008**: System MUST trigger heartbeat vibrations synchronized with visual pulse
- **FR-009**: System MUST use HapticFeedback.heavyImpact for high-Karma crystals, lightImpact for low-Karma
- **FR-010**: System MUST increase vibration intensity and frequency as distance decreases
- **FR-011**: System MUST automatically transition to Mining screen when within 25m
- **FR-012**: System MUST prioritize closest crystal when multiple are nearby

#### Sublimation Flow (Secret → Karma) - Two-Step Process

##### Step 1: Evaluation (評価)

- **FR-013**: System MUST provide text input for secret (minimum 10, maximum 500 characters)
- **FR-014**: System MUST provide "Evaluate" button to trigger AI analysis
- **FR-015**: System MUST display swirling condensation animation during AI processing
- **FR-016**: System MUST call AI (Gemini) to analyze secret and return: emotion type (8 types) + weight score (0-100)
- **FR-017**: System MUST display evaluation preview: crystal image, emotion type, rarity tier, and Karma to earn
- **FR-018**: System MUST NOT save any data to Firestore during evaluation step

##### Step 2: Confirmation (確定)

- **FR-019**: System MUST display "Bury This Secret" and "Cancel" buttons after evaluation
- **FR-020**: System MUST save crystal to Firestore with status='available' ONLY when user confirms
- **FR-021**: System MUST update user's currentKarma balance ONLY when user confirms
- **FR-022**: System MUST award Karma equal to the weight score
- **FR-023**: System MUST play escalating celebration effects for higher scores (S-Rare = maximum effects)
- **FR-024**: System MUST return to input screen without saving if user cancels

#### Crystal Asset System

- **FR-025**: System MUST categorize crystals by 8 emotion types with corresponding colors:
  - Happiness (嬉しさ) - Pink (#FF69B4)
  - Enjoyment (楽しさ) - Orange (#FFA500)
  - Relief (安心) - Green (#32CD32)
  - Anticipation (期待) - Yellow (#FFD700)
  - Sadness (悲しみ) - Blue (#4169E1)
  - Embarrassment (恥ずかしさ) - Purple (#9370DB)
  - Anger (怒り) - Red (#DC143C)
  - Emptiness (虚しさ) - Gray (#708090)
- **FR-026**: System MUST categorize crystals by 3 rarity tiers: Common (0-59), Rare (60-89), S-Rare (90-100)
- **FR-027**: System MUST provide 24 pre-made crystal assets (8 emotions × 3 rarities)
- **FR-028**: System MUST apply pulsing animation to all crystals, with intensity based on rarity
- **FR-029**: System MUST apply glow effects beneath crystals, with brightness based on rarity

#### Mining Flow

- **FR-030**: System MUST display centered crystal image with breathing scale animation
- **FR-031**: System MUST detect tap gestures on crystal
- **FR-032**: System MUST display spark effects, play metallic sound, trigger haptic feedback per tap
- **FR-033**: System MUST show progressive crack damage overlay
- **FR-034**: System MUST shatter crystal after 5-10 taps (durability reaches zero)
- **FR-035**: System MUST synchronize haptic pulses with visual pulsing animation

#### Decipherment Flow (Karma Transaction)

- **FR-036**: System MUST display transaction dialog after mining: "Decipher? Required: X Karma (You have: Y)"
- **FR-037**: System MUST validate user has sufficient Karma before allowing decipherment
- **FR-038**: System MUST use Firestore Transaction (via Cloud Function) for atomic decipherment
- **FR-039**: System MUST verify crystal status='available' at transaction time (first-come-first-served)
- **FR-040**: System MUST deduct Karma from user balance on successful decipherment
- **FR-041**: System MUST change crystal status to 'taken' and set decipheredBy
- **FR-042**: System MUST copy crystal data to user's collected_crystals subcollection
- **FR-043**: System MUST animate secret text reveal with floating particle effect
- **FR-044**: System MUST remove crystal from map for all users after decipherment

#### Journal

- **FR-045**: System MUST display current Karma balance prominently
- **FR-046**: System MUST display grid of deciphered crystals with thumbnails
- **FR-047**: System MUST sort by decipher date (most recent first)
- **FR-048**: System MUST show detail view with crystal image, secret text, Karma cost, date
- **FR-049**: System MUST show empty state when no crystals collected

#### Authentication and Data

- **FR-050**: System MUST authenticate users anonymously (Firebase Auth)
- **FR-051**: System MUST persist user Karma balance in Firestore
- **FR-052**: System MUST persist crystal data with secretText protected until decipherment
- **FR-053**: System MUST track decipherment history to prevent re-deciphering same crystal

---

## Key Entities

### Crystal (想晶)

Represents a sublimated secret that exists in the world until deciphered.

```typescript
{
  // Public info (map display)
  status: 'available' | 'taken',
  karmaValue: number,           // 0-100, also the cost to decipher
  imageUrl: string,             // Crystal asset URL
  aiMetadata: {
    emotionType: 'happiness' | 'enjoyment' | 'relief' | 'anticipation' |
                 'sadness' | 'embarrassment' | 'anger' | 'emptiness',
    score: number               // 0-100 (rarity tier derived from this)
  },
  createdAt: Timestamp,

  // Hidden info (protected until decipherment)
  secretText: string,           // The actual secret

  // Management
  createdBy: string,            // userId who sublimated
  decipheredBy: string | null,  // userId who deciphered (null if available)
  decipheredAt: Timestamp | null
}
```

### User

Represents a player in the system.

```typescript
{
  currentKarma: number,         // Current Karma balance
  createdAt: Timestamp
}
```

### Collected Crystal (Subcollection: users/{userId}/collected_crystals)

Represents a user's deciphered crystal for Journal display.

```typescript
{
  secretText: string,           // The revealed secret
  imageUrl: string,
  karmaCost: number,            // How much Karma was paid
  aiMetadata: { emotionType, score },
  decipheredAt: Timestamp,
  originalCreatorId: string
}
```

---

## Success Criteria

### Measurable Outcomes

- **SC-001**: Sublimation flow completes (text → AI analysis → result) in under 30 seconds
- **SC-002**: Users feel heartbeat feedback within 2 seconds of entering 100m proximity
- **SC-003**: Mining interaction completes (tapping → shatter → reveal) in under 15 seconds
- **SC-004**: AI emotion/score analysis succeeds for 95% of sublimation attempts
- **SC-005**: Map renders smoothly at 60fps with 20+ crystals displayed
- **SC-006**: Transaction (decipherment) resolves correctly in race conditions (first-come-first-served)
- **SC-007**: Haptic feedback clearly differentiates between Common, Rare, and S-Rare crystals
- **SC-008**: Users report feeling the "dark fantasy" atmosphere (survey rating >4.0/5.0)

### Assumptions

- Users will grant location permissions for proximity detection
- Target devices support haptic feedback (iPhone 6S+ / modern Android)
- Network connectivity available during sublimation and decipherment
- Gemini API can reliably analyze text for emotion and "weight"
- Demo will be conducted in a controlled area where crystal positions can be pre-seeded
- 24 pre-made crystal assets (8 emotions × 3 rarities) will be sufficient for MVP (no AI image generation)
- Users understand the "dark secret exchange" concept and find it engaging
- Concurrent decipherment conflicts will be rare enough for simple transaction resolution

---

## Technical Architecture

### Firebase Structure

**Firestore Collections:**
- `users/{userId}` - User data and Karma balance
- `users/{userId}/collected_crystals/{crystalId}` - Deciphered crystal copies
- `crystals/{crystalId}` - Master crystal data

**Cloud Storage:**
- `/crystal_images/{emotion}_{rarity}.png` - Pre-made crystal assets

**Cloud Functions (Recommended):**
- `decipherCrystal(crystalId)` - Atomic transaction for first-come-first-served decipherment

### Security Rules (Simplified for Hackathon)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /collected_crystals/{crystalId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }

    match /crystals/{crystalId} {
      allow read: if request.auth != null;
      allow write: if false; // Cloud Functions only
    }
  }
}
```

### Crystal Asset Matrix (8 Emotions × 3 Rarities = 24 Assets)

| Emotion | Color | Common (0-59) | Rare (60-89) | S-Rare (90-100) |
|---------|-------|---------------|--------------|-----------------|
| Happiness (嬉しさ) | Pink | Small dim pink shard | Glowing pink crystal | Massive pulsing pink cluster |
| Enjoyment (楽しさ) | Orange | Small dim orange shard | Glowing orange crystal | Massive pulsing orange cluster |
| Relief (安心) | Green | Small dim green shard | Glowing green crystal | Massive pulsing green cluster |
| Anticipation (期待) | Yellow | Small dim yellow shard | Glowing yellow crystal | Massive pulsing yellow cluster |
| Sadness (悲しみ) | Blue | Small dim blue shard | Glowing blue crystal | Massive pulsing blue cluster |
| Embarrassment (恥ずかしさ) | Purple | Small dim purple shard | Glowing purple crystal | Massive pulsing purple cluster |
| Anger (怒り) | Red | Small dim red shard | Glowing red crystal | Massive pulsing red cluster |
| Emptiness (虚しさ) | Gray | Small dim gray shard | Glowing gray crystal | Massive pulsing gray cluster |

---

## Demo Strategy

### Position Simulation

Since real-time crystal movement is complex, the demo uses position randomization:

1. Fetch `status='available'` crystals from Firestore (limit 20)
2. Client-side assigns random coordinates within ~500m of demo venue
3. App restart or refresh button re-randomizes positions
4. This creates illusion of "flowing" crystals without backend complexity

### Developer Testing Features

- Mock location override for testing proximity triggers
- Karma balance adjustment for testing transaction flows
- Crystal seeding tool for populating demo area
