# Repository Interfaces: Memory Burial

**作成日**: 2025-11-29  
**機能**: Memory Burial Screen  
**ブランチ**: `002-memory-burial-screen`

## 概要

このドキュメントは、Memory Burial機能で使用されるRepositoryインターフェースの仕様を定義します。クリーンアーキテクチャに従い、Domain層でインターフェースを定義し、Data層で実装します。

---

## Repository一覧

| Repository | 責務 | 定義場所 |
|-----------|------|---------|
| `MemoryBurialRepository` | 記憶の埋葬とデータ管理 | Domain層 |
| `LocationRepository` | 位置情報の取得 | Core Domain層（既存） |

---

## 1. MemoryBurialRepository

### インターフェース定義

**ファイルパス**: `packages/feature/lib/memory_burial/domain/repositories/memory_burial_repository.dart`

```dart
import 'package:core/domain/repositories/base_repository.dart';
import '../entities/memory_burial_entity.dart';
import '../entities/geo_location.dart';

/// 記憶埋葬のリポジトリインターフェース
abstract class MemoryBurialRepository extends BaseRepository {
  /// 記憶を埋葬する
  ///
  /// [memoryText] 記憶テキスト（10～500文字）
  /// [location] 埋葬位置
  ///
  /// Returns: 埋葬されたMemoryBurialEntity
  ///
  /// Throws:
  /// - [InvalidMemoryTextException] テキストが無効
  /// - [InvalidLocationException] 位置情報が無効
  /// - [NetworkException] ネットワークエラー
  /// - [ServerException] サーバーエラー
  /// - [TimeoutException] タイムアウト
  Future<MemoryBurialEntity> buryMemory({
    required String memoryText,
    required GeoLocation location,
  });

  /// ユーザーの埋葬履歴を取得する
  ///
  /// [userId] ユーザーID
  /// [limit] 取得件数（デフォルト: 20）
  ///
  /// Returns: MemoryBurialEntityのリスト
  Future<List<MemoryBurialEntity>> getBurialHistory({
    required String userId,
    int limit = 20,
  });

  /// 特定のクリスタルを取得する
  ///
  /// [crystalId] クリスタルID
  ///
  /// Returns: MemoryBurialEntity
  ///
  /// Throws:
  /// - [NotFoundException] クリスタルが見つからない
  Future<MemoryBurialEntity> getCrystal(String crystalId);
}
```

---

### Repository実装

**ファイルパス**: `packages/feature/lib/memory_burial/data/repositories/memory_burial_repository_impl.dart`

```dart
import 'package:core/domain/errors/app_exception.dart';
import '../../domain/entities/memory_burial_entity.dart';
import '../../domain/entities/geo_location.dart';
import '../../domain/repositories/memory_burial_repository.dart';
import '../../domain/errors/memory_burial_exceptions.dart';
import '../data_sources/memory_burial_remote_data_source.dart';
import '../models/memory_burial_model.dart';

class MemoryBurialRepositoryImpl implements MemoryBurialRepository {
  MemoryBurialRepositoryImpl(this._remoteDataSource);

  final MemoryBurialRemoteDataSource _remoteDataSource;

  @override
  Future<MemoryBurialEntity> buryMemory({
    required String memoryText,
    required GeoLocation location,
  }) async {
    try {
      // バリデーション
      _validateMemoryText(memoryText);
      _validateLocation(location);

      // リモートデータソース呼び出し
      final model = await _remoteDataSource.buryMemory(
        memoryText: memoryText,
        latitude: location.latitude,
        longitude: location.longitude,
      );

      // Entityに変換して返却
      return model.toEntity();
    } on InvalidMemoryTextException {
      rethrow;
    } on InvalidLocationException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw ServerException('記憶の埋葬に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<List<MemoryBurialEntity>> getBurialHistory({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final models = await _remoteDataSource.getBurialHistory(
        userId: userId,
        limit: limit,
      );

      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw ServerException('埋葬履歴の取得に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<MemoryBurialEntity> getCrystal(String crystalId) async {
    try {
      final model = await _remoteDataSource.getCrystal(crystalId);
      return model.toEntity();
    } catch (e) {
      throw NotFoundException('クリスタルが見つかりませんでした');
    }
  }

  /// memoryTextのバリデーション
  void _validateMemoryText(String memoryText) {
    if (memoryText.isEmpty) {
      throw InvalidMemoryTextException('記憶テキストを入力してください');
    }

    if (memoryText.length < 10) {
      throw InvalidMemoryTextException(
        '記憶テキストは10文字以上必要です（現在: ${memoryText.length}文字）'
      );
    }

    if (memoryText.length > 500) {
      throw InvalidMemoryTextException(
        '記憶テキストは500文字以下にしてください（現在: ${memoryText.length}文字）'
      );
    }
  }

  /// locationのバリデーション
  void _validateLocation(GeoLocation location) {
    if (!location.isValid) {
      throw InvalidLocationException();
    }
  }
}
```

