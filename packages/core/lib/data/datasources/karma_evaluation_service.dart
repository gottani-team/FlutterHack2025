import 'dart:convert';
import 'dart:developer' as dev;

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:mustache_template/mustache_template.dart';

import '../../domain/entities/ai_metadata.dart';
import '../../domain/entities/emotion_type.dart';

/// カルマ評価サービス
///
/// Firebase AI Logic (Gemini) を使用して秘密テキストを評価し、
/// 感情タイプとスコアを算出する。
class KarmaEvaluationService {
  KarmaEvaluationService({
    FirebaseRemoteConfig? remoteConfig,
  }) : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _remoteConfig;

  /// Remote Config のキー名
  static const String _promptKey = 'evaluate_karma_point_system';
  static const String _modelsKey = 'models';

  /// 秘密テキストをAIで評価
  ///
  /// [secretText]: 評価対象のテキスト
  ///
  /// Returns: 評価結果（感情タイプとスコア）
  Future<AIMetadata> evaluate(String secretText) async {
    dev.log('[KarmaEvaluationService] evaluate: textLength=${secretText.length}');

    // Remote Config からプロンプトとモデル名を取得
    final promptTemplate = _remoteConfig.getString(_promptKey);
    if (promptTemplate.isEmpty) {
      dev.log('[KarmaEvaluationService] WARNING: Prompt template is empty');
      throw Exception('Karma evaluation prompt not configured in Remote Config');
    }

    final modelsJson = _remoteConfig.getString(_modelsKey);
    final modelsMap = modelsJson.isNotEmpty
        ? json.decode(modelsJson) as Map<String, dynamic>
        : <String, dynamic>{};
    final modelName = modelsMap['evaluateKarma'] as String? ?? 'gemini-2.5-flash';

    dev.log('[KarmaEvaluationService] Using model: $modelName');

    // Mustache テンプレートをレンダリング
    final renderedPrompt = Template(promptTemplate).renderString({
      'secretText': secretText,
    });

    dev.log('[KarmaEvaluationService] Rendered prompt length: ${renderedPrompt.length}');

    // Firebase AI で評価を実行
    final model = FirebaseAI.googleAI().generativeModel(model: modelName);

    final response = await model.generateContent([
      Content.text(renderedPrompt),
    ]);

    final responseText = response.text;
    if (responseText == null || responseText.isEmpty) {
      dev.log('[KarmaEvaluationService] ERROR: Empty response from AI');
      throw Exception('Empty response from AI');
    }

    dev.log('[KarmaEvaluationService] AI response: $responseText');

    // レスポンスをパース
    return _parseResponse(responseText);
  }

  /// AIレスポンスをパースしてAIMetadataを生成
  ///
  /// 期待されるJSON形式:
  /// ```json
  /// {
  ///   "emotion": "happiness",
  ///   "score": 75
  /// }
  /// ```
  AIMetadata _parseResponse(String responseText) {
    try {
      // JSON部分を抽出（マークダウンコードブロックを考慮）
      final jsonStr = _extractJson(responseText);
      final parsed = json.decode(jsonStr) as Map<String, dynamic>;

      final emotionStr = parsed['emotion'] as String? ?? 'emptiness';
      final score = (parsed['score'] as num?)?.toInt() ?? 50;

      final emotionType = EmotionType.fromJson(emotionStr);
      final clampedScore = score.clamp(0, 100);

      dev.log('[KarmaEvaluationService] Parsed: emotion=$emotionType, score=$clampedScore');

      return AIMetadata(
        emotionType: emotionType,
        score: clampedScore,
      );
    } catch (e) {
      dev.log('[KarmaEvaluationService] ERROR parsing response: $e');
      dev.log('[KarmaEvaluationService] Raw response: $responseText');

      // パースに失敗した場合はデフォルト値を返す
      return const AIMetadata(
        emotionType: EmotionType.emptiness,
        score: 50,
      );
    }
  }

  /// JSONを抽出（マークダウンコードブロックやテキストの中から）
  String _extractJson(String text) {
    // マークダウンのJSONコードブロックを検出
    final jsonBlockPattern = RegExp(r'```json\s*([\s\S]*?)\s*```');
    final jsonBlockMatch = jsonBlockPattern.firstMatch(text);
    if (jsonBlockMatch != null) {
      return jsonBlockMatch.group(1)!.trim();
    }

    // 通常のコードブロックを検出
    final codeBlockPattern = RegExp(r'```\s*([\s\S]*?)\s*```');
    final codeBlockMatch = codeBlockPattern.firstMatch(text);
    if (codeBlockMatch != null) {
      return codeBlockMatch.group(1)!.trim();
    }

    // { } で囲まれたJSON部分を検出
    final jsonPattern = RegExp(r'\{[\s\S]*\}');
    final jsonMatch = jsonPattern.firstMatch(text);
    if (jsonMatch != null) {
      return jsonMatch.group(0)!;
    }

    // そのまま返す
    return text.trim();
  }
}
