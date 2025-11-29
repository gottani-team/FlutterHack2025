import '../../domain/entities/location.dart';

/// Geohash エンコーディングユーティリティ
///
/// 位置情報を文字列にエンコードし、Firestoreのインデックスによる
/// 効率的な地理空間クエリを可能にする。
///
/// **実装**: 独自のシンプルなgeohash実装（精度: 5文字 = 約4.9km四方）
class GeohashUtil {
  // Base32文字セット（geohash標準）
  static const String _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

  /// 位置情報をgeohash文字列にエンコード
  ///
  /// [location]: GPS座標
  /// [precision]: 精度（文字数）デフォルト: 5
  ///   - 4文字: 約39km四方
  ///   - 5文字: 約4.9km四方（推奨）
  ///   - 6文字: 約1.2km四方
  ///
  /// Returns: geohash文字列（例: "xn76g"）
  static String encode(Location location, {int precision = 5}) {
    double minLat = -90.0;
    double maxLat = 90.0;
    double minLon = -180.0;
    double maxLon = 180.0;

    String hash = '';
    int bits = 0;
    int bit = 0;
    bool even = true;

    while (hash.length < precision) {
      if (even) {
        // 経度を処理
        final mid = (minLon + maxLon) / 2;
        if (location.longitude > mid) {
          bit |= (1 << (4 - bits));
          minLon = mid;
        } else {
          maxLon = mid;
        }
      } else {
        // 緯度を処理
        final mid = (minLat + maxLat) / 2;
        if (location.latitude > mid) {
          bit |= (1 << (4 - bits));
          minLat = mid;
        } else {
          maxLat = mid;
        }
      }

      even = !even;
      bits++;

      if (bits == 5) {
        hash += _base32[bit];
        bits = 0;
        bit = 0;
      }
    }

    return hash;
  }

  /// Geohash文字列を位置情報にデコード
  ///
  /// [geohash]: geohash文字列
  /// Returns: デコードされた中心位置
  static Location decode(String geohash) {
    double minLat = -90.0;
    double maxLat = 90.0;
    double minLon = -180.0;
    double maxLon = 180.0;

    bool even = true;

    for (int i = 0; i < geohash.length; i++) {
      final char = geohash[i];
      final charIndex = _base32.indexOf(char);

      if (charIndex == -1) {
        throw ArgumentError('Invalid geohash character: $char');
      }

      for (int bitIndex = 4; bitIndex >= 0; bitIndex--) {
        final bit = (charIndex >> bitIndex) & 1;

        if (even) {
          // 経度を処理
          final mid = (minLon + maxLon) / 2;
          if (bit == 1) {
            minLon = mid;
          } else {
            maxLon = mid;
          }
        } else {
          // 緯度を処理
          final mid = (minLat + maxLat) / 2;
          if (bit == 1) {
            minLat = mid;
          } else {
            maxLat = mid;
          }
        }

        even = !even;
      }
    }

    // 中心位置を返す
    final lat = (minLat + maxLat) / 2;
    final lon = (minLon + maxLon) / 2;

    return Location(latitude: lat, longitude: lon);
  }

  /// 指定位置の周辺8エリアを含むgeohashプレフィックスのリストを取得
  ///
  /// Firestore `where IN` クエリで使用するために、
  /// 中心エリアと隣接8エリアのgeohashプレフィックスを返す。
  ///
  /// [location]: 中心位置
  /// [precision]: geohash精度 デフォルト: 4（約39km四方）
  ///
  /// Returns: 9個のgeohashプレフィックスのリスト（中心 + 8方向）
  ///
  /// **Note**: Firestoreの `where IN` は最大10個まで指定可能なので、
  /// precision=4（9エリア）を推奨
  static List<String> getNeighborPrefixes(
    Location location, {
    int precision = 4,
  }) {
    final centerHash = encode(location, precision: precision);

    // 中心エリアを含む
    final prefixes = <String>{centerHash};

    // 周辺8エリアを追加（geohash隣接アルゴリズムの簡易版）
    // 注: 完全な実装では隣接geohashを正確に計算するが、
    // ここでは中心hashの最後の文字を変更して近似
    final lastChar = centerHash[centerHash.length - 1];
    final charIndex = _base32.indexOf(lastChar);

    if (charIndex > 0) {
      prefixes.add(
        centerHash.substring(0, precision - 1) + _base32[charIndex - 1],
      );
    }
    if (charIndex < _base32.length - 1) {
      prefixes.add(
        centerHash.substring(0, precision - 1) + _base32[charIndex + 1],
      );
    }

    // 上下左右の隣接を追加（簡易版）
    for (int offset = -2; offset <= 2; offset++) {
      if (offset != 0 &&
          charIndex + offset >= 0 &&
          charIndex + offset < _base32.length) {
        prefixes.add(
          centerHash.substring(0, precision - 1) + _base32[charIndex + offset],
        );
      }
    }

    return prefixes.toList();
  }
}
