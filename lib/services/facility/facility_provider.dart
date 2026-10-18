import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cqaag_app/services/facility/facility_service.dart';

final facilityServiceProvider = Provider<FacilityService>((ref) {
  return FacilityService();
});
