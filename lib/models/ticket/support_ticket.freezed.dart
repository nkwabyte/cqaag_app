// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'support_ticket.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SupportTicket {

 String get id; String get ticketCode;// e.g. TCK-2026-0012
 String get userId; String get userName; String get userEmail; String? get userPhone; TicketCategory get category; TicketPriority get priority; TicketStatus get status; String get title; String get description; String? get relatedInspectionId; String? get relatedBatchId; List<String> get attachmentUrls; String? get resolutionNotes; String? get resolvedBy; DateTime? get resolvedAt; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of SupportTicket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupportTicketCopyWith<SupportTicket> get copyWith => _$SupportTicketCopyWithImpl<SupportTicket>(this as SupportTicket, _$identity);

  /// Serializes this SupportTicket to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupportTicket&&(identical(other.id, id) || other.id == id)&&(identical(other.ticketCode, ticketCode) || other.ticketCode == ticketCode)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userEmail, userEmail) || other.userEmail == userEmail)&&(identical(other.userPhone, userPhone) || other.userPhone == userPhone)&&(identical(other.category, category) || other.category == category)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.relatedInspectionId, relatedInspectionId) || other.relatedInspectionId == relatedInspectionId)&&(identical(other.relatedBatchId, relatedBatchId) || other.relatedBatchId == relatedBatchId)&&const DeepCollectionEquality().equals(other.attachmentUrls, attachmentUrls)&&(identical(other.resolutionNotes, resolutionNotes) || other.resolutionNotes == resolutionNotes)&&(identical(other.resolvedBy, resolvedBy) || other.resolvedBy == resolvedBy)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,ticketCode,userId,userName,userEmail,userPhone,category,priority,status,title,description,relatedInspectionId,relatedBatchId,const DeepCollectionEquality().hash(attachmentUrls),resolutionNotes,resolvedBy,resolvedAt,createdAt,updatedAt]);

