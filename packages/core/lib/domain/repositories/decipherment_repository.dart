import '../common/result.dart';
import '../entities/collected_crystal.dart';

/// 解読リポジトリ
///
/// カルマを支払ってクリスタルを解読する。
/// FR-033〜FR-041に対応。
abstract class DeciphermentRepository {
  /// クリスタルを解読
  ///
  /// **Process (Atomic Transaction)**:
  /// 1. クリスタルの `status` が `'available'` か確認
  /// 2. ユーザーの `currentKarma` >= クリスタルの `karmaValue` か確認
  /// 3. ユーザーの `currentKarma` から `karmaValue` を減算
  /// 4. クリスタルの `status` を `'taken'` に変更
  /// 5. クリスタルの `decipheredBy`, `decipheredAt` を設定
  /// 6. `collected_crystals` サブコレクションにコピーを作成
  /// 7. 秘密テキストを返す
  ///
  /// [crystalId]: 解読するクリスタルのID
  /// [userId]: 解読者のUID
  ///
  /// Returns: 解読結果（秘密テキストと収集されたクリスタル）
  ///
  /// Errors:
  /// - InsufficientKarmaFailure: カルマ不足
  /// - AlreadyTakenFailure: すでに他のユーザーに解読された
  /// - NotFoundFailure: クリスタルが見つからない
  Future<Result<DeciphermentResult>> decipher({
    required String crystalId,
    required String userId,
  });
}

/// 解読結果
class DeciphermentResult {
  DeciphermentResult({
    required this.secretText,
    required this.collectedCrystal,
    required this.karmaSpent,
  });

  /// 明かされた秘密テキスト
  final String secretText;

  /// 収集されたクリスタル（ジャーナル用）
  final CollectedCrystal collectedCrystal;

  /// 消費されたカルマ
  final int karmaSpent;
}
