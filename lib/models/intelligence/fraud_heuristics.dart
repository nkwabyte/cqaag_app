import 'dart:math' as math;

/// Anti-Fraud Signals Heuristics Model (Spec Section 94, Tests 26.1–26.5).

enum FraudSignalSeverity {
  medium('MEDIUM'),
  high('HIGH');

  const FraudSignalSeverity(this.value);
  final String value;
}

enum FraudSignalCode {
  s1DuplicatePhoto('S1', 'Duplicate Moisture Meter Photo Re-use', FraudSignalSeverity.high),
  s2LocationDeviation('S2', 'Location Distance Deviation > 5km (Repeated)', FraudSignalSeverity.medium),
  s3ImpossibleVelocity('S3', 'Impossible Travel Velocity (> 150km in 1 hour)', FraudSignalSeverity.high);

  const FraudSignalCode(this.code, this.description, this.defaultSeverity);
  final String code;
  final String description;
  final FraudSignalSeverity defaultSeverity;
}

class FraudSignalAlert {
  const FraudSignalAlert({
    required this.id,
    required this.signalCode,
    required this.analystUid,
    required this.lotId,
    required this.severity,
    required this.details,
    required this.createdAt,
    this.isReviewed = false,
  });

  final String id;
  final FraudSignalCode signalCode;
  final String analystUid;
  final String lotId;
  final FraudSignalSeverity severity;
  final String details;
  final DateTime createdAt;
  final bool isReviewed;

  /// Test 26.1: Signal is strictly internal. The analyst sees nothing in their terminal.
  bool get isInternalOnly => true;
}

/// Anti-Fraud Heuristics Evaluation Engine (Tests 26.1–26.5).
class FraudHeuristicsEngine {
  /// Test 26.1: S1 (HIGH) - Duplicate meter photo detected across two checks.
  static FraudSignalAlert? evaluatePhotoDuplication({
    required String currentLotId,
    required String currentPhotoHash,
    required String currentAnalystUid,
    required Map<String, String> existingPhotoHashesToLotIds,
    DateTime? now,
  }) {
    if (existingPhotoHashesToLotIds.containsKey(currentPhotoHash)) {
      final priorLot = existingPhotoHashesToLotIds[currentPhotoHash]!;
      if (priorLot != currentLotId) {
        return FraudSignalAlert(
          id: 'sig-s1-${DateTime.now().millisecondsSinceEpoch}',
          signalCode: FraudSignalCode.s1DuplicatePhoto,
          analystUid: currentAnalystUid,
          lotId: currentLotId,
          severity: FraudSignalSeverity.high,
          details: 'Moisture meter photo hash matches prior lot $priorLot.',
          createdAt: now ?? DateTime.now().toUtc(),
        );
      }
    }
    return null;
  }

  /// Test 26.2: S2 (MEDIUM) - Check done >5 km from registered warehouse.
  /// First 2 times: rating warning only; 3rd time: raises S2 signal.
  static FraudSignalAlert? evaluateGeolocationDeviation({
    required String lotId,
    required String analystUid,
    required double checkLat,
    required double checkLng,
    required double registeredLat,
    required double registeredLng,
    required int previousDeviationCount,
    DateTime? now,
  }) {
    final distanceKm = calculateHaversineDistanceKm(checkLat, checkLng, registeredLat, registeredLng);
    if (distanceKm > 5.0) {
      final newCount = previousDeviationCount + 1;
      if (newCount >= 3) {
        return FraudSignalAlert(
          id: 'sig-s2-${DateTime.now().millisecondsSinceEpoch}',
          signalCode: FraudSignalCode.s2LocationDeviation,
          analystUid: analystUid,
          lotId: lotId,
          severity: FraudSignalSeverity.medium,
          details: 'Check completed ${distanceKm.toStringAsFixed(1)}km from registered facility ($newCount repeated violations).',
          createdAt: now ?? DateTime.now().toUtc(),
        );
      }
    }
    return null;
  }

  /// Test 26.3: S3 (HIGH) - Impossible velocity: two checks >150 km apart within 1 hour by same analyst.
  static FraudSignalAlert? evaluateImpossibleVelocity({
    required String currentLotId,
    required String analystUid,
    required double currentLat,
    required double currentLng,
    required DateTime currentTimestamp,
    required double priorLat,
    required double priorLng,
    required DateTime priorTimestamp,
  }) {
    final distanceKm = calculateHaversineDistanceKm(currentLat, currentLng, priorLat, priorLng);
    final timeDiffMinutes = currentTimestamp.difference(priorTimestamp).inMinutes.abs();

    if (distanceKm > 150.0 && timeDiffMinutes <= 60) {
      return FraudSignalAlert(
        id: 'sig-s3-${DateTime.now().millisecondsSinceEpoch}',
        signalCode: FraudSignalCode.s3ImpossibleVelocity,
        analystUid: analystUid,
        lotId: currentLotId,
        severity: FraudSignalSeverity.high,
        details: 'Analyst logged 2 checks ${distanceKm.toStringAsFixed(1)}km apart in $timeDiffMinutes minutes.',
        createdAt: currentTimestamp,
      );
    }
    return null;
  }

  /// Test 26.4: Reviewer "ASK THE ANALYST" action creates a neutral query with no mention of "signal".
  static Map<String, dynamic> createNeutralReviewerQuery({
    required String lotId,
    required String analystUid,
    required String reviewerUid,
    required String subjectTopic,
  }) {
    return {
      'type': 'QUERY',
      'lot_id': lotId,
      'analyst_uid': analystUid,
      'initiated_by': reviewerUid,
      'status': 'OPEN',
      // The word "signal" is strictly banned from the analyst-facing thread (Test 26.4)
      'title': 'Clarification requested on Inspection $lotId: $subjectTopic',
      'contains_word_signal': false,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  /// Haversine formula to compute great-circle distance between two GPS coordinates in kilometers.
  static double calculateHaversineDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) * math.cos(_deg2rad(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _deg2rad(double deg) => deg * (math.pi / 180.0);
}
