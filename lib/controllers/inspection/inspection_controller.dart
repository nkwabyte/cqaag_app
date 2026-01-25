import 'package:cqaag_app/index.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'inspection_controller.freezed.dart';
part 'inspection_controller.g.dart';

@freezed
abstract class InspectionState with _$InspectionState {
  const InspectionState._();
  const factory InspectionState({
    @Default([]) List<Inspection> allInspections,
    @Default([]) List<Inspection> allCompletedInspections,
  }) = _InspectionState;

  /// Get completed inspections (sorted by completedAt descending)
  List<Inspection> get completed {
    final list = allInspections.where((i) => i.status == InspectionStatus.completed).toList();
    list.sort((a, b) {
      final aTime = a.completedAt ?? DateTime(2000);
      final bTime = b.completedAt ?? DateTime(2000);
      return bTime.compareTo(aTime);
    });
    return list;
  }

  /// Get uncompleted inspections (pending + in-progress, sorted by updatedAt/createdAt descending)
  List<Inspection> get uncompleted {
    final list = allInspections.where((i) => i.status == InspectionStatus.pending || i.status == InspectionStatus.inProgress).toList();
    list.sort((a, b) {
      final aTime = a.updatedAt ?? a.createdAt ?? DateTime(2000);
      final bTime = b.updatedAt ?? b.createdAt ?? DateTime(2000);
      return bTime.compareTo(aTime);
    });
    return list;
  }

  /// Get recent inspections (limit 10, sorted by most relevant time)
  List<Inspection> get recent {
    final list = [...allInspections];
    list.sort((a, b) {
      final aTime = a.updatedAt ?? a.createdAt ?? a.completedAt ?? DateTime(2000);
      final bTime = b.updatedAt ?? b.createdAt ?? b.completedAt ?? DateTime(2000);
      return bTime.compareTo(aTime);
    });
    return list.take(10).toList();
  }
}

@Riverpod(keepAlive: true)
class InspectionController extends _$InspectionController {
  @override
  Stream<InspectionState> build() {
    final user = ref.watch(authServiceProvider).currentUser;
    if (user == null) return Stream.value(const InspectionState());

    final inspectionService = ref.watch(inspectionServiceProvider);

    final userInspectionsStream = inspectionService.streamUserInspections(user.uid);
    final allCompletedStream = inspectionService.streamAllCompletedInspections();

    return Rx.combineLatest2<List<Inspection>, List<Inspection>, InspectionState>(
      userInspectionsStream,
      allCompletedStream,
      (userInspections, allCompleted) {
        // Deduplicate allCompletedInspections by ID just in case
        final seenIds = <String>{};
        final uniqueAllCompleted = allCompleted.where((i) => seenIds.add(i.id)).toList();

        return InspectionState(
          allInspections: userInspections,
          allCompletedInspections: uniqueAllCompleted,
        );
      },
    );
  }

  /// Create a new inspection
  Future<void> createInspection(Inspection inspection) async {
    final inspectionService = ref.read(inspectionServiceProvider);
    await inspectionService.createInspection(inspection);
  }

  /// Update an existing inspection
  Future<void> updateInspection(Inspection inspection) async {
    final inspectionService = ref.read(inspectionServiceProvider);
    await inspectionService.updateInspection(inspection);
  }

  /// Mark inspection as completed
  Future<void> completeInspection(String inspectionId) async {
    final inspectionService = ref.read(inspectionServiceProvider);
    await inspectionService.updateInspectionStatus(
      inspectionId: inspectionId,
      status: InspectionStatus.completed,
      completedAt: DateTime.now(),
    );
  }

  /// Save inspection as pending (partial progress)
  Future<void> saveAsPending(Inspection inspection) async {
    final inspectionService = ref.read(inspectionServiceProvider);
    final pendingInspection = inspection.copyWith(
      status: InspectionStatus.pending,
      updatedAt: DateTime.now(),
    );

    await inspectionService.updateInspection(pendingInspection);
  }
}
