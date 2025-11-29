import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/memory_crystal_model.dart';

/// Firestore Excavation マイクロサービス
///
/// **役割**: Firestoreでクリスタルの採掘処理を実行する
/// **Collection**: `crystals`
///
/// **Features**:
/// - Transactionによる原子的な採掘処理
/// - 採掘可能性のチェック
/// - 競合防止
class FirestoreExcavationService {
  final FirebaseFirestore _firestore;

  /// Collection reference for crystals
  CollectionReference<Map<String, dynamic>> get _crystalsRef =>
      _firestore.collection('crystals');

  FirestoreExcavationService(this._firestore);

  /// クリスタルを採掘する（Transaction使用）
  ///
  /// **Algorithm**:
  /// 1. Transactionを開始
  /// 2. クリスタルを取得
  /// 3. 採掘可能性をチェック（作成者でない、未採掘）
  /// 4. isExcavated, excavatedBy, excavatedAt を更新
  /// 5. Transactionをコミット
  ///
  /// [crystalId]: 採掘するクリスタルのID
  /// [userId]: 採掘者のユーザーID
  ///
  /// Returns: 採掘後のMemoryCrystalModel
  ///
  /// Throws:
  /// - FirebaseException: クリスタルが存在しない、または採掘不可
  /// - Exception: 採掘条件を満たさない場合
  Future<MemoryCrystalModel> excavateCrystal({
    required String crystalId,
    required String userId,
  }) async {
    final docRef = _crystalsRef.doc(crystalId);

    // Transactionで採掘処理を実行
    return await _firestore.runTransaction<MemoryCrystalModel>(
      (transaction) async {
        // Step 1: クリスタルを取得
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw FirebaseException(
            plugin: 'firestore',
            code: 'not-found',
            message: 'Crystal with id $crystalId does not exist',
          );
        }

        // Step 2: データを解析
        final data = snapshot.data();
        if (data == null) {
          throw Exception('Crystal data is null');
        }

        final creatorId = data['creatorId'] as String;
        final isExcavated = data['isExcavated'] as bool? ?? false;

        // Step 3: 採掘可能性をチェック
        if (creatorId == userId) {
          throw Exception(
            'Cannot excavate own crystal (creator: $creatorId, user: $userId)',
          );
        }

        if (isExcavated) {
          throw Exception('Crystal already excavated');
        }

        // Step 4: 採掘データを更新
        transaction.update(docRef, {
          'isExcavated': true,
          'excavatedBy': userId,
          'excavatedAt': FieldValue.serverTimestamp(),
        });

        // Step 5: 更新後のドキュメントを再取得（Transactionの外で）
        // Note: Transaction内では更新後の値を直接取得できないため、
        // データを手動で構築して返す
        final updatedData = {
          ...data,
          'isExcavated': true,
          'excavatedBy': userId,
          'excavatedAt': Timestamp.now(), // 近似値（実際はサーバータイムスタンプ）
        };

        return MemoryCrystalModel.fromJson({
          'id': crystalId,
          ...updatedData,
        });
      },
    );
  }

  /// クリスタルが採掘可能かチェック
  ///
  /// [crystalId]: チェックするクリスタルのID
  /// [userId]: チェックするユーザーID
  ///
  /// Returns: true = 採掘可能、false = 採掘不可
  ///
  /// Throws:
  /// - FirebaseException: クリスタルが存在しない
  Future<bool> canExcavateCrystal({
    required String crystalId,
    required String userId,
  }) async {
    final snapshot = await _crystalsRef.doc(crystalId).get();

    if (!snapshot.exists) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'not-found',
        message: 'Crystal with id $crystalId does not exist',
      );
    }

    final data = snapshot.data();
    if (data == null) {
      return false;
    }

    final creatorId = data['creatorId'] as String;
    final isExcavated = data['isExcavated'] as bool? ?? false;

    // 自分が作成していない、かつ未採掘の場合のみ採掘可能
    return creatorId != userId && !isExcavated;
  }
}
