// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'newsletter_subscription.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NewsletterSubscription {

/// Unique subscription ID
 String get id;/// Subscriber email address
 String get email;/// When the subscription was created
 DateTime get subscribedAt;/// Whether the subscription is active
 bool get isActive;/// Source of subscription (e.g., "guest_events_screen")
 String get source;/// When the subscription was last updated
 DateTime? get updatedAt;
/// Create a copy of NewsletterSubscription
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewsletterSubscriptionCopyWith<NewsletterSubscription> get copyWith => _$NewsletterSubscriptionCopyWithImpl<NewsletterSubscription>(this as NewsletterSubscription, _$identity);

  /// Serializes this NewsletterSubscription to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NewsletterSubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.subscribedAt, subscribedAt) || other.subscribedAt == subscribedAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.source, source) || other.source == source)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,subscribedAt,isActive,source,updatedAt);

@override
String toString() {
  return 'NewsletterSubscription(id: $id, email: $email, subscribedAt: $subscribedAt, isActive: $isActive, source: $source, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $NewsletterSubscriptionCopyWith<$Res>  {
  factory $NewsletterSubscriptionCopyWith(NewsletterSubscription value, $Res Function(NewsletterSubscription) _then) = _$NewsletterSubscriptionCopyWithImpl;
@useResult
$Res call({
 String id, String email, DateTime subscribedAt, bool isActive, String source, DateTime? updatedAt
});




}
/// @nodoc
class _$NewsletterSubscriptionCopyWithImpl<$Res>
    implements $NewsletterSubscriptionCopyWith<$Res> {
  _$NewsletterSubscriptionCopyWithImpl(this._self, this._then);

  final NewsletterSubscription _self;
  final $Res Function(NewsletterSubscription) _then;

/// Create a copy of NewsletterSubscription
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? subscribedAt = null,Object? isActive = null,Object? source = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,subscribedAt: null == subscribedAt ? _self.subscribedAt : subscribedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [NewsletterSubscription].
extension NewsletterSubscriptionPatterns on NewsletterSubscription {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NewsletterSubscription value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NewsletterSubscription() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NewsletterSubscription value)  $default,){
final _that = this;
switch (_that) {
case _NewsletterSubscription():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NewsletterSubscription value)?  $default,){
final _that = this;
switch (_that) {
case _NewsletterSubscription() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  DateTime subscribedAt,  bool isActive,  String source,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NewsletterSubscription() when $default != null:
return $default(_that.id,_that.email,_that.subscribedAt,_that.isActive,_that.source,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  DateTime subscribedAt,  bool isActive,  String source,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _NewsletterSubscription():
return $default(_that.id,_that.email,_that.subscribedAt,_that.isActive,_that.source,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  DateTime subscribedAt,  bool isActive,  String source,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _NewsletterSubscription() when $default != null:
return $default(_that.id,_that.email,_that.subscribedAt,_that.isActive,_that.source,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _NewsletterSubscription extends NewsletterSubscription {
  const _NewsletterSubscription({required this.id, required this.email, required this.subscribedAt, this.isActive = true, this.source = "guest_events_screen", this.updatedAt}): super._();
  factory _NewsletterSubscription.fromJson(Map<String, dynamic> json) => _$NewsletterSubscriptionFromJson(json);

/// Unique subscription ID
@override final  String id;
/// Subscriber email address
@override final  String email;
/// When the subscription was created
@override final  DateTime subscribedAt;
/// Whether the subscription is active
@override@JsonKey() final  bool isActive;
/// Source of subscription (e.g., "guest_events_screen")
@override@JsonKey() final  String source;
/// When the subscription was last updated
@override final  DateTime? updatedAt;

/// Create a copy of NewsletterSubscription
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewsletterSubscriptionCopyWith<_NewsletterSubscription> get copyWith => __$NewsletterSubscriptionCopyWithImpl<_NewsletterSubscription>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NewsletterSubscriptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NewsletterSubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.subscribedAt, subscribedAt) || other.subscribedAt == subscribedAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.source, source) || other.source == source)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,subscribedAt,isActive,source,updatedAt);

@override
String toString() {
  return 'NewsletterSubscription(id: $id, email: $email, subscribedAt: $subscribedAt, isActive: $isActive, source: $source, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$NewsletterSubscriptionCopyWith<$Res> implements $NewsletterSubscriptionCopyWith<$Res> {
  factory _$NewsletterSubscriptionCopyWith(_NewsletterSubscription value, $Res Function(_NewsletterSubscription) _then) = __$NewsletterSubscriptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, DateTime subscribedAt, bool isActive, String source, DateTime? updatedAt
});




}
/// @nodoc
class __$NewsletterSubscriptionCopyWithImpl<$Res>
    implements _$NewsletterSubscriptionCopyWith<$Res> {
  __$NewsletterSubscriptionCopyWithImpl(this._self, this._then);

  final _NewsletterSubscription _self;
  final $Res Function(_NewsletterSubscription) _then;

/// Create a copy of NewsletterSubscription
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? subscribedAt = null,Object? isActive = null,Object? source = null,Object? updatedAt = freezed,}) {
  return _then(_NewsletterSubscription(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,subscribedAt: null == subscribedAt ? _self.subscribedAt : subscribedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
