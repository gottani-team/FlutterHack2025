# Data Model: Map View Feature

**Feature**: Crystal Discovery and Proximity Detection
**Date**: 2025-11-29

## Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                           crystals                               │
│ (Firestore Collection)                                           │
├─────────────────────────────────────────────────────────────────┤
│ id: string (document ID)                                         │
│ memoryText: string                                               │
│ emotionType: string (passion|silence|joy|healing)                │
│ imageUrl: string                                                 │
│ creatorId: string (user ID)                                      │
│ location: GeoPoint {latitude, longitude}                         │
│ createdAt: Timestamp                                             │
│ miningCount: number                                              │
│ status: string (active|being_mined|respawning)                   │
│ lastMinedAt: Timestamp?                                          │
│ respawnHistory: array<GeoPoint>                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ creatorId references
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                            users                                 │
│ (Firestore Collection)                                           │
├─────────────────────────────────────────────────────────────────┤
│ id: string (document ID / Firebase Auth UID)                     │
│ createdAt: Timestamp                                             │
│ lastActiveAt: Timestamp                                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ subcollection
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   users/{userId}/discoveries                     │
│ (Firestore Subcollection)                                        │
├─────────────────────────────────────────────────────────────────┤
│ id: string (document ID)                                         │
│ crystalId: string (reference to crystals)                        │
│ discoveredAt: Timestamp                                          │
│ discoveryLocation: GeoPoint {latitude, longitude}                │
│ crystalLocationAtDiscovery: GeoPoint                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## Entity Definitions

### Crystal (結晶)

**Description**: ユーザーが埋めた記憶を結晶化したもの。地図上に表示され、他のユーザーが採掘できる。

| Field | Type | Required | Description | Validation |
|-------|------|----------|-------------|------------|
| `id` | string | ✅ | Firestore自動生成ID | - |
| `memoryText` | string | ✅ | 記憶テキスト | 10-500文字 |
| `emotionType` | string | ✅ | 感情分類 | enum: passion, silence, joy, healing |
| `imageUrl` | string | ✅ | AI生成画像のStorage URL | 有効なURL形式 |
| `creatorId` | string | ✅ | 作成者のユーザーID | users/{userId}への参照 |
| `location` | GeoPoint | ✅ | 現在の位置座標 | 有効な緯度経度 |
| `createdAt` | Timestamp | ✅ | 作成日時 | - |
| `miningCount` | number | ✅ | 採掘された回数 | >= 0 |
| `status` | string | ✅ | 現在のステータス | enum: active, being_mined, respawning |
| `lastMinedAt` | Timestamp | ❌ | 最後に採掘された日時 | - |
| `respawnHistory` | array | ✅ | リスポーン履歴 | GeoPointの配列 |

**State Transitions**:
```
[作成] → active → being_mined → respawning → active
                      ↑                         │
                      └─────────────────────────┘
```

**Dart Entity**:
```dart
class CrystalEntity extends Equatable {
  final String id;
  final String memoryText;
  final EmotionType emotionType;
  final String imageUrl;
  final String creatorId;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final int miningCount;
  final CrystalStatus status;
  final DateTime? lastMinedAt;
  final List<GeoPoint> respawnHistory;
}

enum EmotionType { passion, silence, joy, healing }
enum CrystalStatus { active, beingMined, respawning }
```

---

### User (ユーザー)

**Description**: アプリを使用するユーザー。Firebase Authenticationで認証。

| Field | Type | Required | Description | Validation |
|-------|------|----------|-------------|------------|
| `id` | string | ✅ | Firebase Auth UID | - |
| `createdAt` | Timestamp | ✅ | アカウント作成日時 | - |
| `lastActiveAt` | Timestamp | ✅ | 最終アクティブ日時 | - |

**Note**: 詳細なユーザー情報はMVPでは省略。匿名認証をサポート。

---

### Discovery Record (発見記録)

**Description**: ユーザーが結晶を採掘した記録。Journalに表示するためのデータ。

