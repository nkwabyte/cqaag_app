import 'package:flutter_test/flutter_test.dart';
import 'package:cqaag_app/services/system/dispatch_messaging_service.dart';

void main() {
  group('Phase 5: Step 12 - Statutory Sending, SMS Truncation & Admin Settings', () {
    test('Test 12.3: cleanAscii removes accents and replaces typographic punctuation', () {
      const input = 'Café résumé with – em-dash and “quotes” & élévation';
      final cleaned = DispatchMessagingService.cleanAscii(input);

      expect(cleaned, equals('Cafe resume with - em-dash and "quotes" & elevation'));
      expect(cleaned.codeUnits.every((c) => c <= 127), isTrue);
    });

    test('Test 12.3: Standard SMS fits under 160 characters with all metrics', () {
      final sms = DispatchMessagingService.buildStatutorySms(
        documentType: 'Moisture Pass',
        role: 'Seller',
        passNumber: 'CQAAG-P-261012-0007',
        statusOfGoods: 'PASSED (8.5%)',
        kor: 48.75,
        nutCount: 198,
        defectivesPercent: 4.2,
        shortLink: 'cqaaggh.org/p/261012-0007',
      );

      expect(sms.length, lessThanOrEqualTo(160));
      expect(sms, contains('CQAAG Moisture Pass CQAAG-P-261012-0007'));
      expect(sms, contains('KOR 48.75 lb'));
      expect(sms, contains('NC 198'));
      expect(sms, contains('Def 4.2%'));
      expect(sms, contains('https://cqaaggh.org/p/261012-0007'));
    });

    test('Test 12.3: Long message progressively drops defectives, then nut count', () {
      // Create a scenario where full message exceeds 160 chars
      final longSms = DispatchMessagingService.buildStatutorySms(
        documentType: 'Export Quality Certificate Original Validation',
        role: 'Consignee International Trading Corporation Limited',
        passNumber: 'CQAAG-EXQ-261012-0007',
        statusOfGoods: 'CONDITIONALLY ACCEPTED WITH CLEARANCE REQUIREMENTS',
        kor: 49.50,
        nutCount: 205,
        defectivesPercent: 5.8,
        shortLink: 'cqaaggh.org/verify/261012-0007-EXQ',
      );

      // Must be <= 160 chars
      expect(longSms.length, lessThanOrEqualTo(160));
      // Defectives dropped first to preserve brevity
      expect(longSms, isNot(contains('Def 5.8%')));
    });

    test('Test 12.2: Channel selection matrix per document type', () {
      // Moisture pass sends SMS, email, in-app
      final moistureChannels = DispatchMessagingService.getChannelsForDocumentType('moisture_pass');
      expect(moistureChannels['sms'], isTrue);
      expect(moistureChannels['email'], isTrue);
      expect(moistureChannels['inApp'], isTrue);

      // Export draft does NOT send SMS (email + in-app only)
      final draftChannels = DispatchMessagingService.getChannelsForDocumentType('export_draft');
      expect(draftChannels['sms'], isFalse);
      expect(draftChannels['email'], isTrue);
      expect(draftChannels['inApp'], isTrue);

      // Declined notice does NOT send SMS
      final declinedChannels = DispatchMessagingService.getChannelsForDocumentType('declined_notice');
      expect(declinedChannels['sms'], isFalse);
      expect(declinedChannels['email'], isTrue);

      // Export Original to shipper only, no SMS
      final originalChannels = DispatchMessagingService.getChannelsForDocumentType('export_original');
      expect(originalChannels['sms'], isFalse);
      expect(originalChannels['email'], isTrue);
    });

    test('Test 12.3: Messaging report computes delivery percentage and financial cost', () {
      final report = DispatchMessagingService.generateMessagingReport(
        totalDispatched: 1000,
        failedCount: 25,
        costPerSmsGhs: 0.08,
      );

      expect(report['totalSent'], equals(1000));
      expect(report['delivered'], equals(975));
      expect(report['failed'], equals(25));
      expect(report['successRatePercent'], equals(97.5));
      expect(report['totalCostGhs'], equals(80.0));
    });
  });
}
