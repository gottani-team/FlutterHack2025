# Data Model: Memory Burial Screen

**作成日**: 2025-11-29  
**機能**: Memory Burial Screen  
**ブランチ**: `002-memory-burial-screen`

## 概要

本ドキュメントは、Memory Burial Screen機能で使用されるデータモデルの詳細を定義します。クリーンアーキテクチャに従い、Domain層のEntity、Data層のModel、およびFirestoreのデータ構造を明確に定義します。

---

## Domain層のエンティティ

### 1. MemoryBurialEntity

**責務**: 埋葬する記憶の情報を表現するドメインエンティティ

**ファイルパス**: `packages/feature/lib/memory_burial/domain/entities/memory_burial_entity.dart`

```dart
import 'package:core/domain/entities/base_entity.dart';
import 'package:equatable/equatable.dart';
import 'geo_location.dart';

class MemoryBurialEntity extends BaseEntity {
  const MemoryBurialEntity({
    required this.id,
    required this.memoryText,
    required this.location,
    required this.buriedAt,
    this.crystalColor,
    this.emotionType,
  });

  final String id;              // クリスタルID（UUID）
  final String memoryText;      // 記憶テキスト（10～500文字）
  final GeoLocation location;   // 埋葬位置
  final DateTime buriedAt;      // 埋葬日時
  final String? crystalColor;   // クリスタルの色（サーバーから返されるが表示しない）
  final String? emotionType;    // 感情タイプ（サーバーから返されるが表示しない）

  @override
  List<Object?> get props => [
    id,
    memoryText,
    location,
    buriedAt,
    crystalColor,
    emotionType,
  ];

  MemoryBurialEntity copyWith({
    String? id,
    String? memoryText,
    GeoLocation? location,
    DateTime? buriedAt,
    String? crystalColor,
    String? emotionType,
  }) {
    return MemoryBurialEntity(
      id: id ?? this.id,
      memoryText: memoryText ?? this.memoryText,
      location: location ?? this.location,
      buriedAt: buriedAt ?? this.buriedAt,
      crystalColor: crystalColor ?? this.crystalColor,
      emotionType: emotionType ?? this.emotionType,
    );
  }
}
```

**バリデーションルール**:
- `memoryText`: 10文字以上、500文字以下
- `location`: 有効な緯度経度（-90～90、-180～180）
- `buriedAt`: 現在時刻または過去（未来は不可）
- `id`: UUID v4形式

---

### 2. GeoLocation

**責務**: 地理的位置情報を表現する値オブジェクト

**ファイルパス**: `packages/feature/lib/memory_burial/domain/entities/geo_location.dart`

```dart
import 'package:equatable/equatable.dart';

class GeoLocation extends Equatable {
  const GeoLocation({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;   // 緯度（-90.0 ～ 90.0）
  final double longitude;  // 経度（-180.0 ～ 180.0）

  /// 位置情報が有効かどうか
  bool get isValid =>
      latitude >= -90.0 &&
      latitude <= 90.0 &&
      longitude >= -180.0 &&
      longitude <= 180.0;

  @override
  List<Object?> get props => [latitude, longitude];

  @override
  String toString() => 'GeoLocation(lat: $latitude, lng: $longitude)';

  /// 2つの位置間の距離を計算（メートル単位）
  /// Haversine公式を使用
  double distanceTo(GeoLocation other) {
    const earthRadiusKm = 6371.0;

    final dLat = _toRadians(other.latitude - latitude);
    final dLon = _toRadians(other.longitude - longitude);

    final lat1 = _toRadians(latitude);
    final lat2 = _toRadians(other.latitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c * 1000; // メートルに変換
  }

  double _toRadians(double degrees) => degrees * pi / 180.0;
}
```

---

## Data層のモデル

### 1. MemoryBurialModel

**責務**: MemoryBurialEntityのJSON表現（FirestoreとFlutterアプリ間のデータ転送）

**ファイルパス**: `packages/feature/lib/memory_burial/data/models/memory_burial_model.dart`

