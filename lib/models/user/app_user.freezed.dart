// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUser {

 String get id; String get firstName; String get lastName; String get email; String get profilePicture; AppUserStatus get status; String? get address; String? get district; String? get region; String? get phoneNumber; String? get role; VerificationData? get verification; VerificationStatus get verificationStatus;@JsonKey(unknownEnumValue: MembershipStatus.notAMember) MembershipStatus get membershipStatus; bool get hasAcceptedTerms; bool get isAdmin; String? get qcCode;/// Official Member Number: CQAAG-M-nnnn (Section 9.1)
 String? get memberCode;/// Cryptographic QR verification code / nonce: e.g. 5C21B7A0 (Section 9.2)
 String? get cardCode; int get cardCodeVersion;/// Membership Category (Section 9.1: Full Member, National Associate, Foreign Associate, Corporate, Honorary)
 String? get membershipCategory;/// Regional Chapter (Section 9.1)
 String? get chapter;/// Professional details (Section 9.2, Section 10)
 String? get jobTitle; String? get employer;/// Corporate specific fields (Section 9.1)
 String? get companyName; String? get representativeName;/// TCDA Licence linking (Section 9.2, Section 22)
 String? get tcdaLicenceNumber; String? get tcdaLicenceStatus;/// Public Member Directory consent and visibility (Section 10)
 bool get directoryConsent; bool get directoryHidden; DateTime? get hiddenAt; String? get hiddenBy; String? get hiddenReason;/// Dates for dues, member since, photo update
 DateTime? get memberSince; DateTime? get duesValidUntil; DateTime? get photoUpdatedAt;/// Set on accounts created for a member with a generated password, so
/// they are asked to choose their own on first sign-in.
 bool get mustChangePassword;
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUserCopyWith<AppUser> get copyWith => _$AppUserCopyWithImpl<AppUser>(this as AppUser, _$identity);

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUser&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.profilePicture, profilePicture) || other.profilePicture == profilePicture)&&(identical(other.status, status) || other.status == status)&&(identical(other.address, address) || other.address == address)&&(identical(other.district, district) || other.district == district)&&(identical(other.region, region) || other.region == region)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.role, role) || other.role == role)&&(identical(other.verification, verification) || other.verification == verification)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.membershipStatus, membershipStatus) || other.membershipStatus == membershipStatus)&&(identical(other.hasAcceptedTerms, hasAcceptedTerms) || other.hasAcceptedTerms == hasAcceptedTerms)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.qcCode, qcCode) || other.qcCode == qcCode)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.cardCode, cardCode) || other.cardCode == cardCode)&&(identical(other.cardCodeVersion, cardCodeVersion) || other.cardCodeVersion == cardCodeVersion)&&(identical(other.membershipCategory, membershipCategory) || other.membershipCategory == membershipCategory)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.jobTitle, jobTitle) || other.jobTitle == jobTitle)&&(identical(other.employer, employer) || other.employer == employer)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.representativeName, representativeName) || other.representativeName == representativeName)&&(identical(other.tcdaLicenceNumber, tcdaLicenceNumber) || other.tcdaLicenceNumber == tcdaLicenceNumber)&&(identical(other.tcdaLicenceStatus, tcdaLicenceStatus) || other.tcdaLicenceStatus == tcdaLicenceStatus)&&(identical(other.directoryConsent, directoryConsent) || other.directoryConsent == directoryConsent)&&(identical(other.directoryHidden, directoryHidden) || other.directoryHidden == directoryHidden)&&(identical(other.hiddenAt, hiddenAt) || other.hiddenAt == hiddenAt)&&(identical(other.hiddenBy, hiddenBy) || other.hiddenBy == hiddenBy)&&(identical(other.hiddenReason, hiddenReason) || other.hiddenReason == hiddenReason)&&(identical(other.memberSince, memberSince) || other.memberSince == memberSince)&&(identical(other.duesValidUntil, duesValidUntil) || other.duesValidUntil == duesValidUntil)&&(identical(other.photoUpdatedAt, photoUpdatedAt) || other.photoUpdatedAt == photoUpdatedAt)&&(identical(other.mustChangePassword, mustChangePassword) || other.mustChangePassword == mustChangePassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,firstName,lastName,email,profilePicture,status,address,district,region,phoneNumber,role,verification,verificationStatus,membershipStatus,hasAcceptedTerms,isAdmin,qcCode,memberCode,cardCode,cardCodeVersion,membershipCategory,chapter,jobTitle,employer,companyName,representativeName,tcdaLicenceNumber,tcdaLicenceStatus,directoryConsent,directoryHidden,hiddenAt,hiddenBy,hiddenReason,memberSince,duesValidUntil,photoUpdatedAt,mustChangePassword]);

