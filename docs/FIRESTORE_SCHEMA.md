# Firestore Database Schema

## Overview

Chimyaku（地脈）- ダークファンタジー位置情報秘密交換ゲームのデータベーススキーマ。

**テーマ**: 「文脈を地脈へ、そして金脈へ」

---

## Collections

### `crystals`（想晶）

昇華された秘密が結晶化したもの。解読されるまで地図上に存在する。

#### Document Structure

```typescript
{
  // === Public Info (Map Display) ===

  // 状態
  status: 'available' | 'taken',  // available: 解読可能, taken: 解読済み

  // カルマ値（解読に必要なコスト）
  karmaValue: number,             // 0-100, AIが判定した秘密の「重さ」

  // クリスタル画像URL
  imageUrl: string,               // Crystal asset URL (emotion × rarity)

  // AI解析メタデータ
  aiMetadata: {
    emotionType: 'happiness' | 'enjoyment' | 'relief' | 'anticipation' |
                 'sadness' | 'embarrassment' | 'anger' | 'emptiness',
    score: number                 // 0-100 (rarity tier derived from this)
  },

  // 作成日時
  createdAt: Timestamp,

  // === Hidden Info (Protected until decipherment) ===

  // 秘密テキスト（解読後に閲覧可能）
  secretText: string,             // 10-500文字

  // === Management ===

  // 作成者ID
  createdBy: string,              // Firebase Auth UID

  // 解読者ID（nullなら未解読）
  decipheredBy: string | null,

  // 解読日時
  decipheredAt: Timestamp | null,

  // === Demo Mode (Position Simulation) ===
  // Note: デモではクライアント側でランダム座標を割り当てるため、
  // サーバーには位置情報を保存しない
}
```

#### Rarity Tiers (derived from score)

| Tier | Score Range | Description |
|------|-------------|-------------|
| Common | 0-59 | Small dim shard |
| Rare | 60-89 | Glowing crystal |
| S-Rare | 90-100 | Massive pulsing cluster |

#### Emotion Types (8 Types with Crystal Colors)

| Type | Color | HEX | Japanese |
|------|-------|-----|----------|
| happiness | Pink | #FF69B4 | 嬉しさ |
| enjoyment | Orange | #FFA500 | 楽しさ |
| relief | Green | #32CD32 | 安心 |
| anticipation | Yellow | #FFD700 | 期待 |
| sadness | Blue | #4169E1 | 悲しみ |
| embarrassment | Purple | #9370DB | 恥ずかしさ |
| anger | Red | #DC143C | 怒り |
| emptiness | Gray | #708090 | 虚しさ |

#### Security Rules

- **Read**: 認証済みユーザーなら誰でも読み取り可能
  - ただし `secretText` は `status='taken'` かつ `decipheredBy` が自分の場合のみ
- **Create**: Cloud Functions経由のみ（昇華処理）
- **Update**: Cloud Functions経由のみ（解読処理）
- **Delete**: 禁止

---

### `users`

プレイヤー情報とカルマ残高を管理。

#### Document Structure

```typescript
{
  // カルマ残高
  currentKarma: number,           // 現在のカルマポイント

  // 作成日時
  createdAt: Timestamp
}
```

#### Security Rules

- **Read/Write**: 自分のドキュメントのみ
- **Karma更新**: Cloud Functions経由のみ（不正防止）

---

### `users/{userId}/collected_crystals`（サブコレクション）

ユーザーが解読したクリスタルのコレクション（ジャーナル用）。

#### Document Structure

```typescript
{
  // 明かされた秘密
  secretText: string,

  // クリスタル画像URL
  imageUrl: string,

  // 支払ったカルマ
  karmaCost: number,

  // AIメタデータ
  aiMetadata: {
    emotionType: 'passion' | 'silence' | 'joy' | 'healing',
    score: number
  },

  // 解読日時
  decipheredAt: Timestamp,

  // 元の作成者ID
  originalCreatorId: string
}
```

#### Security Rules

- **Read/Write**: 自分のサブコレクションのみ

---

## Cloud Functions

### `sublimate`

秘密をカルマに変換し、クリスタルを生成する。

**Input:**
```typescript
{
  secretText: string    // 10-500文字の秘密テキスト
}
```

**Process:**
1. テキストをGemini AIで解析
2. emotion type と score (0-100) を取得
3. クリスタルを `crystals` コレクションに作成
4. ユーザーの `currentKarma` にスコア分を加算
5. 結果を返す

**Output:**
```typescript
{
  crystalId: string,
  karmaAwarded: number,
  aiMetadata: { emotionType, score }
}
```

---

### `decipherCrystal`

