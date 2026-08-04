// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspection_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InspectionState implements DiagnosticableTreeMixin {

 List<Inspection> get allInspections; List<Inspection> get allCompletedInspections;
/// Create a copy of InspectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InspectionStateCopyWith<InspectionState> get copyWith => _$InspectionStateCopyWithImpl<InspectionState>(this as InspectionState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'InspectionState'))
    ..add(DiagnosticsProperty('allInspections', allInspections))..add(DiagnosticsProperty('allCompletedInspections', allCompletedInspections));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InspectionState&&const DeepCollectionEquality().equals(other.allInspections, allInspections)&&const DeepCollectionEquality().equals(other.allCompletedInspections, allCompletedInspections));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(allInspections),const DeepCollectionEquality().hash(allCompletedInspections));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'InspectionState(allInspections: $allInspections, allCompletedInspections: $allCompletedInspections)';
}


}

/// @nodoc
abstract mixin class $InspectionStateCopyWith<$Res>  {
  factory $InspectionStateCopyWith(InspectionState value, $Res Function(InspectionState) _then) = _$InspectionStateCopyWithImpl;
@useResult
$Res call({
 List<Inspection> allInspections, List<Inspection> allCompletedInspections
});




}
/// @nodoc
class _$InspectionStateCopyWithImpl<$Res>
    implements $InspectionStateCopyWith<$Res> {
  _$InspectionStateCopyWithImpl(this._self, this._then);

  final InspectionState _self;
  final $Res Function(InspectionState) _then;

/// Create a copy of InspectionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? allInspections = null,Object? allCompletedInspections = null,}) {
  return _then(_self.copyWith(
allInspections: null == allInspections ? _self.allInspections : allInspections // ignore: cast_nullable_to_non_nullable
as List<Inspection>,allCompletedInspections: null == allCompletedInspections ? _self.allCompletedInspections : allCompletedInspections // ignore: cast_nullable_to_non_nullable
as List<Inspection>,
  ));
}

}


/// Adds pattern-matching-related methods to [InspectionState].
extension InspectionStatePatterns on InspectionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InspectionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InspectionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InspectionState value)  $default,){
final _that = this;
switch (_that) {
case _InspectionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InspectionState value)?  $default,){
final _that = this;
switch (_that) {
case _InspectionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Inspection> allInspections,  List<Inspection> allCompletedInspections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InspectionState() when $default != null:
return $default(_that.allInspections,_that.allCompletedInspections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Inspection> allInspections,  List<Inspection> allCompletedInspections)  $default,) {final _that = this;
switch (_that) {
case _InspectionState():
return $default(_that.allInspections,_that.allCompletedInspections);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Inspection> allInspections,  List<Inspection> allCompletedInspections)?  $default,) {final _that = this;
switch (_that) {
case _InspectionState() when $default != null:
return $default(_that.allInspections,_that.allCompletedInspections);case _:
  return null;

}
}

}

/// @nodoc


class _InspectionState extends InspectionState with DiagnosticableTreeMixin {
  const _InspectionState({final  List<Inspection> allInspections = const [], final  List<Inspection> allCompletedInspections = const []}): _allInspections = allInspections,_allCompletedInspections = allCompletedInspections,super._();
  

 final  List<Inspection> _allInspections;
@override@JsonKey() List<Inspection> get allInspections {
  if (_allInspections is EqualUnmodifiableListView) return _allInspections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allInspections);
}

 final  List<Inspection> _allCompletedInspections;
@override@JsonKey() List<Inspection> get allCompletedInspections {
  if (_allCompletedInspections is EqualUnmodifiableListView) return _allCompletedInspections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allCompletedInspections);
}


/// Create a copy of InspectionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InspectionStateCopyWith<_InspectionState> get copyWith => __$InspectionStateCopyWithImpl<_InspectionState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'InspectionState'))
    ..add(DiagnosticsProperty('allInspections', allInspections))..add(DiagnosticsProperty('allCompletedInspections', allCompletedInspections));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InspectionState&&const DeepCollectionEquality().equals(other._allInspections, _allInspections)&&const DeepCollectionEquality().equals(other._allCompletedInspections, _allCompletedInspections));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_allInspections),const DeepCollectionEquality().hash(_allCompletedInspections));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'InspectionState(allInspections: $allInspections, allCompletedInspections: $allCompletedInspections)';
}


}

/// @nodoc
abstract mixin class _$InspectionStateCopyWith<$Res> implements $InspectionStateCopyWith<$Res> {
  factory _$InspectionStateCopyWith(_InspectionState value, $Res Function(_InspectionState) _then) = __$InspectionStateCopyWithImpl;
@override @useResult
$Res call({
 List<Inspection> allInspections, List<Inspection> allCompletedInspections
});




}
/// @nodoc
class __$InspectionStateCopyWithImpl<$Res>
    implements _$InspectionStateCopyWith<$Res> {
  __$InspectionStateCopyWithImpl(this._self, this._then);

  final _InspectionState _self;
  final $Res Function(_InspectionState) _then;

/// Create a copy of InspectionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? allInspections = null,Object? allCompletedInspections = null,}) {
  return _then(_InspectionState(
allInspections: null == allInspections ? _self._allInspections : allInspections // ignore: cast_nullable_to_non_nullable
as List<Inspection>,allCompletedInspections: null == allCompletedInspections ? _self._allCompletedInspections : allCompletedInspections // ignore: cast_nullable_to_non_nullable
as List<Inspection>,
  ));
}


}

// dart format on
