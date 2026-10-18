import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cqaag_app/services/equipment/equipment_service.dart';

final equipmentServiceProvider = Provider<EquipmentService>((ref) {
  return EquipmentService();
});