カルマを支払ってクリスタルを解読する（アトミックトランザクション）。

**Input:**
```typescript
{
  crystalId: string
}
```

**Process (Transaction):**
1. クリスタルの `status` が `'available'` か確認
2. ユーザーの `currentKarma` >= クリスタルの `karmaValue` か確認
3. ユーザーの `currentKarma` から `karmaValue` を減算
4. クリスタルの `status` を `'taken'` に変更
5. クリスタルの `decipheredBy`, `decipheredAt` を設定
6. `collected_crystals` サブコレクションにコピーを作成
7. 秘密テキストを返す

**Output:**
```typescript
{
  success: boolean,
  secretText: string | null,
  error?: 'INSUFFICIENT_KARMA' | 'ALREADY_TAKEN' | 'NOT_FOUND'
}
```

**Race Condition Handling:**
- Firestoreトランザクションにより、同時解読リクエストは先着順で処理
- 後からのリクエストは `ALREADY_TAKEN` エラーを返す

---

## Crystal Asset Matrix

24種類のプリメイドアセット（8 emotions × 3 rarities）:

| Emotion | Common (0-59) | Rare (60-89) | S-Rare (90-100) |
|---------|---------------|--------------|-----------------|
| Happiness (Pink) | `happiness_common.png` | `happiness_rare.png` | `happiness_srare.png` |
| Enjoyment (Orange) | `enjoyment_common.png` | `enjoyment_rare.png` | `enjoyment_srare.png` |
| Relief (Green) | `relief_common.png` | `relief_rare.png` | `relief_srare.png` |
| Anticipation (Yellow) | `anticipation_common.png` | `anticipation_rare.png` | `anticipation_srare.png` |
| Sadness (Blue) | `sadness_common.png` | `sadness_rare.png` | `sadness_srare.png` |
| Embarrassment (Purple) | `embarrassment_common.png` | `embarrassment_rare.png` | `embarrassment_srare.png` |
| Anger (Red) | `anger_common.png` | `anger_rare.png` | `anger_srare.png` |
| Emptiness (Gray) | `emptiness_common.png` | `emptiness_rare.png` | `emptiness_srare.png` |

**Storage Path:** `/crystal_images/{emotion}_{rarity}.png`

---

## Query Patterns

### 1. 利用可能なクリスタルを取得（デモ用）

```dart
final query = firestore
  .collection('crystals')
  .where('status', isEqualTo: 'available')
  .orderBy('createdAt', descending: true)
  .limit(20);
```

### 2. 自分が作成したクリスタルを取得

```dart
final query = firestore
  .collection('crystals')
  .where('createdBy', isEqualTo: userId)
  .orderBy('createdAt', descending: true)
  .limit(50);
```

### 3. 解読したクリスタルを取得（ジャーナル）

```dart
final query = firestore
  .collection('users')
  .doc(userId)
  .collection('collected_crystals')
  .orderBy('decipheredAt', descending: true)
  .limit(50);
```

---

## Indexes

以下のインデックスを作成:

1. **利用可能クリスタル検索用**
   - Collection: `crystals`
   - Fields: `status` (Ascending) + `createdAt` (Descending)

2. **作成者検索用**
   - Collection: `crystals`
   - Fields: `createdBy` (Ascending) + `createdAt` (Descending)

---

## Performance Considerations

### Query Limits

- 各クエリは `limit(20-50)` を設定してデータ転送量を制限
- ジャーナルはページネーション対応（`startAfter()` 使用）

### Demo Mode Position Simulation

デモでは位置情報をサーバーに保存せず、クライアント側で処理:

1. `status='available'` のクリスタルをFetch（limit 20）
2. クライアント側でデモ会場周辺にランダム座標を割り当て
3. アプリ再起動またはリフレッシュで位置を再ランダマイズ
4. これにより「流れる」クリスタルの錯覚を演出

---

## Data Migration Notes

### From Previous Schema

旧スキーマからの移行ポイント:

| 旧フィールド | 新フィールド | 備考 |
|-------------|-------------|------|
| `text` | `secretText` | 名称変更 |
| `creatorId` | `createdBy` | 名称変更 |
| `isExcavated` | `status` | boolean → enum |
| `excavatedBy` | `decipheredBy` | 名称変更 |
| `excavatedAt` | `decipheredAt` | 名称変更 |
| `emotion` | `aiMetadata.emotionType` | ネスト構造へ |
| - | `karmaValue` | 新規追加 |
| - | `aiMetadata.score` | 新規追加 |
| - | `imageUrl` | 新規追加 |
| `location` | - | 削除（デモ用） |
| `geohash` | - | 削除（デモ用） |
