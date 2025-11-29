// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_view_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MapViewState {
  /// Current user location, null if not yet acquired
  UserLocationEntity? get userLocation;

  /// Location permission status
  LocationPermissionStatus get permissionStatus;

  /// GPS accuracy level for warning display
  GpsAccuracyLevel get gpsAccuracyLevel;

  /// List of crystallization areas visible on the map
  List<CrystallizationAreaEntity> get visibleCrystallizationAreas;

  /// Current proximity detection phase
  ProximityPhase get proximityPhase;

  /// The closest crystal being approached, null if none in range
  CrystallizationAreaEntity? get approachingCrystal;

  /// Distance to the closest crystal in meters, null if none in range
  double? get distanceToClosestCrystal;

  /// Pulse intensity for heartbeat effect (0.0 to 1.0)
  double get pulseIntensity;

  /// Whether haptic feedback is currently active
  bool get isHapticActive;

  /// Whether map is currently loading
  bool get isLoading;

  /// Error message if any operation failed
  String? get errorMessage;

  /// Whether the app is in background mode
  bool get isBackgroundMode;

  /// Map camera center latitude
  double? get mapCenterLatitude;

  /// Map camera center longitude
  double? get mapCenterLongitude;

  /// Map camera zoom level (17+ for 3D buildings to be visible)
  double get mapZoomLevel;

  /// Whether map is following user location
  bool get isFollowingUser;

  /// Remote crystals fetched from Firestore (keyed by crystal ID)
  Map<String, core.Crystal> get remoteCrystals;

  /// Current user's karma balance, null if not yet loaded
  int? get currentKarma;

  /// Whether map style has finished loading
  bool get isMapStyleLoaded;

  /// Whether initial location has been set and camera moved
  bool get hasSetInitialLocation;

  /// Create a copy of MapViewState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MapViewStateCopyWith<MapViewState> get copyWith =>
      _$MapViewStateCopyWithImpl<MapViewState>(
          this as MapViewState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MapViewState &&
            (identical(other.userLocation, userLocation) ||
                other.userLocation == userLocation) &&
            (identical(other.permissionStatus, permissionStatus) ||
                other.permissionStatus == permissionStatus) &&
            (identical(other.gpsAccuracyLevel, gpsAccuracyLevel) ||
                other.gpsAccuracyLevel == gpsAccuracyLevel) &&
            const DeepCollectionEquality().equals(
                other.visibleCrystallizationAreas,
                visibleCrystallizationAreas) &&
            (identical(other.proximityPhase, proximityPhase) ||
                other.proximityPhase == proximityPhase) &&
            (identical(other.approachingCrystal, approachingCrystal) ||
                other.approachingCrystal == approachingCrystal) &&
            (identical(
                    other.distanceToClosestCrystal, distanceToClosestCrystal) ||
                other.distanceToClosestCrystal == distanceToClosestCrystal) &&
            (identical(other.pulseIntensity, pulseIntensity) ||
                other.pulseIntensity == pulseIntensity) &&
            (identical(other.isHapticActive, isHapticActive) ||
                other.isHapticActive == isHapticActive) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.isBackgroundMode, isBackgroundMode) ||
                other.isBackgroundMode == isBackgroundMode) &&
            (identical(other.mapCenterLatitude, mapCenterLatitude) ||
                other.mapCenterLatitude == mapCenterLatitude) &&
            (identical(other.mapCenterLongitude, mapCenterLongitude) ||
                other.mapCenterLongitude == mapCenterLongitude) &&
            (identical(other.mapZoomLevel, mapZoomLevel) ||
                other.mapZoomLevel == mapZoomLevel) &&
            (identical(other.isFollowingUser, isFollowingUser) ||
                other.isFollowingUser == isFollowingUser) &&
            const DeepCollectionEquality()
                .equals(other.remoteCrystals, remoteCrystals) &&
            (identical(other.currentKarma, currentKarma) ||
                other.currentKarma == currentKarma) &&
            (identical(other.isMapStyleLoaded, isMapStyleLoaded) ||
                other.isMapStyleLoaded == isMapStyleLoaded) &&
            (identical(other.hasSetInitialLocation, hasSetInitialLocation) ||
                other.hasSetInitialLocation == hasSetInitialLocation));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        userLocation,
        permissionStatus,
        gpsAccuracyLevel,
        const DeepCollectionEquality().hash(visibleCrystallizationAreas),
        proximityPhase,
        approachingCrystal,
        distanceToClosestCrystal,
        pulseIntensity,
        isHapticActive,
        isLoading,
        errorMessage,
        isBackgroundMode,
        mapCenterLatitude,
        mapCenterLongitude,
        mapZoomLevel,
        isFollowingUser,
        const DeepCollectionEquality().hash(remoteCrystals),
        currentKarma,
        isMapStyleLoaded,
        hasSetInitialLocation
      ]);

  @override
  String toString() {
    return 'MapViewState(userLocation: $userLocation, permissionStatus: $permissionStatus, gpsAccuracyLevel: $gpsAccuracyLevel, visibleCrystallizationAreas: $visibleCrystallizationAreas, proximityPhase: $proximityPhase, approachingCrystal: $approachingCrystal, distanceToClosestCrystal: $distanceToClosestCrystal, pulseIntensity: $pulseIntensity, isHapticActive: $isHapticActive, isLoading: $isLoading, errorMessage: $errorMessage, isBackgroundMode: $isBackgroundMode, mapCenterLatitude: $mapCenterLatitude, mapCenterLongitude: $mapCenterLongitude, mapZoomLevel: $mapZoomLevel, isFollowingUser: $isFollowingUser, remoteCrystals: $remoteCrystals, currentKarma: $currentKarma, isMapStyleLoaded: $isMapStyleLoaded, hasSetInitialLocation: $hasSetInitialLocation)';
  }
}

