import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cqaag_app/index.dart';

part 'membership_application.freezed.dart';
part 'membership_application.g.dart';

/// Model representing a membership application to C.Q.A.A.G
@freezed
abstract class MembershipApplication with _$MembershipApplication {
  const MembershipApplication._();

  @JsonSerializable(fieldRename: FieldRename.snake)
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

    /// Ghana Card / ID Number
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

    // Professional Information
    /// Current job title
    required String currentJobTitle,

    /// Employer/Organization
    required String employerOrganization,

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

    /// Amount the applicant was asked to pay
    double? paymentAmount,

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
    return '$paymentCurrency ${amount.toStringAsFixed(2)}';
  }
}
