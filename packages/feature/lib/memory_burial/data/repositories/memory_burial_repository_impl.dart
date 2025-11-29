import '../../domain/entities/geo_location.dart';
import '../../domain/entities/memory_burial_entity.dart';
import '../../domain/errors/memory_burial_exceptions.dart';
import '../../domain/repositories/memory_burial_repository.dart';
import '../data_sources/memory_burial_remote_data_source.dart';

/// MemoryBurialRepositoryの実装
class MemoryBurialRepositoryImpl implements MemoryBurialRepository {
  MemoryBurialRepositoryImpl(this._remoteDataSource);

  final MemoryBurialRemoteDataSource _remoteDataSource;

  @override
  Future<MemoryBurialEntity> buryMemory({
    required String memoryText,
    required GeoLocation location,
  }) async {
    // バリデーション
    _validateMemoryText(memoryText);
    _validateLocation(location);

    try {
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
    } on MemoryBurialNetworkException {
      rethrow;
    } on MemoryBurialTimeoutException {
      rethrow;
    } catch (e) {
      throw MemoryBurialServerException('記憶の埋葬に失敗しました: ${e.toString()}');
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
      throw MemoryBurialServerException('埋葬履歴の取得に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<MemoryBurialEntity> getCrystal(String crystalId) async {
    try {
      final model = await _remoteDataSource.getCrystal(crystalId);
      return model.toEntity();
    } catch (e) {
      throw const NotFoundException('クリスタルが見つかりませんでした');
    }
  }

  /// memoryTextのバリデーション
  void _validateMemoryText(String memoryText) {
    if (memoryText.isEmpty) {
      throw const InvalidMemoryTextException('記憶テキストを入力してください');
    }

    if (memoryText.length < 10) {
      throw InvalidMemoryTextException(
        '記憶テキストは10文字以上必要です（現在: ${memoryText.length}文字）',
      );
    }

    if (memoryText.length > 500) {
      throw InvalidMemoryTextException(
        '記憶テキストは500文字以下にしてください（現在: ${memoryText.length}文字）',
      );
    }
  }

  /// locationのバリデーション
  void _validateLocation(GeoLocation location) {
    if (!location.isValid) {
      throw const InvalidLocationException();
    }
  }
}
