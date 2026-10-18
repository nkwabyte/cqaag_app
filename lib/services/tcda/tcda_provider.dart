import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cqaag_app/services/tcda/tcda_licence_service.dart';

final tcdaLicenceServiceProvider = Provider<TcdaLicenceService>((ref) {
  return TcdaLicenceService();
});
