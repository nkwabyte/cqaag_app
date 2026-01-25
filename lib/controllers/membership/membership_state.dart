import 'package:cqaag_app/models/membership/membership_application.dart';
import 'package:cqaag_app/models/membership/membership_category.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'membership_state.freezed.dart';

@freezed
abstract class MembershipState with _$MembershipState {
  const MembershipState._();

  const factory MembershipState({
    /// The current user's membership application
    MembershipApplication? myApplication,

    /// All membership applications (Admin only)
    @Default([]) List<MembershipApplication> allApplications,

    /// Whether the initial data is loading
    @Default(false) bool isLoading,
  }) = _MembershipState;

  /// Helper to check if the user has a submitted application
  bool get hasApplication => myApplication != null;

  /// Helper to check if the user's application is approved
  bool get isApproved => myApplication?.status == ApplicationStatus.approved;

  /// Helper to get pending applications count (Admin only)
  int get pendingApplicationsCount => allApplications.where((a) => a.status == ApplicationStatus.submitted || a.status == ApplicationStatus.underReview).length;
}
