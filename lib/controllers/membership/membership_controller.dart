import 'package:cqaag_app/controllers/membership/membership_state.dart';
import 'package:cqaag_app/models/membership/membership_application.dart';
import 'package:cqaag_app/models/membership/membership_category.dart';
import 'package:cqaag_app/services/auth/auth_service.dart';
import 'package:cqaag_app/services/membership/membership_service.dart';
import 'package:cqaag_app/services/user/user_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

part 'membership_controller.g.dart';

/// Controller for managing membership application state
@Riverpod(keepAlive: true)
class MembershipController extends _$MembershipController {
  @override
  Stream<MembershipState> build() {
    final authUser = ref.watch(authServiceProvider).currentUser;

    if (authUser == null) {
      return Stream.value(const MembershipState());
    }

    final membershipService = ref.watch(membershipServiceProvider);

    // Stream for current user's application
    final myApplicationStream = membershipService.streamUserApplication(authUser.uid);

    // Determine if user is admin to decide whether to fetch all applications
    // We need to fetch the user's role/admin status first
    // Simplification: We will just listen to the userService to get the current AppUser profile which has isAdmin
    final appUserStream = ref.watch(userServiceProvider).streamUser(authUser.uid);

    return appUserStream.switchMap((appUser) {
      if (appUser == null) {
        return Stream.value(const MembershipState());
      }

      Stream<List<MembershipApplication>> allApplicationsStream;

      if (appUser.isAdmin) {
        allApplicationsStream = membershipService.streamAllApplications();
      } else {
        allApplicationsStream = Stream.value([]);
      }

      return Rx.combineLatest2<MembershipApplication?, List<MembershipApplication>, MembershipState>(
        myApplicationStream,
        allApplicationsStream,
        (myApplication, allApplications) {
          return MembershipState(
            myApplication: myApplication,
            allApplications: allApplications,
          );
        },
      );
    });
  }

  /// Submit a membership application
  Future<void> submitApplication(MembershipApplication application) async {
    try {
      final membershipService = ref.read(membershipServiceProvider);
      await membershipService.submitApplication(application);
      // State updates automatically via stream
    } catch (e) {
      rethrow;
    }
  }

  /// Save application as draft
  Future<void> saveDraft(MembershipApplication application) async {
    try {
      final membershipService = ref.read(membershipServiceProvider);
      await membershipService.saveDraft(application);
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing application
  Future<void> updateApplication(MembershipApplication application) async {
    try {
      final membershipService = ref.read(membershipServiceProvider);
      await membershipService.updateApplication(application);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a draft application
  Future<void> deleteDraft(String applicationId) async {
    try {
      final membershipService = ref.read(membershipServiceProvider);
      await membershipService.deleteApplication(applicationId);
    } catch (e) {
      rethrow;
    }
  }

  /// Review Application (Admin)
  Future<void> reviewApplication({
    required String applicationId,
    required ApplicationStatus status,
    String? notes,
  }) async {
    try {
      final authUser = ref.read(authServiceProvider).currentUser;
      if (authUser == null) throw Exception('Not authenticated');

      final membershipService = ref.read(membershipServiceProvider);
      await membershipService.updateApplicationStatus(
        applicationId: applicationId,
        status: status,
        reviewNotes: notes,
        reviewerId: authUser.uid,
      );
    } catch (e) {
      rethrow;
    }
  }
}

/// Provider for all membership applications (Admin)
@Riverpod(keepAlive: true)
Stream<List<MembershipApplication>> allMembershipApplications(Ref ref) {
  return ref.watch(membershipControllerProvider.select((value) => Stream.value(value.asData?.value.allApplications ?? [])));
}