---

### Data Source定義

**ファイルパス**: `packages/feature/lib/memory_burial/data/data_sources/memory_burial_remote_data_source.dart`

```dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/memory_burial_model.dart';
import '../../domain/errors/memory_burial_exceptions.dart';

/// Memory Burialのリモートデータソース（Cloud Functions + Firestore）
abstract class MemoryBurialRemoteDataSource {
  /// 記憶を埋葬する（Cloud Functions呼び出し）
  Future<MemoryBurialModel> buryMemory({
    required String memoryText,
    required double latitude,
    required double longitude,
  });

  /// 埋葬履歴を取得する（Firestore直接アクセス）
  Future<List<MemoryBurialModel>> getBurialHistory({
    required String userId,
    int limit = 20,
  });

  /// 特定のクリスタルを取得する（Firestore直接アクセス）
  Future<MemoryBurialModel> getCrystal(String crystalId);
}

class MemoryBurialRemoteDataSourceImpl implements MemoryBurialRemoteDataSource {
  MemoryBurialRemoteDataSourceImpl({
    required FirebaseFunctions functions,
    required FirebaseFirestore firestore,
  })  : _functions = functions,
        _firestore = firestore;

  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;

  @override
  Future<MemoryBurialModel> buryMemory({
    required String memoryText,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final callable = _functions.httpsCallable('buryMemory');

      final result = await callable.call({
        'memoryText': memoryText,
        'location': {
          'latitude': latitude,
          'longitude': longitude,
        },
      }).timeout(
        Duration(seconds: 30),
        onTimeout: () => throw TimeoutException(),
      );

      final data = result.data as Map<String, dynamic>;

      if (data['success'] != true) {
        throw ServerException(data['error']['message'] ?? 'サーバーエラー');
      }

      // Cloud Functionsのレスポンスから直接Modelを構築
      return MemoryBurialModel(
        id: data['crystalId'] as String,
        memoryText: memoryText,
        location: GeoLocationModel(
          latitude: latitude,
          longitude: longitude,
        ),
        buriedAt: DateTime.parse(data['buriedAt'] as String),
        crystalColor: data['crystalColor'] as String?,
        emotionType: data['emotionType'] as String?,
      );
    } on FirebaseFunctionsException catch (e) {
      throw _mapFirebaseFunctionsException(e);
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw NetworkException();
    }
  }

  @override
  Future<List<MemoryBurialModel>> getBurialHistory({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('crystals')
          .where('creatorUserId', isEqualTo: userId)
          .orderBy('buriedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => MemoryBurialModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException('埋葬履歴の取得に失敗しました');
    }
  }

  @override
  Future<MemoryBurialModel> getCrystal(String crystalId) async {
    try {
      final doc = await _firestore
          .collection('crystals')
          .doc(crystalId)
          .get();

      if (!doc.exists) {
        throw NotFoundException('クリスタルが見つかりませんでした');
      }

      return MemoryBurialModel.fromJson(doc.data()!);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException('クリスタルの取得に失敗しました');
    }
  }

  /// FirebaseFunctionsExceptionをアプリケーション例外に変換
  Exception _mapFirebaseFunctionsException(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return UnauthorizedException('認証が必要です');
      case 'invalid-argument':
        return InvalidMemoryTextException(e.message ?? '入力値が不正です');
      case 'deadline-exceeded':
        return TimeoutException();
      case 'resource-exhausted':
        return RateLimitException('リクエスト制限を超過しました');
      case 'internal':
      default:
        return ServerException(e.message ?? 'サーバーエラーが発生しました');
    }
  }
}
```

