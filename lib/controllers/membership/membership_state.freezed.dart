// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membership_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MembershipState {

/// The current user's membership application
 MembershipApplication? get myApplication;/// All membership applications (Admin only)
 List<MembershipApplication> get allApplications;/// Whether the initial data is loading
 bool get isLoading;
/// Create a copy of MembershipState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembershipStateCopyWith<MembershipState> get copyWith => _$MembershipStateCopyWithImpl<MembershipState>(this as MembershipState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MembershipState&&(identical(other.myApplication, myApplication) || other.myApplication == myApplication)&&const DeepCollectionEquality().equals(other.allApplications, allApplications)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,myApplication,const DeepCollectionEquality().hash(allApplications),isLoading);

@override
String toString() {
  return 'MembershipState(myApplication: $myApplication, allApplications: $allApplications, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class $MembershipStateCopyWith<$Res>  {
  factory $MembershipStateCopyWith(MembershipState value, $Res Function(MembershipState) _then) = _$MembershipStateCopyWithImpl;
@useResult
$Res call({
 MembershipApplication? myApplication, List<MembershipApplication> allApplications, bool isLoading
});


$MembershipApplicationCopyWith<$Res>? get myApplication;

}
/// @nodoc
class _$MembershipStateCopyWithImpl<$Res>
    implements $MembershipStateCopyWith<$Res> {
  _$MembershipStateCopyWithImpl(this._self, this._then);

  final MembershipState _self;
  final $Res Function(MembershipState) _then;

/// Create a copy of MembershipState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? myApplication = freezed,Object? allApplications = null,Object? isLoading = null,}) {
  return _then(_self.copyWith(
myApplication: freezed == myApplication ? _self.myApplication : myApplication // ignore: cast_nullable_to_non_nullable
as MembershipApplication?,allApplications: null == allApplications ? _self.allApplications : allApplications // ignore: cast_nullable_to_non_nullable
as List<MembershipApplication>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of MembershipState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MembershipApplicationCopyWith<$Res>? get myApplication {
    if (_self.myApplication == null) {
    return null;
  }

  return $MembershipApplicationCopyWith<$Res>(_self.myApplication!, (value) {
    return _then(_self.copyWith(myApplication: value));
  });
}
}


/// Adds pattern-matching-related methods to [MembershipState].
extension MembershipStatePatterns on MembershipState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MembershipState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MembershipState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MembershipState value)  $default,){
final _that = this;
switch (_that) {
case _MembershipState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MembershipState value)?  $default,){
final _that = this;
switch (_that) {
case _MembershipState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MembershipApplication? myApplication,  List<MembershipApplication> allApplications,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MembershipState() when $default != null:
return $default(_that.myApplication,_that.allApplications,_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MembershipApplication? myApplication,  List<MembershipApplication> allApplications,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _MembershipState():
return $default(_that.myApplication,_that.allApplications,_that.isLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MembershipApplication? myApplication,  List<MembershipApplication> allApplications,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _MembershipState() when $default != null:
return $default(_that.myApplication,_that.allApplications,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class _MembershipState extends MembershipState {
  const _MembershipState({this.myApplication, final  List<MembershipApplication> allApplications = const [], this.isLoading = false}): _allApplications = allApplications,super._();
  

/// The current user's membership application
@override final  MembershipApplication? myApplication;
/// All membership applications (Admin only)
 final  List<MembershipApplication> _allApplications;
/// All membership applications (Admin only)
@override@JsonKey() List<MembershipApplication> get allApplications {
  if (_allApplications is EqualUnmodifiableListView) return _allApplications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allApplications);
}

/// Whether the initial data is loading
@override@JsonKey() final  bool isLoading;

/// Create a copy of MembershipState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembershipStateCopyWith<_MembershipState> get copyWith => __$MembershipStateCopyWithImpl<_MembershipState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MembershipState&&(identical(other.myApplication, myApplication) || other.myApplication == myApplication)&&const DeepCollectionEquality().equals(other._allApplications, _allApplications)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,myApplication,const DeepCollectionEquality().hash(_allApplications),isLoading);

@override
String toString() {
  return 'MembershipState(myApplication: $myApplication, allApplications: $allApplications, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$MembershipStateCopyWith<$Res> implements $MembershipStateCopyWith<$Res> {
  factory _$MembershipStateCopyWith(_MembershipState value, $Res Function(_MembershipState) _then) = __$MembershipStateCopyWithImpl;
@override @useResult
$Res call({
 MembershipApplication? myApplication, List<MembershipApplication> allApplications, bool isLoading
});


@override $MembershipApplicationCopyWith<$Res>? get myApplication;

}
/// @nodoc
class __$MembershipStateCopyWithImpl<$Res>
    implements _$MembershipStateCopyWith<$Res> {
  __$MembershipStateCopyWithImpl(this._self, this._then);

  final _MembershipState _self;
  final $Res Function(_MembershipState) _then;

/// Create a copy of MembershipState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? myApplication = freezed,Object? allApplications = null,Object? isLoading = null,}) {
  return _then(_MembershipState(
myApplication: freezed == myApplication ? _self.myApplication : myApplication // ignore: cast_nullable_to_non_nullable
as MembershipApplication?,allApplications: null == allApplications ? _self._allApplications : allApplications // ignore: cast_nullable_to_non_nullable
as List<MembershipApplication>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of MembershipState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MembershipApplicationCopyWith<$Res>? get myApplication {
    if (_self.myApplication == null) {
    return null;
  }

  return $MembershipApplicationCopyWith<$Res>(_self.myApplication!, (value) {
    return _then(_self.copyWith(myApplication: value));
  });
}
}

// dart format on
