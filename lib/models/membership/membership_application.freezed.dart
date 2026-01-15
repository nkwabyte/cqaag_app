// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membership_application.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MembershipApplication {

/// Unique application ID
 String get id;/// User ID of the applicant
 String get userId;// Personal Information
/// Title/Salutation
 Title get title;/// First name
 String get firstName;/// Middle name(s)
 String? get middleName;/// Last name
 String get lastName;/// Date of birth (stored as ISO 8601 string)
 String get dateOfBirth;/// Gender
 Gender get gender;/// Nationality
 String get nationality;/// Ghana Card / ID Number
 String? get ghanaCardNumber;/// Primary phone number
 String get phoneNumberPrimary;/// Secondary phone number
 String? get phoneNumberSecondary;/// Email address
 String get emailAddress;/// Residential address
 String get residentialAddress;/// Region/District
 String get regionDistrict;// Professional Information
/// Current job title
 String get currentJobTitle;/// Employer/Organization
 String get employerOrganization;/// Desired membership category
 MembershipCategory get membershipCategory;/// Application status
 ApplicationStatus get status;// Timestamps
/// When the application was created
 DateTime? get createdAt;/// When the application was submitted
 DateTime? get submittedAt;/// When the application was last updated
 DateTime? get updatedAt;/// When the application was reviewed
 DateTime? get reviewedAt;// Review Information
/// Notes from the reviewer
 String? get reviewNotes;/// ID of the reviewer
 String? get reviewerId;
/// Create a copy of MembershipApplication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembershipApplicationCopyWith<MembershipApplication> get copyWith => _$MembershipApplicationCopyWithImpl<MembershipApplication>(this as MembershipApplication, _$identity);

  /// Serializes this MembershipApplication to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MembershipApplication&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.middleName, middleName) || other.middleName == middleName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.nationality, nationality) || other.nationality == nationality)&&(identical(other.ghanaCardNumber, ghanaCardNumber) || other.ghanaCardNumber == ghanaCardNumber)&&(identical(other.phoneNumberPrimary, phoneNumberPrimary) || other.phoneNumberPrimary == phoneNumberPrimary)&&(identical(other.phoneNumberSecondary, phoneNumberSecondary) || other.phoneNumberSecondary == phoneNumberSecondary)&&(identical(other.emailAddress, emailAddress) || other.emailAddress == emailAddress)&&(identical(other.residentialAddress, residentialAddress) || other.residentialAddress == residentialAddress)&&(identical(other.regionDistrict, regionDistrict) || other.regionDistrict == regionDistrict)&&(identical(other.currentJobTitle, currentJobTitle) || other.currentJobTitle == currentJobTitle)&&(identical(other.employerOrganization, employerOrganization) || other.employerOrganization == employerOrganization)&&(identical(other.membershipCategory, membershipCategory) || other.membershipCategory == membershipCategory)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.reviewNotes, reviewNotes) || other.reviewNotes == reviewNotes)&&(identical(other.reviewerId, reviewerId) || other.reviewerId == reviewerId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,title,firstName,middleName,lastName,dateOfBirth,gender,nationality,ghanaCardNumber,phoneNumberPrimary,phoneNumberSecondary,emailAddress,residentialAddress,regionDistrict,currentJobTitle,employerOrganization,membershipCategory,status,createdAt,submittedAt,updatedAt,reviewedAt,reviewNotes,reviewerId]);

@override
String toString() {
  return 'MembershipApplication(id: $id, userId: $userId, title: $title, firstName: $firstName, middleName: $middleName, lastName: $lastName, dateOfBirth: $dateOfBirth, gender: $gender, nationality: $nationality, ghanaCardNumber: $ghanaCardNumber, phoneNumberPrimary: $phoneNumberPrimary, phoneNumberSecondary: $phoneNumberSecondary, emailAddress: $emailAddress, residentialAddress: $residentialAddress, regionDistrict: $regionDistrict, currentJobTitle: $currentJobTitle, employerOrganization: $employerOrganization, membershipCategory: $membershipCategory, status: $status, createdAt: $createdAt, submittedAt: $submittedAt, updatedAt: $updatedAt, reviewedAt: $reviewedAt, reviewNotes: $reviewNotes, reviewerId: $reviewerId)';
}


}

