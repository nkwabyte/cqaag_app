import 'package:freezed_annotation/freezed_annotation.dart';

/// Enum representing different membership categories in C.Q.A.A.G
enum MembershipCategory {
  /// Full Members (Ghanaian): Ghanaian QC professionals (voting rights)
  @JsonValue('full')
  full,

  /// Full Members (Foreign QC): Foreign/International QC professionals (voting rights)
  @JsonValue('full_foreign')
  fullForeign,

  /// Associate Members: Interested individuals/entities (non-voting)
  @JsonValue('associate')
  associate,

  /// Corporate Members: Entities supporting quality efforts (non-voting)
  @JsonValue('corporate')
  corporate,

  /// Honorary Members: Distinguished individuals nominated by Board (non-voting)
  @JsonValue('honorary')
  honorary
  ;

  /// Get the display name for the membership category
  String get displayName {
    switch (this) {
      case MembershipCategory.full:
        return 'Full Member (Ghanaian)';
      case MembershipCategory.fullForeign:
        return 'Full Member (Foreign QC)';
      case MembershipCategory.associate:
        return 'Associate Member';
      case MembershipCategory.corporate:
        return 'Corporate Member';
      case MembershipCategory.honorary:
        return 'Honorary Member';
    }
  }

  /// Get the description for the membership category
  String get description {
    switch (this) {
      case MembershipCategory.full:
        return 'Ghanaian certified cashew quality control professional (voting rights)';
      case MembershipCategory.fullForeign:
        return 'International / Foreign cashew quality control professional (voting rights)';
      case MembershipCategory.associate:
        return 'Individuals or entities interested in the Association\'s work but not meeting full eligibility (non-voting)';
      case MembershipCategory.corporate:
        return 'Entities, processors, or organizations supporting quality efforts (non-voting)';
      case MembershipCategory.honorary:
        return 'Distinguished individuals nominated by the Board for significant contributions (non-voting)';
    }
  }

  /// Check if this category has voting rights
  bool get hasVotingRights {
    return this == MembershipCategory.full || this == MembershipCategory.fullForeign;
  }

  /// Get the JSON value
  String get value {
    switch (this) {
      case MembershipCategory.full:
        return 'full';
      case MembershipCategory.fullForeign:
        return 'full_foreign';
      case MembershipCategory.associate:
        return 'associate';
      case MembershipCategory.corporate:
        return 'corporate';
      case MembershipCategory.honorary:
        return 'honorary';
    }
  }
}

/// Enum representing the status of a membership application
enum ApplicationStatus {
  /// Application is being drafted
  @JsonValue('draft')
  draft,

  /// Application has been submitted
  @JsonValue('submitted')
  submitted,

  /// Application is under review
  @JsonValue('under_review')
  underReview,

  /// Application has been approved
  @JsonValue('approved')
  approved,

  /// Application has been rejected
  @JsonValue('rejected')
  rejected
  ;

  /// Get the display name for the application status
  String get displayName {
    switch (this) {
      case ApplicationStatus.draft:
        return 'Draft';
      case ApplicationStatus.submitted:
        return 'Submitted';
      case ApplicationStatus.underReview:
        return 'Under Review';
      case ApplicationStatus.approved:
        return 'Approved';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }

  /// Get the JSON value
  String get value {
    switch (this) {
      case ApplicationStatus.draft:
        return 'draft';
      case ApplicationStatus.submitted:
        return 'submitted';
      case ApplicationStatus.underReview:
        return 'under_review';
      case ApplicationStatus.approved:
        return 'approved';
      case ApplicationStatus.rejected:
        return 'rejected';
    }
  }
}

/// Enum for title/salutation
enum Title {
  @JsonValue('mr')
  mr,
  @JsonValue('mrs')
  mrs,
  @JsonValue('ms')
  ms,
  @JsonValue('dr')
  dr,
  @JsonValue('other')
  other
  ;

  String get displayName {
    switch (this) {
      case Title.mr:
        return 'Mr.';
      case Title.mrs:
        return 'Mrs.';
      case Title.ms:
        return 'Ms.';
      case Title.dr:
        return 'Dr.';
      case Title.other:
        return 'Other';
    }
  }
}

/// Enum for gender
enum Gender {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
  @JsonValue('prefer_not_to_say')
  preferNotToSay
  ;

  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.preferNotToSay:
        return 'Prefer not to say';
    }
  }
}
