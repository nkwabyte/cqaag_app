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

 String get id;// Firebase auto-generated document ID
 String? get inspectionId;// Custom inspection ID (e.g., INS-20260114-4X9P)
 String get inspectorId;// Batch and Farmer Info
 String? get batchId; String? get farmerName;// Acts as Supplier/Farmer Name
 String? get location;// Text-based location (e.g., "Wenchi District, Bono Region")
 CapturedLocation? get capturedLocation;// GPS-captured location with coordinates
 String? get town; String? get chapter;// Basic Info
 String? get truckNumber; String? get company; double get quantity; int get quantityBags;// Quality Metrics
 double get moistureContent; int get nutCount;// Raw Nut Count
 double get kor;// Defect Metrics
 double get goodKernels; double get spottedKernels; double get immatureKernels; double get oilyKernels; double get voidKernels; double get totalDefective; double get totalSpotted; List<String> get imageUrls; InspectionStatus get status; String? get notes;// Timestamps
 DateTime? get createdAt; DateTime? get updatedAt; DateTime? get completedAt;
/// Create a copy of Inspection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InspectionCopyWith<Inspection> get copyWith => _$InspectionCopyWithImpl<Inspection>(this as Inspection, _$identity);

  /// Serializes this Inspection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Inspection&&(identical(other.id, id) || other.id == id)&&(identical(other.inspectionId, inspectionId) || other.inspectionId == inspectionId)&&(identical(other.inspectorId, inspectorId) || other.inspectorId == inspectorId)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.farmerName, farmerName) || other.farmerName == farmerName)&&(identical(other.location, location) || other.location == location)&&(identical(other.capturedLocation, capturedLocation) || other.capturedLocation == capturedLocation)&&(identical(other.town, town) || other.town == town)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.truckNumber, truckNumber) || other.truckNumber == truckNumber)&&(identical(other.company, company) || other.company == company)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.quantityBags, quantityBags) || other.quantityBags == quantityBags)&&(identical(other.moistureContent, moistureContent) || other.moistureContent == moistureContent)&&(identical(other.nutCount, nutCount) || other.nutCount == nutCount)&&(identical(other.kor, kor) || other.kor == kor)&&(identical(other.goodKernels, goodKernels) || other.goodKernels == goodKernels)&&(identical(other.spottedKernels, spottedKernels) || other.spottedKernels == spottedKernels)&&(identical(other.immatureKernels, immatureKernels) || other.immatureKernels == immatureKernels)&&(identical(other.oilyKernels, oilyKernels) || other.oilyKernels == oilyKernels)&&(identical(other.voidKernels, voidKernels) || other.voidKernels == voidKernels)&&(identical(other.totalDefective, totalDefective) || other.totalDefective == totalDefective)&&(identical(other.totalSpotted, totalSpotted) || other.totalSpotted == totalSpotted)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,inspectionId,inspectorId,batchId,farmerName,location,capturedLocation,town,chapter,truckNumber,company,quantity,quantityBags,moistureContent,nutCount,kor,goodKernels,spottedKernels,immatureKernels,oilyKernels,voidKernels,totalDefective,totalSpotted,const DeepCollectionEquality().hash(imageUrls),status,notes,createdAt,updatedAt,completedAt]);