```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/data/models/base_model.dart';
import '../../domain/entities/memory_burial_entity.dart';
import 'geo_location_model.dart';

part 'memory_burial_model.g.dart';

@JsonSerializable()
class MemoryBurialModel extends BaseModel<MemoryBurialEntity> {
  const MemoryBurialModel({
    required this.id,
    required this.memoryText,
    required this.location,
    required this.buriedAt,
    this.crystalColor,
    this.emotionType,
  });

  final String id;
  final String memoryText;
  final GeoLocationModel location;
  
  @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  final DateTime buriedAt;
  
  final String? crystalColor;
  final String? emotionType;

  factory MemoryBurialModel.fromJson(Map<String, dynamic> json) =>
      _$MemoryBurialModelFromJson(json);

  Map<String, dynamic> toJson() => _$MemoryBurialModelToJson(this);

  /// FirestoreのTimestampをDateTimeに変換
  static DateTime _timestampToDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    throw FormatException('Invalid timestamp format');
  }

  /// DateTimeをFirestoreのTimestampに変換
  static dynamic _dateTimeToTimestamp(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }

  @override
  MemoryBurialEntity toEntity() {
    return MemoryBurialEntity(
      id: id,
      memoryText: memoryText,
      location: location.toEntity(),
      buriedAt: buriedAt,
      crystalColor: crystalColor,
      emotionType: emotionType,
    );
  }

  /// EntityからModelを生成
  factory MemoryBurialModel.fromEntity(MemoryBurialEntity entity) {
    return MemoryBurialModel(
      id: entity.id,
      memoryText: entity.memoryText,
      location: GeoLocationModel.fromEntity(entity.location),
      buriedAt: entity.buriedAt,
      crystalColor: entity.crystalColor,
      emotionType: entity.emotionType,
    );
  }
}
```

**コード生成コマンド**:

```bash
cd packages/feature
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### 2. GeoLocationModel

**責務**: GeoLocationのJSON表現

**ファイルパス**: `packages/feature/lib/memory_burial/data/models/geo_location_model.dart`

```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/data/models/base_model.dart';
import '../../domain/entities/geo_location.dart';

part 'geo_location_model.g.dart';

