import 'package:cqaag_app/index.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inspection_controller.g.dart';

@riverpod
class InspectionController extends _$InspectionController {
  @override
  FutureOr<List<Inspection>> build() async {
    // Fetch inspections for the current user
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return [];

    final inspectionService = ref.read(inspectionServiceProvider);
    return await inspectionService.getInspections(user.uid);
  }

  /// Create a new inspection
  Future<void> createInspection(Inspection inspection) async {
    state = const AsyncValue.loading();
    try {
      final inspectionService = ref.read(inspectionServiceProvider);
      await inspectionService.createInspection(inspection);

      // Refresh list
      state = AsyncValue.data([...?state.value, inspection]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Update an existing inspection
  Future<void> updateInspection(Inspection inspection) async {
    state = const AsyncValue.loading();
    try {
      final inspectionService = ref.read(inspectionServiceProvider);
      await inspectionService.updateInspection(inspection);

      // Update in state
      final currentList = state.value ?? [];
      final updatedList = currentList.map((i) => i.id == inspection.id ? inspection : i).toList();
      state = AsyncValue.data(updatedList);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Mark inspection as completed
  Future<void> completeInspection(String inspectionId) async {
    try {
      final inspectionService = ref.read(inspectionServiceProvider);
      await inspectionService.updateInspectionStatus(
        inspectionId: inspectionId,
        status: InspectionStatus.completed,
        completedAt: DateTime.now(),
      );

      // Refresh the list
      ref.invalidateSelf();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Save inspection as pending (partial progress)
  Future<void> saveAsPending(Inspection inspection) async {
    try {
      final inspectionService = ref.read(inspectionServiceProvider);
      final pendingInspection = inspection.copyWith(
        status: InspectionStatus.pending,
        updatedAt: DateTime.now(),
      );

      await inspectionService.updateInspection(pendingInspection);

      // Refresh the list
      ref.invalidateSelf();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider to stream recent inspections for home screen
@riverpod
Stream<List<Inspection>> recentInspections(Ref ref) {
  final user = ref.watch(authServiceProvider).currentUser;
  if (user == null) return Stream.value([]);

  final inspectionService = ref.watch(inspectionServiceProvider);
  return inspectionService.streamRecentInspections(user.uid, limit: 10);
}

/// Provider to stream all completed inspections (for history screen - all users)
@Riverpod(keepAlive: true)
Stream<List<Inspection>> allCompletedInspections(Ref ref) {
  final inspectionService = ref.watch(inspectionServiceProvider);
  return inspectionService.streamAllCompletedInspections();
}

/// Provider to stream user's uncompleted inspections
@riverpod
Stream<List<Inspection>> userUncompletedInspections(Ref ref) {
  final user = ref.watch(authServiceProvider).currentUser;
  if (user == null) return Stream.value([]);

  final inspectionService = ref.watch(inspectionServiceProvider);
  return inspectionService.streamUserUncompletedInspections(user.uid);
}

/// Provider for prioritized inspections (uncompleted first, then recent completed)
@riverpod
List<Inspection> userPrioritizedInspections(Ref ref) {
  final user = ref.watch(authServiceProvider).currentUser;
  if (user == null) return [];

  final uncompletedAsync = ref.watch(userUncompletedInspectionsProvider);
  final recentAsync = ref.watch(recentInspectionsProvider);

  // Using .asData?.value safely retrieves the data if available.

  final uncompleted = uncompletedAsync.asData?.value ?? [];

  if (uncompleted.isNotEmpty) {
    return uncompleted;
  }

  final recent = recentAsync.asData?.value ?? [];
  return recent.where((i) => i.status == InspectionStatus.completed).toList();
}
