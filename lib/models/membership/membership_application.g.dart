// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MembershipApplication _$MembershipApplicationFromJson(
  Map<String, dynamic> json,
) => _MembershipApplication(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  title: $enumDecode(_$TitleEnumMap, json['title']),
  firstName: json['first_name'] as String,
  middleName: json['middle_name'] as String?,
  lastName: json['last_name'] as String,
  dateOfBirth: json['date_of_birth'] as String,
  gender: $enumDecode(_$GenderEnumMap, json['gender']),
  nationality: json['nationality'] as String,
  ghanaCardNumber: json['ghana_card_number'] as String?,
  phoneNumberPrimary: json['phone_number_primary'] as String,
  phoneNumberSecondary: json['phone_number_secondary'] as String?,
  emailAddress: json['email_address'] as String,
  residentialAddress: json['residential_address'] as String,
  regionDistrict: json['region_district'] as String,
  currentJobTitle: json['current_job_title'] as String,
  employerOrganization: json['employer_organization'] as String,
  membershipCategory: $enumDecode(
    _$MembershipCategoryEnumMap,
    json['membership_category'],
  ),
  status:
      $enumDecodeNullable(_$ApplicationStatusEnumMap, json['status']) ??
      ApplicationStatus.draft,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  submittedAt: json['submitted_at'] == null
      ? null
      : DateTime.parse(json['submitted_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  reviewedAt: json['reviewed_at'] == null
      ? null
      : DateTime.parse(json['reviewed_at'] as String),
  reviewNotes: json['review_notes'] as String?,
  reviewerId: json['reviewer_id'] as String?,
  paymentMethod: json['payment_method'] as String?,
  paymentStatus: json['payment_status'] as String? ?? 'unpaid',
  paymentAmount: (json['payment_amount'] as num?)?.toDouble(),
  paymentCurrency: json['payment_currency'] as String? ?? 'GHS',
  paymentEvidenceUrl: json['payment_evidence_url'] as String?,
  paymentReference: json['payment_reference'] as String?,
  paymentMomoNetwork: json['payment_momo_network'] as String?,
  paymentMomoNumber: json['payment_momo_number'] as String?,
  paymentSubmittedAt: json['payment_submitted_at'] == null
      ? null
      : DateTime.parse(json['payment_submitted_at'] as String),
  paymentVerifiedAt: json['payment_verified_at'] == null
      ? null
      : DateTime.parse(json['payment_verified_at'] as String),
  paymentVerifiedBy: json['payment_verified_by'] as String?,
);

Map<String, dynamic> _$MembershipApplicationToJson(
  _MembershipApplication instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'title': _$TitleEnumMap[instance.title]!,
  'first_name': instance.firstName,
  'middle_name': instance.middleName,
  'last_name': instance.lastName,
  'date_of_birth': instance.dateOfBirth,
  'gender': _$GenderEnumMap[instance.gender]!,
  'nationality': instance.nationality,
  'ghana_card_number': instance.ghanaCardNumber,
  'phone_number_primary': instance.phoneNumberPrimary,
  'phone_number_secondary': instance.phoneNumberSecondary,
  'email_address': instance.emailAddress,
  'residential_address': instance.residentialAddress,
  'region_district': instance.regionDistrict,
  'current_job_title': instance.currentJobTitle,
  'employer_organization': instance.employerOrganization,
  'membership_category':
      _$MembershipCategoryEnumMap[instance.membershipCategory]!,
  'status': _$ApplicationStatusEnumMap[instance.status]!,
  'created_at': instance.createdAt?.toIso8601String(),
  'submitted_at': instance.submittedAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'reviewed_at': instance.reviewedAt?.toIso8601String(),
  'review_notes': instance.reviewNotes,
  'reviewer_id': instance.reviewerId,
  'payment_method': instance.paymentMethod,
  'payment_status': instance.paymentStatus,
  'payment_amount': instance.paymentAmount,
  'payment_currency': instance.paymentCurrency,
  'payment_evidence_url': instance.paymentEvidenceUrl,
  'payment_reference': instance.paymentReference,
  'payment_momo_network': instance.paymentMomoNetwork,
  'payment_momo_number': instance.paymentMomoNumber,
  'payment_submitted_at': instance.paymentSubmittedAt?.toIso8601String(),
  'payment_verified_at': instance.paymentVerifiedAt?.toIso8601String(),
  'payment_verified_by': instance.paymentVerifiedBy,
};

const _$TitleEnumMap = {
  Title.mr: 'mr',
  Title.mrs: 'mrs',
  Title.ms: 'ms',
  Title.dr: 'dr',
  Title.other: 'other',
};

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.preferNotToSay: 'prefer_not_to_say',
};

const _$MembershipCategoryEnumMap = {
  MembershipCategory.full: 'full',
  MembershipCategory.associate: 'associate',
  MembershipCategory.corporate: 'corporate',
  MembershipCategory.honorary: 'honorary',
};

const _$ApplicationStatusEnumMap = {
  ApplicationStatus.draft: 'draft',
  ApplicationStatus.submitted: 'submitted',
  ApplicationStatus.underReview: 'under_review',
  ApplicationStatus.approved: 'approved',
  ApplicationStatus.rejected: 'rejected',
};