/// @nodoc
abstract mixin class $MembershipApplicationCopyWith<$Res>  {
  factory $MembershipApplicationCopyWith(MembershipApplication value, $Res Function(MembershipApplication) _then) = _$MembershipApplicationCopyWithImpl;
@useResult
$Res call({
 String id, String userId, Title title, String firstName, String? middleName, String lastName, String dateOfBirth, Gender gender, String nationality, String? ghanaCardNumber, String phoneNumberPrimary, String? phoneNumberSecondary, String emailAddress, String residentialAddress, String regionDistrict, String currentJobTitle, String employerOrganization, MembershipCategory membershipCategory, ApplicationStatus status, DateTime? createdAt, DateTime? submittedAt, DateTime? updatedAt, DateTime? reviewedAt, String? reviewNotes, String? reviewerId
});




}
/// @nodoc
class _$MembershipApplicationCopyWithImpl<$Res>
    implements $MembershipApplicationCopyWith<$Res> {
  _$MembershipApplicationCopyWithImpl(this._self, this._then);

  final MembershipApplication _self;
  final $Res Function(MembershipApplication) _then;

/// Create a copy of MembershipApplication
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? title = null,Object? firstName = null,Object? middleName = freezed,Object? lastName = null,Object? dateOfBirth = null,Object? gender = null,Object? nationality = null,Object? ghanaCardNumber = freezed,Object? phoneNumberPrimary = null,Object? phoneNumberSecondary = freezed,Object? emailAddress = null,Object? residentialAddress = null,Object? regionDistrict = null,Object? currentJobTitle = null,Object? employerOrganization = null,Object? membershipCategory = null,Object? status = null,Object? createdAt = freezed,Object? submittedAt = freezed,Object? updatedAt = freezed,Object? reviewedAt = freezed,Object? reviewNotes = freezed,Object? reviewerId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as Title,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,middleName: freezed == middleName ? _self.middleName : middleName // ignore: cast_nullable_to_non_nullable
as String?,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: null == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,nationality: null == nationality ? _self.nationality : nationality // ignore: cast_nullable_to_non_nullable
as String,ghanaCardNumber: freezed == ghanaCardNumber ? _self.ghanaCardNumber : ghanaCardNumber // ignore: cast_nullable_to_non_nullable
as String?,phoneNumberPrimary: null == phoneNumberPrimary ? _self.phoneNumberPrimary : phoneNumberPrimary // ignore: cast_nullable_to_non_nullable
as String,phoneNumberSecondary: freezed == phoneNumberSecondary ? _self.phoneNumberSecondary : phoneNumberSecondary // ignore: cast_nullable_to_non_nullable
as String?,emailAddress: null == emailAddress ? _self.emailAddress : emailAddress // ignore: cast_nullable_to_non_nullable
as String,residentialAddress: null == residentialAddress ? _self.residentialAddress : residentialAddress // ignore: cast_nullable_to_non_nullable
as String,regionDistrict: null == regionDistrict ? _self.regionDistrict : regionDistrict // ignore: cast_nullable_to_non_nullable
as String,currentJobTitle: null == currentJobTitle ? _self.currentJobTitle : currentJobTitle // ignore: cast_nullable_to_non_nullable
as String,employerOrganization: null == employerOrganization ? _self.employerOrganization : employerOrganization // ignore: cast_nullable_to_non_nullable
as String,membershipCategory: null == membershipCategory ? _self.membershipCategory : membershipCategory // ignore: cast_nullable_to_non_nullable
as MembershipCategory,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ApplicationStatus,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewNotes: freezed == reviewNotes ? _self.reviewNotes : reviewNotes // ignore: cast_nullable_to_non_nullable
as String?,reviewerId: freezed == reviewerId ? _self.reviewerId : reviewerId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MembershipApplication].
extension MembershipApplicationPatterns on MembershipApplication {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MembershipApplication value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MembershipApplication() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MembershipApplication value)  $default,){
final _that = this;
switch (_that) {
case _MembershipApplication():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MembershipApplication value)?  $default,){
final _that = this;
switch (_that) {
case _MembershipApplication() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  Title title,  String firstName,  String? middleName,  String lastName,  String dateOfBirth,  Gender gender,  String nationality,  String? ghanaCardNumber,  String phoneNumberPrimary,  String? phoneNumberSecondary,  String emailAddress,  String residentialAddress,  String regionDistrict,  String currentJobTitle,  String employerOrganization,  MembershipCategory membershipCategory,  ApplicationStatus status,  DateTime? createdAt,  DateTime? submittedAt,  DateTime? updatedAt,  DateTime? reviewedAt,  String? reviewNotes,  String? reviewerId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MembershipApplication() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.firstName,_that.middleName,_that.lastName,_that.dateOfBirth,_that.gender,_that.nationality,_that.ghanaCardNumber,_that.phoneNumberPrimary,_that.phoneNumberSecondary,_that.emailAddress,_that.residentialAddress,_that.regionDistrict,_that.currentJobTitle,_that.employerOrganization,_that.membershipCategory,_that.status,_that.createdAt,_that.submittedAt,_that.updatedAt,_that.reviewedAt,_that.reviewNotes,_that.reviewerId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  Title title,  String firstName,  String? middleName,  String lastName,  String dateOfBirth,  Gender gender,  String nationality,  String? ghanaCardNumber,  String phoneNumberPrimary,  String? phoneNumberSecondary,  String emailAddress,  String residentialAddress,  String regionDistrict,  String currentJobTitle,  String employerOrganization,  MembershipCategory membershipCategory,  ApplicationStatus status,  DateTime? createdAt,  DateTime? submittedAt,  DateTime? updatedAt,  DateTime? reviewedAt,  String? reviewNotes,  String? reviewerId)  $default,) {final _that = this;
switch (_that) {
case _MembershipApplication():
return $default(_that.id,_that.userId,_that.title,_that.firstName,_that.middleName,_that.lastName,_that.dateOfBirth,_that.gender,_that.nationality,_that.ghanaCardNumber,_that.phoneNumberPrimary,_that.phoneNumberSecondary,_that.emailAddress,_that.residentialAddress,_that.regionDistrict,_that.currentJobTitle,_that.employerOrganization,_that.membershipCategory,_that.status,_that.createdAt,_that.submittedAt,_that.updatedAt,_that.reviewedAt,_that.reviewNotes,_that.reviewerId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  Title title,  String firstName,  String? middleName,  String lastName,  String dateOfBirth,  Gender gender,  String nationality,  String? ghanaCardNumber,  String phoneNumberPrimary,  String? phoneNumberSecondary,  String emailAddress,  String residentialAddress,  String regionDistrict,  String currentJobTitle,  String employerOrganization,  MembershipCategory membershipCategory,  ApplicationStatus status,  DateTime? createdAt,  DateTime? submittedAt,  DateTime? updatedAt,  DateTime? reviewedAt,  String? reviewNotes,  String? reviewerId)?  $default,) {final _that = this;
switch (_that) {
case _MembershipApplication() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.firstName,_that.middleName,_that.lastName,_that.dateOfBirth,_that.gender,_that.nationality,_that.ghanaCardNumber,_that.phoneNumberPrimary,_that.phoneNumberSecondary,_that.emailAddress,_that.residentialAddress,_that.regionDistrict,_that.currentJobTitle,_that.employerOrganization,_that.membershipCategory,_that.status,_that.createdAt,_that.submittedAt,_that.updatedAt,_that.reviewedAt,_that.reviewNotes,_that.reviewerId);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MembershipApplication extends MembershipApplication {
  const _MembershipApplication({required this.id, required this.userId, required this.title, required this.firstName, this.middleName, required this.lastName, required this.dateOfBirth, required this.gender, required this.nationality, this.ghanaCardNumber, required this.phoneNumberPrimary, this.phoneNumberSecondary, required this.emailAddress, required this.residentialAddress, required this.regionDistrict, required this.currentJobTitle, required this.employerOrganization, required this.membershipCategory, this.status = ApplicationStatus.draft, this.createdAt, this.submittedAt, this.updatedAt, this.reviewedAt, this.reviewNotes, this.reviewerId}): super._();
  factory _MembershipApplication.fromJson(Map<String, dynamic> json) => _$MembershipApplicationFromJson(json);

/// Unique application ID
@override final  String id;
/// User ID of the applicant
@override final  String userId;
// Personal Information
/// Title/Salutation
@override final  Title title;
/// First name
@override final  String firstName;
/// Middle name(s)
@override final  String? middleName;
/// Last name
@override final  String lastName;
/// Date of birth (stored as ISO 8601 string)
@override final  String dateOfBirth;
/// Gender
@override final  Gender gender;
/// Nationality
@override final  String nationality;
/// Ghana Card / ID Number
@override final  String? ghanaCardNumber;
/// Primary phone number
@override final  String phoneNumberPrimary;
/// Secondary phone number
@override final  String? phoneNumberSecondary;
/// Email address
@override final  String emailAddress;
/// Residential address
@override final  String residentialAddress;
/// Region/District
@override final  String regionDistrict;
// Professional Information
/// Current job title
@override final  String currentJobTitle;
/// Employer/Organization
@override final  String employerOrganization;
/// Desired membership category
@override final  MembershipCategory membershipCategory;
/// Application status
@override@JsonKey() final  ApplicationStatus status;
// Timestamps
/// When the application was created
@override final  DateTime? createdAt;
/// When the application was submitted
@override final  DateTime? submittedAt;
/// When the application was last updated
@override final  DateTime? updatedAt;
/// When the application was reviewed
@override final  DateTime? reviewedAt;
// Review Information
/// Notes from the reviewer
@override final  String? reviewNotes;
/// ID of the reviewer
@override final  String? reviewerId;

/// Create a copy of MembershipApplication
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembershipApplicationCopyWith<_MembershipApplication> get copyWith => __$MembershipApplicationCopyWithImpl<_MembershipApplication>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MembershipApplicationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MembershipApplication&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.middleName, middleName) || other.middleName == middleName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.nationality, nationality) || other.nationality == nationality)&&(identical(other.ghanaCardNumber, ghanaCardNumber) || other.ghanaCardNumber == ghanaCardNumber)&&(identical(other.phoneNumberPrimary, phoneNumberPrimary) || other.phoneNumberPrimary == phoneNumberPrimary)&&(identical(other.phoneNumberSecondary, phoneNumberSecondary) || other.phoneNumberSecondary == phoneNumberSecondary)&&(identical(other.emailAddress, emailAddress) || other.emailAddress == emailAddress)&&(identical(other.residentialAddress, residentialAddress) || other.residentialAddress == residentialAddress)&&(identical(other.regionDistrict, regionDistrict) || other.regionDistrict == regionDistrict)&&(identical(other.currentJobTitle, currentJobTitle) || other.currentJobTitle == currentJobTitle)&&(identical(other.employerOrganization, employerOrganization) || other.employerOrganization == employerOrganization)&&(identical(other.membershipCategory, membershipCategory) || other.membershipCategory == membershipCategory)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.reviewNotes, reviewNotes) || other.reviewNotes == reviewNotes)&&(identical(other.reviewerId, reviewerId) || other.reviewerId == reviewerId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,title,firstName,middleName,lastName,dateOfBirth,gender,nationality,ghanaCardNumber,phoneNumberPrimary,phoneNumberSecondary,emailAddress,residentialAddress,regionDistrict,currentJobTitle,employerOrganization,membershipCategory,status,createdAt,submittedAt,updatedAt,reviewedAt,reviewNotes,reviewerId]);

