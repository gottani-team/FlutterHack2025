// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'core_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CoreFailure {
  String get message;

  /// Create a copy of CoreFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CoreFailureCopyWith<CoreFailure> get copyWith =>
      _$CoreFailureCopyWithImpl<CoreFailure>(this as CoreFailure, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CoreFailure &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'CoreFailure(message: $message)';
  }
}

/// @nodoc
abstract mixin class $CoreFailureCopyWith<$Res> {
  factory $CoreFailureCopyWith(
          CoreFailure value, $Res Function(CoreFailure) _then) =
      _$CoreFailureCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$CoreFailureCopyWithImpl<$Res> implements $CoreFailureCopyWith<$Res> {
  _$CoreFailureCopyWithImpl(this._self, this._then);

  final CoreFailure _self;
  final $Res Function(CoreFailure) _then;

  /// Create a copy of CoreFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_self.copyWith(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [CoreFailure].
extension CoreFailurePatterns on CoreFailure {
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
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AuthFailure value)? auth,
    TResult Function(_NetworkFailure value)? network,
    TResult Function(_NotFoundFailure value)? notFound,
    TResult Function(_PermissionFailure value)? permission,
    TResult Function(_InvalidDataFailure value)? invalidData,
    TResult Function(_DuplicateFailure value)? duplicate,
    TResult Function(_UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuthFailure() when auth != null:
        return auth(_that);
      case _NetworkFailure() when network != null:
        return network(_that);
      case _NotFoundFailure() when notFound != null:
        return notFound(_that);
      case _PermissionFailure() when permission != null:
        return permission(_that);
      case _InvalidDataFailure() when invalidData != null:
        return invalidData(_that);
      case _DuplicateFailure() when duplicate != null:
        return duplicate(_that);
      case _UnknownFailure() when unknown != null:
        return unknown(_that);
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
  TResult map<TResult extends Object?>({
    required TResult Function(_AuthFailure value) auth,
    required TResult Function(_NetworkFailure value) network,
    required TResult Function(_NotFoundFailure value) notFound,
    required TResult Function(_PermissionFailure value) permission,
    required TResult Function(_InvalidDataFailure value) invalidData,
    required TResult Function(_DuplicateFailure value) duplicate,
    required TResult Function(_UnknownFailure value) unknown,
  }) {
    final _that = this;
    switch (_that) {
      case _AuthFailure():
        return auth(_that);
      case _NetworkFailure():
        return network(_that);
      case _NotFoundFailure():
        return notFound(_that);
      case _PermissionFailure():
        return permission(_that);
      case _InvalidDataFailure():
        return invalidData(_that);
      case _DuplicateFailure():
        return duplicate(_that);
      case _UnknownFailure():
        return unknown(_that);
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
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AuthFailure value)? auth,
    TResult? Function(_NetworkFailure value)? network,
    TResult? Function(_NotFoundFailure value)? notFound,
    TResult? Function(_PermissionFailure value)? permission,
    TResult? Function(_InvalidDataFailure value)? invalidData,
    TResult? Function(_DuplicateFailure value)? duplicate,
    TResult? Function(_UnknownFailure value)? unknown,
  }) {
    final _that = this;
    switch (_that) {
      case _AuthFailure() when auth != null:
        return auth(_that);
      case _NetworkFailure() when network != null:
        return network(_that);
      case _NotFoundFailure() when notFound != null:
        return notFound(_that);
      case _PermissionFailure() when permission != null:
        return permission(_that);
      case _InvalidDataFailure() when invalidData != null:
        return invalidData(_that);
      case _DuplicateFailure() when duplicate != null:
        return duplicate(_that);
      case _UnknownFailure() when unknown != null:
        return unknown(_that);
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
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? code)? auth,
    TResult Function(String message, String? code)? network,
    TResult Function(String message)? notFound,
    TResult Function(String message)? permission,
    TResult Function(String message)? invalidData,
    TResult Function(String message)? duplicate,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuthFailure() when auth != null:
        return auth(_that.message, _that.code);
      case _NetworkFailure() when network != null:
        return network(_that.message, _that.code);
      case _NotFoundFailure() when notFound != null:
        return notFound(_that.message);
      case _PermissionFailure() when permission != null:
        return permission(_that.message);
      case _InvalidDataFailure() when invalidData != null:
        return invalidData(_that.message);
      case _DuplicateFailure() when duplicate != null:
        return duplicate(_that.message);
      case _UnknownFailure() when unknown != null:
        return unknown(_that.message);
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
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? code) auth,
    required TResult Function(String message, String? code) network,
    required TResult Function(String message) notFound,
    required TResult Function(String message) permission,
    required TResult Function(String message) invalidData,
    required TResult Function(String message) duplicate,
    required TResult Function(String message) unknown,
  }) {
    final _that = this;
    switch (_that) {
      case _AuthFailure():
        return auth(_that.message, _that.code);
      case _NetworkFailure():
        return network(_that.message, _that.code);
      case _NotFoundFailure():
        return notFound(_that.message);
      case _PermissionFailure():
        return permission(_that.message);
      case _InvalidDataFailure():
        return invalidData(_that.message);
      case _DuplicateFailure():
        return duplicate(_that.message);
      case _UnknownFailure():
        return unknown(_that.message);
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
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? code)? auth,
    TResult? Function(String message, String? code)? network,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? permission,
    TResult? Function(String message)? invalidData,
    TResult? Function(String message)? duplicate,
    TResult? Function(String message)? unknown,
  }) {
    final _that = this;
    switch (_that) {
      case _AuthFailure() when auth != null:
        return auth(_that.message, _that.code);
      case _NetworkFailure() when network != null:
        return network(_that.message, _that.code);
      case _NotFoundFailure() when notFound != null:
        return notFound(_that.message);
      case _PermissionFailure() when permission != null:
        return permission(_that.message);
      case _InvalidDataFailure() when invalidData != null:
        return invalidData(_that.message);
      case _DuplicateFailure() when duplicate != null:
        return duplicate(_that.message);
      case _UnknownFailure() when unknown != null:
        return unknown(_that.message);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AuthFailure implements CoreFailure {
  const _AuthFailure({required this.message, this.code});

  @override
  final String message;
  final String? code;

  /// Create a copy of CoreFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AuthFailureCopyWith<_AuthFailure> get copyWith =>
      __$AuthFailureCopyWithImpl<_AuthFailure>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AuthFailure &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code);

  @override
  String toString() {
    return 'CoreFailure.auth(message: $message, code: $code)';
  }
}

/// @nodoc
abstract mixin class _$AuthFailureCopyWith<$Res>
    implements $CoreFailureCopyWith<$Res> {
  factory _$AuthFailureCopyWith(
          _AuthFailure value, $Res Function(_AuthFailure) _then) =
      __$AuthFailureCopyWithImpl;
  @override
  @useResult
  $Res call({String message, String? code});
}

/// @nodoc
class __$AuthFailureCopyWithImpl<$Res> implements _$AuthFailureCopyWith<$Res> {
  __$AuthFailureCopyWithImpl(this._self, this._then);

  final _AuthFailure _self;
  final $Res Function(_AuthFailure) _then;

  /// Create a copy of CoreFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? code = freezed,
  }) {
    return _then(_AuthFailure(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _NetworkFailure implements CoreFailure {
  const _NetworkFailure({required this.message, this.code});

  @override
  final String message;
  final String? code;

  /// Create a copy of CoreFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NetworkFailureCopyWith<_NetworkFailure> get copyWith =>
      __$NetworkFailureCopyWithImpl<_NetworkFailure>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NetworkFailure &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code);

  @override
  String toString() {
    return 'CoreFailure.network(message: $message, code: $code)';
  }
}

/// @nodoc
abstract mixin class _$NetworkFailureCopyWith<$Res>
    implements $CoreFailureCopyWith<$Res> {
  factory _$NetworkFailureCopyWith(
          _NetworkFailure value, $Res Function(_NetworkFailure) _then) =
      __$NetworkFailureCopyWithImpl;
  @override
  @useResult
  $Res call({String message, String? code});
}

/// @nodoc
class __$NetworkFailureCopyWithImpl<$Res>
    implements _$NetworkFailureCopyWith<$Res> {
  __$NetworkFailureCopyWithImpl(this._self, this._then);

  final _NetworkFailure _self;
  final $Res Function(_NetworkFailure) _then;

  /// Create a copy of CoreFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? code = freezed,
  }) {
    return _then(_NetworkFailure(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _NotFoundFailure implements CoreFailure {
  const _NotFoundFailure({required this.message});

  @override
  final String message;

  /// Create a copy of CoreFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NotFoundFailureCopyWith<_NotFoundFailure> get copyWith =>
      __$NotFoundFailureCopyWithImpl<_NotFoundFailure>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NotFoundFailure &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'CoreFailure.notFound(message: $message)';
  }
}

/// @nodoc
abstract mixin class _$NotFoundFailureCopyWith<$Res>
    implements $CoreFailureCopyWith<$Res> {
  factory _$NotFoundFailureCopyWith(
          _NotFoundFailure value, $Res Function(_NotFoundFailure) _then) =
      __$NotFoundFailureCopyWithImpl;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$NotFoundFailureCopyWithImpl<$Res>
    implements _$NotFoundFailureCopyWith<$Res> {
  __$NotFoundFailureCopyWithImpl(this._self, this._then);

  final _NotFoundFailure _self;
  final $Res Function(_NotFoundFailure) _then;

  /// Create a copy of CoreFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(_NotFoundFailure(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _PermissionFailure implements CoreFailure {
  const _PermissionFailure({required this.message});

  @override
  final String message;

  /// Create a copy of CoreFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PermissionFailureCopyWith<_PermissionFailure> get copyWith =>
      __$PermissionFailureCopyWithImpl<_PermissionFailure>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PermissionFailure &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'CoreFailure.permission(message: $message)';
  }
}

/// @nodoc
abstract mixin class _$PermissionFailureCopyWith<$Res>
    implements $CoreFailureCopyWith<$Res> {
  factory _$PermissionFailureCopyWith(
          _PermissionFailure value, $Res Function(_PermissionFailure) _then) =
      __$PermissionFailureCopyWithImpl;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$PermissionFailureCopyWithImpl<$Res>
    implements _$PermissionFailureCopyWith<$Res> {
  __$PermissionFailureCopyWithImpl(this._self, this._then);

  final _PermissionFailure _self;
  final $Res Function(_PermissionFailure) _then;

  /// Create a copy of CoreFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(_PermissionFailure(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _InvalidDataFailure implements CoreFailure {
  const _InvalidDataFailure({required this.message});

  @override
  final String message;

  /// Create a copy of CoreFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InvalidDataFailureCopyWith<_InvalidDataFailure> get copyWith =>
      __$InvalidDataFailureCopyWithImpl<_InvalidDataFailure>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InvalidDataFailure &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'CoreFailure.invalidData(message: $message)';
  }
}

/// @nodoc
abstract mixin class _$InvalidDataFailureCopyWith<$Res>
    implements $CoreFailureCopyWith<$Res> {
  factory _$InvalidDataFailureCopyWith(
          _InvalidDataFailure value, $Res Function(_InvalidDataFailure) _then) =
      __$InvalidDataFailureCopyWithImpl;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$InvalidDataFailureCopyWithImpl<$Res>
    implements _$InvalidDataFailureCopyWith<$Res> {
  __$InvalidDataFailureCopyWithImpl(this._self, this._then);

  final _InvalidDataFailure _self;
  final $Res Function(_InvalidDataFailure) _then;

  /// Create a copy of CoreFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(_InvalidDataFailure(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _DuplicateFailure implements CoreFailure {
  const _DuplicateFailure({required this.message});

  @override
  final String message;

  /// Create a copy of CoreFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DuplicateFailureCopyWith<_DuplicateFailure> get copyWith =>
      __$DuplicateFailureCopyWithImpl<_DuplicateFailure>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DuplicateFailure &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'CoreFailure.duplicate(message: $message)';
  }
}

/// @nodoc
abstract mixin class _$DuplicateFailureCopyWith<$Res>
    implements $CoreFailureCopyWith<$Res> {
  factory _$DuplicateFailureCopyWith(
          _DuplicateFailure value, $Res Function(_DuplicateFailure) _then) =
      __$DuplicateFailureCopyWithImpl;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$DuplicateFailureCopyWithImpl<$Res>
    implements _$DuplicateFailureCopyWith<$Res> {
  __$DuplicateFailureCopyWithImpl(this._self, this._then);

  final _DuplicateFailure _self;
  final $Res Function(_DuplicateFailure) _then;

  /// Create a copy of CoreFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(_DuplicateFailure(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _UnknownFailure implements CoreFailure {
  const _UnknownFailure({required this.message});

  @override
  final String message;

  /// Create a copy of CoreFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UnknownFailureCopyWith<_UnknownFailure> get copyWith =>
      __$UnknownFailureCopyWithImpl<_UnknownFailure>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UnknownFailure &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'CoreFailure.unknown(message: $message)';
  }
}

/// @nodoc
abstract mixin class _$UnknownFailureCopyWith<$Res>
    implements $CoreFailureCopyWith<$Res> {
  factory _$UnknownFailureCopyWith(
          _UnknownFailure value, $Res Function(_UnknownFailure) _then) =
      __$UnknownFailureCopyWithImpl;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$UnknownFailureCopyWithImpl<$Res>
    implements _$UnknownFailureCopyWith<$Res> {
  __$UnknownFailureCopyWithImpl(this._self, this._then);

  final _UnknownFailure _self;
  final $Res Function(_UnknownFailure) _then;

  /// Create a copy of CoreFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(_UnknownFailure(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
