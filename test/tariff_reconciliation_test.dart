import 'package:flutter_test/flutter_test.dart';
import 'package:cqaag_app/models/tariff/tariff_approval.dart';
import 'package:cqaag_app/services/tariff/tariff_approval_service.dart';

void main() {
  group('Phase 4: Step 18 - Statutory Tariff 2-Person Approval & Daily Reconciliation', () {
    late TariffApprovalService service;

    setUp(() {
      service = TariffApprovalService();
    });

    test('Test 18.1: Change request is WAITING, old tariff applies until approved and effective date reached', () {
      final now = DateTime(2026, 10, 15);
      final effectiveTomorrow = DateTime(2026, 10, 16);

      // 1. Admin creates tariff change request
      final request = service.createChangeRequest(
        id: 'req_001',
        itemKey: 'export_certificate',
        itemName: 'Export Quality Certificate',
        currentAmountGhs: 500.0,
        proposedAmountGhs: 550.0,
        effectiveDate: effectiveTomorrow,
        reason: 'Board Resolution 2026/04',
        initiatorUserId: 'user_admin',
        initiatorRole: 'Admin',
      );

      expect(request.status, equals(TariffApprovalStatus.waitingApproval));
      expect(request.notifiedRoles, contains('President'));
      expect(request.notifiedRoles, contains('GeneralSecretary'));

      // While waiting for approval, old tariff still applies
      final tariffWhileWaiting = service.getEffectiveTariff(
        activeRequest: request,
        fallbackCurrentAmountGhs: 500.0,
        checkDate: now,
      );
      expect(tariffWhileWaiting, equals(500.0));

      // 2. Treasurer approves request
      final approvedRequest = service.approveChangeRequest(
        request: request,
        approverUserId: 'user_treasurer',
        approverRole: 'Treasurer',
        approvedAt: now,
      );
      expect(approvedRequest.status, equals(TariffApprovalStatus.approved));

      // Before effective date, still old tariff
      final tariffBeforeEffective = service.getEffectiveTariff(
        activeRequest: approvedRequest,
        fallbackCurrentAmountGhs: 500.0,
        checkDate: now,
      );
      expect(tariffBeforeEffective, equals(500.0));

      // At or after effective date, new tariff starts
      final tariffAfterEffective = service.getEffectiveTariff(
        activeRequest: approvedRequest,
        fallbackCurrentAmountGhs: 500.0,
        checkDate: effectiveTomorrow,
      );
      expect(tariffAfterEffective, equals(550.0));
    });

    test('Test 18.2: Initiator cannot approve their own tariff change request', () {
      final request = service.createChangeRequest(
        id: 'req_002',
        itemKey: 'moisture_pass',
        itemName: 'Moisture Control Pass',
        currentAmountGhs: 100.0,
        proposedAmountGhs: 120.0,
        effectiveDate: DateTime(2026, 11, 1),
        reason: 'Annual adjustment',
        initiatorUserId: 'user_admin_01',
        initiatorRole: 'Admin',
      );

      // Same user attempts to approve
      expect(
        () => service.approveChangeRequest(
          request: request,
          approverUserId: 'user_admin_01',
          approverRole: 'Treasurer',
        ),
        throwsA(isA<TariffApprovalException>().having(
          (e) => e.code,
          'code',
          'SELF_APPROVAL_FORBIDDEN',
        )),
      );
    });

    test('Test 18.3: Reminder after 2 days and lapses after 7 days', () {
      final created = DateTime(2026, 10, 10);
      final request = TariffChangeRequest(
        id: 'req_003',
        itemKey: 'dispatch_certificate',
        itemName: 'Dispatch Certificate',
        oldAmountGhs: 100.0,
        newAmountGhs: 150.0,
        effectiveDate: DateTime(2026, 11, 1),
        reason: 'Fuel surcharge',
        initiatorUserId: 'user_admin',
        initiatorRole: 'Admin',
        status: TariffApprovalStatus.waitingApproval,
        createdAt: created,
      );

      // Check after 3 days -> reminder triggered
      final withReminder = service.evaluateLapseAndReminders(
        request: request,
        currentDate: created.add(const Duration(days: 3)),
      );
      expect(withReminder.reminderSentAt, isNotNull);
      expect(withReminder.status, equals(TariffApprovalStatus.waitingApproval));

      // Check after 8 days -> lapsed
      final lapsed = service.evaluateLapseAndReminders(
        request: withReminder,
        currentDate: created.add(const Duration(days: 8)),
      );
      expect(lapsed.status, equals(TariffApprovalStatus.lapsed));
      expect(lapsed.lapsedAt, isNotNull);
    });

    test('Test 18.4: Hand refund waits for Treasurer and marks receipt refunded', () {
      final refundReq = HandRefundRequest(
        id: 'ref_001',
        receiptOrPassNumber: 'CQAAG-P-261012-0007',
        amountGhs: 100.0,
        reason: 'Duplicate payment on mobile network',
        initiatorUserId: 'user_analyst',
        createdAt: DateTime.now(),
      );

      expect(refundReq.isApproved, isFalse);
      expect(refundReq.isRefunded, isFalse);

      // Non-treasurer cannot approve
      expect(
        () => service.approveHandRefund(
          request: refundReq,
          approverUserId: 'user_clerk',
          approverRole: 'Clerk',
        ),
        throwsA(isA<TariffApprovalException>().having(
          (e) => e.code,
          'code',
          'TREASURER_APPROVAL_REQUIRED',
        )),
      );

      // Treasurer approves
      final approvedRefund = service.approveHandRefund(
        request: refundReq,
        approverUserId: 'user_treasurer',
        approverRole: 'Treasurer',
      );

      expect(approvedRefund.isApproved, isTrue);
      expect(approvedRefund.isRefunded, isTrue);
    });

    test('Test 18.8 & 18.9: Daily reconciliation handles missed app payment and missing gateway payment', () {
      // 18.8: Gateway confirmed and payment intent open, but app missed confirmation
      // Completed by server run, not logged in exceptions
      final missedAppRecon = service.reconcileTransaction(
        transactionId: 'TXN-99881',
        appRecorded: false,
        gatewayConfirmed: true,
        paymentIntentOpen: true,
        amountGhs: 100.0,
      );
      expect(missedAppRecon['action'], equals('SERVER_COMPLETED'));
      expect(missedAppRecon['isException'], isFalse);
      expect(missedAppRecon['receiptGenerated'], isTrue);

      // 18.9: App recorded payment not found in gateway
      // Logged as an exception; the Pass is NOT cancelled
      final missingGatewayRecon = service.reconcileTransaction(
        transactionId: 'TXN-77441',
        appRecorded: true,
        gatewayConfirmed: false,
        paymentIntentOpen: false,
        amountGhs: 100.0,
      );
      expect(missingGatewayRecon['action'], equals('GATEWAY_MISSING_EXCEPTION'));
      expect(missingGatewayRecon['isException'], isTrue);
      expect(missingGatewayRecon['passCancelled'], isFalse);
    });

    test('Test 18.11: Month-end dues summary calculates 60 / 40 split and bank difference', () {
      // 100 members @ GHS 320 = GHS 32,000.00 collected
      // National split (60%) = GHS 19,200.00
      // Chapter split (40%) = GHS 12,800.00
      // Bank statement deposited: GHS 31,950.00 -> difference -50.00 GHS
      final summary = service.computeMonthEndDues(
        totalCollectedGhs: 32000.0,
        bankReportedGhs: 31950.0,
      );

      expect(summary.nationalSplitGhs, equals(19200.0));
      expect(summary.chapterSplitGhs, equals(12800.0));
      expect(summary.differenceGhs, equals(-50.0));
    });
  });
}
