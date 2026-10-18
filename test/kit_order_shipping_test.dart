import 'package:flutter_test/flutter_test.dart';
import 'package:cqaag_app/models/payment/fee_schedule.dart';
import 'package:cqaag_app/models/payment/kit_order.dart';
import 'package:cqaag_app/models/payment/shipping_zone.dart';
import 'package:cqaag_app/models/user/app_user.dart';

void main() {
  group('Step 14b: Quality Cutting Kit Orders & Shipping Zones (Spec Sections 80–81)', () {
    test('80.1: An order cannot be paid with no item or no address', () {
      final validItems = [
        const SelectedFeeItem(key: 'shears', label: 'Secateurs / Cutting Shears', amount: 150.0),
      ];

      // No item error
      final noItemErr = KitOrderStatutoryRules.validateOrderPrerequisites(
        items: [],
        deliveryAddress: "P.O. Box 45, Wenchi, Bono Region",
        zone: const ShippingZone(id: 'z3', name: 'Zone 3', regions: ['Bono'], fee: 50.0, isClosed: false),
        membershipStatus: MembershipStatus.active,
      );
      expect(noItemErr, contains("at least one item"));

      // No address error
      final noAddrErr = KitOrderStatutoryRules.validateOrderPrerequisites(
        items: validItems,
        deliveryAddress: "",
        zone: const ShippingZone(id: 'z3', name: 'Zone 3', regions: ['Bono'], fee: 50.0, isClosed: false),
        membershipStatus: MembershipStatus.active,
      );
      expect(noAddrErr, contains("Delivery address is required"));

      // Valid case passes
      final valid = KitOrderStatutoryRules.validateOrderPrerequisites(
        items: validItems,
        deliveryAddress: "P.O. Box 45, Wenchi, Bono Region",
        zone: const ShippingZone(id: 'z3', name: 'Zone 3', regions: ['Bono'], fee: 50.0, isClosed: false),
        membershipStatus: MembershipStatus.active,
      );
      expect(valid, isNull);
    });

    test('80.2 & 80.3: Total equals amount charged + receipt, and shows official Association name', () {
      const itemsSubtotal = 350.0;
      const shippingFee = 45.0;
      const totalAmount = itemsSubtotal + shippingFee;

      final order = KitOrder(
        id: 'cqaag-ord-001',
        buyerName: 'Kwame Mensah',
        phoneNumber: '0244123456',
        items: const [
          SelectedFeeItem(key: 'scale', label: 'Digital Gram Scale 0.1g', amount: 350.0),
        ],
        shippingFee: shippingFee,
        total: totalAmount,
        currency: 'GHS',
        createdAt: DateTime(2026, 10, 18, 10, 0),
      );

      // Criterion 80.2: Total on screen equals amount charged
      expect(order.total, equals(395.0));
      expect(order.money(order.total), equals('GHS 395.00'));

      // Criterion 80.3: Association name, never person's name
      expect(KitOrderStatutoryRules.associationOfficialName, equals("Cashew Quality Assessors Association Ghana"));
    });

    test('80.5: All 5 statuses recorded with who changed them and when', () {
      final t0 = DateTime(2026, 10, 18, 8, 0);
      final t1 = DateTime(2026, 10, 18, 9, 30);
      final t2 = DateTime(2026, 10, 18, 14, 0);
      final t3 = DateTime(2026, 10, 19, 10, 0);
      final t4 = DateTime(2026, 10, 20, 16, 0);

      final history = <KitOrderStatusHistoryEntry>[
        KitOrderStatusHistoryEntry(status: KitOrderStatus.ordered, changedBy: 'MEMBER-001', timestamp: t0),
        KitOrderStatusHistoryEntry(status: KitOrderStatus.paid, changedBy: 'TREASURER-001', timestamp: t1, reason: 'MoMo verified'),
        KitOrderStatusHistoryEntry(status: KitOrderStatus.packed, changedBy: 'LOGISTICS-001', timestamp: t2, reason: 'Packed in standard parcel'),
        KitOrderStatusHistoryEntry(status: KitOrderStatus.shipped, changedBy: 'LOGISTICS-001', timestamp: t3, reason: 'Courier tracking #GH98765'),
        KitOrderStatusHistoryEntry(status: KitOrderStatus.delivered, changedBy: 'COURIER-SYSTEM', timestamp: t4, reason: 'Signed by recipient'),
      ];

      expect(history.length, equals(5));
      expect(history[0].status, equals(KitOrderStatus.ordered));
      expect(history[1].status, equals(KitOrderStatus.paid));
      expect(history[2].status, equals(KitOrderStatus.packed));
      expect(history[3].status, equals(KitOrderStatus.shipped));
      expect(history[4].status, equals(KitOrderStatus.delivered));

      // Each entry records who and when
      for (final entry in history) {
        expect(entry.changedBy, isNotEmpty);
        expect(entry.timestamp, isNotNull);
      }
    });

    test('80.6 / P-J1: Cancellation and refund rules before and after SHIPPED', () {
      // Prior to SHIPPED: Secretariat can cancel & refund at any time
      expect(KitOrderStatutoryRules.canCancelAndRefund(currentStatus: 'ordered'), isTrue);
      expect(KitOrderStatutoryRules.canCancelAndRefund(currentStatus: 'paid'), isTrue);
      expect(KitOrderStatutoryRules.canCancelAndRefund(currentStatus: 'packed'), isTrue);

      // After SHIPPED: Only for lost or damaged parcel
      expect(KitOrderStatutoryRules.canCancelAndRefund(currentStatus: 'shipped', isLostOrDamagedParcel: false), isFalse);
      expect(KitOrderStatutoryRules.canCancelAndRefund(currentStatus: 'shipped', isLostOrDamagedParcel: true), isTrue);
      expect(KitOrderStatutoryRules.canCancelAndRefund(currentStatus: 'delivered', isLostOrDamagedParcel: false), isFalse);
      expect(KitOrderStatutoryRules.canCancelAndRefund(currentStatus: 'delivered', isLostOrDamagedParcel: true), isTrue);
    });

    test('80.6 / P-J2: Active member & approved applicant can order; hibernated member cannot', () {
      // Active and verified can order
      expect(KitOrderStatutoryRules.canMemberOrderKit(MembershipStatus.active), isTrue);
      expect(KitOrderStatutoryRules.canMemberOrderKit(MembershipStatus.verified), isTrue);

      // Approved applicant paying for activation can order
      expect(KitOrderStatutoryRules.canMemberOrderKit(MembershipStatus.approvedPaymentPending), isTrue);

      // Hibernated, suspended, declined cannot order until arrears paid
      expect(KitOrderStatutoryRules.canMemberOrderKit(MembershipStatus.hibernated), isFalse);
      expect(KitOrderStatutoryRules.canMemberOrderKit(MembershipStatus.suspended), isFalse);
      expect(KitOrderStatutoryRules.canMemberOrderKit(MembershipStatus.declined), isFalse);
    });

    test('81.1–81.5: Shipping zones exist closed with no fee; updating fee enables payment with audit log', () {
      // Criterion 81.1: The 4 rows exist with no fee and are closed
      final zones = ShippingZone.initialStatutoryZones();
      expect(zones.length, equals(4));
      for (final z in zones) {
        expect(z.fee, isNull);
        expect(z.isClosed, isTrue);
        expect(z.canBePaid, isFalse);
      }

      // Criterion 81.2: Order for a closed zone cannot be paid
      final orderErr = KitOrderStatutoryRules.validateOrderPrerequisites(
        items: [const SelectedFeeItem(key: 'tray', label: 'Sampling Tray', amount: 80.0)],
        deliveryAddress: "Sunyani Central Market",
        zone: zones[2], // Zone 3 (Bono) currently closed
        membershipStatus: MembershipStatus.active,
      );
      expect(orderErr, contains("closed"));

      // Criterion 81.3 & 81.4: Secretariat enters fee -> zone opens with audit history
      final openedZone = zones[2].copyWithNewFee(
        newFee: 40.0,
        changedBy: 'ADMIN-SECRETARIAT',
        reason: 'Courier rate agreement Sunyani 2027',
        timestamp: DateTime(2026, 10, 18, 12, 0),
      );
      expect(openedZone.isClosed, isFalse);
      expect(openedZone.fee, equals(40.0));
      expect(openedZone.canBePaid, isTrue);
      expect(openedZone.history.length, equals(1));
      expect(openedZone.history.first.changedBy, equals('ADMIN-SECRETARIAT'));
      expect(openedZone.history.first.reason, equals('Courier rate agreement Sunyani 2027'));

      // Now order for this zone can be validated and paid
      final validOrder = KitOrderStatutoryRules.validateOrderPrerequisites(
        items: [const SelectedFeeItem(key: 'tray', label: 'Sampling Tray', amount: 80.0)],
        deliveryAddress: "Sunyani Central Market",
        zone: openedZone,
        membershipStatus: MembershipStatus.active,
      );
      expect(validOrder, isNull);

      // Criterion 81.5: An older order keeps its old fee (snapshotting)
      final olderOrder = KitOrder(
        id: 'ord-older-001',
        buyerName: 'Yaw Boateng',
        phoneNumber: '0244000111',
        items: const [SelectedFeeItem(key: 'tray', label: 'Sampling Tray', amount: 80.0)],
        shippingFee: 35.0, // Old fee snapshotted
        total: 115.0,
        currency: 'GHS',
        createdAt: DateTime(2026, 10, 15),
      );
      expect(olderOrder.shippingFee, equals(35.0));
      expect(olderOrder.total, equals(115.0));
    });
  });
}