@override
String toString() {
  return 'AppUser(id: $id, firstName: $firstName, lastName: $lastName, email: $email, profilePicture: $profilePicture, status: $status, address: $address, district: $district, region: $region, phoneNumber: $phoneNumber, role: $role, verification: $verification, verificationStatus: $verificationStatus, membershipStatus: $membershipStatus, hasAcceptedTerms: $hasAcceptedTerms, isAdmin: $isAdmin, qcCode: $qcCode, memberCode: $memberCode, cardCode: $cardCode, cardCodeVersion: $cardCodeVersion, membershipCategory: $membershipCategory, chapter: $chapter, jobTitle: $jobTitle, employer: $employer, companyName: $companyName, representativeName: $representativeName, tcdaLicenceNumber: $tcdaLicenceNumber, tcdaLicenceStatus: $tcdaLicenceStatus, directoryConsent: $directoryConsent, directoryHidden: $directoryHidden, hiddenAt: $hiddenAt, hiddenBy: $hiddenBy, hiddenReason: $hiddenReason, memberSince: $memberSince, duesValidUntil: $duesValidUntil, photoUpdatedAt: $photoUpdatedAt, mustChangePassword: $mustChangePassword)';
}


}

/// @nodoc
abstract mixin class $AppUserCopyWith<$Res>  {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) _then) = _$AppUserCopyWithImpl;
@useResult
$Res call({
 String id, String firstName, String lastName, String email, String profilePicture, AppUserStatus status, String? address, String? district, String? region, String? phoneNumber, String? role, VerificationData? verification, VerificationStatus verificationStatus,@JsonKey(unknownEnumValue: MembershipStatus.notAMember) MembershipStatus membershipStatus, bool hasAcceptedTerms, bool isAdmin, String? qcCode, String? memberCode, String? cardCode, int cardCodeVersion, String? membershipCategory, String? chapter, String? jobTitle, String? employer, String? companyName, String? representativeName, String? tcdaLicenceNumber, String? tcdaLicenceStatus, bool directoryConsent, bool directoryHidden, DateTime? hiddenAt, String? hiddenBy, String? hiddenReason, DateTime? memberSince, DateTime? duesValidUntil, DateTime? photoUpdatedAt, bool mustChangePassword
});


