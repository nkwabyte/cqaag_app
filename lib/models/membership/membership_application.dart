import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cqaag_app/index.dart';

part 'membership_application.freezed.dart';
part 'membership_application.g.dart';

/// Model representing a membership application to C.Q.A.A.G
@freezed
abstract class MembershipApplication with _$MembershipApplication {
  const MembershipApplication._();

  // explicitToJson: the nested fee items and agreement records must be maps,
  // not objects, or Firestore rejects the write.
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory MembershipApplication({
    /// Unique application ID
    required String id,

    /// User ID of the applicant
    required String userId,

    // Personal Information
    /// Title/Salutation
    required Title title,

    /// First name
    required String firstName,

    /// Middle name(s)
    String? middleName,

    /// Last name
    required String lastName,

    /// Date of birth (stored as ISO 8601 string)
    required String dateOfBirth,

    /// Gender
    required Gender gender,

    /// Nationality
    required String nationality,

    /// Place of birth, printed in the identity block of every signed document.
    String? placeOfBirth,

    /// Ghana Card personal ID number, in the form `GHA-#########-#`.
    ///
    /// Under current Ghanaian law this number is the only identity evidence
    /// collected — no images of the card are captured or stored — so it is what
    /// an admin verifies the applicant against.
    String? ghanaCardNumber,

    /// Primary phone number
    required String phoneNumberPrimary,

    /// Secondary phone number
    String? phoneNumberSecondary,

    /// Email address
    required String emailAddress,

    /// Residential address
    required String residentialAddress,

    /// Region/District
    required String regionDistrict,

    /// Current job title. The website writes `job_title`.
    @JsonKey(readValue: _readJobTitle) required String currentJobTitle,

    /// Employer/Organization
    required String employerOrganization,

    /// Employer type (cashew processor, exporter, trader, aggregator, farmer, laboratory, regulatory, academia, other)
    String? employerType,

    /// Industry sector keys (see [IndustrySectors]), as the website stores them.
    @Default(<String>[]) List<String> industrySectors,

    /// Free-text sector, when `other` is among [industrySectors].
    String? industrySectorOther,

    /// Whole years of experience in cashew quality analysis or a related field.
    @JsonKey(fromJson: _intOrNull) int? yearsOfExperience,

    /// Professional qualifications / certifications, e.g. TCDA training.
    String? professionalQualifications,

    /// Highest educational qualification key (see [EducationLevels]).
    ///
    /// The website nests the education fields in an `education` map; they are
    /// read from there when the flat field is absent, and written to both.
    @JsonKey(readValue: _readEducationLevel) String? highestEducationLevel,

    /// What the applicant typed when [highestEducationLevel] is `other`.
    @JsonKey(readValue: _readEducationLevelOther) String? educationLevelOther,

    /// Field of study
    @JsonKey(readValue: _readFieldOfStudy) String? fieldOfStudy,

    /// Institution the qualification was obtained from
    @JsonKey(readValue: _readInstitution) String? institution,

    /// Year qualification was obtained
    @JsonKey(readValue: _readYearObtained, fromJson: _stringOrNull) String? yearQualificationObtained,

    /// Passport or national ID number, for Foreign Associate applicants who do
    /// not hold a Ghana Card. Mirrors [ghanaCardNumber] otherwise.
    String? nationalIdNumber,

    /// Consent to the public member directory, given in the Declaration.
    @Default(false) bool directoryConsent,

    /// The accepted governing documents, keyed `agreement`, `ethics`, `terms`,
    /// `privacy` and `declaration` — what was accepted, how, and when. The A4
    /// PDFs themselves are filed in the association's agreements database.
    @Default(<String, dynamic>{}) Map<String, dynamic> signedDocuments,

    /// Desired membership category
    required MembershipCategory membershipCategory,

    /// Application status
    @Default(ApplicationStatus.draft) ApplicationStatus status,

    // Timestamps
    /// When the application was created
    DateTime? createdAt,

    /// When the application was submitted
    DateTime? submittedAt,

    /// When the application was last updated
    DateTime? updatedAt,

    /// When the application was reviewed
    DateTime? reviewedAt,

    // Review Information
    /// Notes from the reviewer
    String? reviewNotes,

    /// ID of the reviewer
    String? reviewerId,

    // Registration Payment
    //
    // Field names mirror the website exactly so both clients read and write the
    // same `members` documents. The amount and destination account are
    // snapshotted here at submission time, so later changes to settings/payment
    // never rewrite what this applicant was actually asked to pay.
    /// How the fee was paid: `momo` or `paystack`
    String? paymentMethod,

    /// Verification state: unpaid, pending_verification, verified, rejected
    @Default('unpaid') String paymentStatus,

    /// Total the applicant was asked to pay: Registration Fee + Annual Dues
    /// + whichever optional kit items they chose.
    double? paymentAmount,

    /// Registration Fee portion of [paymentAmount], per the fee schedule.
    double? paymentRegistrationFee,

    /// Annual Dues portion of [paymentAmount].
    double? paymentAnnualDues,

    /// Total of the optional kit items the applicant chose to take.
    @Default(0.0) double paymentOptionalTotal,

    /// The optional kit items the applicant chose, priced as at the moment of
    /// choice. Empty when they declined all of them.
    @Default(<SelectedFeeItem>[]) List<SelectedFeeItem> paymentOptionalItems,

    /// The Registration Fee components in force when the applicant was quoted,
    /// snapshotted so a later change to the schedule cannot rewrite history.
    @Default(<SelectedFeeItem>[]) List<SelectedFeeItem> paymentRegistrationComponents,

    /// Currency of [paymentAmount]
    @Default('GHS') String paymentCurrency,

    /// Cloudinary URL of the uploaded payment evidence
    String? paymentEvidenceUrl,

    /// Transaction ID supplied by the applicant
    String? paymentReference,

    /// Network of the account the fee was sent to
    String? paymentMomoNetwork,

    /// Number the fee was sent to
    String? paymentMomoNumber,

    /// When the applicant submitted their payment
    DateTime? paymentSubmittedAt,

    /// When an admin verified the payment
    DateTime? paymentVerifiedAt,

    /// UID of the admin who verified the payment
    String? paymentVerifiedBy,

    /// When a generated sign-in password was emailed to [emailAddress].
    @JsonKey(fromJson: _dateOrNull) DateTime? credentialsIssuedAt,
  }) = _MembershipApplication;

