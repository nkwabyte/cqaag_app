import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cqaag_app/models/membership/membership_category.dart';

part 'payment_settings.freezed.dart';
part 'payment_settings.g.dart';

/// Mobile Money networks the association can collect registration fees on.
enum MomoNetwork {
  @JsonValue('MTN')
  mtn,

  @JsonValue('TELECEL')
  telecel,

  @JsonValue('AIRTELTIGO')
  airtelTigo;

  /// Value stored in Firestore, shared with the website.
  String get value => switch (this) {
    MomoNetwork.mtn => 'MTN',
    MomoNetwork.telecel => 'TELECEL',
    MomoNetwork.airtelTigo => 'AIRTELTIGO',
  };

  /// Human readable label for display.
  String get label => switch (this) {
    MomoNetwork.mtn => 'MTN',
    MomoNetwork.telecel => 'TELECEL',
    MomoNetwork.airtelTigo => 'AirtelTigo',
  };

  static MomoNetwork fromValue(String? value) {
    return MomoNetwork.values.firstWhere(
      (n) => n.value.toUpperCase() == (value ?? '').toUpperCase(),
      orElse: () => MomoNetwork.mtn,
    );
  }
}

/// How an applicant paid their registration fee.
enum PaymentMethod {
  @JsonValue('momo')
  momo,

  @JsonValue('paystack')
  paystack;

  String get value => name;

  String get label => switch (this) {
    PaymentMethod.momo => 'Mobile Money',
    PaymentMethod.paystack => 'Paystack',
  };
}

/// Verification state of an applicant's registration payment.
enum PaymentStatus {
  @JsonValue('unpaid')
  unpaid,

  @JsonValue('pending_verification')
  pendingVerification,

  @JsonValue('verified')
  verified,

  @JsonValue('rejected')
  rejected;

  String get value => switch (this) {
    PaymentStatus.unpaid => 'unpaid',
    PaymentStatus.pendingVerification => 'pending_verification',
    PaymentStatus.verified => 'verified',
    PaymentStatus.rejected => 'rejected',
  };

  String get label => switch (this) {
    PaymentStatus.unpaid => 'Unpaid',
    PaymentStatus.pendingVerification => 'Awaiting verification',
    PaymentStatus.verified => 'Verified',
    PaymentStatus.rejected => 'Rejected',
  };

  static PaymentStatus fromValue(String? value) {
    return PaymentStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => PaymentStatus.unpaid,
    );
  }
}

/// Registration fee and Mobile Money account, stored at `settings/payment`.
///
/// This single document is shared with the CQAAG website, so both clients show
/// the same fee and pay-in account. Only an admin can write it.
@freezed
abstract class PaymentSettings with _$PaymentSettings {
  const PaymentSettings._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory PaymentSettings({
    /// Registration fee amount (Ghanaian / Standard).
    @Default(500.0) double registrationFee,

    /// Registration fee amount for Foreign QC members.
    @Default(1500.0) double foreignRegistrationFee,

    /// ISO currency code. Ghana Cedis unless changed.
    @Default('GHS') String currency,

    /// Mobile Money number applicants send the fee to.
    @Default('+233 55 333 0931') String momoNumber,

    /// Network the MoMo number belongs to.
    @Default('MTN') String momoNetwork,

    /// Name registered on the MoMo account, so applicants can confirm it.
    @Default('Amoafo Ebenezer') String momoAccountName,

    /// When the settings were last changed.
    DateTime? updatedAt,

    /// UID of the admin who last changed them.
    String? updatedBy,
  }) = _PaymentSettings;

  factory PaymentSettings.fromJson(Map<String, dynamic> json) => _$PaymentSettingsFromJson(json);

  /// Defaults used when `settings/payment` does not exist yet, so a fresh
  /// project still shows a sensible fee and account.
  static const PaymentSettings defaults = PaymentSettings();

  MomoNetwork get network => MomoNetwork.fromValue(momoNetwork);

  /// Fee formatted for display, e.g. `GHS 500.00`.
  String get formattedFee => '$currency ${registrationFee.toStringAsFixed(2)}';

  /// Fee for a specific membership category
  double feeForCategory(MembershipCategory? category) {
    if (category == MembershipCategory.fullForeign) {
      return foreignRegistrationFee;
    }
    return registrationFee;
  }

  /// Formatted fee for a specific membership category
  String formattedFeeFor(MembershipCategory? category) {
    return '$currency ${(feeForCategory(category)).toStringAsFixed(2)}';
  }
}
