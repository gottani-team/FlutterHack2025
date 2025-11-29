// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_metadata.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AIMetadata {
  /// 感情タイプ
  EmotionType get emotionType;

  /// スコア（0-100）- 秘密の「重さ」= カルマ値
  int get score;

  /// Create a copy of AIMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AIMetadataCopyWith<AIMetadata> get copyWith =>
      _$AIMetadataCopyWithImpl<AIMetadata>(this as AIMetadata, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AIMetadata &&
            (identical(other.emotionType, emotionType) ||
                other.emotionType == emotionType) &&
            (identical(other.score, score) || other.score == score));
  }

  @override
  int get hashCode => Object.hash(runtimeType, emotionType, score);

  @override
  String toString() {
    return 'AIMetadata(emotionType: $emotionType, score: $score)';
  }
}

/// @nodoc
abstract mixin class $AIMetadataCopyWith<$Res> {
  factory $AIMetadataCopyWith(
          AIMetadata value, $Res Function(AIMetadata) _then) =
      _$AIMetadataCopyWithImpl;
  @useResult
  $Res call({EmotionType emotionType, int score});
}

/// @nodoc
class _$AIMetadataCopyWithImpl<$Res> implements $AIMetadataCopyWith<$Res> {
  _$AIMetadataCopyWithImpl(this._self, this._then);

  final AIMetadata _self;
  final $Res Function(AIMetadata) _then;

  /// Create a copy of AIMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? emotionType = null,
    Object? score = null,
  }) {
    return _then(_self.copyWith(
      emotionType: null == emotionType
          ? _self.emotionType
          : emotionType // ignore: cast_nullable_to_non_nullable
              as EmotionType,
      score: null == score
          ? _self.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [AIMetadata].
extension AIMetadataPatterns on AIMetadata {
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
    TResult Function(_AIMetadata value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AIMetadata() when $default != null:
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
    TResult Function(_AIMetadata value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIMetadata():
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
    TResult? Function(_AIMetadata value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIMetadata() when $default != null:
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
    TResult Function(EmotionType emotionType, int score)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AIMetadata() when $default != null:
        return $default(_that.emotionType, _that.score);
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
    TResult Function(EmotionType emotionType, int score) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIMetadata():
        return $default(_that.emotionType, _that.score);
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
    TResult? Function(EmotionType emotionType, int score)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AIMetadata() when $default != null:
        return $default(_that.emotionType, _that.score);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AIMetadata extends AIMetadata {
  const _AIMetadata({required this.emotionType, required this.score})
      : super._();

  /// 感情タイプ
  @override
  final EmotionType emotionType;

  /// スコア（0-100）- 秘密の「重さ」= カルマ値
  @override
  final int score;

  /// Create a copy of AIMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AIMetadataCopyWith<_AIMetadata> get copyWith =>
      __$AIMetadataCopyWithImpl<_AIMetadata>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AIMetadata &&
            (identical(other.emotionType, emotionType) ||
                other.emotionType == emotionType) &&
            (identical(other.score, score) || other.score == score));
  }

  @override
  int get hashCode => Object.hash(runtimeType, emotionType, score);

  @override
  String toString() {
    return 'AIMetadata(emotionType: $emotionType, score: $score)';
  }
}

/// @nodoc
abstract mixin class _$AIMetadataCopyWith<$Res>
    implements $AIMetadataCopyWith<$Res> {
  factory _$AIMetadataCopyWith(
          _AIMetadata value, $Res Function(_AIMetadata) _then) =
      __$AIMetadataCopyWithImpl;
  @override
  @useResult
  $Res call({EmotionType emotionType, int score});
}

/// @nodoc
class __$AIMetadataCopyWithImpl<$Res> implements _$AIMetadataCopyWith<$Res> {
  __$AIMetadataCopyWithImpl(this._self, this._then);

  final _AIMetadata _self;
  final $Res Function(_AIMetadata) _then;

  /// Create a copy of AIMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? emotionType = null,
    Object? score = null,
  }) {
    return _then(_AIMetadata(
      emotionType: null == emotionType
          ? _self.emotionType
          : emotionType // ignore: cast_nullable_to_non_nullable
              as EmotionType,
      score: null == score
          ? _self.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
