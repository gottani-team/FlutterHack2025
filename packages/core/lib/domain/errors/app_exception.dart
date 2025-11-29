import 'package:equatable/equatable.dart';

/// アプリケーション全体で使用する基底例外クラス
abstract class AppException extends Equatable implements Exception {
  const AppException({
    required this.message,
    this.code,
  });

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => message;
}

/// ネットワーク関連の例外
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
  });
}

/// サーバーエラー
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
  });
}

/// キャッシュ関連の例外
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
  });
}

/// バリデーション例外
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
  });
}

