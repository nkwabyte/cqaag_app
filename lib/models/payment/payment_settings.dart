import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cqaag_app/models/membership/membership_category.dart';
import 'package:cqaag_app/models/payment/fee_schedule.dart';

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
    /// Legacy flat registration fee, kept so records and clients written
    /// before the fee schedule existed still read a sensible number.
    /// New quotes come from [schedule] instead.
    @Default(250.0) double registrationFee,

    /// Legacy flat registration fee for foreign applicants. Under the schedule
    /// the Registration Fee is the same for every fee-paying category; only the
    /// Annual Dues differ.
    @Default(250.0) double foreignRegistrationFee,

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

    /// The full Membership Categories, Fees & Dues Schedule.
    ///
    /// Null on projects that have not saved a schedule yet, in which case
    /// [schedule] falls back to the Board-approved defaults.
    FeeSchedule? feeSchedule,
  }) = _PaymentSettings;

  factory PaymentSettings.fromJson(Map<String, dynamic> json) => _$PaymentSettingsFromJson(json);

  /// Defaults used when `settings/payment` does not exist yet, so a fresh
  /// project still shows a sensible fee and account.
  static const PaymentSettings defaults = PaymentSettings();

  MomoNetwork get network => MomoNetwork.fromValue(momoNetwork);

  /// The fee schedule in force, falling back to the Board-approved defaults.
  FeeSchedule get schedule => feeSchedule ?? FeeSchedule.defaults;

  /// Formats an amount in the configured currency, e.g. `GHS 520.00`.
  String money(double amount) => '$currency ${amount.toStringAsFixed(2)}';

  /// Fee formatted for display, e.g. `GHS 250.00`.
  String get formattedFee => money(registrationFee);

  /// Registration Fee for a membership category, per the fee schedule.
  double feeForCategory(MembershipCategory? category) {
    return schedule.registrationFeeFor(FeeCategory.fromMembership(category));
  }

  /// Formatted Registration Fee for a specific membership category.
  String formattedFeeFor(MembershipCategory? category) {
    return money(feeForCategory(category));
  }

  /// What a category owes before choosing any optional kit items:
  /// Registration Fee + Annual Dues.
  double mandatoryTotalFor(MembershipCategory? category) {
    return schedule.mandatoryTotalFor(FeeCategory.fromMembership(category));
  }

  /// Prices one applicant's choices against the schedule in force.
  FeeQuote quoteFor(
    MembershipCategory? category, {
    List<SelectedFeeItem> selectedOptionalItems = const [],
  }) {
    return schedule.quote(
      FeeCategory.fromMembership(category),
      selectedOptionalItems: selectedOptionalItems,
    );
  }
}
