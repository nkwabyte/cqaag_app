// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verification_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VerificationData {

/// Ghana Card personal ID number, in the form `GHA-#########-#`.
 String get idCardNumber;/// UID of the admin who verified the number.
 String? get verifiedBy;/// When the number was verified.
 DateTime? get dateVerified;/// Legacy, from the superseded document-upload flow. Never written.
 String? get idCardFrontUrl;/// Legacy, from the superseded document-upload flow. Never written.
 String? get idCardBackUrl;/// Legacy, from the superseded document-upload flow. Never written.
 String? get selfieUrl;
/// Create a copy of VerificationData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationDataCopyWith<VerificationData> get copyWith => _$VerificationDataCopyWithImpl<VerificationData>(this as VerificationData, _$identity);

  /// Serializes this VerificationData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationData&&(identical(other.idCardNumber, idCardNumber) || other.idCardNumber == idCardNumber)&&(identical(other.verifiedBy, verifiedBy) || other.verifiedBy == verifiedBy)&&(identical(other.dateVerified, dateVerified) || other.dateVerified == dateVerified)&&(identical(other.idCardFrontUrl, idCardFrontUrl) || other.idCardFrontUrl == idCardFrontUrl)&&(identical(other.idCardBackUrl, idCardBackUrl) || other.idCardBackUrl == idCardBackUrl)&&(identical(other.selfieUrl, selfieUrl) || other.selfieUrl == selfieUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idCardNumber,verifiedBy,dateVerified,idCardFrontUrl,idCardBackUrl,selfieUrl);

@override
String toString() {
  return 'VerificationData(idCardNumber: $idCardNumber, verifiedBy: $verifiedBy, dateVerified: $dateVerified, idCardFrontUrl: $idCardFrontUrl, idCardBackUrl: $idCardBackUrl, selfieUrl: $selfieUrl)';
}


}

