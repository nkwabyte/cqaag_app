// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'captured_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CapturedLocation _$CapturedLocationFromJson(Map<String, dynamic> json) =>
    _CapturedLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      address: json['address'] as String?,
    );

Map<String, dynamic> _$CapturedLocationToJson(_CapturedLocation instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'accuracy': instance.accuracy,
      'altitude': instance.altitude,
      'heading': instance.heading,
      'speed': instance.speed,
      'timestamp': instance.timestamp.toIso8601String(),
      'address': instance.address,
    };
