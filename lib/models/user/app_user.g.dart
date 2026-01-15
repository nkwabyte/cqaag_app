// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  id: json['id'] as String,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  email: json['email'] as String,
  profilePicture:
      json['profile_picture'] as String? ??
      'https://www.gravatar.com/avatar/?d=identicon',
  status:
      $enumDecodeNullable(_$AppUserStatusEnumMap, json['status']) ??
      AppUserStatus.active,
  address: json['address'] as String?,
  district: json['district'] as String?,
  region: json['region'] as String?,
  phoneNumber: json['phone_number'] as String?,
  role: json['role'] as String?,
  verification: json['verification'] == null
      ? null
      : VerificationData.fromJson(json['verification'] as Map<String, dynamic>),
  verificationStatus:
      $enumDecodeNullable(
        _$VerificationStatusEnumMap,
        json['verification_status'],
      ) ??
      VerificationStatus.unverified,
  membershipStatus:
      $enumDecodeNullable(
        _$MembershipStatusEnumMap,
        json['membership_status'],
      ) ??
      MembershipStatus.notAMember,
  isAdmin: json['is_admin'] as bool? ?? false,
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'id': instance.id,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'email': instance.email,
  'profile_picture': instance.profilePicture,
  'status': _$AppUserStatusEnumMap[instance.status]!,
  'address': instance.address,
  'district': instance.district,
  'region': instance.region,
  'phone_number': instance.phoneNumber,
  'role': instance.role,
  'verification': instance.verification,
  'verification_status':
      _$VerificationStatusEnumMap[instance.verificationStatus]!,
  'membership_status': _$MembershipStatusEnumMap[instance.membershipStatus]!,
  'is_admin': instance.isAdmin,
};

const _$AppUserStatusEnumMap = {
  AppUserStatus.active: 'active',
  AppUserStatus.suspended: 'suspended',
  AppUserStatus.banned: 'banned',
  AppUserStatus.inactive: 'inactive',
};

const _$VerificationStatusEnumMap = {
  VerificationStatus.unverified: 'unverified',
  VerificationStatus.pending: 'pending',
  VerificationStatus.verified: 'verified',
  VerificationStatus.rejected: 'rejected',
};

const _$MembershipStatusEnumMap = {
  MembershipStatus.notAMember: 'Not a member',
  MembershipStatus.applied: 'applied',
  MembershipStatus.pendingReview: 'pending review',
  MembershipStatus.underReview: 'under review',
  MembershipStatus.verified: 'verified',
};
