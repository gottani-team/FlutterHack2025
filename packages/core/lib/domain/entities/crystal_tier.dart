/// クリスタルのTier（カルマ値に基づく希少度）
enum CrystalTier {
  /// 石（カルマ ~100）
  stone,

  /// 黒曜石（カルマ ~1000）
  obsidian,

  /// 銅（カルマ ~5000）
  copper,

  /// 銀（カルマ ~10000）
  silver,

  /// 金（カルマ ~25000）
  gold,

  /// クリスタル（カルマ 25000~）
  crystal;

  /// カルマ値からTierを取得
  static CrystalTier fromKarmaValue(int karmaValue) {
    if (karmaValue >= 25000) return CrystalTier.crystal;
    if (karmaValue >= 10000) return CrystalTier.gold;
    if (karmaValue >= 5000) return CrystalTier.silver;
    if (karmaValue >= 1000) return CrystalTier.copper;
    if (karmaValue >= 100) return CrystalTier.obsidian;
    return CrystalTier.stone;
  }

  /// 表示名
  String get displayName {
    return switch (this) {
      CrystalTier.stone => '石',
      CrystalTier.obsidian => '黒曜石',
      CrystalTier.copper => '銅',
      CrystalTier.silver => '銀',
      CrystalTier.gold => '金',
      CrystalTier.crystal => 'クリスタル',
    };
  }
}
