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

 String get idCardFrontUrl; String get idCardBackUrl; String get idCardNumber; String get selfieUrl; String? get verifiedBy; DateTime? get dateVerified;
/// Create a copy of VerificationData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationDataCopyWith<VerificationData> get copyWith => _$VerificationDataCopyWithImpl<VerificationData>(this as VerificationData, _$identity);

  /// Serializes this VerificationData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationData&&(identical(other.idCardFrontUrl, idCardFrontUrl) || other.idCardFrontUrl == idCardFrontUrl)&&(identical(other.idCardBackUrl, idCardBackUrl) || other.idCardBackUrl == idCardBackUrl)&&(identical(other.idCardNumber, idCardNumber) || other.idCardNumber == idCardNumber)&&(identical(other.selfieUrl, selfieUrl) || other.selfieUrl == selfieUrl)&&(identical(other.verifiedBy, verifiedBy) || other.verifiedBy == verifiedBy)&&(identical(other.dateVerified, dateVerified) || other.dateVerified == dateVerified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idCardFrontUrl,idCardBackUrl,idCardNumber,selfieUrl,verifiedBy,dateVerified);

@override
String toString() {
  return 'VerificationData(idCardFrontUrl: $idCardFrontUrl, idCardBackUrl: $idCardBackUrl, idCardNumber: $idCardNumber, selfieUrl: $selfieUrl, verifiedBy: $verifiedBy, dateVerified: $dateVerified)';
}


}

/// @nodoc
abstract mixin class $VerificationDataCopyWith<$Res>  {
  factory $VerificationDataCopyWith(VerificationData value, $Res Function(VerificationData) _then) = _$VerificationDataCopyWithImpl;
@useResult
$Res call({
 String idCardFrontUrl, String idCardBackUrl, String idCardNumber, String selfieUrl, String? verifiedBy, DateTime? dateVerified
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
@pragma('vm:prefer-inline') @override $Res call({Object? idCardFrontUrl = null,Object? idCardBackUrl = null,Object? idCardNumber = null,Object? selfieUrl = null,Object? verifiedBy = freezed,Object? dateVerified = freezed,}) {
  return _then(_self.copyWith(
idCardFrontUrl: null == idCardFrontUrl ? _self.idCardFrontUrl : idCardFrontUrl // ignore: cast_nullable_to_non_nullable
as String,idCardBackUrl: null == idCardBackUrl ? _self.idCardBackUrl : idCardBackUrl // ignore: cast_nullable_to_non_nullable
as String,idCardNumber: null == idCardNumber ? _self.idCardNumber : idCardNumber // ignore: cast_nullable_to_non_nullable
as String,selfieUrl: null == selfieUrl ? _self.selfieUrl : selfieUrl // ignore: cast_nullable_to_non_nullable
as String,verifiedBy: freezed == verifiedBy ? _self.verifiedBy : verifiedBy // ignore: cast_nullable_to_non_nullable
as String?,dateVerified: freezed == dateVerified ? _self.dateVerified : dateVerified // ignore: cast_nullable_to_non_nullable
as DateTime?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String idCardFrontUrl,  String idCardBackUrl,  String idCardNumber,  String selfieUrl,  String? verifiedBy,  DateTime? dateVerified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerificationData() when $default != null:
return $default(_that.idCardFrontUrl,_that.idCardBackUrl,_that.idCardNumber,_that.selfieUrl,_that.verifiedBy,_that.dateVerified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String idCardFrontUrl,  String idCardBackUrl,  String idCardNumber,  String selfieUrl,  String? verifiedBy,  DateTime? dateVerified)  $default,) {final _that = this;
switch (_that) {
case _VerificationData():
return $default(_that.idCardFrontUrl,_that.idCardBackUrl,_that.idCardNumber,_that.selfieUrl,_that.verifiedBy,_that.dateVerified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String idCardFrontUrl,  String idCardBackUrl,  String idCardNumber,  String selfieUrl,  String? verifiedBy,  DateTime? dateVerified)?  $default,) {final _that = this;
switch (_that) {
case _VerificationData() when $default != null:
return $default(_that.idCardFrontUrl,_that.idCardBackUrl,_that.idCardNumber,_that.selfieUrl,_that.verifiedBy,_that.dateVerified);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _VerificationData implements VerificationData {
  const _VerificationData({required this.idCardFrontUrl, required this.idCardBackUrl, required this.idCardNumber, required this.selfieUrl, this.verifiedBy, this.dateVerified});
  factory _VerificationData.fromJson(Map<String, dynamic> json) => _$VerificationDataFromJson(json);

@override final  String idCardFrontUrl;
@override final  String idCardBackUrl;
@override final  String idCardNumber;
@override final  String selfieUrl;
@override final  String? verifiedBy;
@override final  DateTime? dateVerified;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerificationData&&(identical(other.idCardFrontUrl, idCardFrontUrl) || other.idCardFrontUrl == idCardFrontUrl)&&(identical(other.idCardBackUrl, idCardBackUrl) || other.idCardBackUrl == idCardBackUrl)&&(identical(other.idCardNumber, idCardNumber) || other.idCardNumber == idCardNumber)&&(identical(other.selfieUrl, selfieUrl) || other.selfieUrl == selfieUrl)&&(identical(other.verifiedBy, verifiedBy) || other.verifiedBy == verifiedBy)&&(identical(other.dateVerified, dateVerified) || other.dateVerified == dateVerified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idCardFrontUrl,idCardBackUrl,idCardNumber,selfieUrl,verifiedBy,dateVerified);

@override
String toString() {
  return 'VerificationData(idCardFrontUrl: $idCardFrontUrl, idCardBackUrl: $idCardBackUrl, idCardNumber: $idCardNumber, selfieUrl: $selfieUrl, verifiedBy: $verifiedBy, dateVerified: $dateVerified)';
}


}

/// @nodoc
abstract mixin class _$VerificationDataCopyWith<$Res> implements $VerificationDataCopyWith<$Res> {
  factory _$VerificationDataCopyWith(_VerificationData value, $Res Function(_VerificationData) _then) = __$VerificationDataCopyWithImpl;
@override @useResult
$Res call({
 String idCardFrontUrl, String idCardBackUrl, String idCardNumber, String selfieUrl, String? verifiedBy, DateTime? dateVerified
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
@override @pragma('vm:prefer-inline') $Res call({Object? idCardFrontUrl = null,Object? idCardBackUrl = null,Object? idCardNumber = null,Object? selfieUrl = null,Object? verifiedBy = freezed,Object? dateVerified = freezed,}) {
  return _then(_VerificationData(
idCardFrontUrl: null == idCardFrontUrl ? _self.idCardFrontUrl : idCardFrontUrl // ignore: cast_nullable_to_non_nullable
as String,idCardBackUrl: null == idCardBackUrl ? _self.idCardBackUrl : idCardBackUrl // ignore: cast_nullable_to_non_nullable
as String,idCardNumber: null == idCardNumber ? _self.idCardNumber : idCardNumber // ignore: cast_nullable_to_non_nullable
as String,selfieUrl: null == selfieUrl ? _self.selfieUrl : selfieUrl // ignore: cast_nullable_to_non_nullable
as String,verifiedBy: freezed == verifiedBy ? _self.verifiedBy : verifiedBy // ignore: cast_nullable_to_non_nullable
as String?,dateVerified: freezed == dateVerified ? _self.dateVerified : dateVerified // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
