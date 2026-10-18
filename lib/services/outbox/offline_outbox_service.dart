import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cqaag_app/models/outbox/outbox_item.dart';
import 'package:cqaag_app/models/tcda/tcda_party.dart';
import 'package:cqaag_app/services/tcda/tcda_licence_service.dart';

class OfflineOutboxService {
  final FirebaseFirestore? _firestore;
  final TcdaLicenceService? _tcdaService;

  // Local persistent in-memory queue simulating SQLite/Hive store
  final List<OutboxItem> _localQueue = [];
  bool _isSyncing = false;

  OfflineOutboxService({
    FirebaseFirestore? firestore,
    TcdaLicenceService? tcdaService,
  })  : _firestore = firestore,
        _tcdaService = tcdaService;

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;
  TcdaLicenceService get tcdaService => _tcdaService ?? TcdaLicenceService();

  List<OutboxItem> get items => List.unmodifiable(_localQueue);

  /// Get count of items waiting to be sent
  int get waitingCount => _localQueue
      .where((i) =>
          i.status == OutboxItemStatus.waitingToSend ||
          i.status == OutboxItemStatus.late)
      .length;

  /// Enqueue a new offline transaction item (FIFO)
  Future<OutboxItem> enqueue({
    required OutboxItemType type,
    required Map<String, dynamic> payload,
    required String analystId,
    DateTime? customTimestamp,
  }) async {
    final now = customTimestamp ?? DateTime.now();
    final id = 'OUTBOX-${now.millisecondsSinceEpoch}-${_localQueue.length + 1}';

    final item = OutboxItem(
      id: id,
      type: type,
      payload: payload,
      createdAt: now,
      status: OutboxItemStatus.waitingToSend,
      analystId: analystId,
    );

    _localQueue.add(item);
    return item;
  }

  /// Calculates status string for Top-bar status chip (Spec Section 72, Figure 18)
  String getStatusChipText({required bool isOnline}) {
    if (isOnline) {
      if (waitingCount == 0) return 'Online';
      return 'Online (Syncing $waitingCount waiting)';
    }

    // Check if any items are late (>73 hours)
    final hasLate = _localQueue.any((i) => i.isLate73h && i.status != OutboxItemStatus.sent);
    if (hasLate) {
      return 'Stale Outbox (>3 days un-synced)';
    }

    final hasAmber = _localQueue.any((i) => i.isStaleAmber && i.status != OutboxItemStatus.sent);
    if (hasAmber) {
      return 'Offline ($waitingCount waiting, staleness warning)';
    }

    return 'Offline, $waitingCount waiting';
  }

  /// Check if user has pending items before sign-out (Test 17.6)
  bool hasPendingItems(String analystId) {
    return _localQueue.any((i) =>
        i.analystId == analystId &&
        (i.status == OutboxItemStatus.waitingToSend ||
            i.status == OutboxItemStatus.late ||
            i.status == OutboxItemStatus.needsAttention));
  }

  /// Replay and synchronize outbox queue in strict FIFO order (Test 17.2, 17.3, 17.4, 17.5)
  Future<List<OutboxItem>> syncQueue({bool isOnline = true}) async {
    if (!isOnline || _isSyncing) return _localQueue;
    _isSyncing = true;

    try {
      for (int i = 0; i < _localQueue.length; i++) {
        var item = _localQueue[i];
        if (item.status == OutboxItemStatus.sent) continue;

        // Check staleness (Test 17.3)
        final isLate = item.isLate73h;
        final isFlaggedLate = isLate || item.isFlaggedLate;

        // Mark as syncing
        _localQueue[i] = item.copyWith(
          status: isLate ? OutboxItemStatus.late : OutboxItemStatus.syncing,
          isFlaggedLate: isFlaggedLate,
          attempts: item.attempts + 1,
        );

        try {
          final syncedItem = await _processItem(_localQueue[i]);
          _localQueue[i] = syncedItem;
        } catch (e) {
          _localQueue[i] = _localQueue[i].copyWith(
            status: OutboxItemStatus.failed,
            errorMessage: e.toString(),
          );
        }
      }
    } finally {
      _isSyncing = false;
    }

    return _localQueue;
  }

