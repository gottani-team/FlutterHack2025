# Firestore Schema Contract

**Feature**: Chimyaku Map View
**Date**: 2025-11-29

## Collections

### `crystals`

**Path**: `/crystals/{crystalId}`

```typescript
interface Crystal {
  // Identifiers
  id: string;                    // Auto-generated document ID
  creatorId: string;             // Reference to users/{userId}
  
  // Content
  memoryText: string;            // 10-500 characters
  emotionType: 'passion' | 'silence' | 'joy' | 'healing';
  imageUrl: string;              // Cloud Storage URL
  
  // Location (mutable - changes on respawn)
  location: GeoPoint;            // { latitude: number, longitude: number }
  
  // Status
  status: 'active' | 'being_mined' | 'respawning';
  miningCount: number;           // >= 0
  
  // Timestamps
  createdAt: Timestamp;
  lastMinedAt?: Timestamp;       // Optional, null if never mined
  
  // History
  respawnHistory: GeoPoint[];    // Array of previous locations
}
```

**Indexes**:
```
// Required for geo-query with status filter
crystals: location.latitude ASC, status ==

// For creator's crystals query
crystals: creatorId ==, createdAt DESC
```

**Security Rules**:
```javascript
match /crystals/{crystalId} {
  // Anyone authenticated can read crystals
  allow read: if request.auth != null;
  
  // Only creator can create
  allow create: if request.auth != null 
    && request.resource.data.creatorId == request.auth.uid;
  
  // Status updates allowed for mining (optimistic locking needed)
  allow update: if request.auth != null
    && request.resource.data.status in ['active', 'being_mined', 'respawning'];
}
```

---

### `users`

**Path**: `/users/{userId}`

```typescript
interface User {
  id: string;                    // Same as Firebase Auth UID
  createdAt: Timestamp;
  lastActiveAt: Timestamp;
}
```

**Security Rules**:
```javascript
match /users/{userId} {
  // Users can only read/write their own document
  allow read, write: if request.auth != null 
    && request.auth.uid == userId;
}
```

---

### `users/{userId}/discoveries`

**Path**: `/users/{userId}/discoveries/{discoveryId}`

```typescript
interface Discovery {
  id: string;                              // Auto-generated
  crystalId: string;                       // Reference to crystals/{crystalId}
  discoveredAt: Timestamp;
  discoveryLocation: GeoPoint;             // User's location when mined
  crystalLocationAtDiscovery: GeoPoint;    // Crystal's location when mined
}
```

**Security Rules**:
```javascript
match /users/{userId}/discoveries/{discoveryId} {
  // Users can only access their own discoveries
  allow read, write: if request.auth != null 
    && request.auth.uid == userId;
}
```

---

## Query Patterns

### 1. Get Crystals in Bounding Box

**Use Case**: マップビューポート内の結晶を取得

```dart
Future<List<Crystal>> getCrystalsInBounds({
  required double minLat,
  required double maxLat,
  required double minLon,
  required double maxLon,
}) async {
  // Firestore limitation: can only range query on one field
  final query = firestore
    .collection('crystals')
    .where('location.latitude', isGreaterThanOrEqualTo: minLat)
    .where('location.latitude', isLessThanOrEqualTo: maxLat)
    .where('status', isEqualTo: 'active');
  
  final snapshot = await query.get();
  
  // Client-side filter for longitude
  return snapshot.docs
    .map((doc) => Crystal.fromFirestore(doc))
    .where((c) => c.longitude >= minLon && c.longitude <= maxLon)
    .toList();
}
```

### 2. Update Crystal Status (Mining)

**Use Case**: 採掘開始時にステータスを更新

```dart
Future<bool> startMining(String crystalId, String userId) async {
  final ref = firestore.collection('crystals').doc(crystalId);
  
  return firestore.runTransaction((transaction) async {
    final snapshot = await transaction.get(ref);
    final data = snapshot.data();
    
    // Optimistic locking: only proceed if still active
    if (data?['status'] != 'active') {
      return false; // Another user already mining
    }
    
    transaction.update(ref, {
      'status': 'being_mined',
    });
    
    return true;
  });
}
```

### 3. Complete Mining and Respawn

**Use Case**: 採掘完了後、結晶をリスポーン

```dart
Future<void> completeMiningAndRespawn(
  String crystalId, 
  GeoPoint newLocation,
  String minerId,
  GeoPoint minerLocation,
) async {
  final batch = firestore.batch();
  
  // Update crystal
  final crystalRef = firestore.collection('crystals').doc(crystalId);
  batch.update(crystalRef, {
    'status': 'active',
    'location': newLocation,
    'miningCount': FieldValue.increment(1),
    'lastMinedAt': FieldValue.serverTimestamp(),
    'respawnHistory': FieldValue.arrayUnion([
      firestore.collection('crystals').doc(crystalId).get()
        .then((s) => s.data()?['location'])
    ]),
  });
  
  // Add discovery record
  final discoveryRef = firestore
    .collection('users/$minerId/discoveries')
    .doc();
  batch.set(discoveryRef, {
    'crystalId': crystalId,
    'discoveredAt': FieldValue.serverTimestamp(),
    'discoveryLocation': minerLocation,
    'crystalLocationAtDiscovery': /* current crystal location */,
  });
  
  await batch.commit();
}
```

### 4. Get User's Discoveries

**Use Case**: Journal画面用の発見記録取得

```dart
Future<List<Discovery>> getUserDiscoveries(String userId) async {
  final snapshot = await firestore
    .collection('users/$userId/discoveries')
    .orderBy('discoveredAt', descending: true)
    .get();
  
  return snapshot.docs
    .map((doc) => Discovery.fromFirestore(doc))
    .toList();
}
```

---

## Rate Limits & Quotas

| Operation | Limit | Notes |
|-----------|-------|-------|
| Reads | 50,000/day (free tier) | Geo-queryは複数ドキュメント読み取り |
| Writes | 20,000/day (free tier) | 採掘完了時に2 writes |
| Document Size | 1MB max | 結晶データは数KB程度 |

---

## Migration Notes

### Initial Data Seeding

開発/テスト用の初期結晶データをシードするスクリプト:

```dart
Future<void> seedTestCrystals() async {
  final testCrystals = [
    {
      'memoryText': 'テスト記憶: 東京タワー近くの思い出',
      'emotionType': 'joy',
      'imageUrl': 'https://example.com/test-crystal-1.png',
      'creatorId': 'test_user_1',
      'location': GeoPoint(35.6586, 139.7454),
      'createdAt': FieldValue.serverTimestamp(),
      'miningCount': 0,
      'status': 'active',
      'respawnHistory': [],
    },
    // ... more test crystals
  ];
  
  final batch = firestore.batch();
  for (final crystal in testCrystals) {
    batch.set(firestore.collection('crystals').doc(), crystal);
  }
  await batch.commit();
}
```

