import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/common/result.dart';
import '../../domain/entities/collected_crystal.dart';
import '../../domain/failures/core_failure.dart';
import '../../domain/repositories/decipherment_repository.dart';
import '../models/collected_crystal_model.dart';
import '../models/crystal_model.dart';

/// 解読リポジトリの実装
class DeciphermentRepositoryImpl implements DeciphermentRepository {
  DeciphermentRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _crystalsRef =>
      _firestore.collection('crystals');

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  @override
  Future<Result<DeciphermentResult>> decipher({
    required String crystalId,
    required String userId,
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        // 1. クリスタルを取得
        final crystalDoc = await transaction.get(_crystalsRef.doc(crystalId));

        if (!crystalDoc.exists) {
          throw const CoreFailure.notFound(
            message: 'Crystal not found',
          );
        }

        final crystalModel = CrystalModel.fromFirestore(crystalDoc);

        // 2. ステータスチェック
        if (crystalModel.status != 'available') {
          throw const CoreFailure.alreadyTaken(
            message: 'Crystal has already been deciphered',
          );
        }

        // 3. ユーザーのカルマをチェック
        final userDoc = await transaction.get(_usersRef.doc(userId));

        if (!userDoc.exists) {
          throw const CoreFailure.notFound(
            message: 'User not found',
          );
        }

        final currentKarma =
            (userDoc.data()?['current_karma'] as num?)?.toInt() ?? 0;
        final karmaCost = crystalModel.karmaValue;

        if (currentKarma < karmaCost) {
          throw CoreFailure.insufficientKarma(
            message: 'Insufficient karma to decipher this crystal',
            required: karmaCost,
            available: currentKarma,
          );
        }

        // 4. トランザクション内で更新
        final now = Timestamp.now();

        // デバッグ: 現在のクリスタルデータを確認
        dev.log('=== Decipher Transaction Debug ===');
        dev.log('Crystal ID: $crystalId');
        dev.log('User ID: $userId');
        dev.log('Current crystal data: ${crystalDoc.data()}');

        // 更新するデータを準備
        final updateData = {
          'status': 'taken',
          'deciphered_by': userId,
          'deciphered_at': now,
        };
        dev.log('Update data to send: $updateData');

        // ユーザーのカルマを減算
        transaction.update(_usersRef.doc(userId), {
          'current_karma': currentKarma - karmaCost,
        });

        // クリスタルのステータスを更新
        // Note: build.yamlのfield_rename: snakeに合わせてsnake_caseを使用
        transaction.update(_crystalsRef.doc(crystalId), updateData);

        // collected_crystals サブコレクションに追加
        final collectedCrystalModel = CollectedCrystalModel(
          id: crystalId,
          secretText: crystalModel.secretText,
          karmaCost: karmaCost,
          aiMetadata: crystalModel.aiMetadata,
          decipheredAt: now,
          originalCreatorId: crystalModel.createdBy,
          originalCreatorNickname: crystalModel.creatorNickname,
        );

        transaction.set(
          _usersRef.doc(userId).collection('collected_crystals').doc(crystalId),
          collectedCrystalModel.toFirestore(),
        );

        // 結果を返す
        final collectedCrystal = CollectedCrystal(
          id: crystalId,
          secretText: crystalModel.secretText,
          karmaCost: karmaCost,
          aiMetadata: crystalModel.aiMetadata.toEntity(),
          decipheredAt: now.toDate(),
          originalCreatorId: crystalModel.createdBy,
          originalCreatorNickname: crystalModel.creatorNickname,
        );

        return Result.success(
          DeciphermentResult(
            secretText: crystalModel.secretText,
            collectedCrystal: collectedCrystal,
            karmaSpent: karmaCost,
          ),
        );
      });
    } on CoreFailure catch (e) {
      return Result.failure(e);
    } on FirebaseException catch (e) {
      return Result.failure(
        CoreFailure.network(
          message: e.message ?? 'Failed to decipher crystal',
          code: e.code,
        ),
      );
    } catch (e) {
      return Result.failure(
        CoreFailure.unknown(
          message: 'Failed to decipher crystal: ${e.toString()}',
        ),
      );
    }
  }
}
