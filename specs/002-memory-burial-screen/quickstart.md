# Quickstart: Memory Burial Screen実装ガイド

**作成日**: 2025-11-29  
**機能**: Memory Burial Screen  
**ブランチ**: `002-memory-burial-screen`  
**推定実装時間**: 2～3日

## 概要

このガイドは、Memory Burial Screen機能を段階的に実装するための実践的な手順を提供します。クリーンアーキテクチャに従い、Domain → Data → Presentation → Cloud Functionsの順で実装します。

---

## 前提条件

### 環境確認

- ✅ Flutter 3.38.1以上
- ✅ Dart 3.5.0以上
- ✅ Firebase プロジェクト設定完了
- ✅ Firebase CLI インストール済み
- ✅ iOS/Androidエミュレーターまたは実機

### 必要な依存パッケージ

`packages/feature/pubspec.yaml`で以下を確認：

```yaml
dependencies:
  # State Management
  flutter_riverpod: ^3.0.3
  
  # Firebase（既存）
  cloud_functions: ^6.0.1
  cloud_firestore: ^6.1.0
  
  # Utilities
  equatable: ^2.0.5
  
  # Core package
  core:
    path: ../core
```

**追加パッケージ不要**: 既存の依存関係で全機能を実装可能

---

## 実装フェーズ

### フェーズ1: Domain層実装（推定0.5日）

#### 1.1 エンティティ作成

##### 1.1.1 GeoLocation

**ファイル**: `packages/feature/lib/memory_burial/domain/entities/geo_location.dart`

```dart
import 'package:equatable/equatable.dart';
import 'dart:math';

class GeoLocation extends Equatable {
  const GeoLocation({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  bool get isValid =>
      latitude >= -90.0 &&
      latitude <= 90.0 &&
      longitude >= -180.0 &&
      longitude <= 180.0;

  @override
  List<Object?> get props => [latitude, longitude];

  @override
  String toString() => 'GeoLocation(lat: $latitude, lng: $longitude)';

  double distanceTo(GeoLocation other) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(other.latitude - latitude);
    final dLon = _toRadians(other.longitude - longitude);
    final lat1 = _toRadians(latitude);
    final lat2 = _toRadians(other.latitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c * 1000;
  }

  double _toRadians(double degrees) => degrees * pi / 180.0;
}
```

##### 1.1.2 MemoryBurialEntity

**ファイル**: `packages/feature/lib/memory_burial/domain/entities/memory_burial_entity.dart`

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

  final String id;
  final String memoryText;
  final GeoLocation location;
  final DateTime buriedAt;
  final String? crystalColor;
  final String? emotionType;

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

#### 1.2 例外クラス作成

**ファイル**: `packages/feature/lib/memory_burial/domain/errors/memory_burial_exceptions.dart`

```dart
import 'package:core/domain/errors/app_exception.dart';

class InvalidMemoryTextException extends AppException {
  InvalidMemoryTextException(String message)
      : super(message: message, code: 'invalid-memory-text');
}

class InvalidLocationException extends AppException {
  InvalidLocationException()
      : super(
          message: '位置情報が取得できませんでした',
          code: 'invalid-location',
        );
}

class NetworkException extends AppException {
  NetworkException()
      : super(
          message: 'ネットワークに接続できませんでした',
          code: 'network-error',
        );
}

class ServerException extends AppException {
  ServerException([String? message])
      : super(
          message: message ?? 'サーバーエラーが発生しました',
          code: 'server-error',
        );
}

class TimeoutException extends AppException {
  TimeoutException()
      : super(
          message: 'リクエストがタイムアウトしました',
          code: 'timeout',
        );
}

class RateLimitException extends AppException {
  RateLimitException(String message)
      : super(message: message, code: 'rate-limit');
}

class UnauthorizedException extends AppException {
  UnauthorizedException(String message)
      : super(message: message, code: 'unauthorized');
}

class NotFoundException extends AppException {
  NotFoundException(String message)
      : super(message: message, code: 'not-found');
}
```

#### 1.3 Repositoryインターフェース作成

**ファイル**: `packages/feature/lib/memory_burial/domain/repositories/memory_burial_repository.dart`

詳細は `contracts/repository_interfaces.md` 参照

#### 1.4 UseCase作成

##### 1.4.1 BuryMemoryUseCase

**ファイル**: `packages/feature/lib/memory_burial/domain/use_cases/bury_memory_use_case.dart`

