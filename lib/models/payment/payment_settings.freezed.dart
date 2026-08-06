// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentSettings {

/// Registration fee amount.
 double get registrationFee;/// ISO currency code. Ghana Cedis unless changed.
 String get currency;/// Mobile Money number applicants send the fee to.
 String get momoNumber;/// Network the MoMo number belongs to.
 String get momoNetwork;/// Name registered on the MoMo account, so applicants can confirm it.
 String get momoAccountName;/// When the settings were last changed.
 DateTime? get updatedAt;/// UID of the admin who last changed them.
 String? get updatedBy;
/// Create a copy of PaymentSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentSettingsCopyWith<PaymentSettings> get copyWith => _$PaymentSettingsCopyWithImpl<PaymentSettings>(this as PaymentSettings, _$identity);

  /// Serializes this PaymentSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentSettings&&(identical(other.registrationFee, registrationFee) || other.registrationFee == registrationFee)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.momoNumber, momoNumber) || other.momoNumber == momoNumber)&&(identical(other.momoNetwork, momoNetwork) || other.momoNetwork == momoNetwork)&&(identical(other.momoAccountName, momoAccountName) || other.momoAccountName == momoAccountName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,registrationFee,currency,momoNumber,momoNetwork,momoAccountName,updatedAt,updatedBy);

@override
String toString() {
  return 'PaymentSettings(registrationFee: $registrationFee, currency: $currency, momoNumber: $momoNumber, momoNetwork: $momoNetwork, momoAccountName: $momoAccountName, updatedAt: $updatedAt, updatedBy: $updatedBy)';
}


}

