# Research: Map View Implementation

**Feature**: Crystal Discovery and Proximity Detection (User Story 2)
**Date**: 2025-11-29

## 1. Mapbox Flutter SDK

### Decision
**mapbox_maps_flutter ^2.4.0** を採用

### Rationale
- Flutter公式サポートのネイティブマップSDK
- カスタムスタイル（ダークファンタジーテーマ）のサポート
- レイヤーベースのマーカー管理（結晶エリアの動的表示）
- オフラインマップキャッシュ対応
- 60fps描画パフォーマンス

### Alternatives Considered
| 選択肢 | 却下理由 |
|--------|----------|
| google_maps_flutter | カスタムスタイルの柔軟性が低い、ダークファンタジーテーマ実現困難 |
| flutter_map (OSM) | パフォーマンス、特にアニメーション描画で劣る |
| apple_maps_flutter | iOS限定、クロスプラットフォーム要件を満たさない |

### Implementation Notes
- Mapbox Access Tokenは環境変数で管理（.env）
- カスタムスタイルはMapbox Studioで作成し、Style URLで参照
- 結晶マーカーはSymbolLayerまたはCircleLayerで実装

---

## 2. Location Services

### Decision
**geolocator ^13.0.1** + **permission_handler ^11.3.1** を採用

### Rationale
- iOS/Androidの位置情報APIをラップした成熟したパッケージ
- Streamベースのリアルタイム位置更新
- 精度設定の柔軟性（高精度/バッテリー節約モード）
- バックグラウンド位置更新のサポート

### Alternatives Considered
| 選択肢 | 却下理由 |
|--------|----------|
| location | 機能的に同等だがgeolocatorのコミュニティサポートが強い |
| flutter_background_geolocation | 過剰機能、有料版必要な場合あり |

### Implementation Notes
```dart
// 推奨設定
LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 5, // 5m移動ごとに更新
);
```

---

## 3. Proximity Detection Algorithm

### Decision
**Haversine公式によるクライアントサイド距離計算** を採用

### Rationale
- 地球の曲率を考慮した正確な距離計算
- クライアントサイドで即座に計算可能（レイテンシ最小化）
- Firestoreからの結晶データは定期的にフェッチ、距離計算はローカル

### Implementation
```dart
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const earthRadius = 6371000.0; // メートル
  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
      sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}
```

### Proximity Zones
| ゾーン | 半径 | トリガー |
|--------|------|----------|
| Detection Zone | 100m | Heartbeatフェーズ開始 |
| Mining Zone | 25m | Mining画面遷移 |

---

## 4. Firestore Geo-Query

### Decision
**GeoFlutterFire2** または **手動Bounding Box Query** を採用

### Rationale
- Firestoreはネイティブのgeo-queryをサポートしていない
- GeoHash + Bounding Boxクエリで近似的なgeo-queryを実現
- 1km範囲の結晶取得に十分な精度

### Implementation Approach
```dart
// Bounding Box計算
double kmPerDegree = 111.32; // 赤道での近似値
double latDelta = 1.0 / kmPerDegree; // 1km
double lonDelta = 1.0 / (kmPerDegree * cos(centerLat * pi / 180));

Query query = firestore.collection('crystals')
  .where('location.latitude', isGreaterThan: centerLat - latDelta)
  .where('location.latitude', isLessThan: centerLat + latDelta);
// 注: Firestoreの制約により、経度の範囲クエリはクライアント側でフィルタ
```

### Alternatives Considered
| 選択肢 | 却下理由 |
|--------|----------|
| GeoFlutterFire2 | 追加依存、シンプルなユースケースには過剰 |
| Cloud Functions geo-query | レイテンシ増加、MVP段階では不要 |

---

## 5. Sensory Feedback Synchronization

### Decision
**Timer.periodic + HapticFeedback + AudioPlayer** の同期実装

### Rationale
- 視覚・触覚・聴覚の3モダリティを単一タイマーで同期
- Flutterの`HapticFeedback`クラスでクロスプラットフォーム触覚
- `audioplayers`パッケージで音声再生

### Implementation Pattern
```dart
void _startHeartbeat(double intensity) {
  final intervalMs = (1500 - (intensity * 1000)).round();
  _timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
    // 同期トリガー
    _triggerVisualPulse();
    HapticFeedback.heavyImpact();
    _audioPlayer.play(AssetSource('sounds/resonance.mp3'));
  });
}
```

### Performance Considerations
- 16ms以下のフィードバックレイテンシ目標
- アニメーションはTickerProviderで管理（60fps保証）
- 音声ファイルはプリロードしてレイテンシ最小化

---

## 6. Custom Map Style (Dark Fantasy Theme)

### Decision
**Mapbox Studio でカスタムスタイル作成**

### Rationale
- 完全なビジュアルコントロール
- 世界観（WORLD_IMMERSION原則）に合致
- ランタイムでの動的スタイル切り替え不要

### Style Guidelines
- **背景色**: 深い紫/藍色 (#0D0D1A ~ #1A1A2E)
- **道路**: 薄い青白色の線 (#4A90D9 opacity 0.3)
- **建物**: 暗い灰色シルエット
- **水域**: 深い青 (#0A1628)
- **ラベル**: 最小限、小さなフォント
- **地脈エフェクト**: カスタムレイヤーで実装（パーティクルアニメーション）

### Assets Required
- `mapbox://styles/[username]/[style-id]` 形式のStyle URL
- または `assets/map_style.json` としてバンドル

---

## 7. Battery Optimization

### Decision
**Adaptive Location Update Frequency** を採用

### Rationale
- 連続GPS追跡はバッテリー消費が大きい
- ユーザーの移動状態に応じて更新頻度を調整
- バックグラウンドでは低頻度更新

### Implementation Strategy
| 状態 | 更新間隔 | 精度 |
|------|----------|------|
| アクティブ（フォアグラウンド） | 5m移動ごと | 高精度 |
| 静止検出時 | 30秒ごと | 中精度 |
| バックグラウンド | 50m移動ごと | 低電力 |
| 低バッテリー（<20%） | 更新停止、手動更新のみ | - |

---

## 8. Error Handling Strategy

### Decision
**Graceful Degradation with User Feedback**

### Scenarios & Responses
| エラー | 対応 |
|--------|------|
| GPS権限拒否 | 権限説明ダイアログ → 設定画面誘導 |
| GPS精度不良（>50m） | 警告バナー表示、機能継続 |
| ネットワークエラー | キャッシュ済みデータ使用、リトライボタン |
| Mapbox初期化失敗 | フォールバックUI（リスト表示） |
| 結晶データ取得失敗 | 空のマップ表示、エラーメッセージ |

---

## Summary of Key Decisions

| 領域 | 選択 |
|------|------|
| マップSDK | mapbox_maps_flutter ^2.4.0 |
| 位置情報 | geolocator + permission_handler |
| 距離計算 | Haversine公式（クライアントサイド） |
| Geo-query | Bounding Box Query + クライアントフィルタ |
| フィードバック同期 | Timer.periodic統合 |
| マップスタイル | Mapbox Studioカスタムスタイル |
| バッテリー最適化 | Adaptive Update Frequency |

