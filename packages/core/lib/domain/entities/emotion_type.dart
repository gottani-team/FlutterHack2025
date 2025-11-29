/// 感情タイプの列挙型
///
/// クリスタルの感情分類を表現する8つの基本タイプ。
/// AI分析によって秘密テキストから判定される。
enum EmotionType {
  /// 嬉しさ（ピンク系）- 喜び、幸福感
  happiness,

  /// 楽しさ（オレンジ系）- 楽しみ、ワクワク
  enjoyment,

  /// 安心（緑系）- 安らぎ、ホッとする感覚
  relief,

  /// 期待（黄系）- 希望、待ち望む気持ち
  anticipation,

  /// 悲しみ（青系）- 哀しみ、喪失感
  sadness,

  /// 恥ずかしさ（紫系）- 羞恥、照れ
  embarrassment,

  /// 怒り（赤系）- 憤り、フラストレーション
  anger,

  /// 虚しさ（灰系）- 空虚、無力感
  emptiness;

  /// 日本語表示名を取得
  String get displayName {
    switch (this) {
      case EmotionType.happiness:
        return '嬉しさ';
      case EmotionType.enjoyment:
        return '楽しさ';
      case EmotionType.relief:
        return '安心';
      case EmotionType.anticipation:
        return '期待';
      case EmotionType.sadness:
        return '悲しみ';
      case EmotionType.embarrassment:
        return '恥ずかしさ';
      case EmotionType.anger:
        return '怒り';
      case EmotionType.emptiness:
        return '虚しさ';
    }
  }

  /// 英語表示名を取得
  String get displayNameEn {
    switch (this) {
      case EmotionType.happiness:
        return 'Happiness';
      case EmotionType.enjoyment:
        return 'Enjoyment';
      case EmotionType.relief:
        return 'Relief';
      case EmotionType.anticipation:
        return 'Anticipation';
      case EmotionType.sadness:
        return 'Sadness';
      case EmotionType.embarrassment:
        return 'Embarrassment';
      case EmotionType.anger:
        return 'Anger';
      case EmotionType.emptiness:
        return 'Emptiness';
    }
  }

  /// クリスタルカラーを取得（HEX）
  int get colorHex {
    switch (this) {
      case EmotionType.happiness:
        return 0xFFFDAB9A; // ピンク
      case EmotionType.enjoyment:
        return 0xFFFFE17C; // オレンジ
      case EmotionType.relief:
        return 0xFFB8FB5A; // 緑
      case EmotionType.anticipation:
        return 0xFF5ADEFB; // 黄
      case EmotionType.sadness:
        return 0xFF855AFB; // 青
      case EmotionType.embarrassment:
        return 0xFFFB5AE9; // 紫
      case EmotionType.anger:
        return 0xFFFB5A5D; // 赤
      case EmotionType.emptiness:
        return 0xFF878787; // 灰
    }
  }

  /// JSON シリアライズ用の文字列に変換
  String toJson() => name;

  /// JSON デシリアライズ - 文字列から EmotionType を復元
  static EmotionType fromJson(String json) {
    return EmotionType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => EmotionType.emptiness, // デフォルトは emptiness
    );
  }
}
