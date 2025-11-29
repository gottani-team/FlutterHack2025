import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/location.dart';
import '../models/memory_crystal_model.dart';
import '../utils/geohash.dart';

/// Firestore Discovery マイクロサービス
///
/// **役割**: Firestoreからクリスタル情報を取得する
/// **Collection**: `crystals`
///
/// **Features**:
/// - Geohashを使用した効率的な地理空間クエリ
/// - リアルタイムリスナーによるクリスタル発見通知
/// - クライアント側での正確な距離フィルタリング
class FirestoreDiscoveryService {
  FirestoreDiscoveryService(this._firestore);
  final FirebaseFirestore _firestore;

  /// Collection reference for crystals
  CollectionReference<Map<String, dynamic>> get _crystalsRef =>
      _firestore.collection('crystals');

  /// 周辺のクリスタルを検索
  ///
  /// **Algorithm**:
  /// 1. Geohashプレフィックスで大まかにフィルタリング (Firestore query)
  /// 2. クライアント側で正確な距離計算により絞り込み
  ///
  /// [location]: 検索中心位置
  /// [radiusKm]: 検索半径（km）
  /// [limit]: 最大取得件数
  ///
  /// Returns: List of MemoryCrystalModel within the radius
  ///
  /// Throws:
  /// - FirebaseException: Firestore エラー
  Future<List<MemoryCrystalModel>> findNearby({
    required Location location,
    required double radiusKm,
    int limit = 50,
  }) async {
    // Step 1: Geohash prefix queryでFirestoreから大まかに絞り込み
    final geohashPrefixes = GeohashUtil.getNeighborPrefixes(
      location,
      precision: 4, // 約39km四方 - radius内を確実にカバー
    );

    // Firestoreの制限により、最初の10個のprefixのみ使用（where IN は10個まで）
    final queryPrefixes = geohashPrefixes.take(10).toList();

    QuerySnapshot<Map<String, dynamic>> snapshot;
    if (queryPrefixes.isEmpty) {
      // Fallback: prefixなしで全件取得（通常はここには来ない）
      snapshot = await _crystalsRef.limit(limit).get();
    } else {
      // Geohash prefix で絞り込み
      snapshot = await _crystalsRef
          .where('geohash', whereIn: queryPrefixes)
          .limit(limit * 2) // 余裕を持って取得（後でフィルタするため）
          .get();
    }

    // Step 2: クライアント側で正確な距離計算
    final allCrystals = snapshot.docs
        .map((doc) => MemoryCrystalModel.fromFirestore(doc))
        .toList();

    final nearbyCrystals = allCrystals
        .where((crystal) {
          final crystalLocation = Location(
            latitude: crystal.location.latitude,
            longitude: crystal.location.longitude,
          );
          return crystalLocation.distanceTo(location) <= radiusKm;
        })
        .take(limit)
        .toList();

    return nearbyCrystals;
  }

  /// 特定IDのクリスタルを取得
  ///
  /// [id]: Crystal document ID
  ///
  /// Returns: MemoryCrystalModel
  ///
  /// Throws:
  /// - FirebaseException: Document not found or Firestore error
  Future<MemoryCrystalModel> getCrystalById(String id) async {
    final doc = await _crystalsRef.doc(id).get();

    if (!doc.exists) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'not-found',
        message: 'Crystal with id $id does not exist',
      );
    }

    return MemoryCrystalModel.fromFirestore(doc);
  }

  /// 周辺クリスタルの変更をリアルタイムで監視
  ///
  /// **Note**: Firestoreのリアルタイムリスナーを使用。
  /// クライアント側で距離フィルタリングを行う。
  ///
  /// [location]: 監視中心位置
  /// [radiusKm]: 監視半径（km）
  /// [limit]: 最大取得件数
  ///
  /// Returns: Stream of List<`MemoryCrystalModel`>
  ///
  /// Emits:
  /// - 初回: 現在の周辺クリスタル
  /// - 変更時: 新しいクリスタルが作成された、または採掘された
  Future<Stream<List<MemoryCrystalModel>>> watchNearby({
    required Location location,
    required double radiusKm,
    int limit = 50,
  }) async {
    final geohashPrefixes = GeohashUtil.getNeighborPrefixes(
      location,
      precision: 4,
    );

    final queryPrefixes = geohashPrefixes.take(10).toList();

    Stream<QuerySnapshot<Map<String, dynamic>>> stream;
    if (queryPrefixes.isEmpty) {
      stream = _crystalsRef.limit(limit).snapshots();
    } else {
      stream = _crystalsRef
          .where('geohash', whereIn: queryPrefixes)
          .limit(limit * 2)
          .snapshots();
    }

    return stream.map((snapshot) {
      final allCrystals = snapshot.docs
          .map((doc) => MemoryCrystalModel.fromFirestore(doc))
          .toList();

      final nearbyCrystals = allCrystals
          .where((crystal) {
            final crystalLocation = Location(
              latitude: crystal.location.latitude,
              longitude: crystal.location.longitude,
            );
            return crystalLocation.distanceTo(location) <= radiusKm;
          })
          .take(limit)
          .toList();

      return nearbyCrystals;
    });
  }
}
