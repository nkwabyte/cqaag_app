import 'package:flutter_test/flutter_test.dart';
import 'package:cqaag_app/models/weather/weather_alert_model.dart';

void main() {
  group('Step 23: Weather and Plant Health Field Reporting (Spec Section 20, Tests 23.1–23.9)', () {
    test('23.1: Offline weather card shows reading age; after 24 hours shows Forecast not available', () {
      final baseTime = DateTime(2026, 10, 18, 12, 0);

      final snapshot = WeatherSnapshot(
        district: 'Wenchi',
        temperatureC: 28.5,
        condition: 'Partly Cloudy',
        rainProbabilityPercent: 40,
        rainfallMm: 2.0,
        updatedAt: baseTime,
      );

      // Online
      expect(snapshot.displayForecastStatus(baseTime, true), equals("Partly Cloudy • 28.5°C"));

      // Offline after 5 hours
      final fiveHoursLater = baseTime.add(const Duration(hours: 5));
      expect(snapshot.displayForecastStatus(fiveHoursLater, false), equals("Offline: reading of 5 hours ago"));

      // Offline after 25 hours -> Stale
      final twentyFiveHoursLater = baseTime.add(const Duration(hours: 25));
      expect(snapshot.displayForecastStatus(twentyFiveHoursLater, false), equals("Forecast not available"));
    });

    test('23.2: Drying record rain alert triggers at >= 70% within 6h and deduplicates within 6 hours', () {
      final t0 = DateTime(2026, 10, 18, 10, 0);

      // Condition met: open drying, 75% rain, 3 hours away -> Trigger
      final trigger1 = WeatherAlertEngine.shouldTriggerDryingRainAlarm(
        hasOpenDryingRecord: true,
        rainProbabilityPercent: 75,
        hoursUntilRain: 3,
        lastAlertSentAt: null,
        now: t0,
      );
      expect(trigger1, isTrue);

      // 3 hours later, second forecast still says 70% -> Deduplicated, do not resend
      final t1 = t0.add(const Duration(hours: 3));
      final trigger2 = WeatherAlertEngine.shouldTriggerDryingRainAlarm(
        hasOpenDryingRecord: true,
        rainProbabilityPercent: 70,
        hoursUntilRain: 2,
        lastAlertSentAt: t0,
        now: t1,
      );
      expect(trigger2, isFalse);

      // No open drying record -> Never triggers
      final trigger3 = WeatherAlertEngine.shouldTriggerDryingRainAlarm(
        hasOpenDryingRecord: false,
        rainProbabilityPercent: 90,
        hoursUntilRain: 1,
        lastAlertSentAt: null,
        now: t0,
      );
      expect(trigger3, isFalse);
    });

    test('23.6: Field plant health report requires photos and is blocked without them', () {
      final validReport = PlantHealthObservation(
        id: 'obs-001',
        reporterUid: 'USER-123',
        reporterName: 'Kofi Mensah',
        district: 'Berekum',
        issueType: 'anthracnose',
        description: 'Black leaf spot and blighted nuts on 10 trees',
        photoUrls: ['https://storage.cqaag.org/photos/leaf1.jpg', 'https://storage.cqaag.org/photos/leaf2.jpg'],
        createdAt: DateTime(2026, 10, 18),
      );
      expect(validReport.isValidReport, isTrue);

      final invalidReport = PlantHealthObservation(
        id: 'obs-002',
        reporterUid: 'USER-123',
        reporterName: 'Kofi Mensah',
        district: 'Berekum',
        issueType: 'anthracnose',
        description: 'Leaf spot without photo',
        photoUrls: [],
        createdAt: DateTime(2026, 10, 18),
      );
      expect(invalidReport.isValidReport, isFalse);
    });

    test('23.7: 2 reports of same kind in 1 district within 14 days proposes alert', () {
      final now = DateTime(2026, 10, 18);

      final reports = [
        PlantHealthObservation(
          id: 'r1',
          reporterUid: 'U1',
          reporterName: 'Analyst 1',
          district: 'Tano North',
          issueType: 'mirids',
          description: 'Sucking bug damage on young shoots',
          photoUrls: ['https://example.com/p1.jpg'],
          createdAt: now.subtract(const Duration(days: 4)),
        ),
        PlantHealthObservation(
          id: 'r2',
          reporterUid: 'U2',
          reporterName: 'Analyst 2',
          district: 'Tano North',
          issueType: 'mirids',
          description: 'Dieback and mirids clusters',
          photoUrls: ['https://example.com/p2.jpg'],
          createdAt: now.subtract(const Duration(days: 1)),
        ),
      ];

      expect(WeatherAlertEngine.shouldProposePlantAlert(recentDistrictReports: reports, issueType: 'mirids', now: now), isTrue);
      expect(WeatherAlertEngine.shouldProposePlantAlert(recentDistrictReports: reports, issueType: 'dieback', now: now), isFalse);
    });

    test('23.8: Serious alert builds plain SMS under 160 characters', () {
      final sms = WeatherAlertEngine.buildSeriousAlertSms(
        district: 'Tano North',
        issueType: 'Mirids Outbreak',
        actionAdvice: 'Apply approved botanical neem or recommended bio-pesticide',
      );

      expect(sms.length, lessThanOrEqualTo(160));
      expect(sms, contains('CQAAG PLANT ALERT'));
      expect(sms, contains('Tano North'));
    });

    test('23.9: TCDA read-only representation omits reporter personal identifiable information', () {
      final report = PlantHealthObservation(
        id: 'obs-privacy-01',
        reporterUid: 'SECRET-ANALYST-99',
        reporterName: 'Kwabena Boateng',
        district: 'Jaman South',
        issueType: 'dieback',
        description: 'Branch twig dieback',
        photoUrls: ['https://example.com/twig.jpg'],
        createdAt: DateTime(2026, 10, 18),
        isValidated: true,
      );

      final tcdaView = report.toTcdaRedactedJson();
      expect(tcdaView.containsKey('reporter_name'), isFalse);
      expect(tcdaView.containsKey('reporter_uid'), isFalse);
      expect(tcdaView['district'], equals('Jaman South'));
      expect(tcdaView['is_validated'], isTrue);
    });
  });
}
