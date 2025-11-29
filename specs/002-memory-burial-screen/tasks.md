# Tasks: Memory Burial Screen実装

**作成日**: 2025-11-29  
**機能**: Memory Burial Screen  
**ブランチ**: `002-memory-burial-screen`  
**推定実装時間**: 2～3日

## 概要

このタスクリストは、Memory Burial Screen機能の段階的な実装手順を定義します。

---

## フェーズ1: Domain層実装

### エンティティ作成

- [x] **T-001** `geo_location.dart` - GeoLocationエンティティ作成 ✅
  - ファイル: `packages/feature/lib/memory_burial/domain/entities/geo_location.dart`
  - 緯度・経度、isValid、distanceTo実装

- [x] **T-002** `memory_burial_entity.dart` - MemoryBurialEntityエンティティ作成 ✅
  - ファイル: `packages/feature/lib/memory_burial/domain/entities/memory_burial_entity.dart`
  - id, memoryText, location, buriedAt, crystalColor, emotionType

### 例外クラス作成

- [x] **T-003** `memory_burial_exceptions.dart` - 例外クラス作成 ✅
  - ファイル: `packages/feature/lib/memory_burial/domain/errors/memory_burial_exceptions.dart`
  - InvalidMemoryTextException, InvalidLocationException, TimeoutException, RateLimitException等

### Repositoryインターフェース作成

- [x] **T-004** `memory_burial_repository.dart` - Repositoryインターフェース作成 ✅
  - ファイル: `packages/feature/lib/memory_burial/domain/repositories/memory_burial_repository.dart`
  - buryMemory, getBurialHistory, getCrystal

### UseCase作成

- [x] **T-005** `bury_memory_use_case.dart` - BuryMemoryUseCase作成 ✅
  - ファイル: `packages/feature/lib/memory_burial/domain/use_cases/bury_memory_use_case.dart`
  - LocationRepository + MemoryBurialRepository統合

- [x] **T-006** `get_burial_history_use_case.dart` - GetBurialHistoryUseCase作成 ✅
  - ファイル: `packages/feature/lib/memory_burial/domain/use_cases/get_burial_history_use_case.dart`

---

## フェーズ2: Data層実装

### モデル作成

- [x] **T-007** `geo_location_model.dart` - GeoLocationModel作成 ✅
  - ファイル: `packages/feature/lib/memory_burial/data/models/geo_location_model.dart`
  - JSON変換、GeoPoint変換

- [x] **T-008** `memory_burial_model.dart` - MemoryBurialModel作成 ✅
  - ファイル: `packages/feature/lib/memory_burial/data/models/memory_burial_model.dart`
  - Timestamp変換含む

### コード生成

- [x] **T-009** `build_runner` 実行 - コード生成 ✅
  - コマンド: `cd packages/feature && dart run build_runner build --delete-conflicting-outputs`

### データソース作成

- [x] **T-010** `memory_burial_remote_data_source.dart` - RemoteDataSource作成 ✅
  - ファイル: `packages/feature/lib/memory_burial/data/data_sources/memory_burial_remote_data_source.dart`
  - Cloud Functions呼び出し、Firestore直接アクセス

### Repository実装

- [x] **T-011** `memory_burial_repository_impl.dart` - Repository実装 ✅
  - ファイル: `packages/feature/lib/memory_burial/data/repositories/memory_burial_repository_impl.dart`
  - バリデーション、エラーハンドリング

---

## フェーズ3: Core Package実装（LocationRepository）

- [x] **T-012** `geo_location.dart` (Core) - GeoLocationエンティティ作成（Core Package）✅
  - ファイル: `packages/core/lib/domain/entities/geo_location.dart`
  - Coreパッケージ用（共有）

- [x] **T-013** `location_repository.dart` - LocationRepositoryインターフェース作成 ✅
  - ファイル: `packages/core/lib/domain/repositories/location_repository.dart`
  - getCurrentLocation, requestPermission, isPermissionGranted, isServiceEnabled

- [x] **T-014** `location_repository_impl.dart` - LocationRepository実装（MVP版）✅
  - ファイル: `packages/core/lib/data/repositories/location_repository_impl.dart`
  - モック位置情報（東京駅座標）

- [x] **T-015** `location_providers.dart` - LocationRepository Provider作成 ✅
  - ファイル: `packages/core/lib/presentation/providers/location_providers.dart`

---

## フェーズ4: Presentation層実装

### Provider作成

- [x] **T-016** `memory_burial_providers.dart` - Provider設定 ✅
  - ファイル: `packages/feature/lib/memory_burial/presentation/providers/memory_burial_providers.dart`
  - Firebase、DataSource、Repository、UseCase Provider

- [x] **T-017** `memory_burial_state.dart` - 状態管理クラス作成 ✅
  - ファイル: `packages/feature/lib/memory_burial/presentation/providers/memory_burial_state.dart`
  - 埋葬処理の状態（入力中、処理中、成功、エラー）

### ウィジェット作成

