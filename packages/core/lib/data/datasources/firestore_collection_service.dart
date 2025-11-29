import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/memory_crystal_model.dart';

/// Firestore Collection マイクロサービス
///
/// **役割**: Firestoreからコレクション情報を取得する
/// **Collection**: `crystals`
///
/// **Features**:
/// - 採掘済みクリスタルの取得
/// - リアルタイムリスナー
class FirestoreCollectionService {
  FirestoreCollectionService(this._firestore);
  final FirebaseFirestore _firestore;

  /// Collection reference for crystals
  CollectionReference<Map<String, dynamic>> get _crystalsRef =>
      _firestore.collection('crystals');

  /// ユーザーが採掘したクリスタルを取得
  ///
  /// **Query**:
  /// - where: excavatedBy == userId
  /// - orderBy: excavatedAt descending
  ///
  /// [userId]: ユーザーID
  /// [limit]: 最大取得件数
  ///
  /// Returns: List of MemoryCrystalModel（採掘日時降順）
  ///
  /// Throws:
  /// - FirebaseException: Firestore エラー
  Future<List<MemoryCrystalModel>> getExcavatedCrystals({
    required String userId,
    int limit = 50,
  }) async {
    final snapshot = await _crystalsRef
        .where('excavatedBy', isEqualTo: userId)
        .orderBy('excavatedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => MemoryCrystalModel.fromFirestore(doc))
        .toList();
  }

  /// ユーザーが採掘したクリスタルをリアルタイムで監視
  ///
  /// **Query**:
  /// - where: excavatedBy == userId
  /// - orderBy: excavatedAt descending
  ///
  /// [userId]: ユーザーID
  /// [limit]: 最大取得件数
  ///
  /// Returns: Stream of `List<MemoryCrystalModel>`
  ///
  /// Emits:
  /// - 初回: 現在の採掘済みクリスタル
  /// - 変更時: 新しいクリスタルを採掘した時
  Future<Stream<List<MemoryCrystalModel>>> watchExcavatedCrystals({
    required String userId,
    int limit = 50,
  }) async {
    return _crystalsRef
        .where('excavatedBy', isEqualTo: userId)
        .orderBy('excavatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MemoryCrystalModel.fromFirestore(doc))
          .toList();
    });
  }
}
