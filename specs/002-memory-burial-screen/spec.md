# Feature Specification: Memory Burial Screen

**Feature Branch**: `002-memory-burial-screen`  
**Created**: 2025-11-29  
**Updated**: 2025-11-29  
**Status**: Draft  

## Overview

Memory Burial Screenは、ユーザーが記憶をテキストとして入力し、視覚的なアニメーションとともに「埋める」ことができる画面です。入力されたテキストは文字単位で分解され、ボタンに吸い込まれるエフェクトとともにサーバーに送信されます。

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Memory Text Input and Validation (Priority: P1)

ユーザーが記憶をテキストとして入力し、システムが適切な長さを検証する。

**Why this priority**: Memory Burial体験の基盤となる入力機能。適切な入力検証がなければ、後続のAI生成プロセスが失敗する可能性がある。

**Independent Test**: ユーザーがテキスト入力フィールドにアクセスし、文字数制限（10～500文字）の範囲内でテキストを入力できることを検証することで、単独でテストできる。

**Acceptance Scenarios**:

1. **Given** ユーザーがMemory Burial画面にいる、**When** テキスト入力エリアをタップする、**Then** キーボードが表示され、記憶のテキストを入力できる
2. **Given** ユーザーがテキストを入力している、**When** 文字数が10文字未満の場合、**Then** 埋めるボタンは無効化される
3. **Given** ユーザーがテキストを入力している、**When** 文字数が500文字を超える場合、**Then** 追加入力がブロックされる
4. **Given** ユーザーが10～500文字のテキストを入力した、**When** 入力が完了する、**Then** 埋めるボタンが有効化される

---

### User Story 2 - Memory Burial with Text Dissolution Animation (Priority: P1)

ユーザーが「埋める」ボタンをタップすると、入力テキストが文字単位で分解され、ボタンに吸い込まれるアニメーションが表示され、同時にサーバーへのリクエストが送信される。

**Why this priority**: アプリのコア体験。視覚的なフィードバックとバックエンド処理を同期させることで、スムーズなユーザー体験を実現する。

**Independent Test**: 有効なテキスト入力に対してボタンをタップし、アニメーションが正しく実行され、同時にAPIリクエストが送信されることを検証することで、単独でテストできる。

**Acceptance Scenarios**:

1. **Given** ユーザーが10文字以上のテキストを入力した、**When** 埋めるボタンをタップする、**Then** テキストが文字単位で分解され、ボタンに向かって吸い込まれるアニメーションが開始される
2. **Given** アニメーションが開始された、**When** アニメーションが実行されている、**Then** 同時にサーバーへのリクエストが送信される（記憶テキスト + GPS座標など）
3. **Given** アニメーションが完了した、**When** サーバーからのレスポンスを待機している、**Then** バックグラウンドで処理完了を待つ（ユーザーにはローディング表示なし）
4. **Given** サーバーからのレスポンスが成功した、**When** 埋葬処理が完了する、**Then** 成功メッセージが2秒間表示される
5. **Given** 成功メッセージが表示された、**When** メッセージ表示時間が経過する、**Then** マップ画面に遷移する

---

### User Story 3 - Error Handling and Retry (Priority: P1)

ネットワークエラーやAI生成失敗時に、ユーザーに適切なフィードバックを提供し、リトライ機能を提供する。

**Why this priority**: 実際の使用環境ではネットワークエラーが発生する可能性がある。適切なエラーハンドリングがないと、ユーザー体験が著しく損なわれる。

**Independent Test**: ネットワークを切断した状態で埋めるボタンをタップし、エラーメッセージとリトライボタンが表示されることを検証することで、単独でテストできる。

**Acceptance Scenarios**:

