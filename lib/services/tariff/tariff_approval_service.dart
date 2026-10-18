import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cqaag_app/models/tariff/tariff_approval.dart';

class TariffApprovalException implements Exception {
  final String message;
  final String? code;
  TariffApprovalException(this.message, {this.code});
  @override
  String toString() => message;
}

/// Service implementing Statutory Tariff Two-Person Approval and Daily Reconciliation
/// (Spec Section 88.4 & 89.3 / Tests 18.1 - 18.11)
class TariffApprovalService {
  final FirebaseFirestore? _firestore;

  TariffApprovalService({FirebaseFirestore? firestore}) : _firestore = firestore;

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get tariffRequestsRef =>
      firestore.collection('tariff_change_requests');
  CollectionReference<Map<String, dynamic>> get refundsRef =>
      firestore.collection('hand_refund_requests');

  /// 1. Submits a new tariff change request (Test 18.1)
  TariffChangeRequest createChangeRequest({
    required String id,
    required String itemKey,
    required String itemName,
    required double currentAmountGhs,
    required double proposedAmountGhs,
    required DateTime effectiveDate,
    required String reason,
    required String initiatorUserId,
    required String initiatorRole,
  }) {
    if (reason.trim().isEmpty) {
      throw TariffApprovalException(
        'Reason for tariff modification is mandatory.',
        code: 'REASON_REQUIRED',
      );
    }

    if (proposedAmountGhs < 0) {
      throw TariffApprovalException(
        'Tariff amount cannot be negative.',
        code: 'NEGATIVE_TARIFF',
      );
    }

    // Creates request in waitingApproval state
    return TariffChangeRequest(
      id: id,
      itemKey: itemKey,
      itemName: itemName,
      oldAmountGhs: currentAmountGhs,
      newAmountGhs: proposedAmountGhs,
      effectiveDate: effectiveDate,
      reason: reason,
      initiatorUserId: initiatorUserId,
      initiatorRole: initiatorRole,
      status: TariffApprovalStatus.waitingApproval,
      createdAt: DateTime.now(),
      notifiedRoles: const ['President', 'GeneralSecretary'],
    );
  }

  /// 2. Approves tariff change with strict Two-Person rule (Test 18.2)
  TariffChangeRequest approveChangeRequest({
    required TariffChangeRequest request,
    required String approverUserId,
    required String approverRole,
    DateTime? approvedAt,
  }) {
    if (request.status != TariffApprovalStatus.waitingApproval) {
      throw TariffApprovalException(
        'Request is not waiting for approval (Current status: ${request.status.name}).',
        code: 'INVALID_STATUS',
      );
    }

    // Test 18.2: The initiator tries to approve his own request: refused.
    if (request.initiatorUserId == approverUserId) {
      throw TariffApprovalException(
        'Initiator cannot approve their own tariff change request. Two-person approval is mandatory.',
        code: 'SELF_APPROVAL_FORBIDDEN',
      );
    }

    // Only authorized roles (e.g., Treasurer or Super Admin) can approve
    final allowedRoles = ['Treasurer', 'SuperAdmin', 'Executive'];
    if (!allowedRoles.contains(approverRole)) {
      throw TariffApprovalException(
        'Role "$approverRole" is not authorized to approve statutory tariff modifications.',
        code: 'UNAUTHORIZED_ROLE',
      );
    }

    return request.copyWith(
      status: TariffApprovalStatus.approved,
      approvedByUserId: approverUserId,
      approvedByRole: approverRole,
      approvedAt: approvedAt ?? DateTime.now(),
    );
  }

  /// Returns the effective tariff rate depending on approval status and effective date (Test 18.1)
  double getEffectiveTariff({
    required TariffChangeRequest? activeRequest,
    required double fallbackCurrentAmountGhs,
    DateTime? checkDate,
  }) {
    if (activeRequest == null) return fallbackCurrentAmountGhs;

    // While waiting for approval, old tariff still applies (Test 18.1)
    if (activeRequest.status != TariffApprovalStatus.approved) {
      return activeRequest.oldAmountGhs;
    }

    // New tariff starts at the date set (Test 18.1)
    final now = checkDate ?? DateTime.now();
    if (now.isBefore(activeRequest.effectiveDate)) {
      return activeRequest.oldAmountGhs;
    }

    return activeRequest.newAmountGhs;
  }

