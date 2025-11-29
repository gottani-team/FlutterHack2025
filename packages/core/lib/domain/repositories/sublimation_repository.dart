import '../common/result.dart';
import '../entities/ai_metadata.dart';
import '../entities/crystal.dart';

/// 昇華リポジトリ
///
/// 秘密テキストをカルマに変換し、クリスタルを生成する。
/// FR-013〜FR-021に対応。
///
/// **2段階フロー**:
/// 1. evaluate() - AI評価を実行、ユーザーに結果を表示
/// 2. confirm() - ユーザーが確認後、実際にクリスタルを作成
abstract class SublimationRepository {
  /// Step 1: 秘密テキストをAIで評価（埋める前のプレビュー）
  ///
  /// **Process**:
  /// 1. テキストをGemini AIで解析
  /// 2. emotion type と score (0-100) を取得
  /// 3. 評価結果をユーザーに返す（まだ保存しない）
  ///
  /// [secretText]: 秘密テキスト（10-500文字）
  ///
  /// Returns: AI評価結果（感情タイプ、スコア、獲得予定カルマ）
  ///
  /// Errors:
  /// - ValidationFailure: テキストが10-500文字でない場合
  /// - NetworkFailure: ネットワークエラー
  /// - AIAnalysisFailure: AI解析エラー
  Future<Result<EvaluationResult>> evaluate({
    required String secretText,
  });

  /// Step 2: 評価結果を確認後、クリスタルを作成して埋める
  ///
  /// **Process**:
  /// 1. クリスタルを `crystals` コレクションに作成
  /// 2. ユーザーの `currentKarma` にスコア分を加算
  ///
  /// [secretText]: 秘密テキスト
  /// [evaluation]: Step 1で取得した評価結果
  /// [nickname]: クリスタルに付けるニックネーム
  ///
  /// Returns: 作成されたクリスタルとカルマ情報
  ///
  /// Errors:
  /// - AuthFailure: 未認証の場合
  /// - NetworkFailure: ネットワークエラー
  Future<Result<SublimationResult>> confirm({
    required String secretText,
    required EvaluationResult evaluation,
    required String nickname,
  });
}

/// AI評価結果（Step 1の結果）
///
/// ユーザーに表示して、埋めるかどうかの判断材料とする。
class EvaluationResult {
  EvaluationResult({
    required this.aiMetadata,
    required this.imageUrl,
  });

  /// AI解析メタデータ（感情タイプ、スコア）
  final AIMetadata aiMetadata;

  /// クリスタル画像URL（プレビュー用）
  final String imageUrl;

  /// 獲得予定カルマ（= スコア）
  int get karmaToEarn => aiMetadata.score;

  /// 感情タイプ表示名
  String get emotionDisplayName => aiMetadata.emotionType.displayName;
}

/// 昇華結果（Step 2の結果）
class SublimationResult {
  SublimationResult({
    required this.crystal,
    required this.karmaAwarded,
  });

  /// 生成されたクリスタル
  final Crystal crystal;

  /// 付与されたカルマ
  final int karmaAwarded;

  /// AIメタデータ（クリスタルから取得）
  AIMetadata get aiMetadata => crystal.aiMetadata;
}
