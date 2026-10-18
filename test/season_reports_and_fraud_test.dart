import 'package:flutter_test/flutter_test.dart';
import 'package:cqaag_app/models/intelligence/season_market_report.dart';
import 'package:cqaag_app/models/intelligence/fraud_heuristics.dart';

void main() {
  group('Step 25: Automated Season & Market Reports (Spec Section 92–93)', () {
    test('25.3 & 25.4: Season report draft cannot be sent; approval freezes figures', () {
      final draft = SeasonReport(
        id: 'rep-2026-draft',
        seasonYear: 2026,
        status: SeasonReportStatus.draft,
        totalBagsInspected: 125000,
        totalTonnageMetric: 10000.0,
        averageKor: 48.75,
        averageMoisture: 8.6,
        averageNutCount: 182,
        regionalSummaries: const {
          'Bono': RegionalSeasonSummary(region: 'Bono', totalLots: 240, averageKor: 49.1, averageMoisture: 8.4, averageNutCount: 178),
        },
        createdAt: DateTime(2026, 10, 1),
      );

      // Draft cannot be dispatched (Test 25.3)
      expect(draft.canBeDispatched, isFalse);

      // General Secretary approves and freezes report
      final released = draft.releaseReport(
        generalSecretaryUid: 'GEN-SEC-001',
        timestamp: DateTime(2026, 10, 5),
      );
      expect(released.isReleased, isTrue);
      expect(released.canBeDispatched, isTrue);
      expect(released.approvedByGeneralSecretary, equals('GEN-SEC-001'));

      // Test 25.4: Frozen figures remain identical
      expect(released.averageKor, equals(48.75));
      expect(released.totalTonnageMetric, equals(10000.0));
    });

    test('25.6 & 25.7: Market aggregation suppresses averages under 5 lots and strictly anonymizes', () {
      final weekMonday = DateTime(2026, 10, 12);

      // 4 lots in Savannah (under 5) -> suppress averages per Test 25.6
      final savannahLots = [
        {'kor': 48.0, 'moisture': 8.5, 'nut_count': 180},
        {'kor': 47.5, 'moisture': 8.6, 'nut_count': 185},
        {'kor': 48.2, 'moisture': 8.4, 'nut_count': 179},
        {'kor': 47.8, 'moisture': 8.7, 'nut_count': 182},
      ];
      final savannahMarket = MarketAggregatorEngine.aggregateRegionWeekly(
        weekCommencing: weekMonday,
        region: 'Savannah',
        eligibleLots: savannahLots,
      );
      expect(savannahMarket.lotCount, equals(4));
      expect(savannahMarket.hasSufficientSampleSize, isFalse);
      expect(savannahMarket.displayAverageKor, equals("—"));
      expect(savannahMarket.displayAverageMoisture, equals("—"));
      expect(savannahMarket.displayAverageNutCount, equals("—"));

      // 6 lots in Bono (>= 5) -> publish the 3 averages
      final bonoLots = [
        {'kor': 49.0, 'moisture': 8.2, 'nut_count': 176},
        {'kor': 49.5, 'moisture': 8.4, 'nut_count': 174},
        {'kor': 48.8, 'moisture': 8.6, 'nut_count': 178},
        {'kor': 49.2, 'moisture': 8.3, 'nut_count': 175},
        {'kor': 50.0, 'moisture': 8.1, 'nut_count': 172},
        {'kor': 49.5, 'moisture': 8.2, 'nut_count': 175},
      ];
      final bonoMarket = MarketAggregatorEngine.aggregateRegionWeekly(
        weekCommencing: weekMonday,
        region: 'Bono',
        eligibleLots: bonoLots,
      );
      expect(bonoMarket.lotCount, equals(6));
      expect(bonoMarket.hasSufficientSampleSize, isTrue);
      expect(bonoMarket.displayAverageKor, equals("49.33"));
      expect(bonoMarket.displayAverageMoisture, equals("8.3%"));
      expect(bonoMarket.displayAverageNutCount, equals("175"));

      // Test 25.7: Public view has no name, place, district, price, or tonnage
      final json = bonoMarket.toPublicJson();
      expect(json.containsKey('name'), isFalse);
      expect(json.containsKey('place'), isFalse);
      expect(json.containsKey('district'), isFalse);
      expect(json.containsKey('price'), isFalse);
      expect(json.containsKey('tonnage'), isFalse);
      expect(json['region'], equals('Bono'));
    });

    test('25.8: Practice checks, cancelled checks and uncompleted checks are excluded from market view', () {
      expect(MarketAggregatorEngine.isInspectionEligibleForMarketView(isPractice: true, isCancelled: false, isCompleted: true), isFalse);
      expect(MarketAggregatorEngine.isInspectionEligibleForMarketView(isPractice: false, isCancelled: true, isCompleted: true), isFalse);
      expect(MarketAggregatorEngine.isInspectionEligibleForMarketView(isPractice: false, isCancelled: false, isCompleted: false), isFalse);
      expect(MarketAggregatorEngine.isInspectionEligibleForMarketView(isPractice: false, isCancelled: false, isCompleted: true), isTrue);
    });
  });

  group('Step 26: Anti-Fraud Signals & Heuristics (Spec Section 94, Tests 26.1–26.5)', () {
    test('26.1: S1 (HIGH) triggered silently on duplicate moisture meter photo re-use', () {
      final existingHashes = {
        'hash_abc123': 'LOT-261010-0001',
      };

      // Current check uses same photo hash
      final signal = FraudHeuristicsEngine.evaluatePhotoDuplication(
        currentLotId: 'LOT-261012-0005',
        currentPhotoHash: 'hash_abc123',
        currentAnalystUid: 'ANALYST-42',
        existingPhotoHashesToLotIds: existingHashes,
      );

      expect(signal, isNotNull);
      expect(signal!.signalCode, equals(FraudSignalCode.s1DuplicatePhoto));
      expect(signal.severity, equals(FraudSignalSeverity.high));
      expect(signal.isInternalOnly, isTrue); // Analyst sees nothing in terminal
    });

    test('26.2: S2 (MEDIUM) triggered on 3rd geolocation deviation > 5km', () {
      // Registered facility: Wenchi (7.7333, -2.1000)
      const regLat = 7.7333;
      const regLng = -2.1000;

      // Check performed in Techiman ~30 km away
      const checkLat = 7.5833;
      const checkLng = -1.9333;

      // 1st deviation: null signal (warning counter only)
      final sig1 = FraudHeuristicsEngine.evaluateGeolocationDeviation(
        lotId: 'L-1',
        analystUid: 'A1',
        checkLat: checkLat,
        checkLng: checkLng,
        registeredLat: regLat,
        registeredLng: regLng,
        previousDeviationCount: 0,
      );
      expect(sig1, isNull);

      // 3rd deviation (previousDeviationCount: 2): raises S2 signal
      final sig3 = FraudHeuristicsEngine.evaluateGeolocationDeviation(
        lotId: 'L-3',
        analystUid: 'A1',
        checkLat: checkLat,
        checkLng: checkLng,
        registeredLat: regLat,
        registeredLng: regLng,
        previousDeviationCount: 2,
      );
      expect(sig3, isNotNull);
      expect(sig3!.signalCode, equals(FraudSignalCode.s2LocationDeviation));
      expect(sig3.severity, equals(FraudSignalSeverity.medium));
    });

    test('26.3: S3 (HIGH) triggered on impossible velocity (> 150km in 1 hour)', () {
      final t0 = DateTime(2026, 10, 18, 10, 0);
      final t1 = DateTime(2026, 10, 18, 10, 45); // 45 minutes later

      // Sunyani (7.3399, -2.3268) to Kumasi (6.6885, -1.6244) ~ 125 km (not > 150 km)
      final sigNormal = FraudHeuristicsEngine.evaluateImpossibleVelocity(
        currentLotId: 'LOT-KUMASI',
        analystUid: 'ANALYST-SPEED',
        currentLat: 6.6885,
        currentLng: -1.6244,
        currentTimestamp: t1,
        priorLat: 7.3399,
        priorLng: -2.3268,
        priorTimestamp: t0,
      );
      expect(sigNormal, isNull);

      // Sunyani (7.3399, -2.3268) to Accra (5.6037, -0.1870) ~ 300 km in 45 minutes -> Impossible!
      final sigImpossible = FraudHeuristicsEngine.evaluateImpossibleVelocity(
        currentLotId: 'LOT-ACCRA',
        analystUid: 'ANALYST-SPEED',
        currentLat: 5.6037,
        currentLng: -0.1870,
        currentTimestamp: t1,
        priorLat: 7.3399,
        priorLng: -2.3268,
        priorTimestamp: t0,
      );
      expect(sigImpossible, isNotNull);
      expect(sigImpossible!.signalCode, equals(FraudSignalCode.s3ImpossibleVelocity));
      expect(sigImpossible.severity, equals(FraudSignalSeverity.high));
    });

    test('26.4: ASK THE ANALYST opens neutral query with word signal strictly omitted', () {
      final query = FraudHeuristicsEngine.createNeutralReviewerQuery(
        lotId: 'LOT-261018-0099',
        analystUid: 'ANALYST-01',
        reviewerUid: 'REVIEWER-09',
        subjectTopic: 'Moisture reading clarification',
      );

      expect(query['type'], equals('QUERY'));
      expect(query['status'], equals('OPEN'));
      expect(query['title'], contains('Clarification requested'));
      // Banned word check
      expect(query['title'].toString().toLowerCase(), isNot(contains('signal')));
      expect(query['contains_word_signal'], isFalse);
    });
  });
}