$VerificationDataCopyWith<$Res>? get verification;

}
/// @nodoc
class _$AppUserCopyWithImpl<$Res>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._self, this._then);

  final AppUser _self;
  final $Res Function(AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? profilePicture = null,Object? status = null,Object? address = freezed,Object? district = freezed,Object? region = freezed,Object? phoneNumber = freezed,Object? role = freezed,Object? verification = freezed,Object? verificationStatus = null,Object? membershipStatus = null,Object? hasAcceptedTerms = null,Object? isAdmin = null,Object? qcCode = freezed,Object? memberCode = freezed,Object? cardCode = freezed,Object? cardCodeVersion = null,Object? membershipCategory = freezed,Object? chapter = freezed,Object? jobTitle = freezed,Object? employer = freezed,Object? companyName = freezed,Object? representativeName = freezed,Object? tcdaLicenceNumber = freezed,Object? tcdaLicenceStatus = freezed,Object? directoryConsent = null,Object? directoryHidden = null,Object? hiddenAt = freezed,Object? hiddenBy = freezed,Object? hiddenReason = freezed,Object? memberSince = freezed,Object? duesValidUntil = freezed,Object? photoUpdatedAt = freezed,Object? mustChangePassword = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,profilePicture: null == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AppUserStatus,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,verification: freezed == verification ? _self.verification : verification // ignore: cast_nullable_to_non_nullable
as VerificationData?,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus,membershipStatus: null == membershipStatus ? _self.membershipStatus : membershipStatus // ignore: cast_nullable_to_non_nullable
as MembershipStatus,hasAcceptedTerms: null == hasAcceptedTerms ? _self.hasAcceptedTerms : hasAcceptedTerms // ignore: cast_nullable_to_non_nullable
as bool,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,qcCode: freezed == qcCode ? _self.qcCode : qcCode // ignore: cast_nullable_to_non_nullable
as String?,memberCode: freezed == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String?,cardCode: freezed == cardCode ? _self.cardCode : cardCode // ignore: cast_nullable_to_non_nullable
as String?,cardCodeVersion: null == cardCodeVersion ? _self.cardCodeVersion : cardCodeVersion // ignore: cast_nullable_to_non_nullable
as int,membershipCategory: freezed == membershipCategory ? _self.membershipCategory : membershipCategory // ignore: cast_nullable_to_non_nullable
as String?,chapter: freezed == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as String?,jobTitle: freezed == jobTitle ? _self.jobTitle : jobTitle // ignore: cast_nullable_to_non_nullable
as String?,employer: freezed == employer ? _self.employer : employer // ignore: cast_nullable_to_non_nullable
as String?,companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,representativeName: freezed == representativeName ? _self.representativeName : representativeName // ignore: cast_nullable_to_non_nullable
as String?,tcdaLicenceNumber: freezed == tcdaLicenceNumber ? _self.tcdaLicenceNumber : tcdaLicenceNumber // ignore: cast_nullable_to_non_nullable
as String?,tcdaLicenceStatus: freezed == tcdaLicenceStatus ? _self.tcdaLicenceStatus : tcdaLicenceStatus // ignore: cast_nullable_to_non_nullable
as String?,directoryConsent: null == directoryConsent ? _self.directoryConsent : directoryConsent // ignore: cast_nullable_to_non_nullable
as bool,directoryHidden: null == directoryHidden ? _self.directoryHidden : directoryHidden // ignore: cast_nullable_to_non_nullable
as bool,hiddenAt: freezed == hiddenAt ? _self.hiddenAt : hiddenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,hiddenBy: freezed == hiddenBy ? _self.hiddenBy : hiddenBy // ignore: cast_nullable_to_non_nullable
as String?,hiddenReason: freezed == hiddenReason ? _self.hiddenReason : hiddenReason // ignore: cast_nullable_to_non_nullable
as String?,memberSince: freezed == memberSince ? _self.memberSince : memberSince // ignore: cast_nullable_to_non_nullable
as DateTime?,duesValidUntil: freezed == duesValidUntil ? _self.duesValidUntil : duesValidUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,photoUpdatedAt: freezed == photoUpdatedAt ? _self.photoUpdatedAt : photoUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,mustChangePassword: null == mustChangePassword ? _self.mustChangePassword : mustChangePassword // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerificationDataCopyWith<$Res>? get verification {
    if (_self.verification == null) {
    return null;
  }

  return $VerificationDataCopyWith<$Res>(_self.verification!, (value) {
    return _then(_self.copyWith(verification: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppUser].
extension AppUserPatterns on AppUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUser value)  $default,){
final _that = this;
switch (_that) {
case _AppUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUser value)?  $default,){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String firstName,  String lastName,  String email,  String profilePicture,  AppUserStatus status,  String? address,  String? district,  String? region,  String? phoneNumber,  String? role,  VerificationData? verification,  VerificationStatus verificationStatus, @JsonKey(unknownEnumValue: MembershipStatus.notAMember)  MembershipStatus membershipStatus,  bool hasAcceptedTerms,  bool isAdmin,  String? qcCode,  String? memberCode,  String? cardCode,  int cardCodeVersion,  String? membershipCategory,  String? chapter,  String? jobTitle,  String? employer,  String? companyName,  String? representativeName,  String? tcdaLicenceNumber,  String? tcdaLicenceStatus,  bool directoryConsent,  bool directoryHidden,  DateTime? hiddenAt,  String? hiddenBy,  String? hiddenReason,  DateTime? memberSince,  DateTime? duesValidUntil,  DateTime? photoUpdatedAt,  bool mustChangePassword)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.email,_that.profilePicture,_that.status,_that.address,_that.district,_that.region,_that.phoneNumber,_that.role,_that.verification,_that.verificationStatus,_that.membershipStatus,_that.hasAcceptedTerms,_that.isAdmin,_that.qcCode,_that.memberCode,_that.cardCode,_that.cardCodeVersion,_that.membershipCategory,_that.chapter,_that.jobTitle,_that.employer,_that.companyName,_that.representativeName,_that.tcdaLicenceNumber,_that.tcdaLicenceStatus,_that.directoryConsent,_that.directoryHidden,_that.hiddenAt,_that.hiddenBy,_that.hiddenReason,_that.memberSince,_that.duesValidUntil,_that.photoUpdatedAt,_that.mustChangePassword);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String firstName,  String lastName,  String email,  String profilePicture,  AppUserStatus status,  String? address,  String? district,  String? region,  String? phoneNumber,  String? role,  VerificationData? verification,  VerificationStatus verificationStatus, @JsonKey(unknownEnumValue: MembershipStatus.notAMember)  MembershipStatus membershipStatus,  bool hasAcceptedTerms,  bool isAdmin,  String? qcCode,  String? memberCode,  String? cardCode,  int cardCodeVersion,  String? membershipCategory,  String? chapter,  String? jobTitle,  String? employer,  String? companyName,  String? representativeName,  String? tcdaLicenceNumber,  String? tcdaLicenceStatus,  bool directoryConsent,  bool directoryHidden,  DateTime? hiddenAt,  String? hiddenBy,  String? hiddenReason,  DateTime? memberSince,  DateTime? duesValidUntil,  DateTime? photoUpdatedAt,  bool mustChangePassword)  $default,) {final _that = this;
switch (_that) {
case _AppUser():
return $default(_that.id,_that.firstName,_that.lastName,_that.email,_that.profilePicture,_that.status,_that.address,_that.district,_that.region,_that.phoneNumber,_that.role,_that.verification,_that.verificationStatus,_that.membershipStatus,_that.hasAcceptedTerms,_that.isAdmin,_that.qcCode,_that.memberCode,_that.cardCode,_that.cardCodeVersion,_that.membershipCategory,_that.chapter,_that.jobTitle,_that.employer,_that.companyName,_that.representativeName,_that.tcdaLicenceNumber,_that.tcdaLicenceStatus,_that.directoryConsent,_that.directoryHidden,_that.hiddenAt,_that.hiddenBy,_that.hiddenReason,_that.memberSince,_that.duesValidUntil,_that.photoUpdatedAt,_that.mustChangePassword);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String firstName,  String lastName,  String email,  String profilePicture,  AppUserStatus status,  String? address,  String? district,  String? region,  String? phoneNumber,  String? role,  VerificationData? verification,  VerificationStatus verificationStatus, @JsonKey(unknownEnumValue: MembershipStatus.notAMember)  MembershipStatus membershipStatus,  bool hasAcceptedTerms,  bool isAdmin,  String? qcCode,  String? memberCode,  String? cardCode,  int cardCodeVersion,  String? membershipCategory,  String? chapter,  String? jobTitle,  String? employer,  String? companyName,  String? representativeName,  String? tcdaLicenceNumber,  String? tcdaLicenceStatus,  bool directoryConsent,  bool directoryHidden,  DateTime? hiddenAt,  String? hiddenBy,  String? hiddenReason,  DateTime? memberSince,  DateTime? duesValidUntil,  DateTime? photoUpdatedAt,  bool mustChangePassword)?  $default,) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.email,_that.profilePicture,_that.status,_that.address,_that.district,_that.region,_that.phoneNumber,_that.role,_that.verification,_that.verificationStatus,_that.membershipStatus,_that.hasAcceptedTerms,_that.isAdmin,_that.qcCode,_that.memberCode,_that.cardCode,_that.cardCodeVersion,_that.membershipCategory,_that.chapter,_that.jobTitle,_that.employer,_that.companyName,_that.representativeName,_that.tcdaLicenceNumber,_that.tcdaLicenceStatus,_that.directoryConsent,_that.directoryHidden,_that.hiddenAt,_that.hiddenBy,_that.hiddenReason,_that.memberSince,_that.duesValidUntil,_that.photoUpdatedAt,_that.mustChangePassword);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _AppUser implements AppUser {
  const _AppUser({required this.id, required this.firstName, required this.lastName, required this.email, this.profilePicture = 'https://www.gravatar.com/avatar/?d=identicon', this.status = AppUserStatus.active, this.address, this.district, this.region, this.phoneNumber, this.role, this.verification, this.verificationStatus = VerificationStatus.unverified, @JsonKey(unknownEnumValue: MembershipStatus.notAMember) this.membershipStatus = MembershipStatus.notAMember, this.hasAcceptedTerms = false, this.isAdmin = false, this.qcCode, this.memberCode, this.cardCode, this.cardCodeVersion = 1, this.membershipCategory, this.chapter, this.jobTitle, this.employer, this.companyName, this.representativeName, this.tcdaLicenceNumber, this.tcdaLicenceStatus, this.directoryConsent = false, this.directoryHidden = false, this.hiddenAt, this.hiddenBy, this.hiddenReason, this.memberSince, this.duesValidUntil, this.photoUpdatedAt, this.mustChangePassword = false});
  factory _AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

@override final  String id;
@override final  String firstName;
@override final  String lastName;
@override final  String email;
@override@JsonKey() final  String profilePicture;
@override@JsonKey() final  AppUserStatus status;
@override final  String? address;
@override final  String? district;
@override final  String? region;
@override final  String? phoneNumber;
@override final  String? role;
@override final  VerificationData? verification;
@override@JsonKey() final  VerificationStatus verificationStatus;
@override@JsonKey(unknownEnumValue: MembershipStatus.notAMember) final  MembershipStatus membershipStatus;
@override@JsonKey() final  bool hasAcceptedTerms;
@override@JsonKey() final  bool isAdmin;
@override final  String? qcCode;
/// Official Member Number: CQAAG-M-nnnn (Section 9.1)
@override final  String? memberCode;
/// Cryptographic QR verification code / nonce: e.g. 5C21B7A0 (Section 9.2)
@override final  String? cardCode;
@override@JsonKey() final  int cardCodeVersion;
/// Membership Category (Section 9.1: Full Member, National Associate, Foreign Associate, Corporate, Honorary)
@override final  String? membershipCategory;
/// Regional Chapter (Section 9.1)
@override final  String? chapter;
/// Professional details (Section 9.2, Section 10)
@override final  String? jobTitle;
@override final  String? employer;
/// Corporate specific fields (Section 9.1)
@override final  String? companyName;
@override final  String? representativeName;
/// TCDA Licence linking (Section 9.2, Section 22)
@override final  String? tcdaLicenceNumber;
@override final  String? tcdaLicenceStatus;
/// Public Member Directory consent and visibility (Section 10)
@override@JsonKey() final  bool directoryConsent;
@override@JsonKey() final  bool directoryHidden;
@override final  DateTime? hiddenAt;
@override final  String? hiddenBy;
@override final  String? hiddenReason;
/// Dates for dues, member since, photo update
@override final  DateTime? memberSince;
@override final  DateTime? duesValidUntil;
@override final  DateTime? photoUpdatedAt;
/// Set on accounts created for a member with a generated password, so
/// they are asked to choose their own on first sign-in.
@override@JsonKey() final  bool mustChangePassword;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUserCopyWith<_AppUser> get copyWith => __$AppUserCopyWithImpl<_AppUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUser&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.profilePicture, profilePicture) || other.profilePicture == profilePicture)&&(identical(other.status, status) || other.status == status)&&(identical(other.address, address) || other.address == address)&&(identical(other.district, district) || other.district == district)&&(identical(other.region, region) || other.region == region)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.role, role) || other.role == role)&&(identical(other.verification, verification) || other.verification == verification)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.membershipStatus, membershipStatus) || other.membershipStatus == membershipStatus)&&(identical(other.hasAcceptedTerms, hasAcceptedTerms) || other.hasAcceptedTerms == hasAcceptedTerms)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.qcCode, qcCode) || other.qcCode == qcCode)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.cardCode, cardCode) || other.cardCode == cardCode)&&(identical(other.cardCodeVersion, cardCodeVersion) || other.cardCodeVersion == cardCodeVersion)&&(identical(other.membershipCategory, membershipCategory) || other.membershipCategory == membershipCategory)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.jobTitle, jobTitle) || other.jobTitle == jobTitle)&&(identical(other.employer, employer) || other.employer == employer)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.representativeName, representativeName) || other.representativeName == representativeName)&&(identical(other.tcdaLicenceNumber, tcdaLicenceNumber) || other.tcdaLicenceNumber == tcdaLicenceNumber)&&(identical(other.tcdaLicenceStatus, tcdaLicenceStatus) || other.tcdaLicenceStatus == tcdaLicenceStatus)&&(identical(other.directoryConsent, directoryConsent) || other.directoryConsent == directoryConsent)&&(identical(other.directoryHidden, directoryHidden) || other.directoryHidden == directoryHidden)&&(identical(other.hiddenAt, hiddenAt) || other.hiddenAt == hiddenAt)&&(identical(other.hiddenBy, hiddenBy) || other.hiddenBy == hiddenBy)&&(identical(other.hiddenReason, hiddenReason) || other.hiddenReason == hiddenReason)&&(identical(other.memberSince, memberSince) || other.memberSince == memberSince)&&(identical(other.duesValidUntil, duesValidUntil) || other.duesValidUntil == duesValidUntil)&&(identical(other.photoUpdatedAt, photoUpdatedAt) || other.photoUpdatedAt == photoUpdatedAt)&&(identical(other.mustChangePassword, mustChangePassword) || other.mustChangePassword == mustChangePassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,firstName,lastName,email,profilePicture,status,address,district,region,phoneNumber,role,verification,verificationStatus,membershipStatus,hasAcceptedTerms,isAdmin,qcCode,memberCode,cardCode,cardCodeVersion,membershipCategory,chapter,jobTitle,employer,companyName,representativeName,tcdaLicenceNumber,tcdaLicenceStatus,directoryConsent,directoryHidden,hiddenAt,hiddenBy,hiddenReason,memberSince,duesValidUntil,photoUpdatedAt,mustChangePassword]);

