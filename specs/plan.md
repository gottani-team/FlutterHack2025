# Implementation Plan: Chimyaku Map View - Crystal Discovery & Proximity Detection

**Branch**: `001-chimyaku-app` | **Date**: 2025-11-29 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/spec.md` - User Story 2

## Summary

User Story 2「Crystal Discovery and Proximity Detection」のマップビュー画面をMapboxを使用して実装する。ユーザーがマップ上で結晶化エリアを発見し、接近時に視覚・触覚・聴覚のフィードバックを体験できる機能を構築する。

**技術アプローチ**:
- Mapbox Flutter SDKによるダークファンタジースタイルのマップ表示
- Geolocatorによるリアルタイム位置追跡
- Riverpod + Freezedによる状態管理
- Firestoreによる結晶データのGeo-query

## Technical Context

**Language/Version**: Dart SDK >=3.5.0 <4.0.0 / Flutter 3.38.1
**Primary Dependencies**:
- mapbox_maps_flutter: ^2.4.0 (地図表示)
- geolocator: ^13.0.1 (位置情報サービス)
- permission_handler: ^11.3.1 (権限管理)
- flutter_riverpod: ^3.0.3 (状態管理)
- freezed: ^3.2.3 (イミュータブル状態)
- (Firestoreはスコープアウト - モックデータで実装)

**Storage**: Mock Data (Firestoreとの繋ぎ込みはスコープアウト)
**Testing**: flutter_test + integration_test
**Target Platform**: iOS 15+ / Android 8.0+
**Project Type**: Mobile (Flutter monorepo with feature packages)
**Performance Goals**: 60fps維持、近接検出レイテンシ2秒以内、16ms以下のフィードバック応答
**Constraints**: バッテリー消費最小化、オフラインでのマップタイル閲覧対応
**Scale/Scope**: MVP段階で1000同時ユーザー対応、1km範囲内の結晶表示

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| 原則 | 要件 | 準拠状態 |
|------|------|----------|
| **I. WORLD_IMMERSION** | ダークファンタジー美学、世界観用語使用 | ✅ カスタムMapboxスタイル、「結晶化エリア」「地脈」用語使用 |
| **II. SENSORY_EXPERIENCE** | 視覚+触覚+聴覚の同期フィードバック | ✅ HeartbeatOverlay + HapticFeedback + Audio同期実装予定 |
| **III. AI_UNIQUENESS** | N/A (本ストーリーはAI生成を含まない) | ✅ 該当なし |
| **IV. ARCHITECTURE** | クリーンアーキテクチャ、層分離 | ✅ domain/data/presentation分離済み |
| **V. MVP_PRIORITY** | P1機能優先 | ✅ User Story 2はP1コアループの一部 |
| **VI. JAPANESE_FIRST** | 日本語コミュニケーション | ✅ ドキュメント・コメント日本語 |

**Gate Status**: ✅ PASSED - 全原則に準拠

## Project Structure

### Documentation (this feature)

```text
specs/001-chimyaku-app/
├── spec.md              # 機能仕様書
├── plan.md              # このファイル
├── research.md          # Phase 0: 技術リサーチ
├── data-model.md        # Phase 1: データモデル定義
├── quickstart.md        # Phase 1: クイックスタートガイド
├── contracts/           # Phase 1: APIコントラクト
│   └── firestore-schema.md
└── checklists/
    ├── requirements.md
    └── map-view-implementation.md
```

### Source Code (repository root)

```text
packages/feature/lib/map/
├── domain/
│   ├── entities/
│   │   ├── crystal_entity.dart           # 結晶エンティティ
│   │   ├── crystallization_area_entity.dart  # マップ表示用エリア
│   │   └── user_location_entity.dart     # ユーザー位置情報
│   ├── repositories/
│   │   └── map_repository.dart           # リポジトリインターフェース
│   └── use_cases/
│       ├── watch_user_location_use_case.dart
│       ├── get_nearby_crystals_use_case.dart
│       └── check_crystal_proximity_use_case.dart
├── data/
│   ├── data_sources/
│   │   ├── location_data_source.dart     # GPS/Geolocator実装
│   │   └── crystal_mock_data_source.dart # モックデータ（Firestoreはスコープ外）
│   └── repositories/
│       └── map_repository_impl.dart      # モック実装
└── presentation/
    ├── state/
    │   ├── map_view_state.dart           # ViewState (freezed)
    │   └── map_view_state.freezed.dart
    ├── view_model/
    │   ├── map_view_model.dart           # ViewModel (riverpod)
    │   └── map_view_model.g.dart
    ├── providers/
    │   └── map_providers.dart            # 派生Provider
    ├── pages/
    │   └── map_page.dart                 # メインマップ画面
    └── widgets/
        ├── heartbeat_overlay.dart        # 接近時パルスエフェクト
        ├── crystal_marker.dart           # 結晶マーカー
        ├── gps_warning_banner.dart       # GPS精度警告
        └── permission_dialog.dart        # 権限リクエストUI

packages/core/lib/
├── domain/
│   └── services/
│       └── haptic_service.dart           # 触覚フィードバックサービス
└── presentation/
    └── utils/
        └── audio_player.dart             # 音声再生ユーティリティ
```

**Structure Decision**: Flutter monorepo構造を採用。`packages/feature/lib/map/` に機能を集約し、クリーンアーキテクチャに準拠。共通サービス（Haptic/Audio）は `packages/core` に配置。

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| なし | - | - |

現時点で憲章違反はなし。
