// Season Report and Public Market View Models (Spec Section 92–93, Figure 47, Tests 25.1–25.13).

enum SeasonReportStatus {
  draft('DRAFT'),
  released('RELEASED');

  const SeasonReportStatus(this.value);
  final String value;
}

/// Official Season Intelligence Report Model (Tests 25.3 & 25.4).
class SeasonReport {
  const SeasonReport({
    required this.id,
    required this.seasonYear,
    required this.status,
    required this.totalBagsInspected,
    required this.totalTonnageMetric,
    required this.averageKor,
    required this.averageMoisture,
    required this.averageNutCount,
    required this.regionalSummaries,
    required this.createdAt,
    this.approvedByGeneralSecretary,
    this.releasedAt,
  });

  final String id;
  final int seasonYear;
  final SeasonReportStatus status;
  final int totalBagsInspected;
  final double totalTonnageMetric;
  final double averageKor;
  final double averageMoisture;
  final int averageNutCount;
  final Map<String, RegionalSeasonSummary> regionalSummaries;
  final DateTime createdAt;
  final String? approvedByGeneralSecretary;
  final DateTime? releasedAt;

  bool get isReleased => status == SeasonReportStatus.released;

  /// Test 25.3: A DRAFT report cannot be sent or shared externally.
  bool get canBeDispatched => isReleased;

  /// Test 25.3: Release and freeze season report.
  SeasonReport releaseReport({
    required String generalSecretaryUid,
    DateTime? timestamp,
  }) {
    return SeasonReport(
      id: id,
      seasonYear: seasonYear,
      status: SeasonReportStatus.released,
      totalBagsInspected: totalBagsInspected,
      totalTonnageMetric: totalTonnageMetric,
      averageKor: averageKor,
      averageMoisture: averageMoisture,
      averageNutCount: averageNutCount,
      regionalSummaries: Map.unmodifiable(regionalSummaries),
      createdAt: createdAt,
      approvedByGeneralSecretary: generalSecretaryUid,
      releasedAt: timestamp ?? DateTime.now().toUtc(),
    );
  }
}

class RegionalSeasonSummary {
  const RegionalSeasonSummary({
    required this.region,
    required this.totalLots,
    required this.averageKor,
    required this.averageMoisture,
    required this.averageNutCount,
  });

  final String region;
  final int totalLots;
  final double averageKor;
  final double averageMoisture;
  final int averageNutCount;
}

/// Public Cashew Market View Model (Spec Section 93, Tests 25.6–25.9).
class PublicMarketAggregate {
  const PublicMarketAggregate({
    required this.weekCommencing,
    required this.region,
    required this.lotCount,
    this.averageKor,
    this.averageMoisture,
    this.averageNutCount,
  });

  final DateTime weekCommencing;
  final String region;
  final int lotCount;

  /// Test 25.6: A region with < 5 lots suppresses averages ("—") to prevent re-identification.
  /// A region with >= 5 lots publishes the 3 averages.
  final double? averageKor;
  final double? averageMoisture;
  final int? averageNutCount;

  bool get hasSufficientSampleSize => lotCount >= 5;

  String get displayAverageKor => hasSufficientSampleSize && averageKor != null
      ? averageKor!.toStringAsFixed(2)
      : "—";

  String get displayAverageMoisture => hasSufficientSampleSize && averageMoisture != null
      ? "${averageMoisture!.toStringAsFixed(1)}%"
      : "—";

  String get displayAverageNutCount => hasSufficientSampleSize && averageNutCount != null
      ? averageNutCount!.toString()
      : "—";

  /// Test 25.7: Public market row is strictly anonymized (No trader name, place, district, price, or tonnage).
  Map<String, dynamic> toPublicJson() => {
    'week_commencing': weekCommencing.toIso8601String().split('T').first,
    'region': region,
    'lot_count': lotCount,
    'kor': displayAverageKor,
    'moisture': displayAverageMoisture,
    'nut_count': displayAverageNutCount,
    // Act 843: name, district, place, price, tonnage strictly omitted
  };
}

/// Market Aggregator Engine (Tests 25.6, 25.8).
class MarketAggregatorEngine {
  /// Test 25.8: A practice check, cancelled check, or uncompleted check is NOT counted.
  static bool isInspectionEligibleForMarketView({
    required bool isPractice,
    required bool isCancelled,
    required bool isCompleted,
  }) {
    if (isPractice) return false;
    if (isCancelled) return false;
    if (!isCompleted) return false;
    return true;
  }

  /// Test 25.6: Aggregate weekly region data.
  static PublicMarketAggregate aggregateRegionWeekly({
    required DateTime weekCommencing,
    required String region,
    required List<Map<String, dynamic>> eligibleLots,
  }) {
    final count = eligibleLots.length;
    if (count < 5) {
      // Under 5 lots: return with null averages per Test 25.6
      return PublicMarketAggregate(
        weekCommencing: weekCommencing,
        region: region,
        lotCount: count,
        averageKor: null,
        averageMoisture: null,
        averageNutCount: null,
      );
    }

    double sumKor = 0;
    double sumMoisture = 0;
    int sumNutCount = 0;

    for (final lot in eligibleLots) {
      sumKor += (lot['kor'] as num).toDouble();
      sumMoisture += (lot['moisture'] as num).toDouble();
      sumNutCount += (lot['nut_count'] as num).toInt();
    }

    return PublicMarketAggregate(
      weekCommencing: weekCommencing,
      region: region,
      lotCount: count,
      averageKor: sumKor / count,
      averageMoisture: sumMoisture / count,
      averageNutCount: (sumNutCount / count).round(),
    );
  }
}
