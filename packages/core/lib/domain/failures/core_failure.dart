import 'package:freezed_annotation/freezed_annotation.dart';

part 'core_failure.freezed.dart';

/// Core層のエラー型
///
/// すべてのリポジトリ操作で返されるエラーを統一的に表現する。
/// Freezed union typeを使用して型安全なエラーハンドリングを実現。
@freezed
abstract class CoreFailure with _$CoreFailure {
  /// 認証エラー
  ///
  /// Firebase Authentication関連のエラー。
  /// - ユーザーが認証されていない
  /// - 認証トークンが無効
  /// - 認証セッションの期限切れ
  const factory CoreFailure.auth({
    required String message,
    String? code,
  }) = _AuthFailure;

  /// ネットワークエラー
  ///
  /// Firebase接続エラーやネットワーク障害。
  /// - インターネット接続なし
  /// - Firestoreタイムアウト
  /// - Firebase APIエラー
  const factory CoreFailure.network({
    required String message,
    String? code,
  }) = _NetworkFailure;

  /// リソースが見つからない
  ///
  /// 指定されたIDのドキュメントが存在しない。
  /// - クリスタルが存在しない
  /// - 採掘記録が見つからない
  const factory CoreFailure.notFound({
    required String message,
  }) = _NotFoundFailure;

  /// 権限エラー
  ///
  /// Firestore Security Rulesによるアクセス拒否。
  /// - 読み取り権限なし
  /// - 書き込み権限なし
  const factory CoreFailure.permission({
    required String message,
  }) = _PermissionFailure;

  /// データ検証エラー
  ///
  /// 入力データが無効。
  /// - 必須フィールドが欠落
  /// - データ形式が不正
  const factory CoreFailure.invalidData({
    required String message,
  }) = _InvalidDataFailure;

  /// 重複エラー
  ///
  /// すでに同じデータが存在する。
  /// - 同じユーザーが同じクリスタルを複数回採掘しようとした
  const factory CoreFailure.duplicate({
    required String message,
  }) = _DuplicateFailure;

  /// 不明なエラー
  ///
  /// 上記のカテゴリに分類できないエラー。
  const factory CoreFailure.unknown({
    required String message,
  }) = _UnknownFailure;
}
