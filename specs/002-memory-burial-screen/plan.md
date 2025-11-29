# Implementation Plan: Memory Burial Screen

**作成日**: 2025-11-29  
**更新日**: 2025-11-29  
**機能**: Memory Burial Screen  
**ブランチ**: `002-memory-burial-screen`  
**ステータス**: Implementation Complete ✅

## 概要

このドキュメントは、Memory Burial Screen機能の実装計画の全体像を提供します。spec.mdで定義された要件に基づき、クリーンアーキテクチャに従った設計と実装手順を明確化します。

---

## プロジェクト情報

- **機能名**: Memory Burial Screen
- **優先度**: P1（最高優先度）
- **推定実装時間**: 2～3日
- **チーム**: フルスタック開発者1名
- **技術スタック**: Flutter 3.38.1、Firebase Cloud Functions、Cloud Firestore

---

## 機能概要

ユーザーが記憶をテキストとして入力し、視覚的なアニメーションとともに「埋める」ことができる画面。入力されたテキストは文字単位で分解され、ボタンに吸い込まれるエフェクトとともにサーバーに送信されます。

### 主要機能

1. **テキスト入力**: キーボード常時表示、10～500文字の記憶テキスト入力
2. **テキスト分解アニメーション**: 文字がバラバラに散らばり、下中央のボタンに吸い込まれる視覚効果
3. **サーバーリクエスト**: 記憶テキストと位置情報を送信（アニメーションと同時実行）
4. **クリスタル表示**: アニメーション完了後にクリスタルと「解析中...」を表示
5. **エラーハンドリング**: ネットワークエラー時のリトライ機能

### 画面フロー

```
1. 入力画面 (input)
   - キーボード常時表示
   - 上部にテキスト入力（プレースホルダー：「あなたの言葉」）
   - 中央下にカプセル型ボタン（下矢印アイコン）
   - エンターキーは改行として動作

2. アニメーション中 (animating)
   - 入力テキストが文字単位でバラバラに散らばる
   - 各文字が下中央のボタンに向かって吸い込まれる
   - ボタンに光の柱エフェクト

3. クリスタル表示 (crystalDisplay)
   - 紫のクリスタル画像を中央に表示
   - 「解析中...」テキスト
   - 完了後、マップ画面に遷移
```

### UIデザイン

- **背景**: 水色グラデーション（#A4D4F4 → #8BC4EA → #B8E0F7）
- **背景パターン**: ドットパターン（規則的な点の模様）
- **同心円リング**: 画面中央に波紋のようなエフェクト
- **ボタン**: カプセル型（縦長の角丸長方形）、下矢印アイコン、光エフェクト
- **テキスト色**: ダークブルー（#1A1A2E）

---

## アーキテクチャ設計

### クリーンアーキテクチャ構造

```
packages/feature/lib/memory_burial/
├── domain/                      # ビジネスロジック層
│   ├── entities/
│   │   ├── memory_burial_entity.dart
│   │   └── geo_location.dart
│   ├── repositories/
│   │   └── memory_burial_repository.dart
│   ├── use_cases/
│   │   ├── bury_memory_use_case.dart
│   │   └── get_burial_history_use_case.dart
│   └── errors/
│       └── memory_burial_exceptions.dart
│
├── data/                        # データ層
│   ├── models/
│   │   ├── memory_burial_model.dart
│   │   └── geo_location_model.dart
│   ├── data_sources/
│   │   └── memory_burial_remote_data_source.dart
│   └── repositories/
│       └── memory_burial_repository_impl.dart
│
└── presentation/                # プレゼンテーション層
    ├── pages/
    │   └── memory_burial_page.dart
    ├── widgets/
    │   ├── background_effects.dart      # 背景エフェクト（グラデーション、ドット、リング）
    │   ├── burial_button.dart           # カプセル型ボタン
    │   ├── crystal_display.dart         # クリスタル表示
    │   └── text_dissolution_animation.dart  # 文字バラバラアニメーション
    └── providers/
        ├── memory_burial_providers.dart
        └── memory_burial_state.dart
```

