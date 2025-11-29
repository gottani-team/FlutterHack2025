// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'memory_crystal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MemoryCrystal {
  String get id;
  Location get location;
  EmotionType get emotion;
  String get creatorId;
  DateTime get createdAt;
  bool get isExcavated;
  String? get text;
  String? get excavatedBy;
  DateTime? get excavatedAt;

  /// Create a copy of MemoryCrystal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MemoryCrystalCopyWith<MemoryCrystal> get copyWith =>
      _$MemoryCrystalCopyWithImpl<MemoryCrystal>(
          this as MemoryCrystal, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MemoryCrystal &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.emotion, emotion) || other.emotion == emotion) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isExcavated, isExcavated) ||
                other.isExcavated == isExcavated) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.excavatedBy, excavatedBy) ||
                other.excavatedBy == excavatedBy) &&
            (identical(other.excavatedAt, excavatedAt) ||
                other.excavatedAt == excavatedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, location, emotion, creatorId,
      createdAt, isExcavated, text, excavatedBy, excavatedAt);

  @override
  String toString() {
    return 'MemoryCrystal(id: $id, location: $location, emotion: $emotion, creatorId: $creatorId, createdAt: $createdAt, isExcavated: $isExcavated, text: $text, excavatedBy: $excavatedBy, excavatedAt: $excavatedAt)';
  }
}

/// @nodoc
abstract mixin class $MemoryCrystalCopyWith<$Res> {
  factory $MemoryCrystalCopyWith(
          MemoryCrystal value, $Res Function(MemoryCrystal) _then) =
      _$MemoryCrystalCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      Location location,
      EmotionType emotion,
      String creatorId,
      DateTime createdAt,
      bool isExcavated,
      String? text,
      String? excavatedBy,
      DateTime? excavatedAt});

  $LocationCopyWith<$Res> get location;
}

/// @nodoc
class _$MemoryCrystalCopyWithImpl<$Res>
    implements $MemoryCrystalCopyWith<$Res> {
  _$MemoryCrystalCopyWithImpl(this._self, this._then);

  final MemoryCrystal _self;
  final $Res Function(MemoryCrystal) _then;

  /// Create a copy of MemoryCrystal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? location = null,
    Object? emotion = null,
    Object? creatorId = null,
    Object? createdAt = null,
    Object? isExcavated = null,
    Object? text = freezed,
    Object? excavatedBy = freezed,
    Object? excavatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as Location,
      emotion: null == emotion
          ? _self.emotion
          : emotion // ignore: cast_nullable_to_non_nullable
              as EmotionType,
      creatorId: null == creatorId
          ? _self.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isExcavated: null == isExcavated
          ? _self.isExcavated
          : isExcavated // ignore: cast_nullable_to_non_nullable
              as bool,
      text: freezed == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      excavatedBy: freezed == excavatedBy
          ? _self.excavatedBy
          : excavatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      excavatedAt: freezed == excavatedAt
          ? _self.excavatedAt
          : excavatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }

  /// Create a copy of MemoryCrystal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationCopyWith<$Res> get location {
    return $LocationCopyWith<$Res>(_self.location, (value) {
      return _then(_self.copyWith(location: value));
    });
  }
}

