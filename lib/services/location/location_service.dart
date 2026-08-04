import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cqaag_app/models/location/captured_location.dart';

part 'location_service.g.dart';

/// Service for handling GPS location operations
@riverpod
LocationService locationService(Ref ref) {
  return LocationService();
}

class LocationService {
  /// Check if location permissions are granted
  Future<bool> checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  /// Request location permissions from the user
  Future<LocationPermission> requestPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  /// Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get the current GPS position
  Future<Position> getCurrentPosition() async {
    // Check if location services are enabled
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceDisabledException(
        'Location services are disabled. Please enable location services in your device settings.',
      );
    }

    // Check and request permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationPermissionDeniedException(
          'Location permissions are denied. Please grant location access to capture GPS coordinates.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionDeniedException(
        'Location permissions are permanently denied. Please enable location access in app settings.',
      );
    }

    // Get the current position with high accuracy
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (e) {
      throw LocationCaptureException(
        'Failed to capture location. Please ensure you have a clear view of the sky and try again.',
      );
    }
  }

  /// Get current location and convert to CapturedLocation model
  Future<CapturedLocation> getCapturedLocation() async {
    final position = await getCurrentPosition();

    return CapturedLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      heading: position.heading,
      speed: position.speed,
      timestamp: position.timestamp,
    );
  }

  /// Open the device's location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open the app's settings page
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}

/// Exception thrown when location services are disabled
class LocationServiceDisabledException implements Exception {
  final String message;
  LocationServiceDisabledException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown when location permissions are denied
class LocationPermissionDeniedException implements Exception {
  final String message;
  LocationPermissionDeniedException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown when location capture fails
class LocationCaptureException implements Exception {
  final String message;
  LocationCaptureException(this.message);

  @override
  String toString() => message;
}
