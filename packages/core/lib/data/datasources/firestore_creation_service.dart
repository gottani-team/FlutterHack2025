import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/emotion_type.dart';
import '../../domain/entities/location.dart';
import '../models/memory_crystal_model.dart';
import '../utils/geohash.dart';

/// Firestore Creation マイクロサービス
///
/// **役割**: Firestoreへクリスタル情報を書き込む
/// **Collection**: `crystals`
///
/// **Features**:
/// - クリスタルの新規作成
/// - Geohash自動計算
/// - サーバータイムスタンプ使用
/// - 作成履歴の取得
class FirestoreCreationService {
  FirestoreCreationService(this._firestore);
  final FirebaseFirestore _firestore;

  /// Collection reference for crystals
  CollectionReference<Map<String, dynamic>> get _crystalsRef =>
      _firestore.collection('crystals');

  /// 新しいクリスタルを作成
  ///
  /// **Algorithm**:
  /// 1. Geohashを計算
  /// 2. MemoryCrystalModelを作成
  /// 3. Firestoreに保存（自動でdocument IDが生成される）
  /// 4. 作成されたクリスタルを返す
  ///
  /// [text]: 記憶テキスト
  /// [location]: GPS位置
  /// [emotion]: 感情タイプ（AI判定済み）
  /// [userId]: 作成者ID
  ///
  /// Returns: 作成されたMemoryCrystalModel
  ///
  /// Throws:
  /// - FirebaseException: Firestore エラー
  ///
  /// **Note**: emotionはRepositoryレイヤーでAI判定されたものを受け取る
  Future<MemoryCrystalModel> createCrystal({
    required String text,
    required Location location,
    required EmotionType emotion,
    required String userId,
  }) async {
    // Geohashを計算
    final geohash = GeohashUtil.encode(location, precision: 5);

    // GeoPointに変換
    final geoPoint = GeoPoint(location.latitude, location.longitude);

    // Firestore document referenceを作成（自動生成ID）
    final docRef = _crystalsRef.doc();

    // データを準備
    final data = {
      'location': geoPoint,
      'geohash': geohash,
      'emotion': emotion.toJson(),
      'creatorId': userId,
      'createdAt': FieldValue.serverTimestamp(), // サーバータイムスタンプ
      'isExcavated': false,
      'text': text,
      'excavatedBy': null,
      'excavatedAt': null,
    };

    // Firestoreに保存
    await docRef.set(data);

    // 保存されたドキュメントを取得
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'not-found',
        message: 'Created crystal not found',
      );
    }

    return MemoryCrystalModel.fromFirestore(snapshot);
  }

  /// 特定ユーザーが作成したクリスタルを取得
  ///
  /// [userId]: 作成者ID
  /// [limit]: 最大取得件数
  ///
  /// Returns: List of MemoryCrystalModel（作成日時降順）
  ///
  /// Throws:
  /// - FirebaseException: Firestore エラー
  Future<List<MemoryCrystalModel>> getCreatedCrystals({
    required String userId,
    int limit = 50,
  }) async {
    final snapshot = await _crystalsRef
        .where('creatorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => MemoryCrystalModel.fromFirestore(doc))
        .toList();
  }
}
