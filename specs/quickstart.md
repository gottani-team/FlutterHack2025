# Quickstart: Map View Implementation

**Feature**: Crystal Discovery and Proximity Detection
**Date**: 2025-11-29

## Scope Note

> **重要**: Firestoreとの繋ぎ込みは今回スコープ外です。モックデータで実装を進めます。
> Feature層のエンティティは永続化層とは独立しています。

## Prerequisites

- Flutter 3.38.1 (mise管理)
- Mapbox アカウント & Access Token

---

## Step 1: Add Dependencies

`packages/feature/pubspec.yaml` に以下を追加:

```yaml
dependencies:
  # Map
  mapbox_maps_flutter: ^2.4.0
  
  # Location
  geolocator: ^13.0.1
  permission_handler: ^11.3.1
  
  # Audio (for resonance sound)
  audioplayers: ^6.1.0
```

```bash
cd packages/feature
flutter pub get
```

---

## Step 2: Platform Configuration

### iOS (`app/ios/Runner/Info.plist`)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>地脈の結晶を探索するために位置情報を使用します</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>バックグラウンドでも結晶の接近を検知するために位置情報を使用します</string>
<key>MBXAccessToken</key>
<string>YOUR_MAPBOX_ACCESS_TOKEN</string>
```

### Android (`app/android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

<!-- Inside <application> tag -->
<meta-data
    android:name="MAPBOX_ACCESS_TOKEN"
    android:value="YOUR_MAPBOX_ACCESS_TOKEN" />
```

---

## Step 3: Environment Setup

`.env` ファイルをプロジェクトルートに作成（.gitignore済み）:

```env
MAPBOX_ACCESS_TOKEN=pk.your_mapbox_token_here
```

---

## Step 4: Run Code Generation

```bash
cd packages/feature
flutter pub run build_runner build --delete-conflicting-outputs
```

生成されるファイル:
- `map_view_state.freezed.dart`
- `map_view_model.g.dart`

---

## Step 5: Basic Map Page Structure

`packages/feature/lib/map/presentation/pages/map_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../providers/map_providers.dart';
import '../widgets/heartbeat_overlay.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  MapboxMap? _mapboxMap;

  @override
  void initState() {
    super.initState();
    // 位置情報権限をリクエスト
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapViewModelProvider.notifier).requestLocationPermission();
    });
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    // 初期設定
    _setupMapStyle();
    _setupUserLocationLayer();
  }

  Future<void> _setupMapStyle() async {
    // ダークファンタジースタイルを適用
    // TODO: カスタムスタイルURLを設定
  }

  Future<void> _setupUserLocationLayer() async {
    // ユーザー位置マーカーを設定
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapViewModelProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Mapbox Map
          MapWidget(
            onMapCreated: _onMapCreated,
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: Position(
                  mapState.mapCenterLongitude ?? 139.7671,
                  mapState.mapCenterLatitude ?? 35.6812,
                ),
              ),
              zoom: mapState.mapZoomLevel,
            ),
          ),

          // Heartbeat Overlay (接近時のパルスエフェクト)
          if (mapState.hasCrystalInRange)
            HeartbeatOverlay(
              color: Color(mapState.approachingCrystalColor ?? 0xFFFFFFFF),
              intensity: mapState.pulseIntensity,
            ),

          // GPS Warning Banner
          if (mapState.shouldShowGpsWarning)
            const Positioned(
              top: 50,
              left: 16,
              right: 16,
              child: GpsWarningBanner(),
            ),

          // Loading Indicator
          if (mapState.isLoading)
            const Center(child: CircularProgressIndicator()),

          // Error Message
          if (mapState.errorMessage != null)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: ErrorBanner(message: mapState.errorMessage!),
            ),

          // Recenter Button
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                ref.read(mapViewModelProvider.notifier).recenterOnUser();
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Step 6: Register Route

`app/lib/core/presentation/router/app_router.dart`:

```dart
import 'package:feature/map/presentation/pages/map_page.dart';

// routes内に追加
'/map': (context) => const MapPage(),
```

---

## Step 7: Test Basic Functionality

```bash
cd app
flutter run
```

**確認項目**:
1. [ ] アプリ起動時に位置情報権限ダイアログが表示される
2. [ ] 権限許可後、マップが表示される
3. [ ] 現在地がマップ中央に表示される
4. [ ] ピンチズーム・パンが動作する

---

## Next Steps

1. **Mapboxカスタムスタイル作成** - Mapbox Studioでダークファンタジーテーマ
2. **結晶マーカー実装** - パルスするCircleLayerの追加
3. **近接検出実装** - Haversine計算とフィードバックトリガー
4. **HeartbeatOverlay実装** - 画面端のパルスアニメーション
5. **Mining画面遷移** - 25m以内での自動遷移

---

## Troubleshooting

### Mapboxが表示されない
- Access Tokenが正しく設定されているか確認
- Podfile/build.gradleでプラットフォーム最小バージョンを確認

### 位置情報が取得できない
- 実機でテスト（シミュレータではGPSが不安定）
- 権限設定を確認

### build_runnerエラー
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

