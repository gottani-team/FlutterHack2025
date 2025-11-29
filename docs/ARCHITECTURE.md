# アーキテクチャドキュメント

このドキュメントでは、Flutter App Templateプロジェクトのアーキテクチャ設計について詳しく説明します。

## 目次

1. [概要](#概要)
2. [アーキテクチャ原則](#アーキテクチャ原則)
3. [プロジェクト構造](#プロジェクト構造)
4. [レイヤー構造](#レイヤー構造)
5. [パッケージ構成](#パッケージ構成)
6. [依存関係の方向](#依存関係の方向)
7. [データフロー](#データフロー)
8. [実装例](#実装例)
9. [ベストプラクティス](#ベストプラクティス)

## 概要

このプロジェクトは**クリーンアーキテクチャ**の原則に基づいて設計されています。以下の特徴を持ちます：

- **3層構造**: Domain、Data、Presentationの明確な分離
- **Monorepo構造**: Flutterワークスペースを使用したパッケージ分割
- **依存性注入**: Riverpodによる依存性の管理
- **テスト容易性**: 各層が独立してテスト可能

## アーキテクチャ原則

### 1. 依存関係の逆転原則（Dependency Inversion Principle）

- 内側の層（Domain）は外側の層（Data、Presentation）に依存しない
- 外側の層は内側の層のインターフェースに依存する
- 具体的な実装ではなく、抽象（インターフェース）に依存する

### 2. 単一責任の原則（Single Responsibility Principle）

- 各クラス、各層は単一の責任を持つ
- Domain層はビジネスロジックのみ
- Data層はデータの取得・永続化のみ
- Presentation層はUIとユーザーインタラクションのみ

### 3. 関心の分離（Separation of Concerns）

- ビジネスロジックとUIロジックを分離
- データソースとビジネスロジックを分離
- 各機能を独立したモジュールとして実装

## プロジェクト構造

```
.
├── pubspec.yaml                  # ワークスペース設定（ルート）
├── .mise.toml                    # miseによるバージョン管理設定
│
├── app/                          # メインアプリケーション
│   ├── lib/
│   │   ├── main.dart            # アプリのエントリーポイント
│   │   └── core/
│   │       └── presentation/
│   │           └── router/      # ルーティング設定（app固有）
│   ├── test/                    # アプリのテスト
│   ├── ios/                     # iOS設定
│   └── pubspec.yaml            # アプリの依存関係
│
└── packages/                    # パッケージ（責務単位で分割）
    ├── core/                    # コアパッケージ
    │   ├── lib/
    │   │   ├── domain/         # ドメイン層（コア）
    │   │   ├── data/           # データ層（コア）
    │   │   └── presentation/   # プレゼンテーション層（コア）
    │   ├── test/               # コアパッケージのテスト
    │   └── pubspec.yaml        # コアパッケージの依存関係
    │
    └── feature/                # 機能パッケージ
        ├── lib/
        │   └── [feature_name]/ # 各機能
        │       ├── domain/     # ドメイン層（機能固有）
        │       ├── data/       # データ層（機能固有）
        │       └── presentation/ # プレゼンテーション層（機能固有）
        ├── test/               # 機能パッケージのテスト
        └── pubspec.yaml        # 機能パッケージの依存関係
```

## レイヤー構造

各パッケージ内では以下の3層構造を採用しています：

### Domain層（ドメイン層）

**責任**: ビジネスロジックとエンティティの定義

**特徴**:

- 他の層に依存しない（最内層）
- 純粋なDartクラスのみを使用
- Flutterフレームワークに依存しない
- ビジネスルールを表現

**含まれるもの**:

```
domain/
├── entities/          # ビジネスエンティティ
│   └── base_entity.dart
├── repositories/       # リポジトリインターフェース
│   └── base_repository.dart
├── use_cases/         # ユースケース（ビジネスロジック）
│   └── base_use_case.dart
└── errors/            # 例外クラス
    └── app_exception.dart
```

**例**:

```dart
// packages/feature/lib/home/domain/entities/home_entity.dart
class HomeEntity extends BaseEntity {
  const HomeEntity({
    required this.id,
    required this.title,
    this.description,
  });

  final String id;
  final String title;
  final String? description;
}
```

### Data層（データ層）

**責任**: データの取得と永続化

**特徴**:

- Domain層に依存（Domain層のインターフェースを実装）
- 外部API、データベース、ローカルストレージとの通信
- JSONシリアライゼーション対応

**含まれるもの**:

```
data/
├── models/            # データモデル（JSON対応）
│   └── base_model.dart
├── data_sources/      # データソース実装
│   ├── remote_data_source.dart
│   └── local_data_source.dart
└── repositories/      # リポジトリ実装
    └── [feature]_repository_impl.dart
```

**例**:

```dart
// packages/feature/lib/home/data/models/home_model.dart
@JsonSerializable()
class HomeModel extends BaseModel<HomeEntity> {
  const HomeModel({
    required this.id,
    required this.title,
    this.description,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) =>
      _$HomeModelFromJson(json);

  Map<String, dynamic> toJson() => _$HomeModelToJson(this);

  @override
  HomeEntity toEntity() {
    return HomeEntity(
      id: id,
      title: title,
      description: description,
    );
  }
}
```

### Presentation層（プレゼンテーション層）

**責任**: UIとユーザーインタラクション

**特徴**:

- Domain層に依存（Data層には直接依存しない）
- Flutterウィジェットを使用
- Riverpodによる状態管理と依存性注入

**含まれるもの**:

```
presentation/
├── pages/             # 画面（ページ）
│   └── [feature]_page.dart
├── widgets/           # UIコンポーネント
│   └── [feature]_widget.dart
└── providers/         # Riverpodプロバイダー
    └── [feature]_providers.dart
```

**例**:

```dart
// packages/feature/lib/home/presentation/pages/home_page.dart
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(homeDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: homeDataAsync.when(
        data: (data) => _buildContent(data),
        loading: () => const LoadingWidget(),
        error: (error, stack) => ErrorDisplayWidget(message: error.toString()),
      ),
    );
  }
}
```

## パッケージ構成

### appパッケージ

**責務**:

- アプリケーションのエントリーポイント（`main.dart`）
- ルーティング設定（各機能パッケージを統合）
- プラットフォーム固有の設定（iOS、Android、Web）

**依存関係**:

- `core`パッケージ
- `feature`パッケージ
- Flutter SDK

**構造**:

```
app/
├── lib/
│   ├── main.dart                    # エントリーポイント
│   └── core/
│       └── presentation/
│           └── router/
│               └── app_router.dart  # ルーティング設定
├── ios/                             # iOS設定
└── pubspec.yaml
```

### coreパッケージ

**責務**:

- アプリ全体で共有される機能
- 基底クラスとインターフェースの提供
- 共通のユーティリティとウィジェット

**依存関係**:

- Flutter SDK
- 外部パッケージ（riverpod、freezed、json_annotationなど）

**構造**:

```
packages/core/lib/
├── domain/                          # ドメイン層（コア）
│   ├── entities/
│   │   └── base_entity.dart        # 基底エンティティ
│   ├── repositories/
│   │   └── base_repository.dart    # 基底リポジトリインターフェース
│   ├── use_cases/
│   │   └── base_use_case.dart      # 基底ユースケース
│   └── errors/
│       └── app_exception.dart      # 例外クラス
│
├── data/                            # データ層（コア）
│   ├── models/
│   │   └── base_model.dart         # 基底モデル
│   ├── data_sources/
│   │   ├── remote_data_source.dart # リモートデータソース
│   │   └── local_data_source.dart  # ローカルデータソース
│   ├── constants/
│   │   └── app_constants.dart      # 定数
│   └── utils/
│       └── logger.dart             # ロギングユーティリティ
│
└── presentation/                    # プレゼンテーション層（コア）
    ├── theme/
    │   └── app_theme.dart          # テーマ設定
    ├── widgets/
    │   ├── loading_widget.dart    # ローディングウィジェット
    │   └── error_widget.dart       # エラー表示ウィジェット
    └── utils/
        └── extensions.dart         # 拡張メソッド
```

### featureパッケージ

**責務**:

- 機能ごとの実装
- 各機能は独立したモジュールとして実装
- Domain、Data、Presentationの3層を持つ

**依存関係**:

- `core`パッケージ
- Flutter SDK

**構造**:

```
packages/feature/lib/
└── [feature_name]/                 # 各機能（例: home）
    ├── domain/                     # ドメイン層
    │   ├── entities/
    │   │   └── [feature]_entity.dart
    │   ├── repositories/
    │   │   └── [feature]_repository.dart
    │   └── use_cases/
    │       └── get_[feature]_use_case.dart
    │
    ├── data/                        # データ層
    │   ├── models/
    │   │   └── [feature]_model.dart
    │   ├── data_sources/
    │   │   └── [feature]_remote_data_source.dart
    │   └── repositories/
    │       └── [feature]_repository_impl.dart
    │
    └── presentation/                # プレゼンテーション層
        ├── pages/
        │   └── [feature]_page.dart
        ├── widgets/
        │   └── [feature]_widget.dart
        └── providers/
            └── [feature]_providers.dart
```

## 依存関係の方向

### パッケージ間の依存関係

```
app
 ├─→ core
 └─→ feature ─→ core
```

- **app** → `core`、`feature`
- **feature** → `core`
- **core** → 外部パッケージのみ

### レイヤー間の依存関係

```
Presentation層
    ↓
Domain層
    ↑
Data層
```

- **Domain層**: 他の層に依存しない（最内層）
- **Data層**: Domain層に依存（Domain層のインターフェースを実装）
- **Presentation層**: Domain層に依存（Data層には直接依存しない）

### 依存性注入

Riverpodを使用して依存性を注入します：

```dart
// packages/feature/lib/home/presentation/providers/home_providers.dart

// Data Sources
final remoteDataSourceProvider = Provider<RemoteDataSource>((ref) {
  return const RemoteDataSourceImpl();
});

// Repositories
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final remoteDataSource = ref.watch(homeRemoteDataSourceProvider);
  return HomeRepositoryImpl(remoteDataSource);
});

// Use Cases
final getHomeDataUseCaseProvider = Provider<GetHomeDataUseCase>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return GetHomeDataUseCase(repository);
});

// State Providers
final homeDataProvider = FutureProvider<HomeEntity>((ref) async {
  final useCase = ref.watch(getHomeDataUseCaseProvider);
  return await useCase.call();
});
```

## データフロー

### 典型的なデータフロー

```
1. ユーザーアクション
   ↓
2. Presentation層（Page/Widget）
   - Riverpodプロバイダーから状態を取得
   ↓
3. Use Case（Domain層）
   - ビジネスロジックを実行
   ↓
4. Repository Interface（Domain層）
   - インターフェースを定義
   ↓
5. Repository Implementation（Data層）
   - Domain層のインターフェースを実装
   ↓
6. Data Source（Data層）
   - API呼び出し、データベースアクセスなど
   ↓
7. Model（Data層）
   - JSONからモデルに変換
   ↓
8. Entity（Domain層）
   - モデルからエンティティに変換
   ↓
9. Use Case（Domain層）
   - エンティティを返す
   ↓
10. Presentation層
    - UIを更新
```

### 具体例: ホームデータの取得

```dart
// 1. UIからプロバイダーを監視
final homeDataAsync = ref.watch(homeDataProvider);

// 2. homeDataProviderがGetHomeDataUseCaseを呼び出す
final useCase = ref.watch(getHomeDataUseCaseProvider);
return await useCase.call();

// 3. Use CaseがRepositoryを呼び出す
return await _repository.getHomeData();

// 4. RepositoryがData Sourceを呼び出す
final model = await _remoteDataSource.getHomeData();

// 5. RepositoryがModelをEntityに変換
return model.toEntity();

// 6. EntityがUse Caseを通じてUIに返される
```

## 実装例

### 新しい機能を追加する場合

#### 1. Domain層の実装

**Entity**:

```dart
// packages/feature/lib/user/domain/entities/user_entity.dart
import 'package:core/domain/entities/base_entity.dart';

class UserEntity extends BaseEntity {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  @override
  List<Object?> get props => [id, name, email];
}
```

**Repository Interface**:

```dart
// packages/feature/lib/user/domain/repositories/user_repository.dart
import 'package:core/domain/repositories/base_repository.dart';
import 'package:feature/user/domain/entities/user_entity.dart';

abstract class UserRepository extends BaseRepository {
  Future<UserEntity> getUser(String id);
  Future<List<UserEntity>> getAllUsers();
  Future<UserEntity> createUser(UserEntity user);
}
```

**Use Case**:

```dart
// packages/feature/lib/user/domain/use_cases/get_user_use_case.dart
import 'package:core/domain/use_cases/base_use_case.dart';
import 'package:feature/user/domain/entities/user_entity.dart';
import 'package:feature/user/domain/repositories/user_repository.dart';

class GetUserUseCase implements UseCase<UserEntity, String> {
  const GetUserUseCase(this._repository);

  final UserRepository _repository;

  @override
  Future<UserEntity> call(String userId) async {
    return await _repository.getUser(userId);
  }
}
```

#### 2. Data層の実装

**Model**:

```dart
// packages/feature/lib/user/data/models/user_model.dart
import 'package:core/data/models/base_model.dart';
import 'package:feature/user/domain/entities/user_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends BaseModel<UserEntity> {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
    );
  }
}
```

**Data Source**:

```dart
// packages/feature/lib/user/data/data_sources/user_remote_data_source.dart
import 'package:core/data/data_sources/remote_data_source.dart';
import 'package:feature/user/data/models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getUser(String id);
  Future<List<UserModel>> getAllUsers();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  const UserRemoteDataSourceImpl(this._remoteDataSource);

  final RemoteDataSource _remoteDataSource;

  @override
  Future<UserModel> getUser(String id) async {
    final response = await _remoteDataSource.get('/users/$id');
    return UserModel.fromJson(response);
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    final response = await _remoteDataSource.get('/users');
    final List<dynamic> jsonList = response['users'] as List<dynamic>;
    return jsonList.map((json) => UserModel.fromJson(json)).toList();
  }
}
```

**Repository Implementation**:

```dart
// packages/feature/lib/user/data/repositories/user_repository_impl.dart
import 'package:core/domain/errors/app_exception.dart';
import 'package:feature/user/domain/entities/user_entity.dart';
import 'package:feature/user/domain/repositories/user_repository.dart';
import 'package:feature/user/data/data_sources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl(this._remoteDataSource);

  final UserRemoteDataSource _remoteDataSource;

  @override
  Future<UserEntity> getUser(String id) async {
    try {
      final model = await _remoteDataSource.getUser(id);
      return model.toEntity();
    } catch (e) {
      throw ServerException(
        message: 'Failed to get user: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    try {
      final models = await _remoteDataSource.getAllUsers();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to get users: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserEntity> createUser(UserEntity user) async {
    // TODO: 実装
    throw UnimplementedError();
  }
}
```

#### 3. Presentation層の実装

**Providers**:

```dart
// packages/feature/lib/user/presentation/providers/user_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/data/data_sources/remote_data_source.dart';
import 'package:feature/user/data/data_sources/user_remote_data_source.dart';
import 'package:feature/user/data/repositories/user_repository_impl.dart';
import 'package:feature/user/domain/repositories/user_repository.dart';
import 'package:feature/user/domain/use_cases/get_user_use_case.dart';
import 'package:feature/user/domain/entities/user_entity.dart';

// Data Sources
final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final remoteDataSource = ref.watch(remoteDataSourceProvider);
  return UserRemoteDataSourceImpl(remoteDataSource);
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
final userProvider = FutureProvider.family<UserEntity, String>((ref, userId) async {
  final useCase = ref.watch(getUserUseCaseProvider);
  return await useCase.call(userId);
});
```

**Page**:

```dart
// packages/feature/lib/user/presentation/pages/user_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/presentation/widgets/loading_widget.dart';
import 'package:core/presentation/widgets/error_widget.dart';
import 'package:feature/user/presentation/providers/user_providers.dart';

class UserPage extends ConsumerWidget {
  const UserPage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('User')),
      body: userAsync.when(
        data: (user) => _buildUserContent(user),
        loading: () => const LoadingWidget(),
        error: (error, stackTrace) => ErrorDisplayWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(userProvider(userId)),
        ),
      ),
    );
  }

  Widget _buildUserContent(UserEntity user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name: ${user.name}', style: const TextStyle(fontSize: 18)),
          Text('Email: ${user.email}', style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
```

#### 4. ルーティングに追加

```dart
// app/lib/core/presentation/router/app_router.dart
import 'package:feature/user/presentation/pages/user_page.dart';

GoRoute(
  path: '/user/:id',
  name: 'user',
  builder: (context, state) => UserPage(
    userId: state.pathParameters['id']!,
  ),
),
```

## ベストプラクティス

### 1. 依存関係の方向を守る

- ✅ Domain層は他の層に依存しない
- ✅ Data層とPresentation層はDomain層に依存する
- ✅ Presentation層はData層に直接依存しない
- ✅ featureパッケージはcoreパッケージに依存する
- ✅ appパッケージはcoreパッケージとfeatureパッケージに依存する

### 2. インターフェースの使用

- RepositoryはDomain層でインターフェースとして定義
- Data層でインターフェースを実装
- これにより、テスト時にモックを簡単に差し替え可能

### 3. エンティティとモデルの分離

- **Entity（Domain層）**: 純粋なDartクラス、ビジネスロジックを含む
- **Model（Data層）**: JSONシリアライゼーション対応、APIレスポンスの形式に合わせる
- ModelはEntityに変換する`toEntity()`メソッドを持つ

### 4. ユースケースの活用

- ビジネスロジックはUseCaseに集約
- 1つのUseCaseは1つの責任を持つ
- 複雑なビジネスロジックは複数のUseCaseに分割

### 5. エラーハンドリング

- `core/domain/errors/app_exception.dart`で定義された例外クラスを使用
- ネットワークエラー、サーバーエラー、キャッシュエラーなど、適切な例外タイプを使用
- Presentation層でエラーを適切に表示

### 6. テスト

- 各層を独立してテスト可能
- Domain層のテストは外部依存なしで実行可能
- Data層のテストはモックデータソースを使用
- Presentation層のテストはモックプロバイダーを使用

### 7. コード生成

- `build_runner`を使用してコード生成を実行
- `*.g.dart`、`*.freezed.dart`ファイルは`.gitignore`に含める
- 生成されたファイルは手動で編集しない

### 8. 命名規則

- **Entity**: `[Feature]Entity`（例: `UserEntity`）
- **Model**: `[Feature]Model`（例: `UserModel`）
- **Repository Interface**: `[Feature]Repository`
- **Repository Implementation**: `[Feature]RepositoryImpl`
- **Use Case**: `[Action][Feature]UseCase`（例: `GetUserUseCase`）
- **Data Source**: `[Feature][Type]DataSource`（例: `UserRemoteDataSource`）
- **Page**: `[Feature]Page`（例: `UserPage`）
- **Provider**: `[feature]Provider`（例: `userProvider`）

## まとめ

このアーキテクチャにより、以下の利点が得られます：

1. **保守性**: 各層の責任が明確で、変更の影響範囲が限定的
2. **テスト容易性**: 各層を独立してテスト可能
3. **拡張性**: 新しい機能を追加しやすい
4. **再利用性**: coreパッケージの機能を複数の機能で再利用可能
5. **チーム開発**: 各機能を独立して開発可能

このアーキテクチャに従うことで、スケーラブルで保守しやすいFlutterアプリケーションを構築できます。