| Field | Type | Required | Description | Validation |
|-------|------|----------|-------------|------------|
| `id` | string | ✅ | Firestore自動生成ID | - |
| `crystalId` | string | ✅ | 採掘した結晶のID | crystals/{id}への参照 |
| `discoveredAt` | Timestamp | ✅ | 発見日時 | - |
| `discoveryLocation` | GeoPoint | ✅ | ユーザーの位置 | 有効な緯度経度 |
| `crystalLocationAtDiscovery` | GeoPoint | ✅ | 結晶の位置（発見時点） | 有効な緯度経度 |

---

### Crystallization Area (結晶化エリア) - Derived Entity

**Description**: マップ表示用の派生エンティティ。Crystalから生成され、正確な位置は隠される。

| Field | Type | Description |
|-------|------|-------------|
| `crystalId` | string | 元のCrystal ID |
| `approximateLatitude` | double | ランダム化された緯度（±20m） |
| `approximateLongitude` | double | ランダム化された経度（±20m） |
| `emotionType` | EmotionType | 視覚化用の感情タイプ |
| `status` | AreaStatus | active / beingMined / respawning |

**Note**: このエンティティはFirestoreに保存されない。クライアント側でCrystalから計算される。

---

### User Location (ユーザー位置) - Client-only Entity

**Description**: GPSから取得したユーザーの現在位置。サーバーには送信しない。

| Field | Type | Description |
|-------|------|-------------|
| `latitude` | double | 緯度 |
| `longitude` | double | 経度 |
| `accuracy` | double | 精度（メートル） |
| `timestamp` | DateTime | 取得時刻 |
| `heading` | double? | 方位（度） |
| `speed` | double? | 速度（m/s） |

---

## Firestore Indexes

### Required Composite Indexes

```
Collection: crystals
Fields: 
  - location.latitude (ASC)
  - status (==)
```

**Purpose**: Bounding Box geo-queryとステータスフィルタの組み合わせ

---

## Validation Rules

### Memory Text
- 最小: 10文字
- 最大: 500文字
- 空白のみは不可

### Emotion Type
- 許可値: `passion`, `silence`, `joy`, `healing`

### Location
- 緯度: -90.0 ~ 90.0
- 経度: -180.0 ~ 180.0

### Mining Count
- 非負整数

---

## Data Flow for Map View

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────┐
│   GPS       │────▶│  Location    │────▶│  MapViewModel   │
│   Service   │     │  DataSource  │     │                 │
└─────────────┘     └──────────────┘     │                 │
                                          │  ┌───────────┐  │
┌─────────────┐     ┌──────────────┐     │  │ ViewState │  │
│  Firestore  │────▶│  Crystal     │────▶│  │           │  │
│  crystals   │     │  DataSource  │     │  └───────────┘  │
└─────────────┘     └──────────────┘     └────────┬────────┘
                                                   │
                                                   ▼
                                          ┌─────────────────┐
                                          │    MapPage      │
                                          │    (Widget)     │
                                          └─────────────────┘
```

---

## Sample Data

### Crystal Document
```json
{
  "id": "crystal_abc123",
  "memoryText": "桜の下で出会った友人との大切な時間",
  "emotionType": "joy",
  "imageUrl": "https://storage.googleapis.com/.../crystal_abc123.png",
  "creatorId": "user_xyz789",
  "location": {
    "_latitude": 35.6812,
    "_longitude": 139.7671
  },
  "createdAt": "2025-11-29T10:30:00Z",
  "miningCount": 3,
  "status": "active",
  "lastMinedAt": "2025-11-28T15:45:00Z",
  "respawnHistory": [
    {"_latitude": 35.6800, "_longitude": 139.7650},
    {"_latitude": 35.6825, "_longitude": 139.7690}
  ]
}
```

### Discovery Record Document
```json
{
  "id": "discovery_def456",
  "crystalId": "crystal_abc123",
  "discoveredAt": "2025-11-29T12:00:00Z",
  "discoveryLocation": {
    "_latitude": 35.6815,
    "_longitude": 139.7668
  },
  "crystalLocationAtDiscovery": {
    "_latitude": 35.6812,
    "_longitude": 139.7671
  }
}
```