  factory MembershipApplication.fromJson(Map<String, dynamic> json) => _$MembershipApplicationFromJson(json);

  /// Typed view of [paymentStatus].
  PaymentStatus get payment => PaymentStatus.fromValue(paymentStatus);

  /// Whether an admin has confirmed the registration fee was received.
  bool get isPaymentVerified => payment == PaymentStatus.verified;

  /// Payment amount formatted for display, or null when nothing was recorded.
  String? get formattedPaymentAmount {
    final amount = paymentAmount;
    if (amount == null) return null;
    return money(amount);
  }

  /// Formats an amount in the currency this application was quoted in.
  String money(double amount) => '$paymentCurrency ${amount.toStringAsFixed(2)}';

  /// The fee schedule column that applies to this applicant.
  FeeCategory get feeCategory => FeeCategory.fromMembership(membershipCategory);

  /// Whether the applicant took any optional kit items.
  bool get hasOptionalItems => paymentOptionalItems.isNotEmpty;

  /// Short reference quoted in emails, used with the email address to find the
  /// application again when paying.
  String get reference => id.replaceAll('-', '').substring(0, 8).toUpperCase();

  /// Applicant's full name, as printed on signed documents.
  String get fullName => [firstName, middleName, lastName].where((p) => p != null && p.trim().isNotEmpty).join(' ');

  /// Whether the applicant still owes the membership fee: Honorary Members
  /// and zero-amount records never do, and a payment awaiting verification
  /// counts as paid unless it is rejected.
  bool get isFeeDue {
    if (membershipCategory == MembershipCategory.honorary) return false;
    if ((paymentAmount ?? 1) <= 0) return false;
    return payment == PaymentStatus.unpaid || payment == PaymentStatus.rejected;
  }

  /// Whether a generated sign-in password may be emailed now: the application
  /// is approved and nothing more is owed. Mirrors the website's rule.
  bool get mayReceiveCredentials => status == ApplicationStatus.approved && !isFeeDue;

  /// The ID used in the identity block: Ghana Card, else national ID/passport.
  String? get identityNumber => ghanaCardNumber ?? nationalIdNumber;

  /// Whether the recorded Ghana Card number is structurally valid.
  ///
  /// Surfaced to admins so a malformed number is obvious at a glance rather
  /// than only failing when it is checked against the national register.
  bool get hasValidGhanaCardNumber => GhanaCard.isValid(ghanaCardNumber);
}

Object? _readJobTitle(Map<dynamic, dynamic> json, String key) => json[key] ?? json['job_title'] ?? '';

Object? _readEducation(Map<dynamic, dynamic> json, String flatKey, String nestedKey) {
  final flat = json[flatKey];
  if (flat != null) return flat;
  final education = json['education'];
  return education is Map ? education[nestedKey] : null;
}

Object? _readEducationLevel(Map<dynamic, dynamic> json, String key) => _readEducation(json, key, 'level');
Object? _readEducationLevelOther(Map<dynamic, dynamic> json, String key) => _readEducation(json, key, 'level_other');
Object? _readFieldOfStudy(Map<dynamic, dynamic> json, String key) => _readEducation(json, key, 'field_of_study');
Object? _readInstitution(Map<dynamic, dynamic> json, String key) => _readEducation(json, key, 'institution');
Object? _readYearObtained(Map<dynamic, dynamic> json, String key) => _readEducation(json, key, 'year_obtained');

int? _intOrNull(Object? value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

String? _stringOrNull(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toInt().toString();
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

/// The website writes empty strings for dates it has not set yet.
DateTime? _dateOrNull(Object? value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}

/// Industry sectors offered on the application, keyed as the website stores them.
class IndustrySectors {
  IndustrySectors._();

  static const Map<String, String> labels = {
    'cashew_processing': 'Cashew Processing',
    'export': 'Export',
    'trader_farming': 'Trader / Aggregators / Farming',
    'laboratory': 'Laboratory',
    'regulatory': 'Regulatory',
    'academia': 'Academia',
    'other': 'Other',
  };

  /// Human readable list, with the typed "Other" sector spelled out.
  static String describe(List<String> keys, String? other) {
    final names = keys.where((k) => k != 'other').map((k) => labels[k] ?? k).toList();
    if (keys.contains('other')) {
      names.add(other != null && other.trim().isNotEmpty ? 'Other: ${other.trim()}' : 'Other');
    }
    return names.isEmpty ? '-' : names.join(', ');
  }
}

/// Highest educational qualifications offered, keyed as the website stores them.
class EducationLevels {
  EducationLevels._();

  static const Map<String, String> labels = {
    'diploma': 'Diploma',
    'bachelor': 'Bachelor’s Degree',
    'master': 'Master’s Degree',
    'phd': 'PhD',
    'other': 'Other',
  };

  static String describe(String? level, String? other) {
    if (level == null || level.isEmpty) return '-';
    if (level == 'other') return (other != null && other.trim().isNotEmpty) ? other.trim() : 'Other';
    return labels[level] ?? level;
  }
}
