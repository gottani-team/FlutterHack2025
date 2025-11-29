import 'package:equatable/equatable.dart';

/// Represents the user's current GPS location with accuracy information.
/// This entity is shared across all features that need location data.
class UserLocationEntity extends Equatable {
  /// Latitude coordinate
  final double latitude;

  /// Longitude coordinate
  final double longitude;

  /// Accuracy of the location in meters
  final double accuracy;

  /// Timestamp when this location was recorded
  final DateTime timestamp;

  /// Heading/bearing in degrees (0-360), null if not available
  final double? heading;

  /// Speed in meters per second, null if not available
  final double? speed;

  /// Altitude in meters, null if not available
  final double? altitude;

  const UserLocationEntity({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    this.heading,
    this.speed,
    this.altitude,
  });

  /// Check if the location accuracy is excellent (under 10 meters)
  bool get isExcellent => accuracy <= 10.0;

  /// Check if the location accuracy is acceptable (under 50 meters)
  bool get isAccurate => accuracy <= 50.0;

  /// Check if the location accuracy is poor (over 50 meters)
  bool get isPoorAccuracy => accuracy > 50.0;

  /// Check if the location accuracy is very poor (over 100 meters)
  bool get isVeryPoorAccuracy => accuracy > 100.0;

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        accuracy,
        timestamp,
        heading,
        speed,
        altitude,
      ];

  @override
  String toString() {
    return 'UserLocationEntity(lat: $latitude, lng: $longitude, accuracy: ${accuracy.toStringAsFixed(1)}m)';
  }
}