  Future<OutboxItem> _processItem(OutboxItem item) async {
    // 1. Check if a party was blocked while offline (Test 17.4)
    if (item.type == OutboxItemType.moistureControl) {
      final sellerTcda = item.payload['sellerTcda'] as String?;
      final buyerTcda = item.payload['buyerTcda'] as String?;

      if (sellerTcda != null && sellerTcda.isNotEmpty) {
        final sellerValidation = await _checkPartyBlock(sellerTcda);
        if (sellerValidation != null) {
          return item.copyWith(
            status: OutboxItemStatus.needsAttention,
            errorMessage: 'Party blocked while offline: $sellerValidation',
          );
        }
      }

      if (buyerTcda != null && buyerTcda.isNotEmpty) {
        final buyerValidation = await _checkPartyBlock(buyerTcda);
        if (buyerValidation != null) {
          return item.copyWith(
            status: OutboxItemStatus.needsAttention,
            errorMessage: 'Party blocked while offline: $buyerValidation',
          );
        }
      }
    }

    // 2. Check for Bag Allocation Conflict (Test 17.5)
    if (item.type == OutboxItemType.arrivalCutting || item.type == OutboxItemType.weighingSlip) {
      final requestedBags = item.payload['bagCount'] as int? ?? 0;
      final lotCode = item.payload['lotCode'] as String? ?? '';

      if (requestedBags > 0 && lotCode.isNotEmpty) {
        final conflict = await _checkBagConflict(lotCode, requestedBags);
        if (conflict != null) {
          return item.copyWith(
            status: OutboxItemStatus.conflict,
            conflictDetails: conflict,
            errorMessage: 'Allocation conflict: bags already taken by another device',
          );
        }
      }
    }

    // 3. Perform idempotent server write (Test 17.2)
    final collectionName = switch (item.type) {
      OutboxItemType.moistureControl => 'moisture_passes',
      OutboxItemType.weighingSlip => 'weight_records',
      OutboxItemType.plantReport => 'plant_reports',
      OutboxItemType.arrivalCutting => 'arrival_cuttings',
      OutboxItemType.storageChecklist => 'facility_audits',
    };

    final serverDocRef = firestore.collection(collectionName).doc(item.id);
    await serverDocRef.set({
      ...item.payload,
      'outboxId': item.id,
      'syncedAt': DateTime.now().toIso8601String(),
      'isLateSync': item.isFlaggedLate,
      'offlineAgeHours': item.age.inHours,
    }, SetOptions(merge: true));

    // If item was late (>73h), write alert to Secretariat (Test 17.3)
    if (item.isFlaggedLate) {
      await firestore.collection('audit_events').add({
        'action': 'STALE_OUTBOX_SYNC_ALERT',
        'outboxId': item.id,
        'type': item.type.name,
        'analystId': item.analystId,
        'offlineAgeHours': item.age.inHours,
        'flag': 'LATE',
        'timestamp': DateTime.now().toIso8601String(),
      });
    }

    return item.copyWith(
      status: OutboxItemStatus.sent,
      serverRecordId: item.id,
    );
  }

  Future<String?> _checkPartyBlock(String licenceNumber) async {
    try {
      final party = await tcdaService.checkLicence(licenceNumber);
      if (party != null && (party.effectiveState == TcdaLicenceState.blocked || party.effectiveState == TcdaLicenceState.expired)) {
        return 'Party with licence $licenceNumber is ${party.effectiveState.name.toUpperCase()}. Secretariat approval or renewal required.';
      }
    } catch (_) {}
    return null;
  }

  Future<String?> _checkBagConflict(String lotCode, int requestedBags) async {
    try {
      final doc = await firestore.collection('lots').doc(lotCode).get();
      if (doc.exists) {
        final remainingBags = doc.data()?['remainingBags'] as int? ?? 1000;
        if (requestedBags > remainingBags) {
          return 'Requested $requestedBags bags, but only $remainingBags remain for Lot $lotCode.';
        }
      }
    } catch (_) {}
    return null;
  }
}