  /// 3. Reminder & 7-Day Lapse Rule (Test 18.3)
  TariffChangeRequest evaluateLapseAndReminders({
    required TariffChangeRequest request,
    required DateTime currentDate,
  }) {
    if (request.status != TariffApprovalStatus.waitingApproval) {
      return request;
    }

    final duration = currentDate.difference(request.createdAt);

    // After 7 days it lapses and the initiator is told (Test 18.3)
    if (duration.inDays >= 7) {
      return request.copyWith(
        status: TariffApprovalStatus.lapsed,
        lapsedAt: currentDate,
      );
    }

    // A request not decided in 2 working days sends a reminder (Test 18.3)
    if (duration.inDays >= 2 && request.reminderSentAt == null) {
      return request.copyWith(
        reminderSentAt: currentDate,
      );
    }

    return request;
  }

  /// 4. Hand Refund Approval (Test 18.4 & 18.10)
  HandRefundRequest approveHandRefund({
    required HandRefundRequest request,
    required String approverUserId,
    required String approverRole,
  }) {
    if (approverRole != 'Treasurer' && approverRole != 'SuperAdmin') {
      throw TariffApprovalException(
        'A hand refund waits for the Treasurer to approve.',
        code: 'TREASURER_APPROVAL_REQUIRED',
      );
    }

    if (request.initiatorUserId == approverUserId) {
      throw TariffApprovalException(
        'Initiator cannot approve their own refund request.',
        code: 'SELF_REFUND_FORBIDDEN',
      );
    }

    return request.copyWith(
      isApproved: true,
      approvedByUserId: approverUserId,
      approvedAt: DateTime.now(),
      isRefunded: true,
    );
  }

  /// 5. Nightly Server Reconciliation (Test 18.8 & 18.9)
  Map<String, dynamic> reconcileTransaction({
    required String transactionId,
    required bool appRecorded,
    required bool gatewayConfirmed,
    required bool paymentIntentOpen,
    required double amountGhs,
  }) {
    // Test 18.8: App missed confirmation, but server payment request was open
    // Completed by the server; receipt made and seen in log, not in exceptions.
    if (!appRecorded && gatewayConfirmed && paymentIntentOpen) {
      return {
        'transactionId': transactionId,
        'action': 'SERVER_COMPLETED',
        'isException': false,
        'receiptGenerated': true,
        'amountGhs': amountGhs,
        'notes': 'Completed by server nightly run; confirmation missed by app.',
      };
    }

    // Test 18.9: Payment recorded in app that gateway does NOT have
    // Logged as an exception; the Pass is NOT cancelled.
    if (appRecorded && !gatewayConfirmed) {
      return {
        'transactionId': transactionId,
        'action': 'GATEWAY_MISSING_EXCEPTION',
        'isException': true,
        'passCancelled': false,
        'amountGhs': amountGhs,
        'notes': 'App recorded payment not found in gateway; logged for investigation without cancelling pass.',
      };
    }

    return {
      'transactionId': transactionId,
      'action': 'MATCHED',
      'isException': false,
      'receiptGenerated': false,
      'amountGhs': amountGhs,
      'notes': 'Payment fully reconciled between app and gateway.',
    };
  }

  /// 6. Month-End Dues Summary & 60 / 40 Split (Test 18.11)
  MonthEndDuesSummary computeMonthEndDues({
    required double totalCollectedGhs,
    required double bankReportedGhs,
  }) {
    return MonthEndDuesSummary(
      totalDuesCollectedGhs: totalCollectedGhs,
      bankReportedAmountGhs: bankReportedGhs,
    );
  }
}
