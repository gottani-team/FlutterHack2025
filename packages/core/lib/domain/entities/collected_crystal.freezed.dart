// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collected_crystal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CollectedCrystal {
  String get id;
  String get secretText;
  int get karmaCost;
  AIMetadata get aiMetadata;
  DateTime get decipheredAt;
  String get originalCreatorId;
  String get originalCreatorNickname;

  /// Create a copy of CollectedCrystal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CollectedCrystalCopyWith<CollectedCrystal> get copyWith =>
      _$CollectedCrystalCopyWithImpl<CollectedCrystal>(
          this as CollectedCrystal, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CollectedCrystal &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.secretText, secretText) ||
                other.secretText == secretText) &&
            (identical(other.karmaCost, karmaCost) ||
                other.karmaCost == karmaCost) &&
            (identical(other.aiMetadata, aiMetadata) ||
                other.aiMetadata == aiMetadata) &&
            (identical(other.decipheredAt, decipheredAt) ||
                other.decipheredAt == decipheredAt) &&
            (identical(other.originalCreatorId, originalCreatorId) ||
                other.originalCreatorId == originalCreatorId) &&
            (identical(
                    other.originalCreatorNickname, originalCreatorNickname) ||
                other.originalCreatorNickname == originalCreatorNickname));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, secretText, karmaCost,
      aiMetadata, decipheredAt, originalCreatorId, originalCreatorNickname);

  @override
  String toString() {
    return 'CollectedCrystal(id: $id, secretText: $secretText, karmaCost: $karmaCost, aiMetadata: $aiMetadata, decipheredAt: $decipheredAt, originalCreatorId: $originalCreatorId, originalCreatorNickname: $originalCreatorNickname)';
  }
}

/// @nodoc
abstract mixin class $CollectedCrystalCopyWith<$Res> {
  factory $CollectedCrystalCopyWith(
          CollectedCrystal value, $Res Function(CollectedCrystal) _then) =
      _$CollectedCrystalCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String secretText,
      int karmaCost,
      AIMetadata aiMetadata,
      DateTime decipheredAt,
      String originalCreatorId,
      String originalCreatorNickname});

  $AIMetadataCopyWith<$Res> get aiMetadata;
}

/// @nodoc
class _$CollectedCrystalCopyWithImpl<$Res>
    implements $CollectedCrystalCopyWith<$Res> {
  _$CollectedCrystalCopyWithImpl(this._self, this._then);

  final CollectedCrystal _self;
  final $Res Function(CollectedCrystal) _then;

  /// Create a copy of CollectedCrystal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? secretText = null,
    Object? karmaCost = null,
    Object? aiMetadata = null,
    Object? decipheredAt = null,
    Object? originalCreatorId = null,
    Object? originalCreatorNickname = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      secretText: null == secretText
          ? _self.secretText
          : secretText // ignore: cast_nullable_to_non_nullable
              as String,
      karmaCost: null == karmaCost
          ? _self.karmaCost
          : karmaCost // ignore: cast_nullable_to_non_nullable
              as int,
      aiMetadata: null == aiMetadata
          ? _self.aiMetadata
          : aiMetadata // ignore: cast_nullable_to_non_nullable
              as AIMetadata,
      decipheredAt: null == decipheredAt
          ? _self.decipheredAt
          : decipheredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      originalCreatorId: null == originalCreatorId
          ? _self.originalCreatorId
          : originalCreatorId // ignore: cast_nullable_to_non_nullable
              as String,
      originalCreatorNickname: null == originalCreatorNickname
          ? _self.originalCreatorNickname
          : originalCreatorNickname // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }

  /// Create a copy of CollectedCrystal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AIMetadataCopyWith<$Res> get aiMetadata {
    return $AIMetadataCopyWith<$Res>(_self.aiMetadata, (value) {
      return _then(_self.copyWith(aiMetadata: value));
    });
  }
}