@JsonSerializable()
class GeoLocationModel extends BaseModel<GeoLocation> {
  const GeoLocationModel({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  factory GeoLocationModel.fromJson(Map<String, dynamic> json) =>
      _$GeoLocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$GeoLocationModelToJson(this);

  /// FirestoreのGeoPointから変換
  factory GeoLocationModel.fromGeoPoint(GeoPoint geoPoint) {
    return GeoLocationModel(
      latitude: geoPoint.latitude,
      longitude: geoPoint.longitude,
    );
  }

  /// FirestoreのGeoPointに変換
  GeoPoint toGeoPoint() {
    return GeoPoint(latitude, longitude);
  }

  @override
  GeoLocation toEntity() {
    return GeoLocation(
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// EntityからModelを生成
  factory GeoLocationModel.fromEntity(GeoLocation entity) {
    return GeoLocationModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }
}
```

---

## Firestoreコレクション構造

### コレクション: `crystals`

**パス**: `/crystals/{crystalId}`

**ドキュメント構造**:

```javascript
{
  "id": "550e8400-e29b-41d4-a716-446655440000",      // UUID v4
  "memoryText": "あの日の夕焼けがとても美しかった...",  // string (10-500文字)
  "creatorUserId": "user123",                        // string (Firebase Auth UID)
  "location": GeoPoint(35.6812, 139.7671),           // GeoPoint (緯度, 経度)
  "buriedAt": Timestamp(2025-11-29T12:34:56Z),       // Timestamp
  "crystalColor": "blue",                            // string (サーバー生成)
  "emotionType": "joy",                              // string (サーバー生成)
  "isDiscovered": false,                             // boolean (初期値: false)
  "discoveredBy": [],                                // array<string> (発見したユーザーID)
  "createdAt": Timestamp(2025-11-29T12:34:56Z),      // Timestamp (サーバー側で設定)
  "updatedAt": Timestamp(2025-11-29T12:34:56Z)       // Timestamp (サーバー側で設定)
}
```

**フィールド詳細**:

| フィールド | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| `id` | string | ✅ | UUID v4形式のクリスタルID |
| `memoryText` | string | ✅ | 記憶テキスト（10～500文字） |
| `creatorUserId` | string | ✅ | 埋葬したユーザーのFirebase Auth UID |
| `location` | GeoPoint | ✅ | 埋葬位置（緯度経度） |
| `buriedAt` | Timestamp | ✅ | 埋葬日時 |
| `crystalColor` | string | ❌ | クリスタルの色（サーバー生成） |
| `emotionType` | string | ❌ | 感情タイプ（サーバー生成） |
| `isDiscovered` | boolean | ✅ | 発見済みフラグ（初期値: false） |
| `discoveredBy` | array | ✅ | 発見したユーザーのUID配列 |
| `createdAt` | Timestamp | ✅ | ドキュメント作成日時 |
| `updatedAt` | Timestamp | ✅ | ドキュメント更新日時 |

**インデックス設定**:

```javascript
// Firestore Indexesコンソールで設定
{
  collectionGroup: "crystals",
  queryScope: "COLLECTION",
  fields: [
    { fieldPath: "creatorUserId", order: "ASCENDING" },
    { fieldPath: "buriedAt", order: "DESCENDING" }
  ]
}

// GeoFireクエリ用（将来の近隣検索機能）
{
  collectionGroup: "crystals",
  queryScope: "COLLECTION",
  fields: [
    { fieldPath: "location", order: "ASCENDING" },
    { fieldPath: "isDiscovered", order: "ASCENDING" }
  ]
}
```

---

## Firestore Security Rules

**ファイルパス**: `firestore.rules`

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function: ユーザー認証チェック
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function: 自分のドキュメントか
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Crystals Collection
    match /crystals/{crystalId} {
      
      // 読み取り: 認証済みユーザーのみ
      allow read: if isAuthenticated();
      
      // 作成: 認証済みで、自分のUIDが正しく設定され、バリデーション通過
      allow create: if isAuthenticated()
                    && request.resource.data.creatorUserId == request.auth.uid
                    && request.resource.data.memoryText is string
                    && request.resource.data.memoryText.size() >= 10
                    && request.resource.data.memoryText.size() <= 500
                    && request.resource.data.location is latlng
                    && request.resource.data.buriedAt is timestamp
                    && request.resource.data.isDiscovered == false;
      
      // 更新: 自分が作成したドキュメントのみ、特定フィールドのみ更新可能
      allow update: if isAuthenticated()
                    && resource.data.creatorUserId == request.auth.uid
                    && request.resource.data.memoryText == resource.data.memoryText  // 変更不可
                    && request.resource.data.creatorUserId == resource.data.creatorUserId; // 変更不可
      
      // 削除: 禁止（埋葬後は削除不可）
      allow delete: if false;
    }
  }
}
```

---

## API Request/Response形式

### リクエスト形式（Flutter → Cloud Functions）

**エンドポイント**: `buryMemory`（Cloud Functions HTTPSコール可能関数）

```typescript
// リクエスト
{
  memoryText: string;      // 10～500文字
  location: {
    latitude: number;      // -90.0 ～ 90.0
    longitude: number;     // -180.0 ～ 180.0
  };
}

// レスポンス（成功時）
{
  success: true;
  crystalId: string;       // UUID v4
  crystalColor: string;    // 例: "blue", "red", "green"
  emotionType: string;     // 例: "joy", "sadness", "passion"
  buriedAt: string;        // ISO 8601形式
}

// レスポンス（エラー時）
{
  success: false;
  error: {
    code: string;          // 例: "invalid-argument", "internal"
    message: string;       // エラーメッセージ
  }
}
```

---

## データフロー図

```
┌─────────────────────┐
│  ユーザー入力       │
│  (テキスト + 位置)  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Presentation層     │
│  - MemoryBurialPage │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Domain層           │
│  - BuryMemoryUseCase│
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Data層             │
│  - MemoryRepository │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Cloud Functions    │
│  - buryMemory       │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Firestore          │
│  - crystalsコレクション│
└─────────────────────┘
```

---

## バリデーションルール

### Domain層でのバリデーション

```dart
class MemoryBurialValidator {
  static const int minTextLength = 10;
  static const int maxTextLength = 500;

  /// 記憶テキストをバリデーション
  static ValidationResult validateMemoryText(String text) {
    if (text.isEmpty) {
      return ValidationResult.error('記憶テキストを入力してください');
    }
    
    if (text.length < minTextLength) {
      return ValidationResult.error(
        '記憶テキストは${minTextLength}文字以上必要です（現在: ${text.length}文字）'
      );
    }
    
    if (text.length > maxTextLength) {
      return ValidationResult.error(
        '記憶テキストは${maxTextLength}文字以下にしてください（現在: ${text.length}文字）'
      );
    }
    
    return ValidationResult.success();
  }

  /// 位置情報をバリデーション
  static ValidationResult validateLocation(GeoLocation location) {
    if (!location.isValid) {
      return ValidationResult.error('無効な位置情報です');
    }
    
    return ValidationResult.success();
  }
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult.success()
      : isValid = true,
        errorMessage = null;

  const ValidationResult.error(this.errorMessage) : isValid = false;
}
```

---

## エラークラス定義

**ファイルパス**: `packages/feature/lib/memory_burial/domain/errors/memory_burial_exceptions.dart`

```dart
import 'package:core/domain/errors/app_exception.dart';

/// 記憶テキストが無効
class InvalidMemoryTextException extends AppException {
  InvalidMemoryTextException(String message)
      : super(message: message, code: 'invalid-memory-text');
}

/// 位置情報が無効
class InvalidLocationException extends AppException {
  InvalidLocationException()
      : super(
          message: '位置情報が取得できませんでした',
          code: 'invalid-location',
        );
}

/// 重複埋葬エラー
class DuplicateMemoryException extends AppException {
  DuplicateMemoryException()
      : super(
          message: 'この記憶は既に埋葬されています',
          code: 'duplicate-memory',
        );
}

/// ネットワークエラー
class NetworkException extends AppException {
  NetworkException()
      : super(
          message: 'ネットワークに接続できませんでした',
          code: 'network-error',
        );
}

/// サーバーエラー
class ServerException extends AppException {
  ServerException([String? message])
      : super(
          message: message ?? 'サーバーエラーが発生しました',
          code: 'server-error',
        );
}

/// タイムアウトエラー
class TimeoutException extends AppException {
  TimeoutException()
      : super(
          message: 'リクエストがタイムアウトしました',
          code: 'timeout',
        );
}
```

---

## Model ↔ Entity 変換例

### FirestoreからEntityへの変換フロー

```dart
// 1. FirestoreからドキュメントデータをMap形式で取得
final docSnapshot = await firestore.collection('crystals').doc(crystalId).get();
final data = docSnapshot.data() as Map<String, dynamic>;

// 2. Modelにデシリアライズ
final model = MemoryBurialModel.fromJson(data);

// 3. Entityに変換
final entity = model.toEntity();

// 使用例
print('Memory: ${entity.memoryText}');
print('Location: ${entity.location}');
```

### EntityからFirestoreへの変換フロー

```dart
// 1. Domain層でEntityを作成
final entity = MemoryBurialEntity(
  id: Uuid().v4(),
  memoryText: userInput,
  location: currentLocation,
  buriedAt: DateTime.now(),
);

// 2. ModelにEntity変換
final model = MemoryBurialModel.fromEntity(entity);

// 3. JSONにシリアライズ
final json = model.toJson();

// 4. Firestoreに保存
await firestore.collection('crystals').doc(entity.id).set(json);
```

---

## まとめ

このデータモデル設計により、以下が達成されます：

1. ✅ クリーンアーキテクチャに準拠（Entity/Model分離）
2. ✅ Firestoreとの統合が明確
3. ✅ バリデーションルールが定義済み
4. ✅ エラーハンドリングが体系化
5. ✅ セキュリティルールが実装済み

次のステップでは、このデータモデルを使用したRepository InterfaceとCloud Functions APIの詳細を定義します。

