# FlutterHack2025 - Gottani

FlutterとFirebaseを使用したAI俳句生成アプリのプロジェクトです。Flutterのワークスペース機能を使用したmonorepo構造で、クリーンアーキテクチャに基づいた階層構造で設計されています。

📖 **詳細なアーキテクチャドキュメント**: [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md)

## 特徴

- **Monorepo構造**: Flutterワークスペースを使用したパッケージ分割
- **クリーンアーキテクチャ**: Domain、Data、Presentationの3層構造
- **Firebase統合**: Authentication, Firestore, Functions, Storage, Remote Config, App Check
- **Firebase AI**: Gemini APIを使用したAI俳句生成機能
- **Riverpod**: 状態管理と依存性注入にRiverpodを使用
- **GoRouter**: ルーティングにGoRouterを使用
- **Freezed**: イミュータブルクラスの生成
- **Material 3**: 最新のMaterial Design 3に対応
- **ダークモード対応**: ライト/ダークテーマの両方に対応
- **マルチプラットフォーム**: iOS、Android、Web対応

## 実装済み機能

### 🏠 Home機能

- ホーム画面の表示
- 各機能へのナビゲーション

### 🎋 Haiku(俳句)生成機能

- Firebase AIを使用したAI俳句生成
- インタラクティブなUI
- 生成された俳句の表示

## プロジェクト構造

```
.
├── pubspec.yaml                  # ワークスペース設定（ルート）
├── .mise.toml                    # miseによるバージョン管理設定
├── firebase.json                 # Firebase設定
├── docs/
│   └── ARCHITECTURE.md          # アーキテクチャドキュメント（日本語）
│
├── app/                          # メインアプリケーション
│   ├── lib/
│   │   ├── main.dart            # アプリのエントリーポイント
│   │   ├── firebase_options.dart # Firebase設定（自動生成）
│   │   └── core/
│   │       └── presentation/
│   │           └── router/
│   │               └── app_router.dart # GoRouterルーティング設定
│   ├── test/                    # アプリのテスト
│   ├── ios/                     # iOS設定
│   ├── android/                 # Android設定
│   └── pubspec.yaml            # アプリの依存関係
│
└── packages/                    # パッケージ（責務単位で分割）
    ├── core/                    # コアパッケージ
    │   ├── lib/
    │   │   ├── domain/         # ドメイン層（コア）
    │   │   │   ├── entities/   # 基底エンティティ
    │   │   │   ├── repositories/ # 基底リポジトリ
    │   │   │   ├── use_cases/  # 基底ユースケース
    │   │   │   └── errors/     # 例外クラス
    │   │   ├── data/           # データ層（コア）
    │   │   │   ├── models/     # 基底モデル
    │   │   │   ├── data_sources/ # リモート/ローカルデータソース
    │   │   │   ├── constants/  # アプリ定数
    │   │   │   └── utils/      # ロガーなど
    │   │   └── presentation/   # プレゼンテーション層（コア）
    │   │       ├── theme/      # Material 3テーマ
    │   │       ├── widgets/    # 共通ウィジェット
    │   │       └── utils/      # エクステンションなど
    │   ├── test/               # コアパッケージのテスト
    │   └── pubspec.yaml        # コアパッケージの依存関係
    │
    └── feature/                # 機能パッケージ
        ├── lib/
        │   ├── haiku/          # 俳句生成機能
        │   │   ├── domain/
        │   │   │   ├── entities/
        │   │   │   ├── repositories/
        │   │   │   └── use_cases/
        │   │   ├── data/
        │   │   │   ├── models/
        │   │   │   ├── data_sources/
        │   │   │   └── repositories/
        │   │   └── presentation/
        │   │       ├── pages/
        │   │       ├── providers/
        │   │       └── widgets/
        │   │
        │   └── home/           # ホーム機能
        │       ├── domain/
        │       ├── data/
        │       └── presentation/
        │
        ├── test/               # 機能パッケージのテスト
        └── pubspec.yaml        # 機能パッケージの依存関係
```

## アーキテクチャ

このプロジェクトは**クリーンアーキテクチャ**の原則に基づいて設計されています。各層の責任が明確に分離されており、テストしやすく、保守しやすい構造になっています。

### レイヤー構造

各パッケージ内では以下の3層構造を採用しています：

#### Domain層（ドメイン層）
- **責任**: ビジネスロジックとエンティティの定義
- **依存関係**: 他の層に依存しない（最内層）
- **含まれるもの**:
  - `entities/`: ビジネスエンティティ（純粋なDartクラス）
  - `repositories/`: リポジトリのインターフェース
  - `use_cases/`: ビジネスロジックを実行するユースケース

#### Data層（データ層）
- **責任**: データの取得と永続化
- **依存関係**: Domain層に依存
- **含まれるもの**:
  - `models/`: APIレスポンスやデータベースのモデル（JSONシリアライゼーション対応）
  - `data_sources/`: リモート/ローカルデータソースの実装
  - `repositories/`: リポジトリの実装（Domain層のインターフェースを実装）