/// @nodoc
abstract mixin class $MapViewStateCopyWith<$Res> {
  factory $MapViewStateCopyWith(
          MapViewState value, $Res Function(MapViewState) _then) =
      _$MapViewStateCopyWithImpl;
  @useResult
  $Res call(
      {UserLocationEntity? userLocation,
      LocationPermissionStatus permissionStatus,
      GpsAccuracyLevel gpsAccuracyLevel,
      List<CrystallizationAreaEntity> visibleCrystallizationAreas,
      ProximityPhase proximityPhase,
      CrystallizationAreaEntity? approachingCrystal,
      double? distanceToClosestCrystal,
      double pulseIntensity,
      bool isHapticActive,
      bool isLoading,
      String? errorMessage,
      bool isBackgroundMode,
      double? mapCenterLatitude,
      double? mapCenterLongitude,
      double mapZoomLevel,
      bool isFollowingUser,
      Map<String, core.Crystal> remoteCrystals,
      int? currentKarma,
      bool isMapStyleLoaded,
      bool hasSetInitialLocation});
}

/// @nodoc
class _$MapViewStateCopyWithImpl<$Res> implements $MapViewStateCopyWith<$Res> {
  _$MapViewStateCopyWithImpl(this._self, this._then);

  final MapViewState _self;
  final $Res Function(MapViewState) _then;