@override
String toString() {
  return 'SupportTicket(id: $id, ticketCode: $ticketCode, userId: $userId, userName: $userName, userEmail: $userEmail, userPhone: $userPhone, category: $category, priority: $priority, status: $status, title: $title, description: $description, relatedInspectionId: $relatedInspectionId, relatedBatchId: $relatedBatchId, attachmentUrls: $attachmentUrls, resolutionNotes: $resolutionNotes, resolvedBy: $resolvedBy, resolvedAt: $resolvedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SupportTicketCopyWith<$Res>  {
  factory $SupportTicketCopyWith(SupportTicket value, $Res Function(SupportTicket) _then) = _$SupportTicketCopyWithImpl;
@useResult
$Res call({
 String id, String ticketCode, String userId, String userName, String userEmail, String? userPhone, TicketCategory category, TicketPriority priority, TicketStatus status, String title, String description, String? relatedInspectionId, String? relatedBatchId, List<String> attachmentUrls, String? resolutionNotes, String? resolvedBy, DateTime? resolvedAt, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$SupportTicketCopyWithImpl<$Res>
    implements $SupportTicketCopyWith<$Res> {
  _$SupportTicketCopyWithImpl(this._self, this._then);

  final SupportTicket _self;
  final $Res Function(SupportTicket) _then;

/// Create a copy of SupportTicket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ticketCode = null,Object? userId = null,Object? userName = null,Object? userEmail = null,Object? userPhone = freezed,Object? category = null,Object? priority = null,Object? status = null,Object? title = null,Object? description = null,Object? relatedInspectionId = freezed,Object? relatedBatchId = freezed,Object? attachmentUrls = null,Object? resolutionNotes = freezed,Object? resolvedBy = freezed,Object? resolvedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ticketCode: null == ticketCode ? _self.ticketCode : ticketCode // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userEmail: null == userEmail ? _self.userEmail : userEmail // ignore: cast_nullable_to_non_nullable
as String,userPhone: freezed == userPhone ? _self.userPhone : userPhone // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as TicketCategory,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TicketPriority,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TicketStatus,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,relatedInspectionId: freezed == relatedInspectionId ? _self.relatedInspectionId : relatedInspectionId // ignore: cast_nullable_to_non_nullable
as String?,relatedBatchId: freezed == relatedBatchId ? _self.relatedBatchId : relatedBatchId // ignore: cast_nullable_to_non_nullable
as String?,attachmentUrls: null == attachmentUrls ? _self.attachmentUrls : attachmentUrls // ignore: cast_nullable_to_non_nullable
as List<String>,resolutionNotes: freezed == resolutionNotes ? _self.resolutionNotes : resolutionNotes // ignore: cast_nullable_to_non_nullable
as String?,resolvedBy: freezed == resolvedBy ? _self.resolvedBy : resolvedBy // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SupportTicket].
extension SupportTicketPatterns on SupportTicket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupportTicket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupportTicket() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupportTicket value)  $default,){
final _that = this;
switch (_that) {
case _SupportTicket():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupportTicket value)?  $default,){
final _that = this;
switch (_that) {
case _SupportTicket() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ticketCode,  String userId,  String userName,  String userEmail,  String? userPhone,  TicketCategory category,  TicketPriority priority,  TicketStatus status,  String title,  String description,  String? relatedInspectionId,  String? relatedBatchId,  List<String> attachmentUrls,  String? resolutionNotes,  String? resolvedBy,  DateTime? resolvedAt,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupportTicket() when $default != null:
return $default(_that.id,_that.ticketCode,_that.userId,_that.userName,_that.userEmail,_that.userPhone,_that.category,_that.priority,_that.status,_that.title,_that.description,_that.relatedInspectionId,_that.relatedBatchId,_that.attachmentUrls,_that.resolutionNotes,_that.resolvedBy,_that.resolvedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ticketCode,  String userId,  String userName,  String userEmail,  String? userPhone,  TicketCategory category,  TicketPriority priority,  TicketStatus status,  String title,  String description,  String? relatedInspectionId,  String? relatedBatchId,  List<String> attachmentUrls,  String? resolutionNotes,  String? resolvedBy,  DateTime? resolvedAt,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SupportTicket():
return $default(_that.id,_that.ticketCode,_that.userId,_that.userName,_that.userEmail,_that.userPhone,_that.category,_that.priority,_that.status,_that.title,_that.description,_that.relatedInspectionId,_that.relatedBatchId,_that.attachmentUrls,_that.resolutionNotes,_that.resolvedBy,_that.resolvedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ticketCode,  String userId,  String userName,  String userEmail,  String? userPhone,  TicketCategory category,  TicketPriority priority,  TicketStatus status,  String title,  String description,  String? relatedInspectionId,  String? relatedBatchId,  List<String> attachmentUrls,  String? resolutionNotes,  String? resolvedBy,  DateTime? resolvedAt,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SupportTicket() when $default != null:
return $default(_that.id,_that.ticketCode,_that.userId,_that.userName,_that.userEmail,_that.userPhone,_that.category,_that.priority,_that.status,_that.title,_that.description,_that.relatedInspectionId,_that.relatedBatchId,_that.attachmentUrls,_that.resolutionNotes,_that.resolvedBy,_that.resolvedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _SupportTicket extends SupportTicket {
  const _SupportTicket({required this.id, required this.ticketCode, required this.userId, required this.userName, required this.userEmail, this.userPhone, this.category = TicketCategory.mistakeCorrection, this.priority = TicketPriority.medium, this.status = TicketStatus.open, required this.title, required this.description, this.relatedInspectionId, this.relatedBatchId, final  List<String> attachmentUrls = const [], this.resolutionNotes, this.resolvedBy, this.resolvedAt, this.createdAt, this.updatedAt}): _attachmentUrls = attachmentUrls,super._();
  factory _SupportTicket.fromJson(Map<String, dynamic> json) => _$SupportTicketFromJson(json);

@override final  String id;
@override final  String ticketCode;
// e.g. TCK-2026-0012
@override final  String userId;
@override final  String userName;
@override final  String userEmail;
@override final  String? userPhone;
@override@JsonKey() final  TicketCategory category;
@override@JsonKey() final  TicketPriority priority;
@override@JsonKey() final  TicketStatus status;
@override final  String title;
@override final  String description;
@override final  String? relatedInspectionId;
@override final  String? relatedBatchId;
 final  List<String> _attachmentUrls;
@override@JsonKey() List<String> get attachmentUrls {
  if (_attachmentUrls is EqualUnmodifiableListView) return _attachmentUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachmentUrls);
}

@override final  String? resolutionNotes;
@override final  String? resolvedBy;
@override final  DateTime? resolvedAt;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of SupportTicket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupportTicketCopyWith<_SupportTicket> get copyWith => __$SupportTicketCopyWithImpl<_SupportTicket>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SupportTicketToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupportTicket&&(identical(other.id, id) || other.id == id)&&(identical(other.ticketCode, ticketCode) || other.ticketCode == ticketCode)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userEmail, userEmail) || other.userEmail == userEmail)&&(identical(other.userPhone, userPhone) || other.userPhone == userPhone)&&(identical(other.category, category) || other.category == category)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.relatedInspectionId, relatedInspectionId) || other.relatedInspectionId == relatedInspectionId)&&(identical(other.relatedBatchId, relatedBatchId) || other.relatedBatchId == relatedBatchId)&&const DeepCollectionEquality().equals(other._attachmentUrls, _attachmentUrls)&&(identical(other.resolutionNotes, resolutionNotes) || other.resolutionNotes == resolutionNotes)&&(identical(other.resolvedBy, resolvedBy) || other.resolvedBy == resolvedBy)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,ticketCode,userId,userName,userEmail,userPhone,category,priority,status,title,description,relatedInspectionId,relatedBatchId,const DeepCollectionEquality().hash(_attachmentUrls),resolutionNotes,resolvedBy,resolvedAt,createdAt,updatedAt]);

@override
String toString() {
  return 'SupportTicket(id: $id, ticketCode: $ticketCode, userId: $userId, userName: $userName, userEmail: $userEmail, userPhone: $userPhone, category: $category, priority: $priority, status: $status, title: $title, description: $description, relatedInspectionId: $relatedInspectionId, relatedBatchId: $relatedBatchId, attachmentUrls: $attachmentUrls, resolutionNotes: $resolutionNotes, resolvedBy: $resolvedBy, resolvedAt: $resolvedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SupportTicketCopyWith<$Res> implements $SupportTicketCopyWith<$Res> {
  factory _$SupportTicketCopyWith(_SupportTicket value, $Res Function(_SupportTicket) _then) = __$SupportTicketCopyWithImpl;
@override @useResult
$Res call({
 String id, String ticketCode, String userId, String userName, String userEmail, String? userPhone, TicketCategory category, TicketPriority priority, TicketStatus status, String title, String description, String? relatedInspectionId, String? relatedBatchId, List<String> attachmentUrls, String? resolutionNotes, String? resolvedBy, DateTime? resolvedAt, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$SupportTicketCopyWithImpl<$Res>
    implements _$SupportTicketCopyWith<$Res> {
  __$SupportTicketCopyWithImpl(this._self, this._then);

  final _SupportTicket _self;
  final $Res Function(_SupportTicket) _then;

/// Create a copy of SupportTicket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ticketCode = null,Object? userId = null,Object? userName = null,Object? userEmail = null,Object? userPhone = freezed,Object? category = null,Object? priority = null,Object? status = null,Object? title = null,Object? description = null,Object? relatedInspectionId = freezed,Object? relatedBatchId = freezed,Object? attachmentUrls = null,Object? resolutionNotes = freezed,Object? resolvedBy = freezed,Object? resolvedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_SupportTicket(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ticketCode: null == ticketCode ? _self.ticketCode : ticketCode // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userEmail: null == userEmail ? _self.userEmail : userEmail // ignore: cast_nullable_to_non_nullable
as String,userPhone: freezed == userPhone ? _self.userPhone : userPhone // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as TicketCategory,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TicketPriority,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TicketStatus,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,relatedInspectionId: freezed == relatedInspectionId ? _self.relatedInspectionId : relatedInspectionId // ignore: cast_nullable_to_non_nullable
as String?,relatedBatchId: freezed == relatedBatchId ? _self.relatedBatchId : relatedBatchId // ignore: cast_nullable_to_non_nullable
as String?,attachmentUrls: null == attachmentUrls ? _self._attachmentUrls : attachmentUrls // ignore: cast_nullable_to_non_nullable
as List<String>,resolutionNotes: freezed == resolutionNotes ? _self.resolutionNotes : resolutionNotes // ignore: cast_nullable_to_non_nullable
as String?,resolvedBy: freezed == resolvedBy ? _self.resolvedBy : resolvedBy // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
