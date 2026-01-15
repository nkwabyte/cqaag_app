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
  }) = _MembershipApplication;

  factory MembershipApplication.fromJson(Map<String, dynamic> json) => _$MembershipApplicationFromJson(json);
}
