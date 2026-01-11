import 'package:cqaag_app/models/inspection/inspection.dart';
import 'package:cqaag_app/services/inspection/inspection_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inspection_controller.g.dart';

@riverpod
class InspectionController extends _$InspectionController {
  @override
  FutureOr<List<Inspection>> build() async {
    // Ideally, we would fetch inspections for the current user here
    // For now, return empty list or implement logic to fetch
    return [];
  }

  Future<void> createInspection(Inspection inspection) async {
    state = const AsyncValue.loading();
    try {
      final inspectionService = ref.read(inspectionServiceProvider);
      await inspectionService.createInspection(inspection);
      // Refresh list
      // ref.invalidateSelf(); // Or manually add to state
      state = AsyncValue.data([...?state.value, inspection]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