1. **Given** ユーザーがテキストを入力し埋めるボタンをタップした、**When** ネットワークエラーが発生する、**Then** エラーメッセージが表示される
2. **Given** エラーメッセージが表示されている、**When** リトライボタンをタップする、**Then** 再度リクエストが送信される
3. **Given** AI生成処理が失敗した、**When** サーバーがエラーレスポンスを返す、**Then** エラーメッセージとリトライオプションが表示される
4. **Given** ユーザーがリトライを実行した、**When** 2回目の試行が成功する、**Then** 通常の成功フローが実行される

---

### Edge Cases

- ネットワーク接続が不安定な場合はどうなるか？（タイムアウト設定とリトライメカニズム）
- 埋めるボタンを連打した場合はどうなるか？（重複送信を防止）
- アニメーション実行中に画面を離れた場合はどうなるか？（状態を保存し、戻ったときに適切に処理）
- 位置情報が取得できない場合はどうなるか？（package/core側のモック実装で対応）
- テキストに特殊文字や絵文字が含まれる場合はどうなるか？（適切にエンコードして送信）

## Requirements *(mandatory)*

### Functional Requirements

#### Text Input and Validation

- **FR-001**: System MUST provide a text input area at the top of the screen for memory description
- **FR-002**: System MUST enforce minimum text length of 10 characters
- **FR-003**: System MUST enforce maximum text length of 500 characters
- **FR-004**: System MUST disable "埋める" button when text length is below 10 characters
- **FR-005**: System MUST prevent text input beyond 500 character limit

#### Button and UI Layout

- **FR-006**: System MUST display a circular "埋める" button at the bottom of the screen
- **FR-007**: System MUST apply gradient and light effect styling to the button
- **FR-008**: System MUST enable button only when text length is between 10-500 characters

#### Burial Animation and Request

- **FR-009**: System MUST trigger text dissolution animation when user taps "埋める" button
- **FR-010**: System MUST decompose input text into individual characters during animation
- **FR-011**: System MUST animate characters to move toward and be absorbed into the button
- **FR-012**: System MUST send API request to server simultaneously with animation start
- **FR-013**: System MUST include memory text and GPS coordinates in the request payload
- **FR-014**: System MUST wait for server response in background after animation completes
- **FR-015**: System MUST prevent duplicate requests if user taps button multiple times

#### Success Flow

- **FR-016**: System MUST display success message when server responds successfully
- **FR-017**: System MUST show success message for 2 seconds
- **FR-018**: System MUST navigate to map screen after success message display completes
- **FR-019**: System MUST save crystal data returned from server (color, emotion type, etc.) without displaying to user

#### Error Handling

- **FR-020**: System MUST display error message when network request fails
- **FR-021**: System MUST display error message when AI generation fails
- **FR-022**: System MUST provide retry button when error occurs
- **FR-023**: System MUST preserve user's input text when error occurs (no need to re-type)
- **FR-024**: System MUST implement request timeout (30 seconds)

#### Location Integration

- **FR-025**: System MUST use location data from package/core module
- **FR-026**: System MUST work with mock location data during development

### Key Entities

- **Memory Text**: User input text (10-500 characters)
- **Crystal Data**: Server response containing color, emotion type, and other metadata (not displayed to user)
- **GPS Coordinates**: Location data from package/core module

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can input text and complete burial in under 30 seconds for typical memories (100-200 characters)
- **SC-002**: Text dissolution animation completes within 2 seconds
- **SC-003**: Character count validation responds instantly (within 100ms) as user types
- **SC-004**: Server request succeeds for 95% of burial attempts under normal network conditions
- **SC-005**: Users can successfully retry and complete burial on second attempt for 95% of failures
- **SC-006**: System prevents 100% of duplicate burial attempts
- **SC-007**: Success message displays for exactly 2 seconds before navigation

### Assumptions

- Location data is available from package/core module (mock implementation acceptable)
- Server can process memory text and return crystal data (color, emotion type, etc.)
- Users have network connectivity during burial process (offline handling is for edge cases only)
- Memory text will be primarily in Japanese, but system should support any language input
- Server response time is typically under 10 seconds
- Animation performance is acceptable on target devices
