// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cut_test.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CutTest {

/// Which cut test this is: 1, 2 or 3.
 int get index;/// Where the sample was taken, shown as the column heading on the sheet
/// (e.g. "Sawla"). Falls back to "1st Cutting" when not supplied.
 String? get label; double get moistureContent; int get nutCount;// Fully damaged group
 double get fullyDamagedNuts; double get voidNuts; double get oilNuts;// Spotted / partly sound group
 double get spottedNuts; double get immatureNuts; double get goodKernels; double get emptyShells;
/// Create a copy of CutTest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CutTestCopyWith<CutTest> get copyWith => _$CutTestCopyWithImpl<CutTest>(this as CutTest, _$identity);

  /// Serializes this CutTest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CutTest&&(identical(other.index, index) || other.index == index)&&(identical(other.label, label) || other.label == label)&&(identical(other.moistureContent, moistureContent) || other.moistureContent == moistureContent)&&(identical(other.nutCount, nutCount) || other.nutCount == nutCount)&&(identical(other.fullyDamagedNuts, fullyDamagedNuts) || other.fullyDamagedNuts == fullyDamagedNuts)&&(identical(other.voidNuts, voidNuts) || other.voidNuts == voidNuts)&&(identical(other.oilNuts, oilNuts) || other.oilNuts == oilNuts)&&(identical(other.spottedNuts, spottedNuts) || other.spottedNuts == spottedNuts)&&(identical(other.immatureNuts, immatureNuts) || other.immatureNuts == immatureNuts)&&(identical(other.goodKernels, goodKernels) || other.goodKernels == goodKernels)&&(identical(other.emptyShells, emptyShells) || other.emptyShells == emptyShells));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,label,moistureContent,nutCount,fullyDamagedNuts,voidNuts,oilNuts,spottedNuts,immatureNuts,goodKernels,emptyShells);

@override
String toString() {
  return 'CutTest(index: $index, label: $label, moistureContent: $moistureContent, nutCount: $nutCount, fullyDamagedNuts: $fullyDamagedNuts, voidNuts: $voidNuts, oilNuts: $oilNuts, spottedNuts: $spottedNuts, immatureNuts: $immatureNuts, goodKernels: $goodKernels, emptyShells: $emptyShells)';
}


}