/// @nodoc
abstract mixin class $PaymentSettingsCopyWith<$Res>  {
  factory $PaymentSettingsCopyWith(PaymentSettings value, $Res Function(PaymentSettings) _then) = _$PaymentSettingsCopyWithImpl;
@useResult
$Res call({
 double registrationFee, String currency, String momoNumber, String momoNetwork, String momoAccountName, DateTime? updatedAt, String? updatedBy
});




}
/// @nodoc
class _$PaymentSettingsCopyWithImpl<$Res>
    implements $PaymentSettingsCopyWith<$Res> {
  _$PaymentSettingsCopyWithImpl(this._self, this._then);

  final PaymentSettings _self;
  final $Res Function(PaymentSettings) _then;

/// Create a copy of PaymentSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? registrationFee = null,Object? currency = null,Object? momoNumber = null,Object? momoNetwork = null,Object? momoAccountName = null,Object? updatedAt = freezed,Object? updatedBy = freezed,}) {
  return _then(_self.copyWith(
registrationFee: null == registrationFee ? _self.registrationFee : registrationFee // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,momoNumber: null == momoNumber ? _self.momoNumber : momoNumber // ignore: cast_nullable_to_non_nullable
as String,momoNetwork: null == momoNetwork ? _self.momoNetwork : momoNetwork // ignore: cast_nullable_to_non_nullable
as String,momoAccountName: null == momoAccountName ? _self.momoAccountName : momoAccountName // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedBy: freezed == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentSettings].
extension PaymentSettingsPatterns on PaymentSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentSettings value)  $default,){
final _that = this;
switch (_that) {
case _PaymentSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentSettings value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double registrationFee,  String currency,  String momoNumber,  String momoNetwork,  String momoAccountName,  DateTime? updatedAt,  String? updatedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentSettings() when $default != null:
return $default(_that.registrationFee,_that.currency,_that.momoNumber,_that.momoNetwork,_that.momoAccountName,_that.updatedAt,_that.updatedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double registrationFee,  String currency,  String momoNumber,  String momoNetwork,  String momoAccountName,  DateTime? updatedAt,  String? updatedBy)  $default,) {final _that = this;
switch (_that) {
case _PaymentSettings():
return $default(_that.registrationFee,_that.currency,_that.momoNumber,_that.momoNetwork,_that.momoAccountName,_that.updatedAt,_that.updatedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double registrationFee,  String currency,  String momoNumber,  String momoNetwork,  String momoAccountName,  DateTime? updatedAt,  String? updatedBy)?  $default,) {final _that = this;
switch (_that) {
case _PaymentSettings() when $default != null:
return $default(_that.registrationFee,_that.currency,_that.momoNumber,_that.momoNetwork,_that.momoAccountName,_that.updatedAt,_that.updatedBy);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _PaymentSettings extends PaymentSettings {
  const _PaymentSettings({this.registrationFee = 500.0, this.currency = 'GHS', this.momoNumber = '+233 55 333 0931', this.momoNetwork = 'MTN', this.momoAccountName = 'Amoafo Ebenezer', this.updatedAt, this.updatedBy}): super._();
  factory _PaymentSettings.fromJson(Map<String, dynamic> json) => _$PaymentSettingsFromJson(json);

/// Registration fee amount.
@override@JsonKey() final  double registrationFee;
/// ISO currency code. Ghana Cedis unless changed.
@override@JsonKey() final  String currency;
/// Mobile Money number applicants send the fee to.
@override@JsonKey() final  String momoNumber;
/// Network the MoMo number belongs to.
@override@JsonKey() final  String momoNetwork;
/// Name registered on the MoMo account, so applicants can confirm it.
@override@JsonKey() final  String momoAccountName;
/// When the settings were last changed.
@override final  DateTime? updatedAt;
/// UID of the admin who last changed them.
@override final  String? updatedBy;

/// Create a copy of PaymentSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentSettingsCopyWith<_PaymentSettings> get copyWith => __$PaymentSettingsCopyWithImpl<_PaymentSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentSettings&&(identical(other.registrationFee, registrationFee) || other.registrationFee == registrationFee)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.momoNumber, momoNumber) || other.momoNumber == momoNumber)&&(identical(other.momoNetwork, momoNetwork) || other.momoNetwork == momoNetwork)&&(identical(other.momoAccountName, momoAccountName) || other.momoAccountName == momoAccountName)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,registrationFee,currency,momoNumber,momoNetwork,momoAccountName,updatedAt,updatedBy);

@override
String toString() {
  return 'PaymentSettings(registrationFee: $registrationFee, currency: $currency, momoNumber: $momoNumber, momoNetwork: $momoNetwork, momoAccountName: $momoAccountName, updatedAt: $updatedAt, updatedBy: $updatedBy)';
}


}

/// @nodoc
abstract mixin class _$PaymentSettingsCopyWith<$Res> implements $PaymentSettingsCopyWith<$Res> {
  factory _$PaymentSettingsCopyWith(_PaymentSettings value, $Res Function(_PaymentSettings) _then) = __$PaymentSettingsCopyWithImpl;
@override @useResult
$Res call({
 double registrationFee, String currency, String momoNumber, String momoNetwork, String momoAccountName, DateTime? updatedAt, String? updatedBy
});




}
/// @nodoc
class __$PaymentSettingsCopyWithImpl<$Res>
    implements _$PaymentSettingsCopyWith<$Res> {
  __$PaymentSettingsCopyWithImpl(this._self, this._then);

  final _PaymentSettings _self;
  final $Res Function(_PaymentSettings) _then;

/// Create a copy of PaymentSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? registrationFee = null,Object? currency = null,Object? momoNumber = null,Object? momoNetwork = null,Object? momoAccountName = null,Object? updatedAt = freezed,Object? updatedBy = freezed,}) {
  return _then(_PaymentSettings(
registrationFee: null == registrationFee ? _self.registrationFee : registrationFee // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,momoNumber: null == momoNumber ? _self.momoNumber : momoNumber // ignore: cast_nullable_to_non_nullable
as String,momoNetwork: null == momoNetwork ? _self.momoNetwork : momoNetwork // ignore: cast_nullable_to_non_nullable
as String,momoAccountName: null == momoAccountName ? _self.momoAccountName : momoAccountName // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedBy: freezed == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
