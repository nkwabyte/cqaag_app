import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cqaag_app/models/inspection/analysis_types.dart';
import 'package:cqaag_app/models/payment/fee_schedule.dart';
import 'package:cqaag_app/services/membership/legacy_register.dart';
import 'package:cqaag_app/core/services/pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Quality Certificate terminology and types smoke test', () {
    expect(AnalysisTypes.paid, contains(AnalysisTypes.export));
    expect(AnalysisTypes.paid, contains(AnalysisTypes.moistureControl));
    expect(AnalysisTypes.paid, contains(AnalysisTypes.dispatch));
    expect(AnalysisTypes.paid, contains(AnalysisTypes.arbitration));
    expect(AnalysisTypes.reportFeeCedis, equals(100.0));
    expect(AnalysisTypes.requiresApproval(AnalysisTypes.export), isTrue);
    expect(AnalysisTypes.requiresPayment(AnalysisTypes.export), isTrue);
    expect(AnalysisTypes.requiresPayment(AnalysisTypes.arrivalUpcountry), isFalse);

    // 5 certificates specification checks
    expect(AnalysisTypes.code('Upcountry RCN Arrival'), equals('UAC'));
    expect(AnalysisTypes.code('RCN Dispatch Quality'), equals('DQC'));
    expect(AnalysisTypes.code('RCN Arbitration'), equals('ARB'));
    expect(AnalysisTypes.code('Export Zone RCN Arrival'), equals('EZA'));
    expect(AnalysisTypes.code('RCN Export Quality'), equals('EXQ'));

    // Moisture limits
    expect(AnalysisTypes.maxMoisture('Upcountry RCN Arrival'), equals(10.0));
    expect(AnalysisTypes.maxMoisture('RCN Dispatch Quality'), equals(10.0));
    expect(AnalysisTypes.maxMoisture('RCN Export Quality'), equals(8.0));

    // Fee calculations
    expect(AnalysisTypes.feeFor('Upcountry RCN Arrival'), equals(0.0));
    expect(AnalysisTypes.feeFor('RCN Dispatch Quality'), equals(300.0));
    expect(AnalysisTypes.feeFor('RCN Arbitration'), equals(300.0));
    expect(AnalysisTypes.feeFor('Export Zone RCN Arrival'), equals(0.0));
    expect(AnalysisTypes.feeFor('RCN Export Quality', quantityTons: 51.87), equals(518.70));
  });

  test('Membership Fee Schedule new inputs and existing member rate test', () {
    final schedule = FeeSchedule.defaults;

    // Standard registration fee is 320 GHS
    expect(schedule.registrationFeeFor(FeeCategory.full), equals(320.0));
    expect(schedule.annualDuesFor(FeeCategory.full), equals(200.0));
    expect(schedule.mandatoryTotalFor(FeeCategory.full), equals(520.0));

    // Existing full members who paid earlier GHS 60 pay GHS 200
    expect(schedule.registrationFeeFor(FeeCategory.full, isExistingMember: true), equals(200.0));
    expect(schedule.mandatoryTotalFor(FeeCategory.full, isExistingMember: true), equals(400.0));

    // Other categories
    expect(schedule.registrationFeeFor(FeeCategory.nationalAssociate), equals(320.0));
    expect(schedule.annualDuesFor(FeeCategory.nationalAssociate), equals(100.0));
    expect(schedule.mandatoryTotalFor(FeeCategory.nationalAssociate), equals(420.0));

    expect(schedule.annualDuesFor(FeeCategory.foreignAssociate), equals(1000.0));
    expect(schedule.mandatoryTotalFor(FeeCategory.foreignAssociate), equals(1320.0));

    // Honorary is exempt
    expect(schedule.mandatoryTotalFor(FeeCategory.honorary), equals(0.0));

    // Kits prices
    final boot = schedule.optionalItems.firstWhere((i) => i.key == 'safety_boot');
    expect(boot.amountFor(FeeCategory.full), equals(200.0));
    expect(boot.requiresSize, isTrue);

    final moistureMachine = schedule.optionalItems.firstWhere((i) => i.key == 'moisture_machine');
    expect(moistureMachine.amountFor(FeeCategory.full), equals(2500.0));

    final cutter = schedule.optionalItems.firstWhere((i) => i.key == 'cutter');
    expect(cutter.amountFor(FeeCategory.full), equals(700.0));

    final scale = schedule.optionalItems.firstWhere((i) => i.key == 'kitchen_scale');
    expect(scale.amountFor(FeeCategory.full), equals(302.0));

    final bag = schedule.optionalItems.firstWhere((i) => i.key == 'kit_bag');
    expect(bag.amountFor(FeeCategory.full), equals(242.0));
  });

  test('LegacyRegister matches existing members correctly', () {
    // Ebenezer Amoafo
    expect(LegacyRegister.isExistingMember(phone: '0553330931'), isTrue);
    expect(LegacyRegister.isExistingMember(phone: '+233 55 333 0931'), isTrue);
    expect(LegacyRegister.isExistingMember(name: 'AMANFO KWABENA EBENEZER'), isTrue);

    // Eric Piesie Yeboah
    expect(LegacyRegister.isExistingMember(phone: '0247593276'), isTrue);

    // Unknown person
    expect(LegacyRegister.isExistingMember(phone: '0200000000'), isFalse);
    expect(LegacyRegister.isExistingMember(name: 'Random Stranger'), isFalse);
  });

  test('PdfService generates PDFs for all 5 certificate types', () async {
    // Provide fast offline fonts for unit testing
    final service = PdfService(
      regularFont: () async => pw.Font.helvetica(),
      boldFont: () async => pw.Font.helveticaBold(),
    );

    final baseData = {
      'id': 'INS-TEST-001',
      'inspectionId': 'INS-20261016-TEST',
      'batchId': 'CQAAG-L-261010-0007',
      'date': '2026-10-16',
      'location': 'Wenchi, Bono Region',
      'company': 'Savanna Agro Supplies Ltd',
      'buyerName': 'Gold Coast Nuts Trading',
      'waybillNumber': 'WB-0007345',
      'quantity': '12480',
      'bagCount': '156',
      'truckNumber': 'GN 1234 ABC',
      'inspector': 'Kwabena Ebenezer',
      'qcCode': 'CQAAG-QC-0001',
    };

    // 1. UAC
    final uacBytes = await service.generateReport({...baseData, 'analysisType': 'Upcountry RCN Arrival'});
    expect(uacBytes.isNotEmpty, isTrue);

    // 2. DQC
    final dqcBytes = await service.generateReport({...baseData, 'analysisType': 'RCN Dispatch Quality'});
    expect(dqcBytes.isNotEmpty, isTrue);

    // 3. ARB (2 pages)
    final arbBytes = await service.generateReport({...baseData, 'analysisType': 'RCN Arbitration'});
    expect(arbBytes.isNotEmpty, isTrue);

    // 4. EZA
    final ezaBytes = await service.generateReport({...baseData, 'analysisType': 'Export Zone RCN Arrival'});
    expect(ezaBytes.isNotEmpty, isTrue);

    // 5. EXQ Draft
    final exqDraftBytes = await service.generateReport({
      ...baseData,
      'analysisType': 'RCN Export Quality',
      'approvalStatus': 'pending',
    });
    expect(exqDraftBytes.isNotEmpty, isTrue);

    // 6. EXQ Approved Original (2 pages with Navy Stamp)
    final exqOrigBytes = await service.generateReport({
      ...baseData,
      'analysisType': 'RCN Export Quality',
      'approvalStatus': 'approved',
      'approvedByName': 'Amoafo Ebenezer',
      'approvedAt': '2026-10-16 09:10:00 UTC',
    });
    expect(exqOrigBytes.isNotEmpty, isTrue);
  });
}