/// @nodoc
abstract mixin class $CutTestCopyWith<$Res>  {
  factory $CutTestCopyWith(CutTest value, $Res Function(CutTest) _then) = _$CutTestCopyWithImpl;
@useResult
$Res call({
 int index, String? label, double moistureContent, int nutCount, double fullyDamagedNuts, double voidNuts, double oilNuts, double spottedNuts, double immatureNuts, double goodKernels, double emptyShells
});




}
/// @nodoc
class _$CutTestCopyWithImpl<$Res>
    implements $CutTestCopyWith<$Res> {
  _$CutTestCopyWithImpl(this._self, this._then);

  final CutTest _self;
  final $Res Function(CutTest) _then;

/// Create a copy of CutTest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? index = null,Object? label = freezed,Object? moistureContent = null,Object? nutCount = null,Object? fullyDamagedNuts = null,Object? voidNuts = null,Object? oilNuts = null,Object? spottedNuts = null,Object? immatureNuts = null,Object? goodKernels = null,Object? emptyShells = null,}) {
  return _then(_self.copyWith(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,moistureContent: null == moistureContent ? _self.moistureContent : moistureContent // ignore: cast_nullable_to_non_nullable
as double,nutCount: null == nutCount ? _self.nutCount : nutCount // ignore: cast_nullable_to_non_nullable
as int,fullyDamagedNuts: null == fullyDamagedNuts ? _self.fullyDamagedNuts : fullyDamagedNuts // ignore: cast_nullable_to_non_nullable
as double,voidNuts: null == voidNuts ? _self.voidNuts : voidNuts // ignore: cast_nullable_to_non_nullable
as double,oilNuts: null == oilNuts ? _self.oilNuts : oilNuts // ignore: cast_nullable_to_non_nullable
as double,spottedNuts: null == spottedNuts ? _self.spottedNuts : spottedNuts // ignore: cast_nullable_to_non_nullable
as double,immatureNuts: null == immatureNuts ? _self.immatureNuts : immatureNuts // ignore: cast_nullable_to_non_nullable
as double,goodKernels: null == goodKernels ? _self.goodKernels : goodKernels // ignore: cast_nullable_to_non_nullable
as double,emptyShells: null == emptyShells ? _self.emptyShells : emptyShells // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CutTest].
extension CutTestPatterns on CutTest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CutTest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CutTest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CutTest value)  $default,){
final _that = this;
switch (_that) {
case _CutTest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CutTest value)?  $default,){
final _that = this;
switch (_that) {
case _CutTest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int index,  String? label,  double moistureContent,  int nutCount,  double fullyDamagedNuts,  double voidNuts,  double oilNuts,  double spottedNuts,  double immatureNuts,  double goodKernels,  double emptyShells)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CutTest() when $default != null:
return $default(_that.index,_that.label,_that.moistureContent,_that.nutCount,_that.fullyDamagedNuts,_that.voidNuts,_that.oilNuts,_that.spottedNuts,_that.immatureNuts,_that.goodKernels,_that.emptyShells);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int index,  String? label,  double moistureContent,  int nutCount,  double fullyDamagedNuts,  double voidNuts,  double oilNuts,  double spottedNuts,  double immatureNuts,  double goodKernels,  double emptyShells)  $default,) {final _that = this;
switch (_that) {
case _CutTest():
return $default(_that.index,_that.label,_that.moistureContent,_that.nutCount,_that.fullyDamagedNuts,_that.voidNuts,_that.oilNuts,_that.spottedNuts,_that.immatureNuts,_that.goodKernels,_that.emptyShells);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int index,  String? label,  double moistureContent,  int nutCount,  double fullyDamagedNuts,  double voidNuts,  double oilNuts,  double spottedNuts,  double immatureNuts,  double goodKernels,  double emptyShells)?  $default,) {final _that = this;
switch (_that) {
case _CutTest() when $default != null:
return $default(_that.index,_that.label,_that.moistureContent,_that.nutCount,_that.fullyDamagedNuts,_that.voidNuts,_that.oilNuts,_that.spottedNuts,_that.immatureNuts,_that.goodKernels,_that.emptyShells);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CutTest extends CutTest {
  const _CutTest({required this.index, this.label, this.moistureContent = 0.0, this.nutCount = 0, this.fullyDamagedNuts = 0.0, this.voidNuts = 0.0, this.oilNuts = 0.0, this.spottedNuts = 0.0, this.immatureNuts = 0.0, this.goodKernels = 0.0, this.emptyShells = 0.0}): super._();
  factory _CutTest.fromJson(Map<String, dynamic> json) => _$CutTestFromJson(json);

/// Which cut test this is: 1, 2 or 3.
@override final  int index;
/// Where the sample was taken, shown as the column heading on the sheet
/// (e.g. "Sawla"). Falls back to "1st Cutting" when not supplied.
@override final  String? label;
@override@JsonKey() final  double moistureContent;
@override@JsonKey() final  int nutCount;
// Fully damaged group
@override@JsonKey() final  double fullyDamagedNuts;
@override@JsonKey() final  double voidNuts;
@override@JsonKey() final  double oilNuts;
// Spotted / partly sound group
@override@JsonKey() final  double spottedNuts;
@override@JsonKey() final  double immatureNuts;
@override@JsonKey() final  double goodKernels;
@override@JsonKey() final  double emptyShells;

/// Create a copy of CutTest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CutTestCopyWith<_CutTest> get copyWith => __$CutTestCopyWithImpl<_CutTest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CutTestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CutTest&&(identical(other.index, index) || other.index == index)&&(identical(other.label, label) || other.label == label)&&(identical(other.moistureContent, moistureContent) || other.moistureContent == moistureContent)&&(identical(other.nutCount, nutCount) || other.nutCount == nutCount)&&(identical(other.fullyDamagedNuts, fullyDamagedNuts) || other.fullyDamagedNuts == fullyDamagedNuts)&&(identical(other.voidNuts, voidNuts) || other.voidNuts == voidNuts)&&(identical(other.oilNuts, oilNuts) || other.oilNuts == oilNuts)&&(identical(other.spottedNuts, spottedNuts) || other.spottedNuts == spottedNuts)&&(identical(other.immatureNuts, immatureNuts) || other.immatureNuts == immatureNuts)&&(identical(other.goodKernels, goodKernels) || other.goodKernels == goodKernels)&&(identical(other.emptyShells, emptyShells) || other.emptyShells == emptyShells));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,label,moistureContent,nutCount,fullyDamagedNuts,voidNuts,oilNuts,spottedNuts,immatureNuts,goodKernels,emptyShells);

@override
String toString() {
  return 'CutTest(index: $index, label: $label, moistureContent: $moistureContent, nutCount: $nutCount, fullyDamagedNuts: $fullyDamagedNuts, voidNuts: $voidNuts, oilNuts: $oilNuts, spottedNuts: $spottedNuts, immatureNuts: $immatureNuts, goodKernels: $goodKernels, emptyShells: $emptyShells)';
}


}

/// @nodoc
abstract mixin class _$CutTestCopyWith<$Res> implements $CutTestCopyWith<$Res> {
  factory _$CutTestCopyWith(_CutTest value, $Res Function(_CutTest) _then) = __$CutTestCopyWithImpl;
@override @useResult
$Res call({
 int index, String? label, double moistureContent, int nutCount, double fullyDamagedNuts, double voidNuts, double oilNuts, double spottedNuts, double immatureNuts, double goodKernels, double emptyShells
});




}
/// @nodoc
class __$CutTestCopyWithImpl<$Res>
    implements _$CutTestCopyWith<$Res> {
  __$CutTestCopyWithImpl(this._self, this._then);

  final _CutTest _self;
  final $Res Function(_CutTest) _then;

/// Create a copy of CutTest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? index = null,Object? label = freezed,Object? moistureContent = null,Object? nutCount = null,Object? fullyDamagedNuts = null,Object? voidNuts = null,Object? oilNuts = null,Object? spottedNuts = null,Object? immatureNuts = null,Object? goodKernels = null,Object? emptyShells = null,}) {
  return _then(_CutTest(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,moistureContent: null == moistureContent ? _self.moistureContent : moistureContent // ignore: cast_nullable_to_non_nullable
as double,nutCount: null == nutCount ? _self.nutCount : nutCount // ignore: cast_nullable_to_non_nullable
as int,fullyDamagedNuts: null == fullyDamagedNuts ? _self.fullyDamagedNuts : fullyDamagedNuts // ignore: cast_nullable_to_non_nullable
as double,voidNuts: null == voidNuts ? _self.voidNuts : voidNuts // ignore: cast_nullable_to_non_nullable
as double,oilNuts: null == oilNuts ? _self.oilNuts : oilNuts // ignore: cast_nullable_to_non_nullable
as double,spottedNuts: null == spottedNuts ? _self.spottedNuts : spottedNuts // ignore: cast_nullable_to_non_nullable
as double,immatureNuts: null == immatureNuts ? _self.immatureNuts : immatureNuts // ignore: cast_nullable_to_non_nullable
as double,goodKernels: null == goodKernels ? _self.goodKernels : goodKernels // ignore: cast_nullable_to_non_nullable
as double,emptyShells: null == emptyShells ? _self.emptyShells : emptyShells // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