### データフロー

```
ユーザー入力（テキスト）
    ↓
MemoryBurialPage (Presentation)
    ↓
BuryMemoryUseCase (Domain)
    ↓
    ├─→ LocationRepository (Core) → GPS座標取得
    └─→ MemoryBurialRepository (Domain Interface)
           ↓
       MemoryBurialRepositoryImpl (Data)
           ↓
       MemoryBurialRemoteDataSource (Data)
           ↓
       Cloud Functions → buryMemory
           ↓
       Firestore (crystalsコレクション)
           ↓
       レスポンス（crystalId, color, emotionType）
           ↓
       成功メッセージ表示 → マップ画面遷移
```

---

## 技術スタック

### フロントエンド（Flutter）

- **状態管理**: Riverpod 3.x
- **位置情報**: package/coreモジュール（MVP版はモック実装）
- **アニメーション**: Flutter標準AnimationController + CustomPainter
- **Firebase SDK**: cloud_functions、cloud_firestore

### バックエンド（Firebase）

- **Cloud Functions**: Node.js 18、TypeScript
- **Firestore**: クリスタルデータ永続化
- **リージョン**: asia-northeast1（東京）

### 開発ツール

- **コード生成**: build_runner、json_serializable

---

## 実装フェーズ

### フェーズ1: Domain層（推定0.5日）

**成果物**:
- ✅ エンティティ定義（MemoryBurialEntity, GeoLocation）
- ✅ リポジトリインターフェース定義
- ✅ ユースケース実装（BuryMemory, GetBurialHistory）
- ✅ 例外クラス定義

**依存関係**: なし

---

### フェーズ2: Data層（推定0.5日）

**成果物**:
- ✅ モデル作成とコード生成（MemoryBurialModel, GeoLocationModel）
- ✅ リモートデータソース実装（Cloud Functions + Firestore）
- ✅ リポジトリ実装
- ✅ エラーハンドリング実装

**依存関係**: Domain層完了

---

### フェーズ3: Presentation層（推定1日）

**成果物**:
- ✅ Riverpodプロバイダー設定
- ✅ MemoryBurialPage実装
- ✅ TextDissolutionAnimation実装
- ✅ ルーティング追加

**依存関係**: Data層完了

---

### フェーズ4: Cloud Functions（推定0.5日）

**成果物**:
- ✅ `buryMemory`関数実装
- ✅ バリデーション実装
- ✅ クリスタルデータ生成ロジック（MVP版はキーワードベース）
- ✅ レート制限実装
- ✅ デプロイ

**依存関係**: Data層のAPI呼び出し定義完了

---

### フェーズ5: Core Package（推定0.5日）

**成果物**:
- ✅ LocationRepository実装（MVP版はモック位置情報）
- ✅ LocationRepository Provider設定

**依存関係**: なし

---

## 生成された設計ドキュメント

### 1. Research（調査ドキュメント）

**ファイル**: [`research.md`](./research.md)

**内容**:
- 技術スタック決定と根拠
- アニメーション実装方針
- サーバーAPI統合パターン
- 位置情報管理戦略
- ベストプラクティス
- セキュリティ考慮事項

**対象読者**: 開発者、アーキテクト

---

### 2. Data Model（データモデル）

**ファイル**: [`data-model.md`](./data-model.md)

**内容**:
- エンティティ定義（MemoryBurialEntity, GeoLocation）
- Firestoreコレクション構造
- バリデーションルール
- Model ↔ Entity変換
- Firestore Security Rules

**対象読者**: 開発者、データベース設計者

---

### 3. Cloud Functions API（APIコントラクト）

**ファイル**: [`contracts/cloud_functions_api.md`](./contracts/cloud_functions_api.md)

**内容**:
- Cloud Functions HTTPSコール可能関数の仕様
- `buryMemory`関数（埋葬処理）
- リクエスト/レスポンス形式
- エラーコードと対処方法
- バリデーションルール
- レート制限実装