```dart
import 'package:core/domain/use_cases/base_use_case.dart';
import 'package:core/domain/repositories/location_repository.dart';
import '../entities/memory_burial_entity.dart';
import '../repositories/memory_burial_repository.dart';

class BuryMemoryUseCase implements UseCase<MemoryBurialEntity, BuryMemoryParams> {
  BuryMemoryUseCase({
    required MemoryBurialRepository memoryBurialRepository,
    required LocationRepository locationRepository,
  })  : _memoryBurialRepository = memoryBurialRepository,
        _locationRepository = locationRepository;

  final MemoryBurialRepository _memoryBurialRepository;
  final LocationRepository _locationRepository;

  @override
  Future<MemoryBurialEntity> call(BuryMemoryParams params) async {
    final location = await _locationRepository.getCurrentLocation();
    final result = await _memoryBurialRepository.buryMemory(
      memoryText: params.memoryText,
      location: location,
    );
    return result;
  }
}

class BuryMemoryParams {
  BuryMemoryParams({required this.memoryText});
  final String memoryText;
}
```

##### 1.4.2 GetBurialHistoryUseCase

**ファイル**: `packages/feature/lib/memory_burial/domain/use_cases/get_burial_history_use_case.dart`

```dart
import 'package:core/domain/use_cases/base_use_case.dart';
import '../entities/memory_burial_entity.dart';
import '../repositories/memory_burial_repository.dart';

class GetBurialHistoryUseCase implements UseCase<List<MemoryBurialEntity>, String> {
  GetBurialHistoryUseCase(this._repository);
  final MemoryBurialRepository _repository;

  @override
  Future<List<MemoryBurialEntity>> call(String userId) async {
    return await _repository.getBurialHistory(userId: userId, limit: 20);
  }
}
```

---

### フェーズ2: Data層実装（推定0.5日）

#### 2.1 モデル作成

##### 2.1.1 GeoLocationModel

**ファイル**: `packages/feature/lib/memory_burial/data/models/geo_location_model.dart`

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

  factory GeoLocationModel.fromGeoPoint(GeoPoint geoPoint) {
    return GeoLocationModel(
      latitude: geoPoint.latitude,
      longitude: geoPoint.longitude,
    );
  }

  GeoPoint toGeoPoint() => GeoPoint(latitude, longitude);

  @override
  GeoLocation toEntity() => GeoLocation(latitude: latitude, longitude: longitude);

  factory GeoLocationModel.fromEntity(GeoLocation entity) {
    return GeoLocationModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }
}
```

##### 2.1.2 MemoryBurialModel

**ファイル**: `packages/feature/lib/memory_burial/data/models/memory_burial_model.dart`

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

  static DateTime _timestampToDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    throw FormatException('Invalid timestamp format');
  }

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

#### 2.2 コード生成実行

```bash
cd packages/feature
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 2.3 データソース作成

**ファイル**: `packages/feature/lib/memory_burial/data/data_sources/memory_burial_remote_data_source.dart`

詳細は `contracts/repository_interfaces.md` 参照

#### 2.4 Repository実装作成

**ファイル**: `packages/feature/lib/memory_burial/data/repositories/memory_burial_repository_impl.dart`

詳細は `contracts/repository_interfaces.md` 参照

---

### フェーズ3: Presentation層実装（推定1日）

#### 3.1 Providerの作成

**ファイル**: `packages/feature/lib/memory_burial/presentation/providers/memory_burial_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/domain/repositories/location_repository.dart';
import '../../domain/repositories/memory_burial_repository.dart';
import '../../domain/use_cases/bury_memory_use_case.dart';
import '../../domain/use_cases/get_burial_history_use_case.dart';
import '../../data/data_sources/memory_burial_remote_data_source.dart';
import '../../data/repositories/memory_burial_repository_impl.dart';

// Firebase インスタンス
final firebaseFunctionsProvider = Provider<FirebaseFunctions>((ref) {
  return FirebaseFunctions.instanceFor(region: 'asia-northeast1');
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Data Sources
final memoryBurialRemoteDataSourceProvider =
    Provider<MemoryBurialRemoteDataSource>((ref) {
  final functions = ref.watch(firebaseFunctionsProvider);
  final firestore = ref.watch(firestoreProvider);
  return MemoryBurialRemoteDataSourceImpl(
    functions: functions,
    firestore: firestore,
  );
});

// Repositories
final memoryBurialRepositoryProvider = Provider<MemoryBurialRepository>((ref) {
  final remoteDataSource = ref.watch(memoryBurialRemoteDataSourceProvider);
  return MemoryBurialRepositoryImpl(remoteDataSource);
});

// TODO: LocationRepositoryはCoreパッケージで実装
// final locationRepositoryProvider = Provider<LocationRepository>((ref) {
//   return LocationRepositoryImpl();
// });

// Use Cases
final buryMemoryUseCaseProvider = Provider<BuryMemoryUseCase>((ref) {
  final memoryBurialRepository = ref.watch(memoryBurialRepositoryProvider);
  final locationRepository = ref.watch(locationRepositoryProvider); // Core package
  return BuryMemoryUseCase(
    memoryBurialRepository: memoryBurialRepository,
    locationRepository: locationRepository,
  );
});

final getBurialHistoryUseCaseProvider = Provider<GetBurialHistoryUseCase>((ref) {
  final repository = ref.watch(memoryBurialRepositoryProvider);
  return GetBurialHistoryUseCase(repository);
});

// State Providers
final memoryTextProvider = StateProvider<String>((ref) => '');

final isButtonEnabledProvider = Provider<bool>((ref) {
  final text = ref.watch(memoryTextProvider);
  return text.length >= 10 && text.length <= 500;
});
```