@override
String toString() {
  return 'Inspection(id: $id, inspectionId: $inspectionId, inspectorId: $inspectorId, batchId: $batchId, farmerName: $farmerName, location: $location, capturedLocation: $capturedLocation, town: $town, chapter: $chapter, truckNumber: $truckNumber, company: $company, quantity: $quantity, quantityBags: $quantityBags, moistureContent: $moistureContent, nutCount: $nutCount, kor: $kor, goodKernels: $goodKernels, spottedKernels: $spottedKernels, immatureKernels: $immatureKernels, oilyKernels: $oilyKernels, voidKernels: $voidKernels, totalDefective: $totalDefective, totalSpotted: $totalSpotted, imageUrls: $imageUrls, status: $status, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $InspectionCopyWith<$Res>  {
  factory $InspectionCopyWith(Inspection value, $Res Function(Inspection) _then) = _$InspectionCopyWithImpl;
@useResult
$Res call({
 String id, String? inspectionId, String inspectorId, String? batchId, String? farmerName, String? location, CapturedLocation? capturedLocation, String? town, String? chapter, String? truckNumber, String? company, double quantity, int quantityBags, double moistureContent, int nutCount, double kor, double goodKernels, double spottedKernels, double immatureKernels, double oilyKernels, double voidKernels, double totalDefective, double totalSpotted, List<String> imageUrls, InspectionStatus status, String? notes, DateTime? createdAt, DateTime? updatedAt, DateTime? completedAt
});


$CapturedLocationCopyWith<$Res>? get capturedLocation;

}
/// @nodoc
class _$InspectionCopyWithImpl<$Res>
    implements $InspectionCopyWith<$Res> {
  _$InspectionCopyWithImpl(this._self, this._then);

  final Inspection _self;
  final $Res Function(Inspection) _then;

/// Create a copy of Inspection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? inspectionId = freezed,Object? inspectorId = null,Object? batchId = freezed,Object? farmerName = freezed,Object? location = freezed,Object? capturedLocation = freezed,Object? town = freezed,Object? chapter = freezed,Object? truckNumber = freezed,Object? company = freezed,Object? quantity = null,Object? quantityBags = null,Object? moistureContent = null,Object? nutCount = null,Object? kor = null,Object? goodKernels = null,Object? spottedKernels = null,Object? immatureKernels = null,Object? oilyKernels = null,Object? voidKernels = null,Object? totalDefective = null,Object? totalSpotted = null,Object? imageUrls = null,Object? status = null,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,inspectionId: freezed == inspectionId ? _self.inspectionId : inspectionId // ignore: cast_nullable_to_non_nullable
as String?,inspectorId: null == inspectorId ? _self.inspectorId : inspectorId // ignore: cast_nullable_to_non_nullable
as String,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as String?,farmerName: freezed == farmerName ? _self.farmerName : farmerName // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,capturedLocation: freezed == capturedLocation ? _self.capturedLocation : capturedLocation // ignore: cast_nullable_to_non_nullable
as CapturedLocation?,town: freezed == town ? _self.town : town // ignore: cast_nullable_to_non_nullable
as String?,chapter: freezed == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as String?,truckNumber: freezed == truckNumber ? _self.truckNumber : truckNumber // ignore: cast_nullable_to_non_nullable
as String?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,quantityBags: null == quantityBags ? _self.quantityBags : quantityBags // ignore: cast_nullable_to_non_nullable
as int,moistureContent: null == moistureContent ? _self.moistureContent : moistureContent // ignore: cast_nullable_to_non_nullable
as double,nutCount: null == nutCount ? _self.nutCount : nutCount // ignore: cast_nullable_to_non_nullable
as int,kor: null == kor ? _self.kor : kor // ignore: cast_nullable_to_non_nullable
as double,goodKernels: null == goodKernels ? _self.goodKernels : goodKernels // ignore: cast_nullable_to_non_nullable
as double,spottedKernels: null == spottedKernels ? _self.spottedKernels : spottedKernels // ignore: cast_nullable_to_non_nullable
as double,immatureKernels: null == immatureKernels ? _self.immatureKernels : immatureKernels // ignore: cast_nullable_to_non_nullable
as double,oilyKernels: null == oilyKernels ? _self.oilyKernels : oilyKernels // ignore: cast_nullable_to_non_nullable
as double,voidKernels: null == voidKernels ? _self.voidKernels : voidKernels // ignore: cast_nullable_to_non_nullable
as double,totalDefective: null == totalDefective ? _self.totalDefective : totalDefective // ignore: cast_nullable_to_non_nullable
as double,totalSpotted: null == totalSpotted ? _self.totalSpotted : totalSpotted // ignore: cast_nullable_to_non_nullable
as double,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InspectionStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Inspection
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CapturedLocationCopyWith<$Res>? get capturedLocation {
    if (_self.capturedLocation == null) {
    return null;
  }

  return $CapturedLocationCopyWith<$Res>(_self.capturedLocation!, (value) {
    return _then(_self.copyWith(capturedLocation: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? inspectionId,  String inspectorId,  String? batchId,  String? farmerName,  String? location,  CapturedLocation? capturedLocation,  String? town,  String? chapter,  String? truckNumber,  String? company,  double quantity,  int quantityBags,  double moistureContent,  int nutCount,  double kor,  double goodKernels,  double spottedKernels,  double immatureKernels,  double oilyKernels,  double voidKernels,  double totalDefective,  double totalSpotted,  List<String> imageUrls,  InspectionStatus status,  String? notes,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Inspection() when $default != null:
return $default(_that.id,_that.inspectionId,_that.inspectorId,_that.batchId,_that.farmerName,_that.location,_that.capturedLocation,_that.town,_that.chapter,_that.truckNumber,_that.company,_that.quantity,_that.quantityBags,_that.moistureContent,_that.nutCount,_that.kor,_that.goodKernels,_that.spottedKernels,_that.immatureKernels,_that.oilyKernels,_that.voidKernels,_that.totalDefective,_that.totalSpotted,_that.imageUrls,_that.status,_that.notes,_that.createdAt,_that.updatedAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? inspectionId,  String inspectorId,  String? batchId,  String? farmerName,  String? location,  CapturedLocation? capturedLocation,  String? town,  String? chapter,  String? truckNumber,  String? company,  double quantity,  int quantityBags,  double moistureContent,  int nutCount,  double kor,  double goodKernels,  double spottedKernels,  double immatureKernels,  double oilyKernels,  double voidKernels,  double totalDefective,  double totalSpotted,  List<String> imageUrls,  InspectionStatus status,  String? notes,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _Inspection():
return $default(_that.id,_that.inspectionId,_that.inspectorId,_that.batchId,_that.farmerName,_that.location,_that.capturedLocation,_that.town,_that.chapter,_that.truckNumber,_that.company,_that.quantity,_that.quantityBags,_that.moistureContent,_that.nutCount,_that.kor,_that.goodKernels,_that.spottedKernels,_that.immatureKernels,_that.oilyKernels,_that.voidKernels,_that.totalDefective,_that.totalSpotted,_that.imageUrls,_that.status,_that.notes,_that.createdAt,_that.updatedAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? inspectionId,  String inspectorId,  String? batchId,  String? farmerName,  String? location,  CapturedLocation? capturedLocation,  String? town,  String? chapter,  String? truckNumber,  String? company,  double quantity,  int quantityBags,  double moistureContent,  int nutCount,  double kor,  double goodKernels,  double spottedKernels,  double immatureKernels,  double oilyKernels,  double voidKernels,  double totalDefective,  double totalSpotted,  List<String> imageUrls,  InspectionStatus status,  String? notes,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _Inspection() when $default != null:
return $default(_that.id,_that.inspectionId,_that.inspectorId,_that.batchId,_that.farmerName,_that.location,_that.capturedLocation,_that.town,_that.chapter,_that.truckNumber,_that.company,_that.quantity,_that.quantityBags,_that.moistureContent,_that.nutCount,_that.kor,_that.goodKernels,_that.spottedKernels,_that.immatureKernels,_that.oilyKernels,_that.voidKernels,_that.totalDefective,_that.totalSpotted,_that.imageUrls,_that.status,_that.notes,_that.createdAt,_that.updatedAt,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class _Inspection implements Inspection {
  const _Inspection({required this.id, this.inspectionId, required this.inspectorId, this.batchId, this.farmerName, this.location, this.capturedLocation, this.town, this.chapter, this.truckNumber, this.company, this.quantity = 0.0, this.quantityBags = 0, this.moistureContent = 0.0, this.nutCount = 0, this.kor = 0.0, this.goodKernels = 0.0, this.spottedKernels = 0.0, this.immatureKernels = 0.0, this.oilyKernels = 0.0, this.voidKernels = 0.0, this.totalDefective = 0.0, this.totalSpotted = 0.0, final  List<String> imageUrls = const [], this.status = InspectionStatus.pending, this.notes, this.createdAt, this.updatedAt, this.completedAt}): _imageUrls = imageUrls;
  factory _Inspection.fromJson(Map<String, dynamic> json) => _$InspectionFromJson(json);

@override final  String id;
// Firebase auto-generated document ID
@override final  String? inspectionId;
// Custom inspection ID (e.g., INS-20260114-4X9P)
@override final  String inspectorId;
// Batch and Farmer Info
@override final  String? batchId;
@override final  String? farmerName;
// Acts as Supplier/Farmer Name
@override final  String? location;
// Text-based location (e.g., "Wenchi District, Bono Region")
@override final  CapturedLocation? capturedLocation;
// GPS-captured location with coordinates
@override final  String? town;
@override final  String? chapter;
// Basic Info
@override final  String? truckNumber;
@override final  String? company;
@override@JsonKey() final  double quantity;
@override@JsonKey() final  int quantityBags;
// Quality Metrics
@override@JsonKey() final  double moistureContent;
@override@JsonKey() final  int nutCount;
// Raw Nut Count
@override@JsonKey() final  double kor;
// Defect Metrics
@override@JsonKey() final  double goodKernels;
@override@JsonKey() final  double spottedKernels;
@override@JsonKey() final  double immatureKernels;
@override@JsonKey() final  double oilyKernels;
@override@JsonKey() final  double voidKernels;
@override@JsonKey() final  double totalDefective;
@override@JsonKey() final  double totalSpotted;
 final  List<String> _imageUrls;
@override@JsonKey() List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

@override@JsonKey() final  InspectionStatus status;
@override final  String? notes;
// Timestamps
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Inspection&&(identical(other.id, id) || other.id == id)&&(identical(other.inspectionId, inspectionId) || other.inspectionId == inspectionId)&&(identical(other.inspectorId, inspectorId) || other.inspectorId == inspectorId)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.farmerName, farmerName) || other.farmerName == farmerName)&&(identical(other.location, location) || other.location == location)&&(identical(other.capturedLocation, capturedLocation) || other.capturedLocation == capturedLocation)&&(identical(other.town, town) || other.town == town)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.truckNumber, truckNumber) || other.truckNumber == truckNumber)&&(identical(other.company, company) || other.company == company)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.quantityBags, quantityBags) || other.quantityBags == quantityBags)&&(identical(other.moistureContent, moistureContent) || other.moistureContent == moistureContent)&&(identical(other.nutCount, nutCount) || other.nutCount == nutCount)&&(identical(other.kor, kor) || other.kor == kor)&&(identical(other.goodKernels, goodKernels) || other.goodKernels == goodKernels)&&(identical(other.spottedKernels, spottedKernels) || other.spottedKernels == spottedKernels)&&(identical(other.immatureKernels, immatureKernels) || other.immatureKernels == immatureKernels)&&(identical(other.oilyKernels, oilyKernels) || other.oilyKernels == oilyKernels)&&(identical(other.voidKernels, voidKernels) || other.voidKernels == voidKernels)&&(identical(other.totalDefective, totalDefective) || other.totalDefective == totalDefective)&&(identical(other.totalSpotted, totalSpotted) || other.totalSpotted == totalSpotted)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,inspectionId,inspectorId,batchId,farmerName,location,capturedLocation,town,chapter,truckNumber,company,quantity,quantityBags,moistureContent,nutCount,kor,goodKernels,spottedKernels,immatureKernels,oilyKernels,voidKernels,totalDefective,totalSpotted,const DeepCollectionEquality().hash(_imageUrls),status,notes,createdAt,updatedAt,completedAt]);

@override
String toString() {
  return 'Inspection(id: $id, inspectionId: $inspectionId, inspectorId: $inspectorId, batchId: $batchId, farmerName: $farmerName, location: $location, capturedLocation: $capturedLocation, town: $town, chapter: $chapter, truckNumber: $truckNumber, company: $company, quantity: $quantity, quantityBags: $quantityBags, moistureContent: $moistureContent, nutCount: $nutCount, kor: $kor, goodKernels: $goodKernels, spottedKernels: $spottedKernels, immatureKernels: $immatureKernels, oilyKernels: $oilyKernels, voidKernels: $voidKernels, totalDefective: $totalDefective, totalSpotted: $totalSpotted, imageUrls: $imageUrls, status: $status, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$InspectionCopyWith<$Res> implements $InspectionCopyWith<$Res> {
  factory _$InspectionCopyWith(_Inspection value, $Res Function(_Inspection) _then) = __$InspectionCopyWithImpl;
@override @useResult
$Res call({
 String id, String? inspectionId, String inspectorId, String? batchId, String? farmerName, String? location, CapturedLocation? capturedLocation, String? town, String? chapter, String? truckNumber, String? company, double quantity, int quantityBags, double moistureContent, int nutCount, double kor, double goodKernels, double spottedKernels, double immatureKernels, double oilyKernels, double voidKernels, double totalDefective, double totalSpotted, List<String> imageUrls, InspectionStatus status, String? notes, DateTime? createdAt, DateTime? updatedAt, DateTime? completedAt
});


@override $CapturedLocationCopyWith<$Res>? get capturedLocation;

}
/// @nodoc
class __$InspectionCopyWithImpl<$Res>
    implements _$InspectionCopyWith<$Res> {
  __$InspectionCopyWithImpl(this._self, this._then);

  final _Inspection _self;
  final $Res Function(_Inspection) _then;

/// Create a copy of Inspection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? inspectionId = freezed,Object? inspectorId = null,Object? batchId = freezed,Object? farmerName = freezed,Object? location = freezed,Object? capturedLocation = freezed,Object? town = freezed,Object? chapter = freezed,Object? truckNumber = freezed,Object? company = freezed,Object? quantity = null,Object? quantityBags = null,Object? moistureContent = null,Object? nutCount = null,Object? kor = null,Object? goodKernels = null,Object? spottedKernels = null,Object? immatureKernels = null,Object? oilyKernels = null,Object? voidKernels = null,Object? totalDefective = null,Object? totalSpotted = null,Object? imageUrls = null,Object? status = null,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? completedAt = freezed,}) {
  return _then(_Inspection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,inspectionId: freezed == inspectionId ? _self.inspectionId : inspectionId // ignore: cast_nullable_to_non_nullable
as String?,inspectorId: null == inspectorId ? _self.inspectorId : inspectorId // ignore: cast_nullable_to_non_nullable
as String,batchId: freezed == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as String?,farmerName: freezed == farmerName ? _self.farmerName : farmerName // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,capturedLocation: freezed == capturedLocation ? _self.capturedLocation : capturedLocation // ignore: cast_nullable_to_non_nullable
as CapturedLocation?,town: freezed == town ? _self.town : town // ignore: cast_nullable_to_non_nullable
as String?,chapter: freezed == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as String?,truckNumber: freezed == truckNumber ? _self.truckNumber : truckNumber // ignore: cast_nullable_to_non_nullable
as String?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,quantityBags: null == quantityBags ? _self.quantityBags : quantityBags // ignore: cast_nullable_to_non_nullable
as int,moistureContent: null == moistureContent ? _self.moistureContent : moistureContent // ignore: cast_nullable_to_non_nullable
as double,nutCount: null == nutCount ? _self.nutCount : nutCount // ignore: cast_nullable_to_non_nullable
as int,kor: null == kor ? _self.kor : kor // ignore: cast_nullable_to_non_nullable
as double,goodKernels: null == goodKernels ? _self.goodKernels : goodKernels // ignore: cast_nullable_to_non_nullable
as double,spottedKernels: null == spottedKernels ? _self.spottedKernels : spottedKernels // ignore: cast_nullable_to_non_nullable
as double,immatureKernels: null == immatureKernels ? _self.immatureKernels : immatureKernels // ignore: cast_nullable_to_non_nullable
as double,oilyKernels: null == oilyKernels ? _self.oilyKernels : oilyKernels // ignore: cast_nullable_to_non_nullable
as double,voidKernels: null == voidKernels ? _self.voidKernels : voidKernels // ignore: cast_nullable_to_non_nullable
as double,totalDefective: null == totalDefective ? _self.totalDefective : totalDefective // ignore: cast_nullable_to_non_nullable
as double,totalSpotted: null == totalSpotted ? _self.totalSpotted : totalSpotted // ignore: cast_nullable_to_non_nullable
as double,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InspectionStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Inspection
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CapturedLocationCopyWith<$Res>? get capturedLocation {
    if (_self.capturedLocation == null) {
    return null;
  }

  return $CapturedLocationCopyWith<$Res>(_self.capturedLocation!, (value) {
    return _then(_self.copyWith(capturedLocation: value));
  });
}
}

// dart format on
