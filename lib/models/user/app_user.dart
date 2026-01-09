import 'package:freezed_annotation/freezed_annotation.dart';

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
  @JsonValue('pending')
  pending,
  @JsonValue('verified')
  verified,
  @JsonValue('rejected')
  rejected
  ;

  String get value {
    switch (this) {
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
  @JsonValue('verified')
  verified
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
      case MembershipStatus.verified:
        return 'verified';
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
    @Default(VerificationStatus.pending) VerificationStatus verificationStatus,
    @Default(MembershipStatus.notAMember) MembershipStatus membershipStatus,
    @Default(false) bool isAdmin,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}