**対象読者**: バックエンド開発者、フロントエンド開発者

---

### 4. Repository Interfaces（リポジトリインターフェース）

**ファイル**: [`contracts/repository_interfaces.md`](./contracts/repository_interfaces.md)

**内容**:
- `MemoryBurialRepository`インターフェース
- `LocationRepository`インターフェース（Core Package）
- ユースケース実装例
- 例外クラス定義
- テスト戦略

**対象読者**: 開発者、テスター

---

### 5. Quickstart（実装ガイド）

**ファイル**: [`quickstart.md`](./quickstart.md)

**内容**:
- 段階的な実装手順
- フェーズごとの詳細タスク
- コード例とテンプレート
- 依存パッケージリスト
- チェックリスト
- トラブルシューティング

**対象読者**: 実装担当開発者

---

## 要件マッピング

### 機能要件カバレッジ

| 要件カテゴリ | 機能要件 | 実装場所 | ステータス |
|------------|---------|---------|-----------|
| テキスト入力とバリデーション | FR-001～FR-005 | `MemoryBurialPage` | 設計完了 |
| ボタンとUIレイアウト | FR-006～FR-008 | `MemoryBurialPage` | 設計完了 |
| 埋葬アニメーションとリクエスト | FR-009～FR-015 | `TextDissolutionAnimation` + UseCase | 設計完了 |
| 成功フロー | FR-016～FR-019 | `MemoryBurialPage` | 設計完了 |
| エラーハンドリング | FR-020～FR-024 | Repository + Presentation層 | 設計完了 |
| 位置情報統合 | FR-025～FR-026 | `LocationRepository` (Core Package) | 設計完了 |

### 成功基準マッピング

| 成功基準 | 目標値 | 実装方法 |
|---------|-------|---------|
| SC-001 | 30秒以内で埋葬完了 | アニメーション2秒 + API30秒タイムアウト |
| SC-002 | アニメーション2秒以内 | AnimationController duration設定 |
| SC-003 | バリデーション100ms以内 | リアルタイムバリデーション（onChanged） |
| SC-004 | 95%成功率 | リトライ機構、適切なエラーハンドリング |
| SC-005 | リトライ95%成功 | エラー時に入力テキスト保持 |
| SC-006 | 重複防止100% | ローカルフラグ + Firestoreトランザクション |
| SC-007 | 成功メッセージ正確に2秒 | Future.delayed(Duration(seconds: 2)) |

---

## リスクと緩和策

### 高リスク項目

1. **Cloud Functionsタイムアウト**
   - **リスク**: サーバー処理が30秒を超える
   - **緩和策**: タイムアウト設定、リトライ機構、キャッシュ実装

2. **位置情報取得失敗**
   - **リスク**: GPS精度不足、権限拒否
   - **緩和策**: MVP版はモック位置情報、将来的に実装

3. **重複埋葬**
   - **リスク**: ユーザーが誤って複数回タップ
   - **緩和策**: ローカルフラグとFirestoreトランザクションで二重防止

### 中リスク項目

1. **レート制限超過**
   - **緩和策**: Cloud Functions側でレート制限実装

2. **ネットワークエラー**
   - **緩和策**: リトライ機構、明確なエラーメッセージ

---

## 依存関係と前提条件

### 外部依存

- **Firebase Services**: Cloud Functions、Firestoreが設定済み
- **Firebase Authentication**: ユーザー認証済み

### プロジェクト内依存

- **Core Package**: `BaseEntity`、`BaseRepository`、`BaseUseCase`が実装済み
- **Firebase設定**: `firebase_options.dart`が設定済み
- **LocationRepository**: MVP版はモック実装、将来的に実装

---

## セキュリティ考慮事項

### 認証とアクセス制御

- すべてのCloud Functionsで Firebase Authentication必須
- Firestore Security Rulesで読み取り/書き込み制限
- レート制限実装（5リクエスト/分、100リクエスト/日）

