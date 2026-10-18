/// Weather and Plant Health Models (Spec Section 20, Figures 10, Tests 23.1–23.9).
enum PlantHealthSeverity {
  information('information', 'Information'),
  moderate('moderate', 'Moderate Alert'),
  serious('serious', 'Serious Alert');

  const PlantHealthSeverity(this.value, this.label);
  final String value;
  final String label;

  static PlantHealthSeverity fromValue(String? val) {
    return PlantHealthSeverity.values.firstWhere(
      (s) => s.value == val,
      orElse: () => PlantHealthSeverity.information,
    );
  }
}

/// Weather card telemetry snapshot (Test 23.1).
class WeatherSnapshot {
  const WeatherSnapshot({
    required this.district,
    required this.temperatureC,
    required this.condition,
    required this.rainProbabilityPercent,
    required this.rainfallMm,
    required this.updatedAt,
    this.forecastSevenDays = const [],
  });

  final String district;
  final double temperatureC;
  final String condition;
  final int rainProbabilityPercent;
  final double rainfallMm;
  final DateTime updatedAt;
  final List<DayForecast> forecastSevenDays;

  bool isStale(DateTime now) => now.difference(updatedAt).inHours >= 24;

  String displayForecastStatus(DateTime now, bool isOnline) {
    if (!isOnline && isStale(now)) {
      return "Forecast not available";
    }
    if (!isOnline) {
      final hoursAgo = now.difference(updatedAt).inHours;
      return "Offline: reading of $hoursAgo hours ago";
    }
    return "$condition • ${temperatureC.toStringAsFixed(1)}°C";
  }
}

class DayForecast {
  const DayForecast({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.rainProbability,
    required this.condition,
  });

  final DateTime date;
  final double tempMax;
  final double tempMin;
  final int rainProbability;
  final String condition;
}

/// Plant Health Field Observation (Tests 23.6 & 23.9).
class PlantHealthObservation {
  const PlantHealthObservation({
    required this.id,
    required this.reporterUid,
    required this.reporterName,
    required this.district,
    required this.issueType, // e.g., 'mirids', 'dieback', 'anthracnose'
    required this.description,
    required this.photoUrls,
    required this.createdAt,
    this.isValidated = false,
  });

  final String id;
  final String reporterUid;
  final String reporterName;
  final String district;
  final String issueType;
  final String description;
  final List<String> photoUrls;
  final DateTime createdAt;
  final bool isValidated;

  /// Test 23.6: A report without a photo cannot be sent.
  bool get isValidReport => photoUrls.isNotEmpty;

  /// Test 23.9: Redacted view for TCDA statutory portal (no reporter name/phone).
  Map<String, dynamic> toTcdaRedactedJson() => {
    'id': id,
    'district': district,
    'issue_type': issueType,
    'description': description,
    'photo_urls': photoUrls,
    'created_at': createdAt.toIso8601String(),
    'is_validated': isValidated,
    // Act 843: reporter_name and reporter_uid are strictly omitted
  };
}

/// Weather and Rain Alert Rules Engine (Tests 23.2, 23.4, 23.7, 23.8).
class WeatherAlertEngine {
  /// Test 23.2: Drying record rain alarm logic.
  /// Forecast gives >= 70% rain within 6 hours -> sends amber alert + push.
  /// Deduplicated within 6-hour window so second forecast 3h later does not resend.
  static bool shouldTriggerDryingRainAlarm({
    required bool hasOpenDryingRecord,
    required int rainProbabilityPercent,
    required int hoursUntilRain,
    DateTime? lastAlertSentAt,
    required DateTime now,
  }) {
    if (!hasOpenDryingRecord) return false;
    if (rainProbabilityPercent < 70) return false;
    if (hoursUntilRain > 6) return false;

    if (lastAlertSentAt != null) {
      // Deduplicate: if an alert was sent in the last 6 hours, do not resend
      if (now.difference(lastAlertSentAt).inHours < 6) {
        return false;
      }
    }
    return true;
  }

  /// Test 23.7: Propose pest/disease outbreak alert when 2 reports of same kind in 1 district within 14 days.
  static bool shouldProposePlantAlert({
    required List<PlantHealthObservation> recentDistrictReports,
    required String issueType,
    required DateTime now,
  }) {
    final matches = recentDistrictReports.where((r) {
      final daysAgo = now.difference(r.createdAt).inDays;
      return r.issueType == issueType && daysAgo <= 14;
    }).length;

    return matches >= 2;
  }

  /// Test 23.8: 160-char maximum plain ASCII SMS for Serious plant health alerts.
  static String buildSeriousAlertSms({
    required String district,
    required String issueType,
    required String actionAdvice,
  }) {
    final raw = "CQAAG PLANT ALERT: $issueType reported in $district. $actionAdvice. Check app notices for guidelines.";
    if (raw.length <= 160) return raw;
    return '${raw.substring(0, 157)}...';
  }
}
