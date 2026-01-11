// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Inspection {

 String get id; String get inspectorId;// Basic Info
 String? get truckNumber; String? get company; double get quantity;// Quality Metrics
 double get moistureContent; int get nutCount; double get kor; List<String> get imageUrls; InspectionStatus get status; String? get notes; DateTime? get completedAt;
/// Create a copy of Inspection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InspectionCopyWith<Inspection> get copyWith => _$InspectionCopyWithImpl<Inspection>(this as Inspection, _$identity);

  /// Serializes this Inspection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Inspection&&(identical(other.id, id) || other.id == id)&&(identical(other.inspectorId, inspectorId) || other.inspectorId == inspectorId)&&(identical(other.truckNumber, truckNumber) || other.truckNumber == truckNumber)&&(identical(other.company, company) || other.company == company)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.moistureContent, moistureContent) || other.moistureContent == moistureContent)&&(identical(other.nutCount, nutCount) || other.nutCount == nutCount)&&(identical(other.kor, kor) || other.kor == kor)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,inspectorId,truckNumber,company,quantity,moistureContent,nutCount,kor,const DeepCollectionEquality().hash(imageUrls),status,notes,completedAt);

@override
String toString() {
  return 'Inspection(id: $id, inspectorId: $inspectorId, truckNumber: $truckNumber, company: $company, quantity: $quantity, moistureContent: $moistureContent, nutCount: $nutCount, kor: $kor, imageUrls: $imageUrls, status: $status, notes: $notes, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $InspectionCopyWith<$Res>  {
  factory $InspectionCopyWith(Inspection value, $Res Function(Inspection) _then) = _$InspectionCopyWithImpl;
@useResult
$Res call({
 String id, String inspectorId, String? truckNumber, String? company, double quantity, double moistureContent, int nutCount, double kor, List<String> imageUrls, InspectionStatus status, String? notes, DateTime? completedAt
});




}
/// @nodoc
class _$InspectionCopyWithImpl<$Res>
    implements $InspectionCopyWith<$Res> {
  _$InspectionCopyWithImpl(this._self, this._then);

  final Inspection _self;
  final $Res Function(Inspection) _then;

/// Create a copy of Inspection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? inspectorId = null,Object? truckNumber = freezed,Object? company = freezed,Object? quantity = null,Object? moistureContent = null,Object? nutCount = null,Object? kor = null,Object? imageUrls = null,Object? status = null,Object? notes = freezed,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,inspectorId: null == inspectorId ? _self.inspectorId : inspectorId // ignore: cast_nullable_to_non_nullable
as String,truckNumber: freezed == truckNumber ? _self.truckNumber : truckNumber // ignore: cast_nullable_to_non_nullable
as String?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,moistureContent: null == moistureContent ? _self.moistureContent : moistureContent // ignore: cast_nullable_to_non_nullable
as double,nutCount: null == nutCount ? _self.nutCount : nutCount // ignore: cast_nullable_to_non_nullable
as int,kor: null == kor ? _self.kor : kor // ignore: cast_nullable_to_non_nullable
as double,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InspectionStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Inspection].
extension InspectionPatterns on Inspection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Inspection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Inspection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Inspection value)  $default,){
final _that = this;
switch (_that) {
case _Inspection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Inspection value)?  $default,){
final _that = this;
switch (_that) {
case _Inspection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String inspectorId,  String? truckNumber,  String? company,  double quantity,  double moistureContent,  int nutCount,  double kor,  List<String> imageUrls,  InspectionStatus status,  String? notes,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Inspection() when $default != null:
return $default(_that.id,_that.inspectorId,_that.truckNumber,_that.company,_that.quantity,_that.moistureContent,_that.nutCount,_that.kor,_that.imageUrls,_that.status,_that.notes,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String inspectorId,  String? truckNumber,  String? company,  double quantity,  double moistureContent,  int nutCount,  double kor,  List<String> imageUrls,  InspectionStatus status,  String? notes,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _Inspection():
return $default(_that.id,_that.inspectorId,_that.truckNumber,_that.company,_that.quantity,_that.moistureContent,_that.nutCount,_that.kor,_that.imageUrls,_that.status,_that.notes,_that.completedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String inspectorId,  String? truckNumber,  String? company,  double quantity,  double moistureContent,  int nutCount,  double kor,  List<String> imageUrls,  InspectionStatus status,  String? notes,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _Inspection() when $default != null:
return $default(_that.id,_that.inspectorId,_that.truckNumber,_that.company,_that.quantity,_that.moistureContent,_that.nutCount,_that.kor,_that.imageUrls,_that.status,_that.notes,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Inspection implements Inspection {
  const _Inspection({required this.id, required this.inspectorId, this.truckNumber, this.company, this.quantity = 0.0, this.moistureContent = 0.0, this.nutCount = 0, this.kor = 0.0, final  List<String> imageUrls = const [], this.status = InspectionStatus.pending, this.notes, this.completedAt}): _imageUrls = imageUrls;
  factory _Inspection.fromJson(Map<String, dynamic> json) => _$InspectionFromJson(json);

@override final  String id;
@override final  String inspectorId;
// Basic Info
@override final  String? truckNumber;
@override final  String? company;
@override@JsonKey() final  double quantity;
// Quality Metrics
@override@JsonKey() final  double moistureContent;
@override@JsonKey() final  int nutCount;
@override@JsonKey() final  double kor;
 final  List<String> _imageUrls;
@override@JsonKey() List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

@override@JsonKey() final  InspectionStatus status;
@override final  String? notes;
@override final  DateTime? completedAt;

/// Create a copy of Inspection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InspectionCopyWith<_Inspection> get copyWith => __$InspectionCopyWithImpl<_Inspection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InspectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Inspection&&(identical(other.id, id) || other.id == id)&&(identical(other.inspectorId, inspectorId) || other.inspectorId == inspectorId)&&(identical(other.truckNumber, truckNumber) || other.truckNumber == truckNumber)&&(identical(other.company, company) || other.company == company)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.moistureContent, moistureContent) || other.moistureContent == moistureContent)&&(identical(other.nutCount, nutCount) || other.nutCount == nutCount)&&(identical(other.kor, kor) || other.kor == kor)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,inspectorId,truckNumber,company,quantity,moistureContent,nutCount,kor,const DeepCollectionEquality().hash(_imageUrls),status,notes,completedAt);

@override
String toString() {
  return 'Inspection(id: $id, inspectorId: $inspectorId, truckNumber: $truckNumber, company: $company, quantity: $quantity, moistureContent: $moistureContent, nutCount: $nutCount, kor: $kor, imageUrls: $imageUrls, status: $status, notes: $notes, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$InspectionCopyWith<$Res> implements $InspectionCopyWith<$Res> {
  factory _$InspectionCopyWith(_Inspection value, $Res Function(_Inspection) _then) = __$InspectionCopyWithImpl;
@override @useResult
$Res call({
 String id, String inspectorId, String? truckNumber, String? company, double quantity, double moistureContent, int nutCount, double kor, List<String> imageUrls, InspectionStatus status, String? notes, DateTime? completedAt
});




}
/// @nodoc
class __$InspectionCopyWithImpl<$Res>
    implements _$InspectionCopyWith<$Res> {
  __$InspectionCopyWithImpl(this._self, this._then);

  final _Inspection _self;
  final $Res Function(_Inspection) _then;

/// Create a copy of Inspection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? inspectorId = null,Object? truckNumber = freezed,Object? company = freezed,Object? quantity = null,Object? moistureContent = null,Object? nutCount = null,Object? kor = null,Object? imageUrls = null,Object? status = null,Object? notes = freezed,Object? completedAt = freezed,}) {
  return _then(_Inspection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,inspectorId: null == inspectorId ? _self.inspectorId : inspectorId // ignore: cast_nullable_to_non_nullable
as String,truckNumber: freezed == truckNumber ? _self.truckNumber : truckNumber // ignore: cast_nullable_to_non_nullable
as String?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,moistureContent: null == moistureContent ? _self.moistureContent : moistureContent // ignore: cast_nullable_to_non_nullable
as double,nutCount: null == nutCount ? _self.nutCount : nutCount // ignore: cast_nullable_to_non_nullable
as int,kor: null == kor ? _self.kor : kor // ignore: cast_nullable_to_non_nullable
as double,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InspectionStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