---

## 2. LocationRepository（Core Package）

### インターフェース定義

**ファイルパス**: `packages/core/lib/domain/repositories/location_repository.dart`

```dart
import 'package:core/domain/repositories/base_repository.dart';
import '../entities/geo_location.dart'; // Coreパッケージで定義

/// 位置情報取得のリポジトリインターフェース
abstract class LocationRepository extends BaseRepository {
  /// 現在位置を取得する
  ///
  /// Returns: GeoLocation
  ///
  /// Throws:
  /// - [LocationPermissionDeniedException] 位置情報権限が拒否された
  /// - [LocationServiceDisabledException] 位置情報サービスが無効
  /// - [TimeoutException] タイムアウト
  Future<GeoLocation> getCurrentLocation();

  /// 位置情報権限をリクエストする
  ///
  /// Returns: 権限が許可されたかどうか
  Future<bool> requestPermission();

  /// 位置情報権限が許可されているか確認する
  ///
  /// Returns: 権限が許可されているかどうか
  Future<bool> isPermissionGranted();

  /// 位置情報サービスが有効か確認する
  ///
  /// Returns: サービスが有効かどうか
  Future<bool> isServiceEnabled();
}
```

**注意**: LocationRepositoryはCoreパッケージに実装する必要があります（FR-025対応）。MVPでは、以下のような実装を想定します：

```dart
// packages/core/lib/data/repositories/location_repository_impl.dart
class LocationRepositoryImpl implements LocationRepository {
  // 開発時はモック位置を返す
  @override
  Future<GeoLocation> getCurrentLocation() async {
    // TODO: 実際の位置情報取得実装（geolocatorパッケージ使用）
    // MVP版では東京駅の座標を返す
    return GeoLocation(latitude: 35.6812, longitude: 139.7671);
  }

  @override
  Future<bool> requestPermission() async {
    // TODO: 実装
    return true;
  }

  @override
  Future<bool> isPermissionGranted() async {
    // TODO: 実装
    return true;
  }

  @override
  Future<bool> isServiceEnabled() async {
    // TODO: 実装
    return true;
  }
}
```

---

## Use Case実装例

### BuryMemoryUseCase

**ファイルパス**: `packages/feature/lib/memory_burial/domain/use_cases/bury_memory_use_case.dart`

```dart
import 'package:core/domain/use_cases/base_use_case.dart';
import 'package:core/domain/repositories/location_repository.dart';
import '../entities/memory_burial_entity.dart';
import '../repositories/memory_burial_repository.dart';

/// 記憶を埋葬するユースケース
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
    // 1. 位置情報を取得
    final location = await _locationRepository.getCurrentLocation();

    // 2. 記憶を埋葬
    final result = await _memoryBurialRepository.buryMemory(
      memoryText: params.memoryText,
      location: location,
    );

    return result;
  }
}

/// BuryMemoryUseCaseのパラメータ
class BuryMemoryParams {
  BuryMemoryParams({required this.memoryText});

  final String memoryText;
}
```

### GetBurialHistoryUseCase

**ファイルパス**: `packages/feature/lib/memory_burial/domain/use_cases/get_burial_history_use_case.dart`

```dart
import 'package:core/domain/use_cases/base_use_case.dart';
import '../entities/memory_burial_entity.dart';
import '../repositories/memory_burial_repository.dart';

/// 埋葬履歴を取得するユースケース
class GetBurialHistoryUseCase implements UseCase<List<MemoryBurialEntity>, String> {
  GetBurialHistoryUseCase(this._repository);

  final MemoryBurialRepository _repository;

  @override
  Future<List<MemoryBurialEntity>> call(String userId) async {
    return await _repository.getBurialHistory(
      userId: userId,
      limit: 20,
    );
  }
}
```

---

## エラークラス定義（再掲）

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

/// 位置情報権限が拒否された
class LocationPermissionDeniedException extends AppException {
  LocationPermissionDeniedException()
      : super(
          message: '位置情報の権限が拒否されました',
          code: 'location-permission-denied',
        );
}

