/// クリスタルの状態を表す列挙型
///
/// クリスタルが解読可能か、すでに解読済みかを表現する。
enum CrystalStatus {
  /// 利用可能（解読可能）
  available,

  /// 取得済み（解読済み）
  taken;

  /// JSON シリアライズ用の文字列に変換
  String toJson() => name;

  /// JSON デシリアライズ - 文字列から CrystalStatus を復元
  static CrystalStatus fromJson(String json) {
    return CrystalStatus.values.firstWhere(
      (e) => e.name == json,
      orElse: () => CrystalStatus.available,
    );
  }

  /// 日本語表示名を取得
  String get displayName {
    switch (this) {
      case CrystalStatus.available:
        return '解読可能';
      case CrystalStatus.taken:
        return '解読済み';
    }
  }
}
