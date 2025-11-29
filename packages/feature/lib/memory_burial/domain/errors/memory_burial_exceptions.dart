import 'package:core/domain/errors/app_exception.dart';

/// 記憶テキストが無効
class InvalidMemoryTextException extends AppException {
  const InvalidMemoryTextException(String message)
      : super(message: message, code: 'invalid-memory-text');
}

/// 位置情報が無効
class InvalidLocationException extends AppException {
  const InvalidLocationException()
      : super(
          message: '位置情報が取得できませんでした',
          code: 'invalid-location',
        );
}

/// 位置情報権限が拒否された
class LocationPermissionDeniedException extends AppException {
  const LocationPermissionDeniedException()
      : super(
          message: '位置情報の権限が拒否されました',
          code: 'location-permission-denied',
        );
}

/// 位置情報サービスが無効
class LocationServiceDisabledException extends AppException {
  const LocationServiceDisabledException()
      : super(
          message: '位置情報サービスが無効です',
          code: 'location-service-disabled',
        );
}

/// 重複埋葬エラー
class DuplicateMemoryException extends AppException {
  const DuplicateMemoryException()
      : super(
          message: 'この記憶は既に埋葬されています',
          code: 'duplicate-memory',
        );
}

/// タイムアウトエラー
class MemoryBurialTimeoutException extends AppException {
  const MemoryBurialTimeoutException()
      : super(
          message: 'リクエストがタイムアウトしました',
          code: 'timeout',
        );
}

/// レート制限エラー
class RateLimitException extends AppException {
  const RateLimitException(String message)
      : super(message: message, code: 'rate-limit');
}

/// 認証エラー
class UnauthorizedException extends AppException {
  const UnauthorizedException(String message)
      : super(message: message, code: 'unauthorized');
}

/// 見つからない
class NotFoundException extends AppException {
  const NotFoundException(String message)
      : super(message: message, code: 'not-found');
}

/// Memory Burial専用ネットワークエラー
class MemoryBurialNetworkException extends AppException {
  const MemoryBurialNetworkException()
      : super(
          message: 'ネットワークに接続できませんでした',
          code: 'network-error',
        );
}

/// Memory Burial専用サーバーエラー
class MemoryBurialServerException extends AppException {
  const MemoryBurialServerException([String? message])
      : super(
          message: message ?? 'サーバーエラーが発生しました',
          code: 'server-error',
        );
}
