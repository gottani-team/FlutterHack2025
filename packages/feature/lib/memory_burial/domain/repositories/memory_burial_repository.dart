import 'package:core/domain/repositories/base_repository.dart';

import '../entities/geo_location.dart';
import '../entities/memory_burial_entity.dart';

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
  /// - [MemoryBurialNetworkException] ネットワークエラー
  /// - [MemoryBurialServerException] サーバーエラー
  /// - [MemoryBurialTimeoutException] タイムアウト
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
