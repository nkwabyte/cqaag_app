import 'package:freezed_annotation/freezed_annotation.dart';

/// The membership categories of Constitution Art. 2, as amended.
///
/// The stored JSON values predate the amendment and are kept as they are, so
/// existing records still read; the labels follow the amended Constitution and
/// the Board's fee schedule.
enum MembershipCategory {
  /// Full Membership: indigenous (Ghanaian) cashew QC professionals. Votes,
  /// may hold office, and may be recommended to TCDA for licensing.
  @JsonValue('full')
  full,

  /// Foreign Associate Members (Art. 2.1(b)): foreign cashew quality analysts
  /// coming to practise in Ghana. No vote, but TCDA-licensing eligible.
  @JsonValue('full_foreign')
  fullForeign,

  /// National Associate Members (Art. 2.1(a)): Ghanaian nationals interested in
  /// the Association's work but not fully eligible. No vote.
  @JsonValue('associate')
  associate,

  /// Corporate Members: laboratories, processors and organizations supporting
  /// quality efforts. No vote.
  @JsonValue('corporate')
  corporate,

  /// Honorary Members: distinguished individuals nominated by the Board.
  /// No vote, and pay no fees.
  @JsonValue('honorary')
  honorary
  ;

  /// Get the display name for the membership category
  String get displayName {
    switch (this) {
      case MembershipCategory.full:
        return 'Full Member';
      case MembershipCategory.fullForeign:
        return 'Foreign Associate Member';
      case MembershipCategory.associate:
        return 'National Associate Member';
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
        return 'Experienced Ghanaian cashew quality control professional. Votes, may hold executive office, and may be recommended to TCDA for licensing.';
      case MembershipCategory.fullForeign:
        return 'Foreign cashew quality analyst coming to practise in Ghana. Non-voting, but may be recommended to TCDA for licensing.';
      case MembershipCategory.associate:
        return 'Ghanaian national interested in the Association\'s work but not meeting full eligibility, e.g. a student or trainee. Non-voting.';
      case MembershipCategory.corporate:
        return 'Laboratory, processor, or organization supporting quality efforts. Non-voting.';
      case MembershipCategory.honorary:
        return 'Distinguished individual nominated by the Board for significant contributions. Non-voting and pays no fees.';
    }
  }

  /// Whether this category carries voting rights (Art. 2 and 3, as amended).
  ///
  /// Only Full Membership does — Foreign Associate Members are TCDA-licensing
  /// eligible but do not vote.
  bool get hasVotingRights => this == MembershipCategory.full;

  /// Whether this category may hold executive office.
  bool get canHoldOffice => this == MembershipCategory.full;

  /// Whether members of this category may be recommended to the TCDA for
  /// licensing to practise nationwide (Art. 2, as amended).
  bool get isTcdaLicensingEligible =>
      this == MembershipCategory.full || this == MembershipCategory.fullForeign;

  /// Honorary Members pay no fees at all.
  bool get isFeeExempt => this == MembershipCategory.honorary;

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
