import 'package:cqaag_app/models/membership/membership_application.dart';
import 'package:cqaag_app/models/membership/membership_category.dart';
import 'package:cqaag_app/services/membership/membership_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'membership_controller.g.dart';

/// Controller for managing membership application state
@riverpod
class MembershipController extends _$MembershipController {
  @override
  FutureOr<MembershipApplication?> build() async {
    // Return null initially, will be loaded when needed
    return null;
  }

  /// Submit a membership application
  Future<void> submitApplication(MembershipApplication application) async {
    state = const AsyncValue.loading();

    try {
      final membershipService = ref.read(membershipServiceProvider);
      await membershipService.submitApplication(application);

      // Reload the application
      state = AsyncValue.data(
        application.copyWith(
          status: ApplicationStatus.submitted,
          submittedAt: DateTime.now(),
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Save application as draft
  Future<void> saveDraft(MembershipApplication application) async {
    state = const AsyncValue.loading();

    try {
      final membershipService = ref.read(membershipServiceProvider);
      await membershipService.saveDraft(application);

      state = AsyncValue.data(
        application.copyWith(
          status: ApplicationStatus.draft,
          updatedAt: DateTime.now(),
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Update an existing application
  Future<void> updateApplication(MembershipApplication application) async {
    state = const AsyncValue.loading();

    try {
      final membershipService = ref.read(membershipServiceProvider);
      await membershipService.updateApplication(application);

      state = AsyncValue.data(
        application.copyWith(
          updatedAt: DateTime.now(),
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Delete a draft application
  Future<void> deleteDraft(String applicationId) async {
    state = const AsyncValue.loading();

    try {
      final membershipService = ref.read(membershipServiceProvider);
      await membershipService.deleteApplication(applicationId);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Load application by user ID
  Future<void> loadApplicationByUserId(String userId) async {
    state = const AsyncValue.loading();

    try {
      final membershipService = ref.read(membershipServiceProvider);
      final application = await membershipService.getApplicationByUserId(userId);

      state = AsyncValue.data(application);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Load application by ID
  Future<void> loadApplicationById(String applicationId) async {
    state = const AsyncValue.loading();

    try {
      final membershipService = ref.read(membershipServiceProvider);
      final application = await membershipService.getApplicationById(applicationId);

      state = AsyncValue.data(application);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Provider to stream user's membership application
@riverpod
Stream<MembershipApplication?> userMembershipApplication(
  Ref ref,
  String userId,
) {
  final membershipService = ref.watch(membershipServiceProvider);
  return membershipService.streamUserApplication(userId);
}

/// Provider to stream a specific application by ID
@riverpod
Stream<MembershipApplication?> membershipApplicationById(
  Ref ref,
  String applicationId,
) {
  final membershipService = ref.watch(membershipServiceProvider);
  return membershipService.streamApplicationById(applicationId);
}

/// Provider to stream all applications (for admin use)
@riverpod
Stream<List<MembershipApplication>> allMembershipApplications(Ref ref) {
  final membershipService = ref.watch(membershipServiceProvider);
  return membershipService.streamAllApplications();
}
