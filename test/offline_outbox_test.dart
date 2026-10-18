import 'package:flutter_test/flutter_test.dart';
import 'package:cqaag_app/models/outbox/outbox_item.dart';
import 'package:cqaag_app/services/outbox/offline_outbox_service.dart';

void main() {
  group('Step 17: Shared Offline Outbox Layer (Tests 17.1 - 17.7)', () {
    late OfflineOutboxService outboxService;

    setUp(() {
      outboxService = OfflineOutboxService();
    });

    test('Test 17.1: Airplane mode: 3 offline checks are queued as WAITING TO SEND and status chip says "Offline, 3 waiting"', () async {
      await outboxService.enqueue(
        type: OutboxItemType.moistureControl,
        payload: {'lotCode': 'CQAAG-L-261018-0001', 'moisture': 9.4},
        analystId: 'analyst-01',
      );

      await outboxService.enqueue(
        type: OutboxItemType.weighingSlip,
        payload: {'lotCode': 'CQAAG-L-261018-0001', 'weight': 27512},
        analystId: 'analyst-01',
      );

      await outboxService.enqueue(
        type: OutboxItemType.plantReport,
        payload: {'district': 'Wenchi', 'condition': 'Healthy'},
        analystId: 'analyst-01',
      );

      expect(outboxService.waitingCount, 3);
      expect(outboxService.getStatusChipText(isOnline: false), 'Offline, 3 waiting');
      expect(outboxService.items.length, 3);
      for (final item in outboxService.items) {
        expect(item.status, OutboxItemStatus.waitingToSend);
      }
    });

    test('Test 17.3: Item aged 49 hours shows amber note; aged 73 hours is LATE with stale alert', () async {
      final now = DateTime.now();

      // Fresh item (1 hour old)
      final freshItem = OutboxItem(
        id: 'fresh-1',
        type: OutboxItemType.moistureControl,
        payload: {},
        createdAt: now.subtract(const Duration(hours: 1)),
        analystId: 'analyst-01',
      );
      expect(freshItem.isStaleAmber, isFalse);
      expect(freshItem.isLate73h, isFalse);

      // Amber item (50 hours old: >= 49h and < 73h)
      final amberItem = OutboxItem(
        id: 'amber-1',
        type: OutboxItemType.moistureControl,
        payload: {},
        createdAt: now.subtract(const Duration(hours: 50)),
        analystId: 'analyst-01',
      );
      expect(amberItem.isStaleAmber, isTrue);
      expect(amberItem.isLate73h, isFalse);

      // Late item (74 hours old: >= 73h)
      final lateItem = OutboxItem(
        id: 'late-1',
        type: OutboxItemType.moistureControl,
        payload: {},
        createdAt: now.subtract(const Duration(hours: 74)),
        analystId: 'analyst-01',
      );
      expect(lateItem.isLate73h, isTrue);

      // Test chip text with late item
      await outboxService.enqueue(
        type: OutboxItemType.moistureControl,
        payload: {},
        analystId: 'analyst-01',
        customTimestamp: now.subtract(const Duration(hours: 75)),
      );
      expect(outboxService.getStatusChipText(isOnline: false), 'Stale Outbox (>3 days un-synced)');
    });

    test('Test 17.6: hasPendingItems warns analyst before signout with items waiting', () async {
      expect(outboxService.hasPendingItems('analyst-99'), isFalse);

      await outboxService.enqueue(
        type: OutboxItemType.moistureControl,
        payload: {},
        analystId: 'analyst-99',
      );

      expect(outboxService.hasPendingItems('analyst-99'), isTrue);
      expect(outboxService.hasPendingItems('analyst-other'), isFalse);
    });
  });
}
