/// Result型 - 成功または失敗を表現する
///
/// `Either<Failure, Success>` の代わりに使用する独自のResult型。
/// Dart 3.0の sealed class を使用して型安全性を実現。
///
/// **使用例**:
/// ```dart
/// Future<Result<User>> getUser(String id) async {
///   try {
///     final user = await fetchUser(id);
///     return Result.success(user);
///   } catch (e) {
///     return Result.failure(CoreFailure.network(message: e.toString()));
///   }
/// }
///
/// // 使用側
/// final result = await getUser('123');
/// switch (result) {
///   case Success(value: final user):
///     print('User: ${user.name}');
///   case Failure(error: final error):
///     print('Error: ${error.message}');
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// 成功を作成
  factory Result.success(T value) = Success<T>;

  /// 失敗を作成
  factory Result.failure(dynamic error) = Failure<T>;

  /// 成功かどうか
  bool get isSuccess => this is Success<T>;

  /// 失敗かどうか
  bool get isFailure => this is Failure<T>;

  /// 成功の場合は値を返し、失敗の場合はnullを返す
  T? get valueOrNull => switch (this) {
        Success(value: final v) => v,
        Failure() => null,
      };

  /// 失敗の場合はエラーを返し、成功の場合はnullを返す
  dynamic get errorOrNull => switch (this) {
        Success() => null,
        Failure(error: final e) => e,
      };

  /// map: 成功の場合は値を変換し、失敗の場合はそのまま返す
  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success(value: final v) => Result.success(transform(v)),
      Failure(error: final e) => Result.failure(e),
    };
  }

  /// flatMap: 成功の場合は新しいResultを返し、失敗の場合はそのまま返す
  Result<R> flatMap<R>(Result<R> Function(T value) transform) {
    return switch (this) {
      Success(value: final v) => transform(v),
      Failure(error: final e) => Result.failure(e),
    };
  }

  /// when: パターンマッチング風のヘルパーメソッド
  R when<R>({
    required R Function(T value) success,
    required R Function(dynamic error) failure,
  }) {
    return switch (this) {
      Success(value: final v) => success(v),
      Failure(error: final e) => failure(e),
    };
  }
}

/// 成功
final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;

  @override
  String toString() => 'Success($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// 失敗
final class Failure<T> extends Result<T> {
  const Failure(this.error);
  final dynamic error;

  @override
  String toString() => 'Failure($error)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;
}
