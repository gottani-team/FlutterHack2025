// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'crystal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Crystal {
  String get id;
  CrystalStatus get status;
  int get karmaValue;
  AIMetadata get aiMetadata;
  DateTime get createdAt;
  String get createdBy;
  String get creatorNickname;
  String? get secretText;
  String? get decipheredBy;
  DateTime? get decipheredAt;

  /// Create a copy of Crystal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CrystalCopyWith<Crystal> get copyWith =>
      _$CrystalCopyWithImpl<Crystal>(this as Crystal, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Crystal &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.karmaValue, karmaValue) ||
                other.karmaValue == karmaValue) &&
            (identical(other.aiMetadata, aiMetadata) ||
                other.aiMetadata == aiMetadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.creatorNickname, creatorNickname) ||
                other.creatorNickname == creatorNickname) &&
            (identical(other.secretText, secretText) ||
                other.secretText == secretText) &&
            (identical(other.decipheredBy, decipheredBy) ||
                other.decipheredBy == decipheredBy) &&
            (identical(other.decipheredAt, decipheredAt) ||
                other.decipheredAt == decipheredAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      status,
      karmaValue,
      aiMetadata,
      createdAt,
      createdBy,
      creatorNickname,
      secretText,
      decipheredBy,
      decipheredAt);

  @override
  String toString() {
    return 'Crystal(id: $id, status: $status, karmaValue: $karmaValue, aiMetadata: $aiMetadata, createdAt: $createdAt, createdBy: $createdBy, creatorNickname: $creatorNickname, secretText: $secretText, decipheredBy: $decipheredBy, decipheredAt: $decipheredAt)';
  }
}

/// @nodoc
abstract mixin class $CrystalCopyWith<$Res> {
  factory $CrystalCopyWith(Crystal value, $Res Function(Crystal) _then) =
      _$CrystalCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      CrystalStatus status,
      int karmaValue,
      AIMetadata aiMetadata,
      DateTime createdAt,
      String createdBy,
      String creatorNickname,
      String? secretText,
      String? decipheredBy,
      DateTime? decipheredAt});

  $AIMetadataCopyWith<$Res> get aiMetadata;
}

/// @nodoc
class _$CrystalCopyWithImpl<$Res> implements $CrystalCopyWith<$Res> {
  _$CrystalCopyWithImpl(this._self, this._then);

  final Crystal _self;
  final $Res Function(Crystal) _then;

  /// Create a copy of Crystal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? karmaValue = null,
    Object? aiMetadata = null,
    Object? createdAt = null,
    Object? createdBy = null,
    Object? creatorNickname = null,
    Object? secretText = freezed,
    Object? decipheredBy = freezed,
    Object? decipheredAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as CrystalStatus,
      karmaValue: null == karmaValue
          ? _self.karmaValue
          : karmaValue // ignore: cast_nullable_to_non_nullable
              as int,
      aiMetadata: null == aiMetadata
          ? _self.aiMetadata
          : aiMetadata // ignore: cast_nullable_to_non_nullable
              as AIMetadata,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdBy: null == createdBy
          ? _self.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      creatorNickname: null == creatorNickname
          ? _self.creatorNickname
          : creatorNickname // ignore: cast_nullable_to_non_nullable
              as String,
      secretText: freezed == secretText
          ? _self.secretText
          : secretText // ignore: cast_nullable_to_non_nullable
              as String?,
      decipheredBy: freezed == decipheredBy
          ? _self.decipheredBy
          : decipheredBy // ignore: cast_nullable_to_non_nullable
              as String?,
      decipheredAt: freezed == decipheredAt
          ? _self.decipheredAt
          : decipheredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }

  /// Create a copy of Crystal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AIMetadataCopyWith<$Res> get aiMetadata {
    return $AIMetadataCopyWith<$Res>(_self.aiMetadata, (value) {
      return _then(_self.copyWith(aiMetadata: value));
    });
  }
}

