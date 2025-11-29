/// Location permission status enum.
/// This is shared across all features that need location permission handling.
enum LocationPermissionStatus {
  /// Permission not yet requested
  notDetermined,

  /// Permission has been granted
  granted,

  /// Permission was denied by user (can be requested again)
  denied,

  /// Permission is permanently denied (settings required)
  permanentlyDenied,

  /// Location services are disabled on device
  serviceDisabled,

  /// Requesting permission is currently in progress
  requesting,
}

/// Extension methods for LocationPermissionStatus
extension LocationPermissionStatusX on LocationPermissionStatus {
  /// Returns true if the user can use location features
  bool get canUseLocation => this == LocationPermissionStatus.granted;

  /// Returns true if the user needs to be prompted for permission
  bool get needsPermissionRequest =>
      this == LocationPermissionStatus.notDetermined ||
      this == LocationPermissionStatus.denied;

  /// Returns true if the user needs to go to settings to enable location
  bool get needsSettings =>
      this == LocationPermissionStatus.permanentlyDenied ||
      this == LocationPermissionStatus.serviceDisabled;

  /// Returns true if permission request is still pending
  bool get isRequesting => this == LocationPermissionStatus.requesting;

  /// Returns a user-friendly message for the current status
  String get userMessage {
    switch (this) {
      case LocationPermissionStatus.notDetermined:
        return '位置情報の許可が必要です';
      case LocationPermissionStatus.granted:
        return '位置情報を利用できます';
      case LocationPermissionStatus.denied:
        return '位置情報の許可が拒否されました。許可すると周辺の結晶を探せます。';
      case LocationPermissionStatus.permanentlyDenied:
        return '位置情報の許可が完全に拒否されています。設定から許可してください。';
      case LocationPermissionStatus.serviceDisabled:
        return '位置情報サービスが無効です。設定から有効にしてください。';
      case LocationPermissionStatus.requesting:
        return '位置情報の許可を確認中...';
    }
  }
}
