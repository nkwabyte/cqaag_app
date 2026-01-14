// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'captured_location.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CapturedLocation {

/// GPS latitude coordinate
 double get latitude;/// GPS longitude coordinate
 double get longitude;/// Accuracy of the location in meters
 double get accuracy;/// Altitude in meters (nullable - may not be available)
 double? get altitude;/// Heading in degrees (nullable - may not be available)
 double? get heading;/// Speed in meters per second (nullable - may not be available)
 double? get speed;/// Timestamp when the location was captured
 DateTime get timestamp;/// Reverse geocoded address (optional, nullable)
 String? get address;
/// Create a copy of CapturedLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CapturedLocationCopyWith<CapturedLocation> get copyWith => _$CapturedLocationCopyWithImpl<CapturedLocation>(this as CapturedLocation, _$identity);

  /// Serializes this CapturedLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CapturedLocation&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.altitude, altitude) || other.altitude == altitude)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,accuracy,altitude,heading,speed,timestamp,address);

@override
String toString() {
  return 'CapturedLocation(latitude: $latitude, longitude: $longitude, accuracy: $accuracy, altitude: $altitude, heading: $heading, speed: $speed, timestamp: $timestamp, address: $address)';
}


}

/// @nodoc
abstract mixin class $CapturedLocationCopyWith<$Res>  {
  factory $CapturedLocationCopyWith(CapturedLocation value, $Res Function(CapturedLocation) _then) = _$CapturedLocationCopyWithImpl;
@useResult
$Res call({
 double latitude, double longitude, double accuracy, double? altitude, double? heading, double? speed, DateTime timestamp, String? address
});




}
/// @nodoc
class _$CapturedLocationCopyWithImpl<$Res>
    implements $CapturedLocationCopyWith<$Res> {
  _$CapturedLocationCopyWithImpl(this._self, this._then);

  final CapturedLocation _self;
  final $Res Function(CapturedLocation) _then;

/// Create a copy of CapturedLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitude = null,Object? longitude = null,Object? accuracy = null,Object? altitude = freezed,Object? heading = freezed,Object? speed = freezed,Object? timestamp = null,Object? address = freezed,}) {
  return _then(_self.copyWith(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,altitude: freezed == altitude ? _self.altitude : altitude // ignore: cast_nullable_to_non_nullable
as double?,heading: freezed == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double?,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CapturedLocation].
extension CapturedLocationPatterns on CapturedLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CapturedLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CapturedLocation() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CapturedLocation value)  $default,){
final _that = this;
switch (_that) {
case _CapturedLocation():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CapturedLocation value)?  $default,){
final _that = this;
switch (_that) {
case _CapturedLocation() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double latitude,  double longitude,  double accuracy,  double? altitude,  double? heading,  double? speed,  DateTime timestamp,  String? address)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CapturedLocation() when $default != null:
return $default(_that.latitude,_that.longitude,_that.accuracy,_that.altitude,_that.heading,_that.speed,_that.timestamp,_that.address);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double latitude,  double longitude,  double accuracy,  double? altitude,  double? heading,  double? speed,  DateTime timestamp,  String? address)  $default,) {final _that = this;
switch (_that) {
case _CapturedLocation():
return $default(_that.latitude,_that.longitude,_that.accuracy,_that.altitude,_that.heading,_that.speed,_that.timestamp,_that.address);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double latitude,  double longitude,  double accuracy,  double? altitude,  double? heading,  double? speed,  DateTime timestamp,  String? address)?  $default,) {final _that = this;
switch (_that) {
case _CapturedLocation() when $default != null:
return $default(_that.latitude,_that.longitude,_that.accuracy,_that.altitude,_that.heading,_that.speed,_that.timestamp,_that.address);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CapturedLocation implements CapturedLocation {
  const _CapturedLocation({required this.latitude, required this.longitude, required this.accuracy, this.altitude, this.heading, this.speed, required this.timestamp, this.address});
  factory _CapturedLocation.fromJson(Map<String, dynamic> json) => _$CapturedLocationFromJson(json);

/// GPS latitude coordinate
@override final  double latitude;
/// GPS longitude coordinate
@override final  double longitude;
/// Accuracy of the location in meters
@override final  double accuracy;
/// Altitude in meters (nullable - may not be available)
@override final  double? altitude;
/// Heading in degrees (nullable - may not be available)
@override final  double? heading;
/// Speed in meters per second (nullable - may not be available)
@override final  double? speed;
/// Timestamp when the location was captured
@override final  DateTime timestamp;
/// Reverse geocoded address (optional, nullable)
@override final  String? address;

/// Create a copy of CapturedLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CapturedLocationCopyWith<_CapturedLocation> get copyWith => __$CapturedLocationCopyWithImpl<_CapturedLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CapturedLocationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CapturedLocation&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.altitude, altitude) || other.altitude == altitude)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,accuracy,altitude,heading,speed,timestamp,address);

@override
String toString() {
  return 'CapturedLocation(latitude: $latitude, longitude: $longitude, accuracy: $accuracy, altitude: $altitude, heading: $heading, speed: $speed, timestamp: $timestamp, address: $address)';
}


}

/// @nodoc
abstract mixin class _$CapturedLocationCopyWith<$Res> implements $CapturedLocationCopyWith<$Res> {
  factory _$CapturedLocationCopyWith(_CapturedLocation value, $Res Function(_CapturedLocation) _then) = __$CapturedLocationCopyWithImpl;
@override @useResult
$Res call({
 double latitude, double longitude, double accuracy, double? altitude, double? heading, double? speed, DateTime timestamp, String? address
});




}
/// @nodoc
class __$CapturedLocationCopyWithImpl<$Res>
    implements _$CapturedLocationCopyWith<$Res> {
  __$CapturedLocationCopyWithImpl(this._self, this._then);

  final _CapturedLocation _self;
  final $Res Function(_CapturedLocation) _then;

/// Create a copy of CapturedLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitude = null,Object? longitude = null,Object? accuracy = null,Object? altitude = freezed,Object? heading = freezed,Object? speed = freezed,Object? timestamp = null,Object? address = freezed,}) {
  return _then(_CapturedLocation(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,altitude: freezed == altitude ? _self.altitude : altitude // ignore: cast_nullable_to_non_nullable
as double?,heading: freezed == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double?,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
