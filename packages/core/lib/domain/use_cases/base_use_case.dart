import 'package:equatable/equatable.dart';

/// ユースケースの基底クラス
abstract class UseCase<TResult, TParams> {
  const UseCase();
  Future<TResult> call(TParams params);
}

/// パラメータなしのユースケース
abstract class UseCaseNoParams<TResult> {
  const UseCaseNoParams();
  Future<TResult> call();
}

/// パラメータの基底クラス
abstract class Params extends Equatable {
  const Params();
}

/// パラメータなしを表すクラス
class NoParams extends Params {
  const NoParams();

  @override
  List<Object?> get props => [];
}