  /// Create a copy of MapViewState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userLocation = freezed,
    Object? permissionStatus = null,
    Object? gpsAccuracyLevel = null,
    Object? visibleCrystallizationAreas = null,
    Object? proximityPhase = null,
    Object? approachingCrystal = freezed,
    Object? distanceToClosestCrystal = freezed,
    Object? pulseIntensity = null,
    Object? isHapticActive = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? isBackgroundMode = null,
    Object? mapCenterLatitude = freezed,
    Object? mapCenterLongitude = freezed,
    Object? mapZoomLevel = null,
    Object? isFollowingUser = null,
    Object? remoteCrystals = null,
    Object? currentKarma = freezed,
    Object? isMapStyleLoaded = null,
    Object? hasSetInitialLocation = null,
  }) {
    return _then(_self.copyWith(
      userLocation: freezed == userLocation
          ? _self.userLocation
          : userLocation // ignore: cast_nullable_to_non_nullable
              as UserLocationEntity?,
      permissionStatus: null == permissionStatus
          ? _self.permissionStatus
          : permissionStatus // ignore: cast_nullable_to_non_nullable
              as LocationPermissionStatus,
      gpsAccuracyLevel: null == gpsAccuracyLevel
          ? _self.gpsAccuracyLevel
          : gpsAccuracyLevel // ignore: cast_nullable_to_non_nullable
              as GpsAccuracyLevel,
      visibleCrystallizationAreas: null == visibleCrystallizationAreas
          ? _self.visibleCrystallizationAreas
          : visibleCrystallizationAreas // ignore: cast_nullable_to_non_nullable
              as List<CrystallizationAreaEntity>,
      proximityPhase: null == proximityPhase
          ? _self.proximityPhase
          : proximityPhase // ignore: cast_nullable_to_non_nullable
              as ProximityPhase,
      approachingCrystal: freezed == approachingCrystal
          ? _self.approachingCrystal
          : approachingCrystal // ignore: cast_nullable_to_non_nullable
              as CrystallizationAreaEntity?,
      distanceToClosestCrystal: freezed == distanceToClosestCrystal
          ? _self.distanceToClosestCrystal
          : distanceToClosestCrystal // ignore: cast_nullable_to_non_nullable
              as double?,
      pulseIntensity: null == pulseIntensity
          ? _self.pulseIntensity
          : pulseIntensity // ignore: cast_nullable_to_non_nullable
              as double,
      isHapticActive: null == isHapticActive
          ? _self.isHapticActive
          : isHapticActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      isBackgroundMode: null == isBackgroundMode
          ? _self.isBackgroundMode
          : isBackgroundMode // ignore: cast_nullable_to_non_nullable
              as bool,
      mapCenterLatitude: freezed == mapCenterLatitude
          ? _self.mapCenterLatitude
          : mapCenterLatitude // ignore: cast_nullable_to_non_nullable
              as double?,
      mapCenterLongitude: freezed == mapCenterLongitude
          ? _self.mapCenterLongitude
          : mapCenterLongitude // ignore: cast_nullable_to_non_nullable
              as double?,
      mapZoomLevel: null == mapZoomLevel
          ? _self.mapZoomLevel
          : mapZoomLevel // ignore: cast_nullable_to_non_nullable
              as double,
      isFollowingUser: null == isFollowingUser
          ? _self.isFollowingUser
          : isFollowingUser // ignore: cast_nullable_to_non_nullable
              as bool,
      remoteCrystals: null == remoteCrystals
          ? _self.remoteCrystals
          : remoteCrystals // ignore: cast_nullable_to_non_nullable
              as Map<String, core.Crystal>,
      currentKarma: freezed == currentKarma
          ? _self.currentKarma
          : currentKarma // ignore: cast_nullable_to_non_nullable
              as int?,
      isMapStyleLoaded: null == isMapStyleLoaded
          ? _self.isMapStyleLoaded
          : isMapStyleLoaded // ignore: cast_nullable_to_non_nullable
              as bool,
      hasSetInitialLocation: null == hasSetInitialLocation
          ? _self.hasSetInitialLocation
          : hasSetInitialLocation // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [MapViewState].
extension MapViewStatePatterns on MapViewState {
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
    TResult Function(_MapViewState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MapViewState() when $default != null:
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
    TResult Function(_MapViewState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MapViewState():
        return $default(_that);
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
    TResult? Function(_MapViewState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MapViewState() when $default != null:
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
            UserLocationEntity? userLocation,
            LocationPermissionStatus permissionStatus,
            GpsAccuracyLevel gpsAccuracyLevel,
            List<CrystallizationAreaEntity> visibleCrystallizationAreas,
            ProximityPhase proximityPhase,
            CrystallizationAreaEntity? approachingCrystal,
            double? distanceToClosestCrystal,
            double pulseIntensity,
            bool isHapticActive,
            bool isLoading,
            String? errorMessage,
            bool isBackgroundMode,
            double? mapCenterLatitude,
            double? mapCenterLongitude,
            double mapZoomLevel,
            bool isFollowingUser,
            Map<String, core.Crystal> remoteCrystals,
            int? currentKarma,
            bool isMapStyleLoaded,
            bool hasSetInitialLocation)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MapViewState() when $default != null:
        return $default(
            _that.userLocation,
            _that.permissionStatus,
            _that.gpsAccuracyLevel,
            _that.visibleCrystallizationAreas,
            _that.proximityPhase,
            _that.approachingCrystal,
            _that.distanceToClosestCrystal,
            _that.pulseIntensity,
            _that.isHapticActive,
            _that.isLoading,
            _that.errorMessage,
            _that.isBackgroundMode,
            _that.mapCenterLatitude,
            _that.mapCenterLongitude,
            _that.mapZoomLevel,
            _that.isFollowingUser,
            _that.remoteCrystals,
            _that.currentKarma,
            _that.isMapStyleLoaded,
            _that.hasSetInitialLocation);
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
            UserLocationEntity? userLocation,
            LocationPermissionStatus permissionStatus,
            GpsAccuracyLevel gpsAccuracyLevel,
            List<CrystallizationAreaEntity> visibleCrystallizationAreas,
            ProximityPhase proximityPhase,
            CrystallizationAreaEntity? approachingCrystal,
            double? distanceToClosestCrystal,
            double pulseIntensity,
            bool isHapticActive,
            bool isLoading,
            String? errorMessage,
            bool isBackgroundMode,
            double? mapCenterLatitude,
            double? mapCenterLongitude,
            double mapZoomLevel,
            bool isFollowingUser,
            Map<String, core.Crystal> remoteCrystals,
            int? currentKarma,
            bool isMapStyleLoaded,
            bool hasSetInitialLocation)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MapViewState():
        return $default(
            _that.userLocation,
            _that.permissionStatus,
            _that.gpsAccuracyLevel,
            _that.visibleCrystallizationAreas,
            _that.proximityPhase,
            _that.approachingCrystal,
            _that.distanceToClosestCrystal,
            _that.pulseIntensity,
            _that.isHapticActive,
            _that.isLoading,
            _that.errorMessage,
            _that.isBackgroundMode,
            _that.mapCenterLatitude,
            _that.mapCenterLongitude,
            _that.mapZoomLevel,
            _that.isFollowingUser,
            _that.remoteCrystals,
            _that.currentKarma,
            _that.isMapStyleLoaded,
            _that.hasSetInitialLocation);
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
            UserLocationEntity? userLocation,
            LocationPermissionStatus permissionStatus,
            GpsAccuracyLevel gpsAccuracyLevel,
            List<CrystallizationAreaEntity> visibleCrystallizationAreas,
            ProximityPhase proximityPhase,
            CrystallizationAreaEntity? approachingCrystal,
            double? distanceToClosestCrystal,
            double pulseIntensity,
            bool isHapticActive,
            bool isLoading,
            String? errorMessage,
            bool isBackgroundMode,
            double? mapCenterLatitude,
            double? mapCenterLongitude,
            double mapZoomLevel,
            bool isFollowingUser,
            Map<String, core.Crystal> remoteCrystals,
            int? currentKarma,
            bool isMapStyleLoaded,
            bool hasSetInitialLocation)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MapViewState() when $default != null:
        return $default(
            _that.userLocation,
            _that.permissionStatus,
            _that.gpsAccuracyLevel,
            _that.visibleCrystallizationAreas,
            _that.proximityPhase,
            _that.approachingCrystal,
            _that.distanceToClosestCrystal,
            _that.pulseIntensity,
            _that.isHapticActive,
            _that.isLoading,
            _that.errorMessage,
            _that.isBackgroundMode,
            _that.mapCenterLatitude,
            _that.mapCenterLongitude,
            _that.mapZoomLevel,
            _that.isFollowingUser,
            _that.remoteCrystals,
            _that.currentKarma,
            _that.isMapStyleLoaded,
            _that.hasSetInitialLocation);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _MapViewState extends MapViewState {
  const _MapViewState(
      {this.userLocation,
      this.permissionStatus = LocationPermissionStatus.notDetermined,
      this.gpsAccuracyLevel = GpsAccuracyLevel.good,
      final List<CrystallizationAreaEntity> visibleCrystallizationAreas =
          const [],
      this.proximityPhase = ProximityPhase.none,
      this.approachingCrystal,
      this.distanceToClosestCrystal,
      this.pulseIntensity = 0.0,
      this.isHapticActive = false,
      this.isLoading = true,
      this.errorMessage,
      this.isBackgroundMode = false,
      this.mapCenterLatitude,
      this.mapCenterLongitude,
      this.mapZoomLevel = 17.5,
      this.isFollowingUser = true,
      final Map<String, core.Crystal> remoteCrystals = const {},
      this.currentKarma,
      this.isMapStyleLoaded = false,
      this.hasSetInitialLocation = false})
      : _visibleCrystallizationAreas = visibleCrystallizationAreas,
        _remoteCrystals = remoteCrystals,
        super._();

  /// Current user location, null if not yet acquired
  @override
  final UserLocationEntity? userLocation;

  /// Location permission status
  @override
  @JsonKey()
  final LocationPermissionStatus permissionStatus;

  /// GPS accuracy level for warning display
  @override
  @JsonKey()
  final GpsAccuracyLevel gpsAccuracyLevel;

  /// List of crystallization areas visible on the map
  final List<CrystallizationAreaEntity> _visibleCrystallizationAreas;

  /// List of crystallization areas visible on the map
  @override
  @JsonKey()
  List<CrystallizationAreaEntity> get visibleCrystallizationAreas {
    if (_visibleCrystallizationAreas is EqualUnmodifiableListView)
      return _visibleCrystallizationAreas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_visibleCrystallizationAreas);
  }

  /// Current proximity detection phase
  @override
  @JsonKey()
  final ProximityPhase proximityPhase;

  /// The closest crystal being approached, null if none in range
  @override
  final CrystallizationAreaEntity? approachingCrystal;

  /// Distance to the closest crystal in meters, null if none in range
  @override
  final double? distanceToClosestCrystal;

  /// Pulse intensity for heartbeat effect (0.0 to 1.0)
  @override
  @JsonKey()
  final double pulseIntensity;

  /// Whether haptic feedback is currently active
  @override
  @JsonKey()
  final bool isHapticActive;

  /// Whether map is currently loading
  @override
  @JsonKey()
  final bool isLoading;

  /// Error message if any operation failed
  @override
  final String? errorMessage;

  /// Whether the app is in background mode
  @override
  @JsonKey()
  final bool isBackgroundMode;

  /// Map camera center latitude
  @override
  final double? mapCenterLatitude;

  /// Map camera center longitude
  @override
  final double? mapCenterLongitude;

  /// Map camera zoom level (17+ for 3D buildings to be visible)
  @override
  @JsonKey()
  final double mapZoomLevel;

  /// Whether map is following user location
  @override
  @JsonKey()
  final bool isFollowingUser;

  /// Remote crystals fetched from Firestore (keyed by crystal ID)
  final Map<String, core.Crystal> _remoteCrystals;

  /// Remote crystals fetched from Firestore (keyed by crystal ID)
  @override
  @JsonKey()
  Map<String, core.Crystal> get remoteCrystals {
    if (_remoteCrystals is EqualUnmodifiableMapView) return _remoteCrystals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_remoteCrystals);
  }

  /// Current user's karma balance, null if not yet loaded
  @override
  final int? currentKarma;

  /// Whether map style has finished loading
  @override
  @JsonKey()
  final bool isMapStyleLoaded;

  /// Whether initial location has been set and camera moved
  @override
  @JsonKey()
  final bool hasSetInitialLocation;

  /// Create a copy of MapViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MapViewStateCopyWith<_MapViewState> get copyWith =>
      __$MapViewStateCopyWithImpl<_MapViewState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MapViewState &&
            (identical(other.userLocation, userLocation) ||
                other.userLocation == userLocation) &&
            (identical(other.permissionStatus, permissionStatus) ||
                other.permissionStatus == permissionStatus) &&
            (identical(other.gpsAccuracyLevel, gpsAccuracyLevel) ||
                other.gpsAccuracyLevel == gpsAccuracyLevel) &&
            const DeepCollectionEquality().equals(
                other._visibleCrystallizationAreas,
                _visibleCrystallizationAreas) &&
            (identical(other.proximityPhase, proximityPhase) ||
                other.proximityPhase == proximityPhase) &&
            (identical(other.approachingCrystal, approachingCrystal) ||
                other.approachingCrystal == approachingCrystal) &&
            (identical(
                    other.distanceToClosestCrystal, distanceToClosestCrystal) ||
                other.distanceToClosestCrystal == distanceToClosestCrystal) &&
            (identical(other.pulseIntensity, pulseIntensity) ||
                other.pulseIntensity == pulseIntensity) &&
            (identical(other.isHapticActive, isHapticActive) ||
                other.isHapticActive == isHapticActive) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.isBackgroundMode, isBackgroundMode) ||
                other.isBackgroundMode == isBackgroundMode) &&
            (identical(other.mapCenterLatitude, mapCenterLatitude) ||
                other.mapCenterLatitude == mapCenterLatitude) &&
            (identical(other.mapCenterLongitude, mapCenterLongitude) ||
                other.mapCenterLongitude == mapCenterLongitude) &&
            (identical(other.mapZoomLevel, mapZoomLevel) ||
                other.mapZoomLevel == mapZoomLevel) &&
            (identical(other.isFollowingUser, isFollowingUser) ||
                other.isFollowingUser == isFollowingUser) &&
            const DeepCollectionEquality()
                .equals(other._remoteCrystals, _remoteCrystals) &&
            (identical(other.currentKarma, currentKarma) ||
                other.currentKarma == currentKarma) &&
            (identical(other.isMapStyleLoaded, isMapStyleLoaded) ||
                other.isMapStyleLoaded == isMapStyleLoaded) &&
            (identical(other.hasSetInitialLocation, hasSetInitialLocation) ||
                other.hasSetInitialLocation == hasSetInitialLocation));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        userLocation,
        permissionStatus,
        gpsAccuracyLevel,
        const DeepCollectionEquality().hash(_visibleCrystallizationAreas),
        proximityPhase,
        approachingCrystal,
        distanceToClosestCrystal,
        pulseIntensity,
        isHapticActive,
        isLoading,
        errorMessage,
        isBackgroundMode,
        mapCenterLatitude,
        mapCenterLongitude,
        mapZoomLevel,
        isFollowingUser,
        const DeepCollectionEquality().hash(_remoteCrystals),
        currentKarma,
        isMapStyleLoaded,
        hasSetInitialLocation
      ]);

  @override
  String toString() {
    return 'MapViewState(userLocation: $userLocation, permissionStatus: $permissionStatus, gpsAccuracyLevel: $gpsAccuracyLevel, visibleCrystallizationAreas: $visibleCrystallizationAreas, proximityPhase: $proximityPhase, approachingCrystal: $approachingCrystal, distanceToClosestCrystal: $distanceToClosestCrystal, pulseIntensity: $pulseIntensity, isHapticActive: $isHapticActive, isLoading: $isLoading, errorMessage: $errorMessage, isBackgroundMode: $isBackgroundMode, mapCenterLatitude: $mapCenterLatitude, mapCenterLongitude: $mapCenterLongitude, mapZoomLevel: $mapZoomLevel, isFollowingUser: $isFollowingUser, remoteCrystals: $remoteCrystals, currentKarma: $currentKarma, isMapStyleLoaded: $isMapStyleLoaded, hasSetInitialLocation: $hasSetInitialLocation)';
  }
}