/// Adds pattern-matching-related methods to [Crystal].
extension CrystalPatterns on Crystal {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Crystal value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Crystal() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Crystal value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Crystal():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Crystal value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Crystal() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            CrystalStatus status,
            int karmaValue,
            AIMetadata aiMetadata,
            DateTime createdAt,
            String createdBy,
            String creatorNickname,
            String? secretText,
            String? decipheredBy,
            DateTime? decipheredAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Crystal() when $default != null:
        return $default(
            _that.id,
            _that.status,
            _that.karmaValue,
            _that.aiMetadata,
            _that.createdAt,
            _that.createdBy,
            _that.creatorNickname,
            _that.secretText,
            _that.decipheredBy,
            _that.decipheredAt);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            CrystalStatus status,
            int karmaValue,
            AIMetadata aiMetadata,
            DateTime createdAt,
            String createdBy,
            String creatorNickname,
            String? secretText,
            String? decipheredBy,
            DateTime? decipheredAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Crystal():
        return $default(
            _that.id,
            _that.status,
            _that.karmaValue,
            _that.aiMetadata,
            _that.createdAt,
            _that.createdBy,
            _that.creatorNickname,
            _that.secretText,
            _that.decipheredBy,
            _that.decipheredAt);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            CrystalStatus status,
            int karmaValue,
            AIMetadata aiMetadata,
            DateTime createdAt,
            String createdBy,
            String creatorNickname,
            String? secretText,
            String? decipheredBy,
            DateTime? decipheredAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Crystal() when $default != null:
        return $default(
            _that.id,
            _that.status,
            _that.karmaValue,
            _that.aiMetadata,
            _that.createdAt,
            _that.createdBy,
            _that.creatorNickname,
            _that.secretText,
            _that.decipheredBy,
            _that.decipheredAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Crystal extends Crystal {
  const _Crystal(
      {required this.id,
      required this.status,
      required this.karmaValue,
      required this.aiMetadata,
      required this.createdAt,
      required this.createdBy,
      required this.creatorNickname,
      this.secretText,
      this.decipheredBy,
      this.decipheredAt})
      : super._();

  @override
  final String id;
  @override
  final CrystalStatus status;
  @override
  final int karmaValue;
  @override
  final AIMetadata aiMetadata;
  @override
  final DateTime createdAt;
  @override
  final String createdBy;
  @override
  final String creatorNickname;
  @override
  final String? secretText;
  @override
  final String? decipheredBy;
  @override
  final DateTime? decipheredAt;

  /// Create a copy of Crystal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CrystalCopyWith<_Crystal> get copyWith =>
      __$CrystalCopyWithImpl<_Crystal>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Crystal &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.karmaValue, karmaValue) ||
                other.karmaValue == karmaValue) &&
            (identical(other.aiMetadata, aiMetadata) ||
                other.aiMetadata == aiMetadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.creatorNickname, creatorNickname) ||
                other.creatorNickname == creatorNickname) &&
            (identical(other.secretText, secretText) ||
                other.secretText == secretText) &&
            (identical(other.decipheredBy, decipheredBy) ||
                other.decipheredBy == decipheredBy) &&
            (identical(other.decipheredAt, decipheredAt) ||
                other.decipheredAt == decipheredAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      status,
      karmaValue,
      aiMetadata,
      createdAt,
      createdBy,
      creatorNickname,
      secretText,
      decipheredBy,
      decipheredAt);

  @override
  String toString() {
    return 'Crystal(id: $id, status: $status, karmaValue: $karmaValue, aiMetadata: $aiMetadata, createdAt: $createdAt, createdBy: $createdBy, creatorNickname: $creatorNickname, secretText: $secretText, decipheredBy: $decipheredBy, decipheredAt: $decipheredAt)';
  }
}

/// @nodoc
abstract mixin class _$CrystalCopyWith<$Res> implements $CrystalCopyWith<$Res> {
  factory _$CrystalCopyWith(_Crystal value, $Res Function(_Crystal) _then) =
      __$CrystalCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      CrystalStatus status,
      int karmaValue,
      AIMetadata aiMetadata,
      DateTime createdAt,
      String createdBy,
      String creatorNickname,
      String? secretText,
      String? decipheredBy,
      DateTime? decipheredAt});

  @override
  $AIMetadataCopyWith<$Res> get aiMetadata;
}

/// @nodoc
class __$CrystalCopyWithImpl<$Res> implements _$CrystalCopyWith<$Res> {
  __$CrystalCopyWithImpl(this._self, this._then);

  final _Crystal _self;
  final $Res Function(_Crystal) _then;

  /// Create a copy of Crystal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? karmaValue = null,
    Object? aiMetadata = null,
    Object? createdAt = null,
    Object? createdBy = null,
    Object? creatorNickname = null,
    Object? secretText = freezed,
    Object? decipheredBy = freezed,
    Object? decipheredAt = freezed,
  }) {
    return _then(_Crystal(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as CrystalStatus,
      karmaValue: null == karmaValue
          ? _self.karmaValue
          : karmaValue // ignore: cast_nullable_to_non_nullable
              as int,
      aiMetadata: null == aiMetadata
          ? _self.aiMetadata
          : aiMetadata // ignore: cast_nullable_to_non_nullable
              as AIMetadata,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdBy: null == createdBy
          ? _self.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      creatorNickname: null == creatorNickname
          ? _self.creatorNickname
          : creatorNickname // ignore: cast_nullable_to_non_nullable
              as String,
      secretText: freezed == secretText
          ? _self.secretText
          : secretText // ignore: cast_nullable_to_non_nullable
              as String?,
      decipheredBy: freezed == decipheredBy
          ? _self.decipheredBy
          : decipheredBy // ignore: cast_nullable_to_non_nullable
              as String?,
      decipheredAt: freezed == decipheredAt
          ? _self.decipheredAt
          : decipheredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }

  /// Create a copy of Crystal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AIMetadataCopyWith<$Res> get aiMetadata {
    return $AIMetadataCopyWith<$Res>(_self.aiMetadata, (value) {
      return _then(_self.copyWith(aiMetadata: value));
    });
  }
}

// dart format on