@override
String toString() {
  return 'MembershipApplication(id: $id, userId: $userId, title: $title, firstName: $firstName, middleName: $middleName, lastName: $lastName, dateOfBirth: $dateOfBirth, gender: $gender, nationality: $nationality, ghanaCardNumber: $ghanaCardNumber, phoneNumberPrimary: $phoneNumberPrimary, phoneNumberSecondary: $phoneNumberSecondary, emailAddress: $emailAddress, residentialAddress: $residentialAddress, regionDistrict: $regionDistrict, currentJobTitle: $currentJobTitle, employerOrganization: $employerOrganization, membershipCategory: $membershipCategory, status: $status, createdAt: $createdAt, submittedAt: $submittedAt, updatedAt: $updatedAt, reviewedAt: $reviewedAt, reviewNotes: $reviewNotes, reviewerId: $reviewerId)';
}


}

/// @nodoc
abstract mixin class _$MembershipApplicationCopyWith<$Res> implements $MembershipApplicationCopyWith<$Res> {
  factory _$MembershipApplicationCopyWith(_MembershipApplication value, $Res Function(_MembershipApplication) _then) = __$MembershipApplicationCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, Title title, String firstName, String? middleName, String lastName, String dateOfBirth, Gender gender, String nationality, String? ghanaCardNumber, String phoneNumberPrimary, String? phoneNumberSecondary, String emailAddress, String residentialAddress, String regionDistrict, String currentJobTitle, String employerOrganization, MembershipCategory membershipCategory, ApplicationStatus status, DateTime? createdAt, DateTime? submittedAt, DateTime? updatedAt, DateTime? reviewedAt, String? reviewNotes, String? reviewerId
});




}
/// @nodoc
class __$MembershipApplicationCopyWithImpl<$Res>
    implements _$MembershipApplicationCopyWith<$Res> {
  __$MembershipApplicationCopyWithImpl(this._self, this._then);

  final _MembershipApplication _self;
  final $Res Function(_MembershipApplication) _then;

/// Create a copy of MembershipApplication
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? title = null,Object? firstName = null,Object? middleName = freezed,Object? lastName = null,Object? dateOfBirth = null,Object? gender = null,Object? nationality = null,Object? ghanaCardNumber = freezed,Object? phoneNumberPrimary = null,Object? phoneNumberSecondary = freezed,Object? emailAddress = null,Object? residentialAddress = null,Object? regionDistrict = null,Object? currentJobTitle = null,Object? employerOrganization = null,Object? membershipCategory = null,Object? status = null,Object? createdAt = freezed,Object? submittedAt = freezed,Object? updatedAt = freezed,Object? reviewedAt = freezed,Object? reviewNotes = freezed,Object? reviewerId = freezed,}) {
  return _then(_MembershipApplication(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as Title,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,middleName: freezed == middleName ? _self.middleName : middleName // ignore: cast_nullable_to_non_nullable
as String?,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: null == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,nationality: null == nationality ? _self.nationality : nationality // ignore: cast_nullable_to_non_nullable
as String,ghanaCardNumber: freezed == ghanaCardNumber ? _self.ghanaCardNumber : ghanaCardNumber // ignore: cast_nullable_to_non_nullable
as String?,phoneNumberPrimary: null == phoneNumberPrimary ? _self.phoneNumberPrimary : phoneNumberPrimary // ignore: cast_nullable_to_non_nullable
as String,phoneNumberSecondary: freezed == phoneNumberSecondary ? _self.phoneNumberSecondary : phoneNumberSecondary // ignore: cast_nullable_to_non_nullable
as String?,emailAddress: null == emailAddress ? _self.emailAddress : emailAddress // ignore: cast_nullable_to_non_nullable
as String,residentialAddress: null == residentialAddress ? _self.residentialAddress : residentialAddress // ignore: cast_nullable_to_non_nullable
as String,regionDistrict: null == regionDistrict ? _self.regionDistrict : regionDistrict // ignore: cast_nullable_to_non_nullable
as String,currentJobTitle: null == currentJobTitle ? _self.currentJobTitle : currentJobTitle // ignore: cast_nullable_to_non_nullable
as String,employerOrganization: null == employerOrganization ? _self.employerOrganization : employerOrganization // ignore: cast_nullable_to_non_nullable
as String,membershipCategory: null == membershipCategory ? _self.membershipCategory : membershipCategory // ignore: cast_nullable_to_non_nullable
as MembershipCategory,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ApplicationStatus,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewNotes: freezed == reviewNotes ? _self.reviewNotes : reviewNotes // ignore: cast_nullable_to_non_nullable
as String?,reviewerId: freezed == reviewerId ? _self.reviewerId : reviewerId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
