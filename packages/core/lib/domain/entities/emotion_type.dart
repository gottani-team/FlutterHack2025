/// 感情タイプの列挙型
///
/// クリスタルの感情分類を表現する4つの基本タイプ。
/// AI分析によって記憶テキストから判定される。
enum EmotionType {
  /// 情熱（赤系）- 熱い感情、興奮、エネルギー
  passion,

  /// 静寂（青系）- 落ち着き、平穏、瞑想
  silence,

  /// 喜び（黄系）- 幸福、楽しさ、ポジティブ
  joy,

  /// 癒やし（緑系）- 安らぎ、回復、優しさ
  healing;

  /// 日本語表示名を取得
  String get displayName {
    switch (this) {
      case EmotionType.passion:
        return '情熱';
      case EmotionType.silence:
        return '静寂';
      case EmotionType.joy:
        return '喜び';
      case EmotionType.healing:
        return '癒やし';
    }
  }

  /// JSON シリアライズ用の文字列に変換
  String toJson() => name;

  /// JSON デシリアライズ - 文字列から EmotionType を復元
  static EmotionType fromJson(String json) {
    return EmotionType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => EmotionType.healing, // デフォルトは healing
    );
  }
}