/// @nodoc
abstract mixin class _$MapViewStateCopyWith<$Res>
    implements $MapViewStateCopyWith<$Res> {
  factory _$MapViewStateCopyWith(
          _MapViewState value, $Res Function(_MapViewState) _then) =
      __$MapViewStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {UserLocationEntity? userLocation,
      LocationPermissionStatus permissionStatus,
      GpsAccuracyLevel gpsAccuracyLevel,
      List<CrystallizationAreaEntity> visibleCrystallizationAreas,
      ProximityPhase proximityPhase,
      CrystallizationAreaEntity? approachingCrystal,
      double? distanceToClosestCrystal,
      double pulseIntensity,
      bool isHapticActive,
      bool isLoading,
      String? errorMessage,
      bool isBackgroundMode,
      double? mapCenterLatitude,
      double? mapCenterLongitude,
      double mapZoomLevel,
      bool isFollowingUser,
      Map<String, core.Crystal> remoteCrystals,
      int? currentKarma,
      bool isMapStyleLoaded,
      bool hasSetInitialLocation});
}

/// @nodoc
class __$MapViewStateCopyWithImpl<$Res>
    implements _$MapViewStateCopyWith<$Res> {
  __$MapViewStateCopyWithImpl(this._self, this._then);

  final _MapViewState _self;
  final $Res Function(_MapViewState) _then;

  /// Create a copy of MapViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? userLocation = freezed,
    Object? permissionStatus = null,
    Object? gpsAccuracyLevel = null,
    Object? visibleCrystallizationAreas = null,
    Object? proximityPhase = null,
    Object? approachingCrystal = freezed,
    Object? distanceToClosestCrystal = freezed,
    Object? pulseIntensity = null,
    Object? isHapticActive = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? isBackgroundMode = null,
    Object? mapCenterLatitude = freezed,
    Object? mapCenterLongitude = freezed,
    Object? mapZoomLevel = null,
    Object? isFollowingUser = null,
    Object? remoteCrystals = null,
    Object? currentKarma = freezed,
    Object? isMapStyleLoaded = null,
    Object? hasSetInitialLocation = null,
  }) {
    return _then(_MapViewState(
      userLocation: freezed == userLocation
          ? _self.userLocation
          : userLocation // ignore: cast_nullable_to_non_nullable
              as UserLocationEntity?,
      permissionStatus: null == permissionStatus
          ? _self.permissionStatus
          : permissionStatus // ignore: cast_nullable_to_non_nullable
              as LocationPermissionStatus,
      gpsAccuracyLevel: null == gpsAccuracyLevel
          ? _self.gpsAccuracyLevel
          : gpsAccuracyLevel // ignore: cast_nullable_to_non_nullable
              as GpsAccuracyLevel,
      visibleCrystallizationAreas: null == visibleCrystallizationAreas
          ? _self._visibleCrystallizationAreas
          : visibleCrystallizationAreas // ignore: cast_nullable_to_non_nullable
              as List<CrystallizationAreaEntity>,
      proximityPhase: null == proximityPhase
          ? _self.proximityPhase
          : proximityPhase // ignore: cast_nullable_to_non_nullable
              as ProximityPhase,
      approachingCrystal: freezed == approachingCrystal
          ? _self.approachingCrystal
          : approachingCrystal // ignore: cast_nullable_to_non_nullable
              as CrystallizationAreaEntity?,
      distanceToClosestCrystal: freezed == distanceToClosestCrystal
          ? _self.distanceToClosestCrystal
          : distanceToClosestCrystal // ignore: cast_nullable_to_non_nullable
              as double?,
      pulseIntensity: null == pulseIntensity
          ? _self.pulseIntensity
          : pulseIntensity // ignore: cast_nullable_to_non_nullable
              as double,
      isHapticActive: null == isHapticActive
          ? _self.isHapticActive
          : isHapticActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      isBackgroundMode: null == isBackgroundMode
          ? _self.isBackgroundMode
          : isBackgroundMode // ignore: cast_nullable_to_non_nullable
              as bool,
      mapCenterLatitude: freezed == mapCenterLatitude
          ? _self.mapCenterLatitude
          : mapCenterLatitude // ignore: cast_nullable_to_non_nullable
              as double?,
      mapCenterLongitude: freezed == mapCenterLongitude
          ? _self.mapCenterLongitude
          : mapCenterLongitude // ignore: cast_nullable_to_non_nullable
              as double?,
      mapZoomLevel: null == mapZoomLevel
          ? _self.mapZoomLevel
          : mapZoomLevel // ignore: cast_nullable_to_non_nullable
              as double,
      isFollowingUser: null == isFollowingUser
          ? _self.isFollowingUser
          : isFollowingUser // ignore: cast_nullable_to_non_nullable
              as bool,
      remoteCrystals: null == remoteCrystals
          ? _self._remoteCrystals
          : remoteCrystals // ignore: cast_nullable_to_non_nullable
              as Map<String, core.Crystal>,
      currentKarma: freezed == currentKarma
          ? _self.currentKarma
          : currentKarma // ignore: cast_nullable_to_non_nullable
              as int?,
      isMapStyleLoaded: null == isMapStyleLoaded
          ? _self.isMapStyleLoaded
          : isMapStyleLoaded // ignore: cast_nullable_to_non_nullable
              as bool,
      hasSetInitialLocation: null == hasSetInitialLocation
          ? _self.hasSetInitialLocation
          : hasSetInitialLocation // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
