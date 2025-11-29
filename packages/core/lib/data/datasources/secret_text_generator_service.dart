import 'dart:developer' as dev;

import 'package:firebase_ai/firebase_ai.dart';

import '../../domain/entities/emotion_type.dart';

/// 秘密テキスト生成サービス
///
/// Firebase AI Logic (Gemini) を使用して指定された感情タイプと
/// カルマ値に基づいて秘密テキストを生成する（デバッグ用）。
class SecretTextGeneratorService {
  SecretTextGeneratorService();

  /// 指定された感情タイプとカルマ値に基づいて秘密テキストを生成
  ///
  /// [emotionType]: 生成する秘密の感情タイプ
  /// [targetKarma]: 目標カルマ値（0-100）
  ///
  /// Returns: 生成された秘密テキスト
  Future<String> generate({
    required EmotionType emotionType,
    required int targetKarma,
  }) async {
    dev.log(
      '[SecretTextGenerator] generate: emotion=${emotionType.name}, karma=$targetKarma',
    );

    final prompt = _buildPrompt(emotionType, targetKarma);

    // Firebase AI で秘密テキストを生成
    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
    );

    final response = await model.generateContent([
      Content.text(prompt),
    ]);

    final responseText = response.text;
    if (responseText == null || responseText.isEmpty) {
      dev.log('[SecretTextGenerator] ERROR: Empty response from AI');
      throw Exception('Empty response from AI');
    }

    // 余分な引用符や改行を削除
    final cleanedText = responseText
        .trim()
        .replaceAll(RegExp(r'^[「"\']+'), '')
        .replaceAll(RegExp(r'[」"\']+$'), '')
        .trim();

    dev.log('[SecretTextGenerator] Generated: $cleanedText');

    return cleanedText;
  }

  /// プロンプトを構築
  String _buildPrompt(EmotionType emotionType, int targetKarma) {
    final emotionDescription = _getEmotionDescription(emotionType);
    final intensityDescription = _getIntensityDescription(targetKarma);

    return '''
あなたは日本語で秘密を告白する人になりきってください。
以下の条件に基づいて、誰にも言えない秘密の文章を1つだけ生成してください。

【条件】
- 感情タイプ: ${emotionType.displayName} ($emotionDescription)
- 感情の強度: $intensityDescription (目標スコア: $targetKarma/100)
- 文字数: 50〜150文字程度
- 一人称で書く
- リアルで共感できる内容にする
- 具体的なエピソードを含める

【出力形式】
秘密の文章のみを出力してください。説明や前置きは不要です。
''';
  }

  /// 感情タイプの説明を取得
  String _getEmotionDescription(EmotionType emotionType) {
    switch (emotionType) {
      case EmotionType.happiness:
        return '喜び、幸福感、嬉しい出来事';
      case EmotionType.enjoyment:
        return '楽しさ、ワクワク、面白い体験';
      case EmotionType.relief:
        return '安心、ホッとする感覚、癒し';
      case EmotionType.anticipation:
        return '期待、希望、夢、願い';
      case EmotionType.sadness:
        return '悲しみ、喪失感、寂しさ';
      case EmotionType.embarrassment:
        return '恥ずかしさ、羞恥、黒歴史';
      case EmotionType.anger:
        return '怒り、憤り、イライラ';
      case EmotionType.emptiness:
        return '虚しさ、空虚感、無力感';
    }
  }

  /// カルマ値に基づく強度の説明を取得
  String _getIntensityDescription(int karma) {
    if (karma >= 80) {
      return '非常に深刻で重い秘密。人生を変えるような出来事。一生誰にも言えないレベル';
    } else if (karma >= 60) {
      return '重要な秘密。長年心に秘めてきた。親しい人にも言いづらい';
    } else if (karma >= 40) {
      return '中程度の秘密。少し恥ずかしいが、いつか話せるかもしれない';
    } else if (karma >= 20) {
      return '軽い秘密。ちょっとした出来事だが、まだ誰にも話していない';
    } else {
      return 'とても軽い秘密。日常のささいな出来事';
    }
  }
}
