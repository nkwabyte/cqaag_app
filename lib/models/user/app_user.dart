import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cqaag_app/models/user/verification_data.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

enum AppUserStatus {
  @JsonValue('active')
  active,
  @JsonValue('suspended')
  suspended,
  @JsonValue('banned')
  banned,
  @JsonValue('inactive')
  inactive
  ;

  String get value {
    switch (this) {
      case AppUserStatus.active:
        return 'active';
      case AppUserStatus.suspended:
        return 'suspended';
      case AppUserStatus.banned:
        return 'banned';
      case AppUserStatus.inactive:
        return 'inactive';
    }
  }
}

enum VerificationStatus {
  @JsonValue('unverified')
  unverified,
  @JsonValue('pending')
  pending,
  @JsonValue('verified')
  verified,
  @JsonValue('rejected')
  rejected
  ;

  String get value {
    switch (this) {
      case VerificationStatus.unverified:
        return 'unverified';
      case VerificationStatus.pending:
        return 'pending';
      case VerificationStatus.verified:
        return 'verified';
      case VerificationStatus.rejected:
        return 'rejected';
    }
  }
}

enum MembershipStatus {
  @JsonValue('Not a member')
  notAMember,
  @JsonValue('applied')
  applied,
  @JsonValue('pending review')
  pendingReview,
  @JsonValue('under review')
  underReview,
  @JsonValue('approved_payment_pending')
  approvedPaymentPending,
  @JsonValue('active')
  active,
  @JsonValue('verified')
  verified,
  @JsonValue('hibernated')
  hibernated,
  @JsonValue('suspended')
  suspended,
  @JsonValue('declined')
  declined
  ;

  String get value {
    switch (this) {
      case MembershipStatus.notAMember:
        return 'Not a member';
      case MembershipStatus.applied:
        return 'applied';
      case MembershipStatus.pendingReview:
        return 'pending review';
      case MembershipStatus.underReview:
        return 'under review';
      case MembershipStatus.approvedPaymentPending:
        return 'approved_payment_pending';
      case MembershipStatus.active:
        return 'active';
      case MembershipStatus.verified:
        return 'verified';
      case MembershipStatus.hibernated:
        return 'hibernated';
      case MembershipStatus.suspended:
        return 'suspended';
      case MembershipStatus.declined:
        return 'declined';
    }
  }
}

@freezed
abstract class AppUser with _$AppUser {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory AppUser({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    @Default('https://www.gravatar.com/avatar/?d=identicon') String profilePicture,
    @Default(AppUserStatus.active) AppUserStatus status,
    String? address,
    String? district,
    String? region,
    String? phoneNumber,
    String? role,
    VerificationData? verification,
    @Default(VerificationStatus.unverified) VerificationStatus verificationStatus,
    @JsonKey(unknownEnumValue: MembershipStatus.notAMember)
    @Default(MembershipStatus.notAMember) MembershipStatus membershipStatus,
    @Default(false) bool hasAcceptedTerms,
    @Default(false) bool isAdmin,
    String? qcCode,

    /// Official Member Number: CQAAG-M-nnnn (Section 9.1)
    String? memberCode,

    /// Cryptographic QR verification code / nonce: e.g. 5C21B7A0 (Section 9.2)
    String? cardCode,
    @Default(1) int cardCodeVersion,

    /// Membership Category (Section 9.1: Full Member, National Associate, Foreign Associate, Corporate, Honorary)
    String? membershipCategory,

    /// Regional Chapter (Section 9.1)
    String? chapter,

    /// Professional details (Section 9.2, Section 10)
    String? jobTitle,
    String? employer,

    /// Corporate specific fields (Section 9.1)
    String? companyName,
    String? representativeName,

    /// TCDA Licence linking (Section 9.2, Section 22)
    String? tcdaLicenceNumber,
    String? tcdaLicenceStatus,

    /// Public Member Directory consent and visibility (Section 10)
    @Default(false) bool directoryConsent,
    @Default(false) bool directoryHidden,
    DateTime? hiddenAt,
    String? hiddenBy,
    String? hiddenReason,

    /// Dates for dues, member since, photo update
    DateTime? memberSince,
    DateTime? duesValidUntil,
    DateTime? photoUpdatedAt,

    /// Set on accounts created for a member with a generated password, so
    /// they are asked to choose their own on first sign-in.
    @Default(false) bool mustChangePassword,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}

extension AppUserX on AppUser {
  /// Check if user is approved to perform inspections and access reports
  bool get isApproved => isAdmin || (verificationStatus == VerificationStatus.verified && status == AppUserStatus.active);

  /// Get the permanent, unique QC Code for this analyst
  String get effectiveQcCode {
    if (qcCode != null && qcCode!.trim().isNotEmpty) {
      return qcCode!.trim().toUpperCase();
    }
    final shortId = id.length >= 6 ? id.substring(0, 6).toUpperCase() : id.toUpperCase();
    return 'CQAAG-QC-$shortId';
  }

  /// Standardized Member Code CQAAG-M-nnnn (Section 9.1)
  String get effectiveMemberCode {
    if (memberCode != null && memberCode!.trim().isNotEmpty) {
      return memberCode!.trim().toUpperCase();
    }
    // Fallback based on ID digits if not explicitly assigned
    final digits = id.replaceAll(RegExp(r'[^0-9]'), '');
    final padNum = digits.isNotEmpty ? digits.padLeft(4, '0') : '0001';
    final suffix = padNum.length > 4 ? padNum.substring(padNum.length - 4) : padNum;
    return 'CQAAG-M-$suffix';
  }

  /// Good Standing evaluation per Section 9.2 & Section 6 (90-day grace period)
  bool get isGoodStanding {
    if (membershipStatus == MembershipStatus.suspended || membershipStatus == MembershipStatus.declined) {
      return false;
    }
    if (membershipStatus == MembershipStatus.hibernated) {
      return false;
    }
    if (membershipStatus == MembershipStatus.active || membershipStatus == MembershipStatus.verified) {
      if (duesValidUntil != null) {
        // 90-day grace period past expiry
        final graceCutoff = duesValidUntil!.add(const Duration(days: 90));
        return DateTime.now().isBefore(graceCutoff);
      }
      return true;
    }
    return false;
  }

  /// Effective QR verification Code
  String get effectiveCardCode {
    if (cardCode != null && cardCode!.trim().isNotEmpty) {
      return cardCode!.trim();
    }
    // Deterministic short hash code from ID
    final hash = (id.hashCode.abs() % 0xFFFFFFF).toRadixString(16).toUpperCase().padLeft(8, '0');
    return hash;
  }

  /// Official Web QR verification URL per Section 9.2
  String get verificationQrUrl => 'https://cqaaggh.org/m/$effectiveMemberCode?s=$effectiveCardCode';
}
