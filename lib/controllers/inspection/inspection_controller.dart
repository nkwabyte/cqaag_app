import 'dart:io' as io;
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
    final list = allInspections.where((i) => i.status == InspectionStatus.pending || i.status == InspectionStatus.inProgress || i.status == InspectionStatus.pendingSync).toList();
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

  /// Sync offline pending Sync inspections
  Future<int> syncPendingInspections() async {
    final connectivity = ref.read(connectivityServiceProvider);
    if (!await connectivity.hasInternetAccess()) return 0;

    final stateValue = state.value;
    if (stateValue == null) return 0;

    final pendingSyncInspections = stateValue.allInspections.where((i) => i.status == InspectionStatus.pendingSync).toList();
    if (pendingSyncInspections.isEmpty) return 0;

    final cloudinary = ref.read(cloudinaryServiceProvider);
    final inspectionService = ref.read(inspectionServiceProvider);
    int syncedCount = 0;

    for (final inspection in pendingSyncInspections) {
      try {
        final List<String> oldUrls = inspection.imageUrls;
        final List<String> newUrls = [];

        for (final localPath in oldUrls) {
          if (!localPath.startsWith('http')) {
            final file = io.File(localPath); 
            if (await file.exists()) {
              final url = await cloudinary.uploadInspectionPhoto(file);
              if (url != null) {
                newUrls.add(url);
              } else {
                throw Exception('Failed to upload image $localPath');
              }
            } else {
              // If file is missing, we must decide either fail or continue. Let's throw.
              throw Exception('Local image missing: $localPath');
            }
          } else {
            // It's already an http URL (unlikely but possible if manually set)
            newUrls.add(localPath);
          }
        }

        final syncedInspection = inspection.copyWith(
          imageUrls: newUrls,
          status: InspectionStatus.completed,
          completedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await inspectionService.updateInspection(syncedInspection);
        syncedCount++;
      } catch (e) {
        debugPrint('Failed to sync inspection ${inspection.id}: $e');
        // Continue to the next one
      }
    }
    
    return syncedCount;
  }
}
