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
        unknownValue: MembershipStatus.notAMember,
      ) ??
      MembershipStatus.notAMember,
  hasAcceptedTerms: json['has_accepted_terms'] as bool? ?? false,
  isAdmin: json['is_admin'] as bool? ?? false,
  qcCode: json['qc_code'] as String?,
  memberCode: json['member_code'] as String?,
  cardCode: json['card_code'] as String?,
  cardCodeVersion: (json['card_code_version'] as num?)?.toInt() ?? 1,
  membershipCategory: json['membership_category'] as String?,
  chapter: json['chapter'] as String?,
  jobTitle: json['job_title'] as String?,
  employer: json['employer'] as String?,
  companyName: json['company_name'] as String?,
  representativeName: json['representative_name'] as String?,
  tcdaLicenceNumber: json['tcda_licence_number'] as String?,
  tcdaLicenceStatus: json['tcda_licence_status'] as String?,
  directoryConsent: json['directory_consent'] as bool? ?? false,
  directoryHidden: json['directory_hidden'] as bool? ?? false,
  hiddenAt: json['hidden_at'] == null
      ? null
      : DateTime.parse(json['hidden_at'] as String),
  hiddenBy: json['hidden_by'] as String?,
  hiddenReason: json['hidden_reason'] as String?,
  memberSince: json['member_since'] == null
      ? null
      : DateTime.parse(json['member_since'] as String),
  duesValidUntil: json['dues_valid_until'] == null
      ? null
      : DateTime.parse(json['dues_valid_until'] as String),
  photoUpdatedAt: json['photo_updated_at'] == null
      ? null
      : DateTime.parse(json['photo_updated_at'] as String),
  mustChangePassword: json['must_change_password'] as bool? ?? false,
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
  'has_accepted_terms': instance.hasAcceptedTerms,
  'is_admin': instance.isAdmin,
  'qc_code': instance.qcCode,
  'member_code': instance.memberCode,
  'card_code': instance.cardCode,
  'card_code_version': instance.cardCodeVersion,
  'membership_category': instance.membershipCategory,
  'chapter': instance.chapter,
  'job_title': instance.jobTitle,
  'employer': instance.employer,
  'company_name': instance.companyName,
  'representative_name': instance.representativeName,
  'tcda_licence_number': instance.tcdaLicenceNumber,
  'tcda_licence_status': instance.tcdaLicenceStatus,
  'directory_consent': instance.directoryConsent,
  'directory_hidden': instance.directoryHidden,
  'hidden_at': instance.hiddenAt?.toIso8601String(),
  'hidden_by': instance.hiddenBy,
  'hidden_reason': instance.hiddenReason,
  'member_since': instance.memberSince?.toIso8601String(),
  'dues_valid_until': instance.duesValidUntil?.toIso8601String(),
  'photo_updated_at': instance.photoUpdatedAt?.toIso8601String(),
  'must_change_password': instance.mustChangePassword,
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
  MembershipStatus.approvedPaymentPending: 'approved_payment_pending',
  MembershipStatus.active: 'active',
  MembershipStatus.verified: 'verified',
  MembershipStatus.hibernated: 'hibernated',
  MembershipStatus.suspended: 'suspended',
  MembershipStatus.declined: 'declined',
};