/// 位置情報サービスが無効
class LocationServiceDisabledException extends AppException {
  LocationServiceDisabledException()
      : super(
          message: '位置情報サービスが無効です',
          code: 'location-service-disabled',
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

/// レート制限エラー
class RateLimitException extends AppException {
  RateLimitException(String message)
      : super(message: message, code: 'rate-limit');
}

/// 認証エラー
class UnauthorizedException extends AppException {
  UnauthorizedException(String message)
      : super(message: message, code: 'unauthorized');
}

/// 見つからない
class NotFoundException extends AppException {
  NotFoundException(String message)
      : super(message: message, code: 'not-found');
}
```

---

## テスト例

### Repository実装のテスト

**ファイルパス**: `packages/feature/test/memory_burial/data/repositories/memory_burial_repository_impl_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:feature/memory_burial/data/repositories/memory_burial_repository_impl.dart';
import 'package:feature/memory_burial/data/data_sources/memory_burial_remote_data_source.dart';
import 'package:feature/memory_burial/domain/entities/geo_location.dart';
import 'package:feature/memory_burial/domain/errors/memory_burial_exceptions.dart';

class MockMemoryBurialRemoteDataSource extends Mock
    implements MemoryBurialRemoteDataSource {}

void main() {
  late MemoryBurialRepositoryImpl repository;
  late MockMemoryBurialRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockMemoryBurialRemoteDataSource();
    repository = MemoryBurialRepositoryImpl(mockDataSource);
  });

  group('buryMemory', () {
    const memoryText = 'あの日の夕焼けがとても美しかった。';
    const location = GeoLocation(latitude: 35.6812, longitude: 139.7671);

    test('should return MemoryBurialEntity when successful', () async {
      // Arrange
      final mockModel = MemoryBurialModel(
        id: 'test-id',
        memoryText: memoryText,
        location: GeoLocationModel.fromEntity(location),
        buriedAt: DateTime.now(),
        crystalColor: 'blue',
        emotionType: 'joy',
      );

      when(() => mockDataSource.buryMemory(
            memoryText: memoryText,
            latitude: location.latitude,
            longitude: location.longitude,
          )).thenAnswer((_) async => mockModel);

      // Act
      final result = await repository.buryMemory(
        memoryText: memoryText,
        location: location,
      );

      // Assert
      expect(result.memoryText, memoryText);
      expect(result.location, location);
      verify(() => mockDataSource.buryMemory(
            memoryText: memoryText,
            latitude: location.latitude,
            longitude: location.longitude,
          )).called(1);
    });

    test('should throw InvalidMemoryTextException when text is too short', () async {
      // Arrange
      const shortText = '短い'; // 2文字（10文字未満）

      // Act & Assert
      expect(
        () => repository.buryMemory(
          memoryText: shortText,
          location: location,
        ),
        throwsA(isA<InvalidMemoryTextException>()),
      );
    });

    test('should throw InvalidLocationException when location is invalid', () async {
      // Arrange
      const invalidLocation = GeoLocation(latitude: 999, longitude: 999); // 無効な座標

      // Act & Assert
      expect(
        () => repository.buryMemory(
          memoryText: memoryText,
          location: invalidLocation,
        ),
        throwsA(isA<InvalidLocationException>()),
      );
    });

    test('should throw NetworkException when network error occurs', () async {
      // Arrange
      when(() => mockDataSource.buryMemory(
            memoryText: any(named: 'memoryText'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          )).thenThrow(NetworkException());

      // Act & Assert
      expect(
        () => repository.buryMemory(
          memoryText: memoryText,
          location: location,
        ),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
```

---

## まとめ

このRepositoryインターフェース設計により、以下が実現されます：

1. ✅ クリーンアーキテクチャに準拠（Domain層でインターフェース定義）
2. ✅ テスタビリティの向上（モック差し替えが容易）
3. ✅ 明確なエラーハンドリング
4. ✅ 包括的なバリデーション
5. ✅ Cloud FunctionsとFirestoreの統合

次のステップでは、これらのRepositoryを使用したPresentation層の実装ガイドを作成します。

