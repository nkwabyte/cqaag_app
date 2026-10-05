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
  placeOfBirth: json['place_of_birth'] as String?,
  ghanaCardNumber: json['ghana_card_number'] as String?,
  phoneNumberPrimary: json['phone_number_primary'] as String,
  phoneNumberSecondary: json['phone_number_secondary'] as String?,
  emailAddress: json['email_address'] as String,
  residentialAddress: json['residential_address'] as String,
  regionDistrict: json['region_district'] as String,
  currentJobTitle: _readJobTitle(json, 'current_job_title') as String,
  employerOrganization: json['employer_organization'] as String,
  employerType: json['employer_type'] as String?,
  industrySectors:
      (json['industry_sectors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  industrySectorOther: json['industry_sector_other'] as String?,
  yearsOfExperience: _intOrNull(json['years_of_experience']),
  professionalQualifications: json['professional_qualifications'] as String?,
  highestEducationLevel:
      _readEducationLevel(json, 'highest_education_level') as String?,
  educationLevelOther:
      _readEducationLevelOther(json, 'education_level_other') as String?,
  fieldOfStudy: _readFieldOfStudy(json, 'field_of_study') as String?,
  institution: _readInstitution(json, 'institution') as String?,
  yearQualificationObtained: _stringOrNull(
    _readYearObtained(json, 'year_qualification_obtained'),
  ),
  nationalIdNumber: json['national_id_number'] as String?,
  directoryConsent: json['directory_consent'] as bool? ?? false,
  signedDocuments:
      json['signed_documents'] as Map<String, dynamic>? ??
      const <String, dynamic>{},
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
  paymentRegistrationFee: (json['payment_registration_fee'] as num?)
      ?.toDouble(),
  paymentAnnualDues: (json['payment_annual_dues'] as num?)?.toDouble(),
  paymentOptionalTotal:
      (json['payment_optional_total'] as num?)?.toDouble() ?? 0.0,
  paymentOptionalItems:
      (json['payment_optional_items'] as List<dynamic>?)
          ?.map((e) => SelectedFeeItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SelectedFeeItem>[],
  paymentRegistrationComponents:
      (json['payment_registration_components'] as List<dynamic>?)
          ?.map((e) => SelectedFeeItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SelectedFeeItem>[],
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
  credentialsIssuedAt: _dateOrNull(json['credentials_issued_at']),
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
  'place_of_birth': instance.placeOfBirth,
  'ghana_card_number': instance.ghanaCardNumber,
  'phone_number_primary': instance.phoneNumberPrimary,
  'phone_number_secondary': instance.phoneNumberSecondary,
  'email_address': instance.emailAddress,
  'residential_address': instance.residentialAddress,
  'region_district': instance.regionDistrict,
  'current_job_title': instance.currentJobTitle,
  'employer_organization': instance.employerOrganization,
  'employer_type': instance.employerType,
  'industry_sectors': instance.industrySectors,
  'industry_sector_other': instance.industrySectorOther,
  'years_of_experience': instance.yearsOfExperience,
  'professional_qualifications': instance.professionalQualifications,
  'highest_education_level': instance.highestEducationLevel,
  'education_level_other': instance.educationLevelOther,
  'field_of_study': instance.fieldOfStudy,
  'institution': instance.institution,
  'year_qualification_obtained': instance.yearQualificationObtained,
  'national_id_number': instance.nationalIdNumber,
  'directory_consent': instance.directoryConsent,
  'signed_documents': instance.signedDocuments,
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
  'payment_registration_fee': instance.paymentRegistrationFee,
  'payment_annual_dues': instance.paymentAnnualDues,
  'payment_optional_total': instance.paymentOptionalTotal,
  'payment_optional_items': instance.paymentOptionalItems
      .map((e) => e.toJson())
      .toList(),
  'payment_registration_components': instance.paymentRegistrationComponents
      .map((e) => e.toJson())
      .toList(),
  'payment_currency': instance.paymentCurrency,
  'payment_evidence_url': instance.paymentEvidenceUrl,
  'payment_reference': instance.paymentReference,
  'payment_momo_network': instance.paymentMomoNetwork,
  'payment_momo_number': instance.paymentMomoNumber,
  'payment_submitted_at': instance.paymentSubmittedAt?.toIso8601String(),
  'payment_verified_at': instance.paymentVerifiedAt?.toIso8601String(),
  'payment_verified_by': instance.paymentVerifiedBy,
  'credentials_issued_at': instance.credentialsIssuedAt?.toIso8601String(),
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
  MembershipCategory.fullForeign: 'full_foreign',
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