#### 3.2 ページ作成

**ファイル**: `packages/feature/lib/memory_burial/presentation/pages/memory_burial_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../providers/memory_burial_providers.dart';
import '../widgets/text_dissolution_animation.dart';
import '../../domain/use_cases/bury_memory_use_case.dart';

class MemoryBurialPage extends ConsumerStatefulWidget {
  const MemoryBurialPage({super.key});

  @override
  ConsumerState<MemoryBurialPage> createState() => _MemoryBurialPageState();
}

class _MemoryBurialPageState extends ConsumerState<MemoryBurialPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isBurying = false;
  bool _showSuccessMessage = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleBuryAction() async {
    if (_isBurying) return;

    setState(() => _isBurying = true);

    try {
      final memoryText = ref.read(memoryTextProvider);

      // アニメーションとAPI呼び出しを並列実行
      await Future.wait([
        _animationController.forward().orCancel,
        _buryMemoryApiCall(memoryText),
      ]);

      // 成功メッセージ表示
      setState(() => _showSuccessMessage = true);

      // 2秒後にマップ画面に遷移
      await Future.delayed(Duration(seconds: 2));

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/map');
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isBurying = false;
        _animationController.reset();
      });
    }
  }

  Future<void> _buryMemoryApiCall(String memoryText) async {
    final useCase = ref.read(buryMemoryUseCaseProvider);
    await useCase.call(BuryMemoryParams(memoryText: memoryText));
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('エラー'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('閉じる'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleBuryAction(); // リトライ
            },
            child: Text('再試行'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final memoryText = ref.watch(memoryTextProvider);
    final isButtonEnabled = ref.watch(isButtonEnabledProvider);

    if (_showSuccessMessage) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 80, color: Colors.green),
              SizedBox(height: 16),
              Text(
                '記憶を埋葬しました',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('記憶の埋葬'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // テキスト入力エリア
                TextField(
                  maxLength: 500,
                  maxLines: 10,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(500),
                  ],
                  decoration: InputDecoration(
                    hintText: '記憶を入力してください（10～500文字）',
                    border: OutlineInputBorder(),
                    counterText: '${memoryText.length}/500',
                    errorText: memoryText.isNotEmpty && memoryText.length < 10
                        ? '最低10文字必要です'
                        : null,
                  ),
                  onChanged: (value) {
                    ref.read(memoryTextProvider.notifier).state = value;
                  },
                ),

                Spacer(),

                // 埋めるボタン
                SizedBox(
                  height: 100,
                  width: 100,
                  child: ElevatedButton(
                    onPressed: isButtonEnabled && !_isBurying
                        ? _handleBuryAction
                        : null,
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(24),
                    ),
                    child: _isBurying
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('埋める', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),

          // アニメーションオーバーレイ
          if (_isBurying)
            TextDissolutionAnimation(
              text: memoryText,
              controller: _animationController,
            ),
        ],
      ),
    );
  }
}
```

#### 3.3 アニメーションウィジェット作成

**ファイル**: `packages/feature/lib/memory_burial/presentation/widgets/text_dissolution_animation.dart`

