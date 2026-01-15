import 'package:freezed_annotation/freezed_annotation.dart';

part 'captured_location.freezed.dart';
part 'captured_location.g.dart';

/// Represents a GPS-captured location with full geolocation metadata
@freezed
abstract class CapturedLocation with _$CapturedLocation {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CapturedLocation({
    /// GPS latitude coordinate
    required double latitude,

    /// GPS longitude coordinate
    required double longitude,

    /// Accuracy of the location in meters
    required double accuracy,

    /// Altitude in meters (nullable - may not be available)
    double? altitude,

    /// Heading in degrees (nullable - may not be available)
    double? heading,

    /// Speed in meters per second (nullable - may not be available)
    double? speed,

    /// Timestamp when the location was captured
    required DateTime timestamp,

    /// Reverse geocoded address (optional, nullable)
    String? address,
  }) = _CapturedLocation;

  factory CapturedLocation.fromJson(Map<String, dynamic> json) => _$CapturedLocationFromJson(json);
}