@override
String toString() {
  return 'AppUser(id: $id, firstName: $firstName, lastName: $lastName, email: $email, profilePicture: $profilePicture, status: $status, address: $address, district: $district, region: $region, phoneNumber: $phoneNumber, role: $role, verification: $verification, verificationStatus: $verificationStatus, membershipStatus: $membershipStatus, hasAcceptedTerms: $hasAcceptedTerms, isAdmin: $isAdmin, qcCode: $qcCode, memberCode: $memberCode, cardCode: $cardCode, cardCodeVersion: $cardCodeVersion, membershipCategory: $membershipCategory, chapter: $chapter, jobTitle: $jobTitle, employer: $employer, companyName: $companyName, representativeName: $representativeName, tcdaLicenceNumber: $tcdaLicenceNumber, tcdaLicenceStatus: $tcdaLicenceStatus, directoryConsent: $directoryConsent, directoryHidden: $directoryHidden, hiddenAt: $hiddenAt, hiddenBy: $hiddenBy, hiddenReason: $hiddenReason, memberSince: $memberSince, duesValidUntil: $duesValidUntil, photoUpdatedAt: $photoUpdatedAt, mustChangePassword: $mustChangePassword)';
}


}

/// @nodoc
abstract mixin class _$AppUserCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$AppUserCopyWith(_AppUser value, $Res Function(_AppUser) _then) = __$AppUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String firstName, String lastName, String email, String profilePicture, AppUserStatus status, String? address, String? district, String? region, String? phoneNumber, String? role, VerificationData? verification, VerificationStatus verificationStatus,@JsonKey(unknownEnumValue: MembershipStatus.notAMember) MembershipStatus membershipStatus, bool hasAcceptedTerms, bool isAdmin, String? qcCode, String? memberCode, String? cardCode, int cardCodeVersion, String? membershipCategory, String? chapter, String? jobTitle, String? employer, String? companyName, String? representativeName, String? tcdaLicenceNumber, String? tcdaLicenceStatus, bool directoryConsent, bool directoryHidden, DateTime? hiddenAt, String? hiddenBy, String? hiddenReason, DateTime? memberSince, DateTime? duesValidUntil, DateTime? photoUpdatedAt, bool mustChangePassword
});