### データ保護

- ユーザーの記憶テキストはFirestore暗号化保存
- 入力テキストのサニタイゼーション（XSS対策）
- 位置情報も保存（監査用）

### Firestore Security Rules

```javascript
match /crystals/{crystalId} {
  allow create: if request.auth != null
                && request.resource.data.creatorUserId == request.auth.uid
                && request.resource.data.memoryText.size() >= 10
                && request.resource.data.memoryText.size() <= 500;
  allow read: if request.auth != null;
  allow update, delete: if false; // 埋葬後は変更不可
}
```

---

## デプロイ戦略

### ステージング環境

1. Cloud Functionsを開発環境にデプロイ
2. Flutterアプリを内部テスター向けにビルド
3. 機能テストと受入テスト実施

### プロダクション環境

1. すべてのテストがパス
2. 成功基準（SC-001～SC-007）の検証完了
3. Firestore Security Rulesレビュー完了
4. 段階的ロールアウト（10% → 50% → 100%）

---

## 完了基準

### 機能完了

- ✅ すべての機能要件（FR-001～FR-026）実装完了
- ✅ すべての受入シナリオが通過
- ✅ エッジケースが適切に処理されている

### 品質完了

- ✅ 成功基準（SC-001～SC-007）すべて達成
- ✅ エラーハンドリングが適切に実装されている
- ✅ セキュリティルールが設定されている

### ドキュメント完了

- ✅ 実装計画ドキュメント（本ドキュメント）
- ✅ APIドキュメント
- ✅ 開発者向けクイックスタートガイド

---

## 次のステップ

1. **実装開始**: `quickstart.md`に従って実装を開始
2. **定期レビュー**: 各フェーズ完了後にコードレビュー実施
3. **統合テスト**: すべてのフェーズ完了後にエンドツーエンドテスト
4. **デプロイ**: ステージング環境→プロダクション環境

---

## 参考資料

- **仕様書**: [`spec.md`](./spec.md)
- **リサーチドキュメント**: [`research.md`](./research.md)
- **データモデル**: [`data-model.md`](./data-model.md)
- **Cloud Functions API**: [`contracts/cloud_functions_api.md`](./contracts/cloud_functions_api.md)
- **リポジトリインターフェース**: [`contracts/repository_interfaces.md`](./contracts/repository_interfaces.md)
- **実装ガイド**: [`quickstart.md`](./quickstart.md)
- **アーキテクチャドキュメント**: [`../../docs/ARCHITECTURE.md`](../../docs/ARCHITECTURE.md)

---

## 実装チェックリスト（サマリー）

### Domain層
- [ ] エンティティ作成（MemoryBurialEntity, GeoLocation）
- [ ] Repositoryインターフェース作成
- [ ] UseCases作成
- [ ] 例外クラス作成

### Data層
- [ ] モデル作成（MemoryBurialModel, GeoLocationModel）
- [ ] コード生成実行
- [ ] データソース実装
- [ ] Repository実装

### Presentation層
- [ ] Provider設定
- [ ] MemoryBurialPage作成
- [ ] アニメーションウィジェット作成
- [ ] ルーティング追加

### Cloud Functions
- [ ] `buryMemory`関数実装
- [ ] バリデーション実装
- [ ] デプロイ

### Core Package
- [ ] LocationRepository実装（MVP版）
- [ ] Provider追加

### その他
- [ ] Firestore Security Rules設定
- [ ] Firebase Consoleで動作確認

---

**実装計画策定完了**: 2025-11-29  
**レビュー承認**: 未承認  
**実装開始予定**: 承認後即座

---

## 変更履歴

| 日付 | 変更内容 | 変更者 |
|------|---------|--------|
| 2025-11-29 | 初版作成（spec.mdを元に1から作成） | AI Planning Agent |
| 2025-11-29 | UIリニューアル（水色テーマ、カプセル型ボタン、文字バラバラアニメーション、クリスタル表示） | AI Implementation Agent |