/// @nodoc
abstract mixin class $VerificationDataCopyWith<$Res>  {
  factory $VerificationDataCopyWith(VerificationData value, $Res Function(VerificationData) _then) = _$VerificationDataCopyWithImpl;
@useResult
$Res call({
 String idCardNumber, String? verifiedBy, DateTime? dateVerified, String? idCardFrontUrl, String? idCardBackUrl, String? selfieUrl
});




}
/// @nodoc
class _$VerificationDataCopyWithImpl<$Res>
    implements $VerificationDataCopyWith<$Res> {
  _$VerificationDataCopyWithImpl(this._self, this._then);

  final VerificationData _self;
  final $Res Function(VerificationData) _then;

/// Create a copy of VerificationData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idCardNumber = null,Object? verifiedBy = freezed,Object? dateVerified = freezed,Object? idCardFrontUrl = freezed,Object? idCardBackUrl = freezed,Object? selfieUrl = freezed,}) {
  return _then(_self.copyWith(
idCardNumber: null == idCardNumber ? _self.idCardNumber : idCardNumber // ignore: cast_nullable_to_non_nullable
as String,verifiedBy: freezed == verifiedBy ? _self.verifiedBy : verifiedBy // ignore: cast_nullable_to_non_nullable
as String?,dateVerified: freezed == dateVerified ? _self.dateVerified : dateVerified // ignore: cast_nullable_to_non_nullable
as DateTime?,idCardFrontUrl: freezed == idCardFrontUrl ? _self.idCardFrontUrl : idCardFrontUrl // ignore: cast_nullable_to_non_nullable
as String?,idCardBackUrl: freezed == idCardBackUrl ? _self.idCardBackUrl : idCardBackUrl // ignore: cast_nullable_to_non_nullable
as String?,selfieUrl: freezed == selfieUrl ? _self.selfieUrl : selfieUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VerificationData].
extension VerificationDataPatterns on VerificationData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerificationData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerificationData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerificationData value)  $default,){
final _that = this;
switch (_that) {
case _VerificationData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerificationData value)?  $default,){
final _that = this;
switch (_that) {
case _VerificationData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String idCardNumber,  String? verifiedBy,  DateTime? dateVerified,  String? idCardFrontUrl,  String? idCardBackUrl,  String? selfieUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerificationData() when $default != null:
return $default(_that.idCardNumber,_that.verifiedBy,_that.dateVerified,_that.idCardFrontUrl,_that.idCardBackUrl,_that.selfieUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String idCardNumber,  String? verifiedBy,  DateTime? dateVerified,  String? idCardFrontUrl,  String? idCardBackUrl,  String? selfieUrl)  $default,) {final _that = this;
switch (_that) {
case _VerificationData():
return $default(_that.idCardNumber,_that.verifiedBy,_that.dateVerified,_that.idCardFrontUrl,_that.idCardBackUrl,_that.selfieUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String idCardNumber,  String? verifiedBy,  DateTime? dateVerified,  String? idCardFrontUrl,  String? idCardBackUrl,  String? selfieUrl)?  $default,) {final _that = this;
switch (_that) {
case _VerificationData() when $default != null:
return $default(_that.idCardNumber,_that.verifiedBy,_that.dateVerified,_that.idCardFrontUrl,_that.idCardBackUrl,_that.selfieUrl);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _VerificationData extends VerificationData {
  const _VerificationData({required this.idCardNumber, this.verifiedBy, this.dateVerified, this.idCardFrontUrl, this.idCardBackUrl, this.selfieUrl}): super._();
  factory _VerificationData.fromJson(Map<String, dynamic> json) => _$VerificationDataFromJson(json);

/// Ghana Card personal ID number, in the form `GHA-#########-#`.
@override final  String idCardNumber;
/// UID of the admin who verified the number.
@override final  String? verifiedBy;
/// When the number was verified.
@override final  DateTime? dateVerified;
/// Legacy, from the superseded document-upload flow. Never written.
@override final  String? idCardFrontUrl;
/// Legacy, from the superseded document-upload flow. Never written.
@override final  String? idCardBackUrl;
/// Legacy, from the superseded document-upload flow. Never written.
@override final  String? selfieUrl;

/// Create a copy of VerificationData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerificationDataCopyWith<_VerificationData> get copyWith => __$VerificationDataCopyWithImpl<_VerificationData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerificationDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerificationData&&(identical(other.idCardNumber, idCardNumber) || other.idCardNumber == idCardNumber)&&(identical(other.verifiedBy, verifiedBy) || other.verifiedBy == verifiedBy)&&(identical(other.dateVerified, dateVerified) || other.dateVerified == dateVerified)&&(identical(other.idCardFrontUrl, idCardFrontUrl) || other.idCardFrontUrl == idCardFrontUrl)&&(identical(other.idCardBackUrl, idCardBackUrl) || other.idCardBackUrl == idCardBackUrl)&&(identical(other.selfieUrl, selfieUrl) || other.selfieUrl == selfieUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idCardNumber,verifiedBy,dateVerified,idCardFrontUrl,idCardBackUrl,selfieUrl);

@override
String toString() {
  return 'VerificationData(idCardNumber: $idCardNumber, verifiedBy: $verifiedBy, dateVerified: $dateVerified, idCardFrontUrl: $idCardFrontUrl, idCardBackUrl: $idCardBackUrl, selfieUrl: $selfieUrl)';
}


}

/// @nodoc
abstract mixin class _$VerificationDataCopyWith<$Res> implements $VerificationDataCopyWith<$Res> {
  factory _$VerificationDataCopyWith(_VerificationData value, $Res Function(_VerificationData) _then) = __$VerificationDataCopyWithImpl;
@override @useResult
$Res call({
 String idCardNumber, String? verifiedBy, DateTime? dateVerified, String? idCardFrontUrl, String? idCardBackUrl, String? selfieUrl
});




}
/// @nodoc
class __$VerificationDataCopyWithImpl<$Res>
    implements _$VerificationDataCopyWith<$Res> {
  __$VerificationDataCopyWithImpl(this._self, this._then);

  final _VerificationData _self;
  final $Res Function(_VerificationData) _then;

/// Create a copy of VerificationData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idCardNumber = null,Object? verifiedBy = freezed,Object? dateVerified = freezed,Object? idCardFrontUrl = freezed,Object? idCardBackUrl = freezed,Object? selfieUrl = freezed,}) {
  return _then(_VerificationData(
idCardNumber: null == idCardNumber ? _self.idCardNumber : idCardNumber // ignore: cast_nullable_to_non_nullable
as String,verifiedBy: freezed == verifiedBy ? _self.verifiedBy : verifiedBy // ignore: cast_nullable_to_non_nullable
as String?,dateVerified: freezed == dateVerified ? _self.dateVerified : dateVerified // ignore: cast_nullable_to_non_nullable
as DateTime?,idCardFrontUrl: freezed == idCardFrontUrl ? _self.idCardFrontUrl : idCardFrontUrl // ignore: cast_nullable_to_non_nullable
as String?,idCardBackUrl: freezed == idCardBackUrl ? _self.idCardBackUrl : idCardBackUrl // ignore: cast_nullable_to_non_nullable
as String?,selfieUrl: freezed == selfieUrl ? _self.selfieUrl : selfieUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