@override $VerificationDataCopyWith<$Res>? get verification;

}
/// @nodoc
class __$AppUserCopyWithImpl<$Res>
    implements _$AppUserCopyWith<$Res> {
  __$AppUserCopyWithImpl(this._self, this._then);

  final _AppUser _self;
  final $Res Function(_AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? profilePicture = null,Object? status = null,Object? address = freezed,Object? district = freezed,Object? region = freezed,Object? phoneNumber = freezed,Object? role = freezed,Object? verification = freezed,Object? verificationStatus = null,Object? membershipStatus = null,Object? hasAcceptedTerms = null,Object? isAdmin = null,Object? qcCode = freezed,Object? memberCode = freezed,Object? cardCode = freezed,Object? cardCodeVersion = null,Object? membershipCategory = freezed,Object? chapter = freezed,Object? jobTitle = freezed,Object? employer = freezed,Object? companyName = freezed,Object? representativeName = freezed,Object? tcdaLicenceNumber = freezed,Object? tcdaLicenceStatus = freezed,Object? directoryConsent = null,Object? directoryHidden = null,Object? hiddenAt = freezed,Object? hiddenBy = freezed,Object? hiddenReason = freezed,Object? memberSince = freezed,Object? duesValidUntil = freezed,Object? photoUpdatedAt = freezed,Object? mustChangePassword = null,}) {
  return _then(_AppUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,profilePicture: null == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AppUserStatus,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,verification: freezed == verification ? _self.verification : verification // ignore: cast_nullable_to_non_nullable
as VerificationData?,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus,membershipStatus: null == membershipStatus ? _self.membershipStatus : membershipStatus // ignore: cast_nullable_to_non_nullable
as MembershipStatus,hasAcceptedTerms: null == hasAcceptedTerms ? _self.hasAcceptedTerms : hasAcceptedTerms // ignore: cast_nullable_to_non_nullable
as bool,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,qcCode: freezed == qcCode ? _self.qcCode : qcCode // ignore: cast_nullable_to_non_nullable
as String?,memberCode: freezed == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String?,cardCode: freezed == cardCode ? _self.cardCode : cardCode // ignore: cast_nullable_to_non_nullable
as String?,cardCodeVersion: null == cardCodeVersion ? _self.cardCodeVersion : cardCodeVersion // ignore: cast_nullable_to_non_nullable
as int,membershipCategory: freezed == membershipCategory ? _self.membershipCategory : membershipCategory // ignore: cast_nullable_to_non_nullable
as String?,chapter: freezed == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as String?,jobTitle: freezed == jobTitle ? _self.jobTitle : jobTitle // ignore: cast_nullable_to_non_nullable
as String?,employer: freezed == employer ? _self.employer : employer // ignore: cast_nullable_to_non_nullable
as String?,companyName: freezed == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String?,representativeName: freezed == representativeName ? _self.representativeName : representativeName // ignore: cast_nullable_to_non_nullable
as String?,tcdaLicenceNumber: freezed == tcdaLicenceNumber ? _self.tcdaLicenceNumber : tcdaLicenceNumber // ignore: cast_nullable_to_non_nullable
as String?,tcdaLicenceStatus: freezed == tcdaLicenceStatus ? _self.tcdaLicenceStatus : tcdaLicenceStatus // ignore: cast_nullable_to_non_nullable
as String?,directoryConsent: null == directoryConsent ? _self.directoryConsent : directoryConsent // ignore: cast_nullable_to_non_nullable
as bool,directoryHidden: null == directoryHidden ? _self.directoryHidden : directoryHidden // ignore: cast_nullable_to_non_nullable
as bool,hiddenAt: freezed == hiddenAt ? _self.hiddenAt : hiddenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,hiddenBy: freezed == hiddenBy ? _self.hiddenBy : hiddenBy // ignore: cast_nullable_to_non_nullable
as String?,hiddenReason: freezed == hiddenReason ? _self.hiddenReason : hiddenReason // ignore: cast_nullable_to_non_nullable
as String?,memberSince: freezed == memberSince ? _self.memberSince : memberSince // ignore: cast_nullable_to_non_nullable
as DateTime?,duesValidUntil: freezed == duesValidUntil ? _self.duesValidUntil : duesValidUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,photoUpdatedAt: freezed == photoUpdatedAt ? _self.photoUpdatedAt : photoUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,mustChangePassword: null == mustChangePassword ? _self.mustChangePassword : mustChangePassword // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerificationDataCopyWith<$Res>? get verification {
    if (_self.verification == null) {
    return null;
  }

  return $VerificationDataCopyWith<$Res>(_self.verification!, (value) {
    return _then(_self.copyWith(verification: value));
  });
}
}

// dart format on