```dart
import 'package:flutter/material.dart';

class TextDissolutionAnimation extends StatelessWidget {
  const TextDissolutionAnimation({
    super.key,
    required this.text,
    required this.controller,
  });

  final String text;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Stack(
          children: text.split('').asMap().entries.map((entry) {
            final index = entry.key;
            final char = entry.value;
            final progress = (controller.value - (index / text.length)).clamp(0.0, 1.0);

            return Positioned(
              left: MediaQuery.of(context).size.width / 2 +
                  (index - text.length / 2) * 20 * (1 - progress),
              top: MediaQuery.of(context).size.height / 2 -
                  100 * progress,
              child: Opacity(
                opacity: 1 - progress,
                child: Text(
                  char,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
```

#### 3.4 ルーティング追加

**ファイル**: `app/lib/core/presentation/router/app_router.dart`

```dart
GoRoute(
  path: '/memory-burial',
  name: 'memory-burial',
  builder: (context, state) => const MemoryBurialPage(),
),
```

---

### フェーズ4: Cloud Functions実装（推定0.5日）

#### 4.1 関数実装

**ファイル**: `functions/src/index.ts`

詳細は `contracts/cloud_functions_api.md` 参照

#### 4.2 デプロイ

```bash
cd functions
npm install
npm run build
firebase deploy --only functions:buryMemory
```

---

### フェーズ5: Core Package実装（LocationRepository）

#### 5.1 LocationRepository実装（MVP版）

**ファイル**: `packages/core/lib/data/repositories/location_repository_impl.dart`

```dart
import 'package:core/domain/repositories/location_repository.dart';
import 'package:core/domain/entities/geo_location.dart';

/// MVP版: モック位置情報を返すLocationRepository実装
class LocationRepositoryImpl implements LocationRepository {
  @override
  Future<GeoLocation> getCurrentLocation() async {
    // MVP版: 東京駅の座標を返す
    await Future.delayed(Duration(seconds: 1)); // 実際のGPS取得をシミュレート
    return GeoLocation(latitude: 35.6812, longitude: 139.7671);
  }

  @override
  Future<bool> requestPermission() async {
    return true;
  }

  @override
  Future<bool> isPermissionGranted() async {
    return true;
  }

  @override
  Future<bool> isServiceEnabled() async {
    return true;
  }
}
```

#### 5.2 Providerの追加

**ファイル**: `packages/core/lib/presentation/providers/location_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/location_repository.dart';
import '../../data/repositories/location_repository_impl.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl();
});
```

---

## チェックリスト

### Domain層

- [ ] `GeoLocation` エンティティ作成
- [ ] `MemoryBurialEntity` エンティティ作成
- [ ] `MemoryBurialRepository` インターフェース作成
- [ ] `BuryMemoryUseCase` 作成
- [ ] `GetBurialHistoryUseCase` 作成
- [ ] 例外クラス作成

### Data層

- [ ] `GeoLocationModel` 作成
- [ ] `MemoryBurialModel` 作成
- [ ] コード生成実行
- [ ] `MemoryBurialRemoteDataSource` 作成
- [ ] `MemoryBurialRepositoryImpl` 作成

### Presentation層

- [ ] Provider設定
- [ ] `MemoryBurialPage` 作成
- [ ] `TextDissolutionAnimation` ウィジェット作成
- [ ] ルーティング追加

### Cloud Functions

- [ ] `buryMemory` 関数実装
- [ ] バリデーション実装
- [ ] デプロイ

### Core Package

- [ ] `LocationRepositoryImpl` 実装（MVP版）
- [ ] `LocationRepository` Provider追加

### その他

- [ ] Firestore Security Rules設定
- [ ] テスト作成（オプション）

---

## トラブルシューティング

### よくある問題

#### 1. Cloud Functionsがタイムアウトする

```bash
# タイムアウト設定を延長
functions
  .runWith({ timeoutSeconds: 60 })
  .https.onCall(...)
```

#### 2. コード生成エラー

```bash
# キャッシュクリア
flutter clean
cd packages/feature
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 3. Firestoreへの書き込みが失敗

- Security Rulesを確認
- 認証トークンが正しく送信されているか確認
- Firebase Consoleでログを確認

---

## 次のステップ

実装完了後、以下を確認：

1. ✅ すべての機能要件（FR-001～FR-026）が満たされているか
2. ✅ 成功基準（SC-001～SC-007）が達成されているか
3. ✅ エッジケースが適切に処理されているか

---

## 参考資料

- [仕様書](./spec.md)
- [リサーチドキュメント](./research.md)
- [データモデル](./data-model.md)
- [Cloud Functions API](./contracts/cloud_functions_api.md)
- [リポジトリインターフェース](./contracts/repository_interfaces.md)

---

**実装を開始する準備ができました！** 🚀

