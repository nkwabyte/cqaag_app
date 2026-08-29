import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:cqaag_app/models/payment/payment_settings.dart';

part 'payment_settings_service.g.dart';

/// Reads and writes `settings/payment`, the registration fee and Mobile Money
/// account shared between this app and the CQAAG website.
class PaymentSettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PaymentSettingsService();

  DocumentReference<Map<String, dynamic>> get _settingsDoc => _firestore.collection('settings').doc('payment');

  /// Live payment settings.
  ///
  /// Falls back to [PaymentSettings.defaults] when the document is missing or
  /// unreadable, so the payment screen never renders a blank fee.
  Stream<PaymentSettings> streamSettings() async* {
    // Yield cached or default settings immediately so paymentSettingsProvider never hangs
    PaymentSettings initial;
    try {
      initial = await getSettings();
    } catch (_) {
      initial = PaymentSettings.defaults;
    }
    yield initial;

    // Stream live updates from Firestore
    await for (final snap in _settingsDoc.snapshots().handleError((Object error) {
      // Quietly fall back to defaults if unauthenticated or permissions denied
    })) {
      yield _fromSnapshot(snap);
    }
  }

  /// One-off read, used where a stream would be overkill.
  Future<PaymentSettings> getSettings() async {
    try {
      return _fromSnapshot(await _settingsDoc.get());
    } catch (e) {
      return PaymentSettings.defaults;
    }
  }

  PaymentSettings _fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data();
    if (!snap.exists || data == null) return PaymentSettings.defaults;

    try {
      return PaymentSettings.fromJson(_normalise(data));
    } catch (e) {
      debugPrint('Malformed payment settings, using defaults: $e');
      return PaymentSettings.defaults;
    }
  }

  /// Firestore stores numbers as int or double and timestamps as [Timestamp],
  /// neither of which the generated `fromJson` accepts directly.
  Map<String, dynamic> _normalise(Map<String, dynamic> data) {
    final out = Map<String, dynamic>.from(data);

    final fee = out['registration_fee'];
    if (fee is num) out['registration_fee'] = fee.toDouble();

    final foreignFee = out['foreign_registration_fee'];
    if (foreignFee is num) out['foreign_registration_fee'] = foreignFee.toDouble();

    final updatedAt = out['updated_at'];
    if (updatedAt is Timestamp) {
      out['updated_at'] = updatedAt.toDate().toIso8601String();
    }

    return out;
  }

  /// Persists the fee and MoMo account. Admin only, enforced by Firestore rules.
  Future<void> updateSettings({
    required double registrationFee,
    double foreignRegistrationFee = 1500.0,
    required MomoNetwork momoNetwork,
    required String momoNumber,
    required String momoAccountName,
    required String updatedBy,
  }) async {
    await _settingsDoc.set({
      'registration_fee': registrationFee,
      'foreign_registration_fee': foreignRegistrationFee,
      'currency': 'GHS',
      'momo_network': momoNetwork.value,
      'momo_number': momoNumber,
      'momo_account_name': momoAccountName,
      'updated_at': DateTime.now().toIso8601String(),
      'updated_by': updatedBy,
    }, SetOptions(merge: true));
  }
}

/// Provider for [PaymentSettingsService].
@Riverpod(keepAlive: true)
PaymentSettingsService paymentSettingsService(Ref ref) {
  return PaymentSettingsService();
}

/// Live payment settings for any screen that needs the fee or MoMo account.
@Riverpod(keepAlive: true)
Stream<PaymentSettings> paymentSettings(Ref ref) {
  return ref.watch(paymentSettingsServiceProvider).streamSettings();
}