- [x] **T-018** `text_dissolution_animation.dart` - アニメーションウィジェット作成 ✅
  - ファイル: `packages/feature/lib/memory_burial/presentation/widgets/text_dissolution_animation.dart`
  - 文字バラバラ吸い込みアニメーション（2.5秒）
  - 3フェーズ: 散らばり → 浮遊 → 吸い込み

- [x] **T-018a** `background_effects.dart` - 背景エフェクト作成 ✅
  - ファイル: `packages/feature/lib/memory_burial/presentation/widgets/background_effects.dart`
  - 水色グラデーション、ドットパターン、同心円リング、光の柱エフェクト

- [x] **T-018b** `burial_button.dart` - カプセル型ボタン作成 ✅
  - ファイル: `packages/feature/lib/memory_burial/presentation/widgets/burial_button.dart`
  - カプセル型（縦長角丸）、下矢印アイコン、グローエフェクト、クリスタルアイコン

- [x] **T-018c** `crystal_display.dart` - クリスタル表示ウィジェット作成 ✅
  - ファイル: `packages/feature/lib/memory_burial/presentation/widgets/crystal_display.dart`
  - 紫のクリスタル画像、「解析中...」テキスト

### ページ作成

- [x] **T-019** `memory_burial_page.dart` - メインページ作成 ✅
  - ファイル: `packages/feature/lib/memory_burial/presentation/pages/memory_burial_page.dart`
  - 3フェーズ管理: input → animating → crystalDisplay
  - キーボード常時表示、エンターキー=改行、シンプルなテキスト入力UI

### ルーティング追加

- [x] **T-020** ルーティング設定追加 ✅
  - ファイル: `app/lib/core/presentation/router/app_router.dart`
  - `/memory-burial` ルート追加

---

## フェーズ5: Cloud Functions実装

> **Note**: Cloud Functionsはcore側で実装するため、feature側ではモックを想定

- [x] **T-021** `buryMemory` 関数作成 - スキップ（core側で実装）
  - ファイル: `functions/src/buryMemory.ts`
  - 認証チェック、バリデーション、クリスタルデータ生成、Firestore保存

- [x] **T-022** Cloud Functions index.ts 更新 - スキップ（core側で実装）
  - ファイル: `functions/src/index.ts`
  - buryMemory関数エクスポート

- [x] **T-023** レート制限実装 - スキップ（core側で実装）
  - ファイル: `functions/src/utils/rateLimit.ts`
  - 5リクエスト/分、100リクエスト/日

---

## フェーズ6: Firebase設定

> **Note**: Firebase設定はcore側で実装するため、スキップ

- [x] **T-024** Firestore Security Rules更新 - スキップ（core側で実装）
  - ファイル: `firestore.rules`
  - crystalsコレクションのルール追加

- [x] **T-025** Firestore Index設定 - スキップ（core側で実装）
  - Firebase Console または `firestore.indexes.json`
  - creatorUserId + buriedAt の複合インデックス

---

## フェーズ7: 統合とデプロイ

> **Note**: デプロイはcore側で実施

- [x] **T-026** Cloud Functions デプロイ - スキップ（core側で実施）
  - コマンド: `firebase deploy --only functions:buryMemory`

- [x] **T-027** Firestore Security Rules デプロイ - スキップ（core側で実施）
  - コマンド: `firebase deploy --only firestore:rules`

- [x] **T-028** Feature側の統合確認 ✅
  - リンターエラー解消、コード整合性確認

---

## タスク依存関係

```
T-001 ─┬─► T-002 ─► T-004 ─► T-005 ─► T-006
       │                      │
       │                      ▼
       │              T-012 ─► T-013 ─► T-014 ─► T-015
       │
       ├─► T-003
       │
       └─► T-007 ─┬─► T-008 ─► T-009 ─► T-010 ─► T-011
                  │
                  ▼
           T-016 ─► T-017 ─► T-018 ─► T-019 ─► T-020
                                              │
                                              ▼
                              T-021 ─► T-022 ─► T-023
                                              │
                                              ▼
                              T-024 ─► T-025 ─► T-026 ─► T-027 ─► T-028
```

---

## 並列実行可能なタスク [P]

以下のタスクは他タスクと並列実行可能です：

- **T-001** と **T-003** [P]
- **T-005** と **T-006** [P]
- **T-007** と **T-008** [P]
- **T-012** と **T-016** [P]（フェーズ3とフェーズ4は並行可能）
- **T-021** と **T-024** [P]（Cloud FunctionsとFirestore Rulesは並行可能）

---

## 完了基準

すべてのタスクが完了し、以下が検証されていること：

- [x] Feature側の機能要件が実装されている（Domain/Data/Presentation層）
- [x] エラーハンドリングが適切に実装されている
- [ ] Cloud Functionsがデプロイされ、動作している（core側で実装）
- [ ] Firestore Security Rulesが設定されている（core側で実装）
- [ ] エンドツーエンドテスト実施

---

## 変更履歴

| 日付 | 変更内容 | 変更者 |
|------|---------|--------|
| 2025-11-29 | 初版作成 | AI Implementation Agent |
| 2025-11-29 | UIリニューアル（水色テーマ、カプセル型ボタン、クリスタル表示） | AI Implementation Agent |