/// Adds pattern-matching-related methods to [CollectedCrystal].
extension CollectedCrystalPatterns on CollectedCrystal {
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
    TResult Function(_CollectedCrystal value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CollectedCrystal() when $default != null:
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
    TResult Function(_CollectedCrystal value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CollectedCrystal():
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
    TResult? Function(_CollectedCrystal value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CollectedCrystal() when $default != null:
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
            String secretText,
            int karmaCost,
            AIMetadata aiMetadata,
            DateTime decipheredAt,
            String originalCreatorId,
            String originalCreatorNickname)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CollectedCrystal() when $default != null:
        return $default(
            _that.id,
            _that.secretText,
            _that.karmaCost,
            _that.aiMetadata,
            _that.decipheredAt,
            _that.originalCreatorId,
            _that.originalCreatorNickname);
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
            String secretText,
            int karmaCost,
            AIMetadata aiMetadata,
            DateTime decipheredAt,
            String originalCreatorId,
            String originalCreatorNickname)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CollectedCrystal():
        return $default(
            _that.id,
            _that.secretText,
            _that.karmaCost,
            _that.aiMetadata,
            _that.decipheredAt,
            _that.originalCreatorId,
            _that.originalCreatorNickname);
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
            String secretText,
            int karmaCost,
            AIMetadata aiMetadata,
            DateTime decipheredAt,
            String originalCreatorId,
            String originalCreatorNickname)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CollectedCrystal() when $default != null:
        return $default(
            _that.id,
            _that.secretText,
            _that.karmaCost,
            _that.aiMetadata,
            _that.decipheredAt,
            _that.originalCreatorId,
            _that.originalCreatorNickname);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CollectedCrystal extends CollectedCrystal {
  const _CollectedCrystal(
      {required this.id,
      required this.secretText,
      required this.karmaCost,
      required this.aiMetadata,
      required this.decipheredAt,
      required this.originalCreatorId,
      required this.originalCreatorNickname})
      : super._();

  @override
  final String id;
  @override
  final String secretText;
  @override
  final int karmaCost;
  @override
  final AIMetadata aiMetadata;
  @override
  final DateTime decipheredAt;
  @override
  final String originalCreatorId;
  @override
  final String originalCreatorNickname;

  /// Create a copy of CollectedCrystal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CollectedCrystalCopyWith<_CollectedCrystal> get copyWith =>
      __$CollectedCrystalCopyWithImpl<_CollectedCrystal>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CollectedCrystal &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.secretText, secretText) ||
                other.secretText == secretText) &&
            (identical(other.karmaCost, karmaCost) ||
                other.karmaCost == karmaCost) &&
            (identical(other.aiMetadata, aiMetadata) ||
                other.aiMetadata == aiMetadata) &&
            (identical(other.decipheredAt, decipheredAt) ||
                other.decipheredAt == decipheredAt) &&
            (identical(other.originalCreatorId, originalCreatorId) ||
                other.originalCreatorId == originalCreatorId) &&
            (identical(
                    other.originalCreatorNickname, originalCreatorNickname) ||
                other.originalCreatorNickname == originalCreatorNickname));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, secretText, karmaCost,
      aiMetadata, decipheredAt, originalCreatorId, originalCreatorNickname);

  @override
  String toString() {
    return 'CollectedCrystal(id: $id, secretText: $secretText, karmaCost: $karmaCost, aiMetadata: $aiMetadata, decipheredAt: $decipheredAt, originalCreatorId: $originalCreatorId, originalCreatorNickname: $originalCreatorNickname)';
  }
}

/// @nodoc
abstract mixin class _$CollectedCrystalCopyWith<$Res>
    implements $CollectedCrystalCopyWith<$Res> {
  factory _$CollectedCrystalCopyWith(
          _CollectedCrystal value, $Res Function(_CollectedCrystal) _then) =
      __$CollectedCrystalCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String secretText,
      int karmaCost,
      AIMetadata aiMetadata,
      DateTime decipheredAt,
      String originalCreatorId,
      String originalCreatorNickname});

  @override
  $AIMetadataCopyWith<$Res> get aiMetadata;
}

/// @nodoc
class __$CollectedCrystalCopyWithImpl<$Res>
    implements _$CollectedCrystalCopyWith<$Res> {
  __$CollectedCrystalCopyWithImpl(this._self, this._then);

  final _CollectedCrystal _self;
  final $Res Function(_CollectedCrystal) _then;

  /// Create a copy of CollectedCrystal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? secretText = null,
    Object? karmaCost = null,
    Object? aiMetadata = null,
    Object? decipheredAt = null,
    Object? originalCreatorId = null,
    Object? originalCreatorNickname = null,
  }) {
    return _then(_CollectedCrystal(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      secretText: null == secretText
          ? _self.secretText
          : secretText // ignore: cast_nullable_to_non_nullable
              as String,
      karmaCost: null == karmaCost
          ? _self.karmaCost
          : karmaCost // ignore: cast_nullable_to_non_nullable
              as int,
      aiMetadata: null == aiMetadata
          ? _self.aiMetadata
          : aiMetadata // ignore: cast_nullable_to_non_nullable
              as AIMetadata,
      decipheredAt: null == decipheredAt
          ? _self.decipheredAt
          : decipheredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      originalCreatorId: null == originalCreatorId
          ? _self.originalCreatorId
          : originalCreatorId // ignore: cast_nullable_to_non_nullable
              as String,
      originalCreatorNickname: null == originalCreatorNickname
          ? _self.originalCreatorNickname
          : originalCreatorNickname // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }

  /// Create a copy of CollectedCrystal
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