#### Presentation層（プレゼンテーション層）
- **責任**: UIとユーザーインタラクション
- **依存関係**: Domain層に依存（Data層には直接依存しない）
- **含まれるもの**:
  - `pages/`: 画面（ページ）
  - `widgets/`: UIコンポーネント
  - `providers/`: Riverpodプロバイダー（依存性注入と状態管理）

### パッケージの責務

#### appパッケージ
- アプリケーションのエントリーポイント
- ルーティング設定（各機能パッケージを統合）
- プラットフォーム固有の設定（iOS、Android、Web）

#### coreパッケージ
- アプリ全体で共有される機能
- Domain層の基底クラス、例外クラス
- Data層の基底データソース（ネットワーク、ローカルストレージ）
- Presentation層の共通UIコンポーネント（テーマ、共通ウィジェット）

#### featureパッケージ
- 機能ごとの実装
- 各機能は独立したモジュールとして実装
- Domain、Data、Presentationの3層を持つ

### データフロー

```
UI (Presentation - app/feature)
  ↓
Use Case (Domain - feature)
  ↓
Repository Interface (Domain - feature)
  ↓
Repository Implementation (Data - feature)
  ↓
Data Source (Data - feature/core)
  ↓
API/Database
```

## セットアップ

### 前提条件

- [mise](https://mise.jdx.dev/) がインストールされていること
- miseを使ってFlutterのバージョン（3.38.1）を管理します
- **iOS開発の場合**: Xcodeがインストールされていること（macOSのみ）
- **Android開発の場合**: Android StudioとAndroid SDKがインストールされていること
- **Firebase**: Firebaseプロジェクト（gottani-2025）への適切なアクセス権限

### セットアップ手順

1. **miseでツールをインストール**:
```bash
# プロジェクトルートで実行
mise install
```

これにより、`.mise.toml`で指定されたFlutterのバージョンがインストールされます。

2. **依存関係をインストール**:
```bash
# ルートディレクトリから実行（ワークスペース全体に適用）
flutter pub get

# または各パッケージで個別に実行することも可能
cd app && flutter pub get
cd ../packages/core && flutter pub get
cd ../feature && flutter pub get
```

3. **コード生成を実行（必要に応じて）**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **アプリを実行**:
```bash
cd app

# iOSシミュレーターで実行
flutter run -d ios

# または特定のデバイスを指定
flutter run -d "iPhone 17 Pro"

# Androidエミュレーターで実行
flutter run -d android

# 利用可能なデバイスを確認
flutter devices
```

### miseの使い方

- **ツールのインストール**: `mise install`
- **現在のバージョン確認**: `mise list`
- **特定のバージョンを指定**: `.mise.toml`を編集して`flutter = "3.24.0"`のように指定
- **自動的に環境が有効化**: プロジェクトディレクトリに入ると自動的にmiseが環境を有効化します

## 使用方法

### 新しい機能を追加する

1. `packages/feature/lib/` 配下に新しい機能フォルダを作成（例: `packages/feature/lib/user/`）

2. 各層のファイルを作成:

   **Domain層**:
   ```dart
   // packages/feature/lib/user/domain/entities/user_entity.dart
   import 'package:core/domain/entities/base_entity.dart';
   class UserEntity extends BaseEntity { ... }

   // packages/feature/lib/user/domain/repositories/user_repository.dart
   import 'package:core/domain/repositories/base_repository.dart';
   abstract class UserRepository extends BaseRepository { ... }

   // packages/feature/lib/user/domain/use_cases/get_user_use_case.dart
   import 'package:core/domain/use_cases/base_use_case.dart';
   class GetUserUseCase implements UseCase<UserEntity, String> { ... }
   ```

   **Data層**:
   ```dart
   // packages/feature/lib/user/data/models/user_model.dart
   import 'package:core/data/models/base_model.dart';
   class UserModel extends BaseModel<UserEntity> { ... }

   // packages/feature/lib/user/data/data_sources/user_remote_data_source.dart
   import 'package:core/data/data_sources/remote_data_source.dart';
   class UserRemoteDataSourceImpl implements UserRemoteDataSource { ... }

   // packages/feature/lib/user/data/repositories/user_repository_impl.dart
   class UserRepositoryImpl implements UserRepository { ... }
   ```

   **Presentation層**:
   ```dart
   // packages/feature/lib/user/presentation/providers/user_providers.dart
   final userRepositoryProvider = Provider<UserRepository>((ref) { ... });
   final getUserUseCaseProvider = Provider<GetUserUseCase>((ref) { ... });

   // packages/feature/lib/user/presentation/pages/user_page.dart
   class UserPage extends ConsumerWidget { ... }
   ```

3. `app/lib/core/presentation/router/app_router.dart` にルートを追加:
```dart
import 'package:feature/user/presentation/pages/user_page.dart';

GoRoute(
  path: '/user/:id',
  name: 'user',
  builder: (context, state) => UserPage(userId: state.pathParameters['id']!),
),
```

### ルーティング

`app/lib/core/presentation/router/app_router.dart` でルーティングを管理します。

```dart
GoRoute(
  path: '/your-route',
  name: 'your-route-name',
  builder: (context, state) => const YourPage(),
),
```

### 状態管理と依存性注入

Riverpodを使用して状態管理と依存性注入を行います。各機能の `presentation/providers/` フォルダにプロバイダーを定義します。

```dart
// Data Sources
final remoteDataSourceProvider = Provider<RemoteDataSource>((ref) {
  return const RemoteDataSourceImpl();
});

// Repositories
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final remoteDataSource = ref.watch(userRemoteDataSourceProvider);
  return UserRepositoryImpl(remoteDataSource);
});

// Use Cases
final getUserUseCaseProvider = Provider<GetUserUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetUserUseCase(repository);
});

// State Providers
final userProvider = FutureProvider<UserEntity>((ref) async {
  final useCase = ref.watch(getUserUseCaseProvider);
  return await useCase.call('user-id');
});
```

### テーマのカスタマイズ

`packages/core/lib/presentation/theme/app_theme.dart` でテーマをカスタマイズできます。

## 含まれるパッケージ

### appパッケージ

- `flutter_riverpod`: 状態管理
- `go_router`: ルーティング
- `firebase_core`: Firebase初期化
- `firebase_app_check`: Firebaseアプリチェック
- `firebase_remote_config`: リモート設定
- `core`: コアパッケージ（ローカル依存）
- `feature`: 機能パッケージ（ローカル依存）

### coreパッケージ

- `flutter_riverpod`: 状態管理
- `riverpod_annotation`: Riverpodコード生成
- `freezed_annotation`: イミュータブルクラス
- `json_annotation`: JSONシリアライゼーション
- `equatable`: 値の等価性比較
- `logger`: ロギング

### featureパッケージ

- `flutter_riverpod` & `hooks_riverpod`: 状態管理
- `flutter_hooks`: React Hooksスタイルの状態管理
- `freezed_annotation`: イミュータブルクラス
- `json_annotation`: JSONシリアライゼーション
- **Firebaseサービス**:
  - `cloud_firestore`: Firestoreデータベース
  - `cloud_functions`: Cloud Functions呼び出し
  - `firebase_ai`: Gemini AI統合
  - `firebase_auth`: ユーザー認証
  - `firebase_storage`: ファイルストレージ
- **UI/UXライブラリ**:
  - `gap`: レイアウト用スペーシング
  - `google_fonts`: Googleフォント
  - `shimmer`: ローディングアニメーション
  - `cached_network_image`: 画像キャッシング
  - `file_picker`: ファイル選択
  - `url_launcher`: URL起動
  - `flutter_inappwebview`: インアプリブラウザ
- `core`: コアパッケージ（ローカル依存）

## 技術スタック

### バージョン情報

- **Flutter**: 3.38.1
- **Dart**: >=3.5.0 <4.0.0
- **Firebase プロジェクト**: gottani-2025

### 主要ライブラリ

- **状態管理**: Riverpod 3.0+, Flutter Hooks
- **ルーティング**: GoRouter 17.0+
- **バックエンド**: Firebase (Firestore, Functions, Auth, Storage, AI)
- **コード生成**: Freezed, JsonSerializable, Riverpod Generator
- **UI**: Material Design 3, Google Fonts

## ベストプラクティス

1. **依存関係の方向**:
   - Domain層は他の層に依存しません
   - Data層とPresentation層はDomain層に依存します
   - featureパッケージはcoreパッケージに依存します
   - appパッケージはcoreパッケージとfeatureパッケージに依存します

2. **インターフェースの使用**: RepositoryはDomain層でインターフェースとして定義し、Data層で実装します。

3. **エンティティとモデルの分離**: Domain層のエンティティは純粋なDartクラス、Data層のモデルはJSONシリアライゼーション対応。

4. **ユースケース**: ビジネスロジックはUseCaseに集約します。

5. **エラーハンドリング**: `core/domain/errors/app_exception.dart` で定義された例外クラスを使用します。

6. **パッケージの独立性**: 各パッケージは可能な限り独立しており、他のパッケージへの依存は最小限にします。

7. **Firebase統合**: すべてのFirebase呼び出しはData層のDataSourceで行い、適切なエラーハンドリングを実装します。

## プロジェクト情報

- **プロジェクト名**: FlutterHack2025 - Gottani
- **バージョン**: 1.0.0+1
- **開発環境**: mise を使用したバージョン管理

## ライセンス

このプロジェクトは自由に使用・改変できます。