/// Adds pattern-matching-related methods to [MemoryCrystal].
extension MemoryCrystalPatterns on MemoryCrystal {
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
    TResult Function(_MemoryCrystal value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MemoryCrystal() when $default != null:
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
    TResult Function(_MemoryCrystal value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MemoryCrystal():
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
    TResult? Function(_MemoryCrystal value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MemoryCrystal() when $default != null:
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
            Location location,
            EmotionType emotion,
            String creatorId,
            DateTime createdAt,
            bool isExcavated,
            String? text,
            String? excavatedBy,
            DateTime? excavatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MemoryCrystal() when $default != null:
        return $default(
            _that.id,
            _that.location,
            _that.emotion,
            _that.creatorId,
            _that.createdAt,
            _that.isExcavated,
            _that.text,
            _that.excavatedBy,
            _that.excavatedAt);
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
            Location location,
            EmotionType emotion,
            String creatorId,
            DateTime createdAt,
            bool isExcavated,
            String? text,
            String? excavatedBy,
            DateTime? excavatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MemoryCrystal():
        return $default(
            _that.id,
            _that.location,
            _that.emotion,
            _that.creatorId,
            _that.createdAt,
            _that.isExcavated,
            _that.text,
            _that.excavatedBy,
            _that.excavatedAt);
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
            Location location,
            EmotionType emotion,
            String creatorId,
            DateTime createdAt,
            bool isExcavated,
            String? text,
            String? excavatedBy,
            DateTime? excavatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MemoryCrystal() when $default != null:
        return $default(
            _that.id,
            _that.location,
            _that.emotion,
            _that.creatorId,
            _that.createdAt,
            _that.isExcavated,
            _that.text,
            _that.excavatedBy,
            _that.excavatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _MemoryCrystal extends MemoryCrystal {
  const _MemoryCrystal(
      {required this.id,
      required this.location,
      required this.emotion,
      required this.creatorId,
      required this.createdAt,
      this.isExcavated = false,
      this.text,
      this.excavatedBy,
      this.excavatedAt})
      : super._();

  @override
  final String id;
  @override
  final Location location;
  @override
  final EmotionType emotion;
  @override
  final String creatorId;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final bool isExcavated;
  @override
  final String? text;
  @override
  final String? excavatedBy;
  @override
  final DateTime? excavatedAt;

  /// Create a copy of MemoryCrystal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MemoryCrystalCopyWith<_MemoryCrystal> get copyWith =>
      __$MemoryCrystalCopyWithImpl<_MemoryCrystal>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MemoryCrystal &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.emotion, emotion) || other.emotion == emotion) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isExcavated, isExcavated) ||
                other.isExcavated == isExcavated) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.excavatedBy, excavatedBy) ||
                other.excavatedBy == excavatedBy) &&
            (identical(other.excavatedAt, excavatedAt) ||
                other.excavatedAt == excavatedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, location, emotion, creatorId,
      createdAt, isExcavated, text, excavatedBy, excavatedAt);

  @override
  String toString() {
    return 'MemoryCrystal(id: $id, location: $location, emotion: $emotion, creatorId: $creatorId, createdAt: $createdAt, isExcavated: $isExcavated, text: $text, excavatedBy: $excavatedBy, excavatedAt: $excavatedAt)';
  }
}

/// @nodoc
abstract mixin class _$MemoryCrystalCopyWith<$Res>
    implements $MemoryCrystalCopyWith<$Res> {
  factory _$MemoryCrystalCopyWith(
          _MemoryCrystal value, $Res Function(_MemoryCrystal) _then) =
      __$MemoryCrystalCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      Location location,
      EmotionType emotion,
      String creatorId,
      DateTime createdAt,
      bool isExcavated,
      String? text,
      String? excavatedBy,
      DateTime? excavatedAt});

  @override
  $LocationCopyWith<$Res> get location;
}

/// @nodoc
class __$MemoryCrystalCopyWithImpl<$Res>
    implements _$MemoryCrystalCopyWith<$Res> {
  __$MemoryCrystalCopyWithImpl(this._self, this._then);

  final _MemoryCrystal _self;
  final $Res Function(_MemoryCrystal) _then;

  /// Create a copy of MemoryCrystal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? location = null,
    Object? emotion = null,
    Object? creatorId = null,
    Object? createdAt = null,
    Object? isExcavated = null,
    Object? text = freezed,
    Object? excavatedBy = freezed,
    Object? excavatedAt = freezed,
  }) {
    return _then(_MemoryCrystal(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as Location,
      emotion: null == emotion
          ? _self.emotion
          : emotion // ignore: cast_nullable_to_non_nullable
              as EmotionType,
      creatorId: null == creatorId
          ? _self.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isExcavated: null == isExcavated
          ? _self.isExcavated
          : isExcavated // ignore: cast_nullable_to_non_nullable
              as bool,
      text: freezed == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      excavatedBy: freezed == excavatedBy
          ? _self.excavatedBy
          : excavatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      excavatedAt: freezed == excavatedAt
          ? _self.excavatedAt
          : excavatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }

  /// Create a copy of MemoryCrystal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationCopyWith<$Res> get location {
    return $LocationCopyWith<$Res>(_self.location, (value) {
      return _then(_self.copyWith(location: value));
    });
  }
}

// dart format on
