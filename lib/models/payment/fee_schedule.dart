import 'package:cqaag_app/models/membership/membership_category.dart';

/// A column of the CQAAG Membership Categories, Fees & Dues Schedule
/// (Constitution Art. 2, as amended).
///
/// The schedule prices every line item per category, so a single fee never
/// stands on its own — it is always read against one of these columns.
enum FeeCategory {
  /// Full Membership — indigenous (Ghanaian) cashew QC professionals.
  full('full', 'Full Membership'),

  /// Associate Members who are Ghanaian nationals (Art. 2.1(a)).
  nationalAssociate('national_associate', 'National Associate Members'),

  /// Associate Members who are not Ghanaian nationals (Art. 2.1(b)).
  foreignAssociate('foreign_associate', 'Foreign Associate Members'),

  /// Laboratories, processors and organizations supporting quality efforts.
  corporate('corporate', 'Corporate Members'),

  /// Distinguished individuals nominated by the Board. Pay no fees.
  honorary('honorary', 'Honorary Members');

  const FeeCategory(this.key, this.label);

  /// Key used in Firestore, shared with the website.
  final String key;

  /// Column heading as it appears in the fee schedule.
  final String label;

  static FeeCategory fromKey(String? key) {
    return FeeCategory.values.firstWhere(
      (c) => c.key == key,
      orElse: () => FeeCategory.full,
    );
  }

  /// The schedule column that applies to a membership category.
  static FeeCategory fromMembership(MembershipCategory? category) {
    return switch (category) {
      MembershipCategory.fullForeign => FeeCategory.foreignAssociate,
      MembershipCategory.associate => FeeCategory.nationalAssociate,
      MembershipCategory.corporate => FeeCategory.corporate,
      MembershipCategory.honorary => FeeCategory.honorary,
      _ => FeeCategory.full,
    };
  }

  /// Honorary Members pay no fees at all (Art. 2, Categories).
  bool get isExempt => this == FeeCategory.honorary;
}

/// One priced row of the fee schedule, with an amount per category column.
///
/// A `null` amount means the Board has not set a price for that category yet
/// (the yellow cells of the source schedule); a zero amount means the item is
/// not offered to that category. Neither is ever charged.
class FeeLineItem {
  const FeeLineItem({
    required this.key,
    required this.label,
    this.amounts = const {},
    this.requiresSize = false,
  });

  /// Stable identifier, e.g. `lacoste`, `safety_boot`.
  final String key;

  /// Human readable name shown to applicants and admins.
  final String label;

  /// Amount per [FeeCategory.key]. Missing or null entries are unpriced.
  final Map<String, double?> amounts;

  /// Whether the applicant must state a size when taking this item.
  final bool requiresSize;

  /// Price for [category], or null when the Board has not set one.
  double? amountFor(FeeCategory category) => amounts[category.key];

  /// Whether this item can actually be charged to [category].
  bool isAvailableTo(FeeCategory category) {
    if (category.isExempt) return false;
    final amount = amountFor(category);
    return amount != null && amount > 0;
  }

  FeeLineItem copyWithAmount(FeeCategory category, double? amount) {
    return FeeLineItem(
      key: key,
      label: label,
      amounts: {...amounts, category.key: amount},
      requiresSize: requiresSize,
    );
  }

  factory FeeLineItem.fromJson(Map<String, dynamic> json) {
    final rawAmounts = json['amounts'];
    final amounts = <String, double?>{};
    if (rawAmounts is Map) {
      for (final entry in rawAmounts.entries) {
        final value = entry.value;
        amounts[entry.key.toString()] = value is num ? value.toDouble() : null;
      }
    }

    return FeeLineItem(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      amounts: amounts,
      requiresSize: json['requires_size'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'label': label,
    'amounts': amounts,
    'requires_size': requiresSize,
  };
}

/// An optional item an applicant chose to take, priced at the moment of choice.
class SelectedFeeItem {
  const SelectedFeeItem({
    required this.key,
    required this.label,
    required this.amount,
    this.size,
  });

  final String key;
  final String label;
  final double amount;

  /// Free-text size, for items such as the safety boot.
  final String? size;

  String get displayLabel => (size == null || size!.trim().isEmpty) ? label : '$label (size ${size!.trim()})';

  factory SelectedFeeItem.fromJson(Map<String, dynamic> json) {
    final amount = json['amount'];
    return SelectedFeeItem(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      amount: amount is num ? amount.toDouble() : 0,
      size: json['size']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'label': label,
    'amount': amount,
    if (size != null && size!.trim().isNotEmpty) 'size': size!.trim(),
  };
}

/// The full CQAAG fee schedule: what every category owes and what they may
/// optionally take on top.
///
/// Stored under `settings/payment.fee_schedule` so the website and the mobile
/// app always quote the same figures.
class FeeSchedule {
  const FeeSchedule({
    required this.registrationComponents,
    required this.annualDues,
    required this.optionalItems,
  });

  /// Line items that add up to the Registration Fee.
  final List<FeeLineItem> registrationComponents;

  /// Annual Dues per [FeeCategory.key], inclusive of the TCDA recommendation
  /// letter where applicable.
  final Map<String, double?> annualDues;

  /// Kit items an applicant may choose to take, or decline.
  final List<FeeLineItem> optionalItems;

  /// Standard Registration Fee decided by the Board
  static const double standardRegistrationFee = 320.0;

  /// Existing Full Members on the register who paid the earlier GH₵60
  /// pay a discounted activation registration fee of GH₵200.
  static const double existingMemberRegistrationFee = 200.0;

  /// Full Member Annual Dues
  static const double fullMemberAnnualDues = 200.0;

  /// Foreign Associate special Annual Dues
  static const double foreignAssociateAnnualDues = 1000.0;

  /// Half-rate factor for National Associate and Corporate Annual Dues (0.5 * 200 = 100)
  static const double halfRateFactor = 0.5;

  /// Total at activation for Full Members: GH₵320 Reg + GH₵200 Dues = GH₵520
  static const double fullMemberTotalAtActivation = 520.0;

  /// Total at activation for Existing Full Members: GH₵200 Reg + GH₵200 Dues = GH₵400
  static const double existingMemberTotalAtActivation = 400.0;

  /// Constitutional revenue sharing (Constitution Art. 2):
  /// Annual Dues are shared 60% to Chapter and 40% to National Association.
  /// Registration Fee belongs 100% to National Association.
  static const double chapterDuesSharePercentage = 0.60;
  static const double nationalDuesSharePercentage = 0.40;
  static const double registrationFeeNationalSharePercentage = 1.00;

  /// Monthly recurring consumable: Gloves at GH₵70 per box (GH₵840 per year)
  static const double glovesMonthlyPrice = 70.0;
  static const double glovesAnnualPrice = 840.0;

  /// One-time kit subtotal (8 items from Kits sheet excluding monthly consumables: GH₵4,009)
  static const double kitSubtotalOneTime = 4009.0;

  /// Register counts from the official spreadsheet import:
  /// 63 existing members (marked Paid) + 35 other members = 98 Full Members
  static const int legacyExistingPaidCount = 63;
  static const int legacyOtherCount = 35;
  static const int legacyTotalCount = 98;

  /// Revenue projection from the 98-member register:
  /// Existing: 63 × GH₵400 = GH₵25,200 (GH₵12,600 Reg + GH₵12,600 Dues)
  /// Other: 35 × GH₵520 = GH₵18,200 (GH₵11,200 Reg + GH₵7,000 Dues)
  /// Total: GH₵43,400 (GH₵23,800 Reg + GH₵19,600 Dues)
  static const double legacyExistingProjectedRevenue = 25200.0;
  static const double legacyOtherProjectedRevenue = 18200.0;
  static const double legacyTotalProjectedRevenue = 43400.0;

  /// The schedule as confirmed by the Board, used until an admin edits it.
  ///
  /// Source: CQAAG_Membership_Fee_Schedule_New.xlsx
  /// (all Constitution categories, Art. 2 as amended).
  static final FeeSchedule defaults = FeeSchedule(
    registrationComponents: [
      _uniform('lacoste', 'Lacoste shirt', 65),
      _uniform('reflectors', 'Reflectors', 65),
      _uniform('membership_card', 'Membership Card', 50),
      _uniform('miscellaneous', 'Miscellaneous', 70),
      _uniform('association_margin', "Margin for the Association's activities", 70),
    ],
    annualDues: const {
      'full': 200,
      'national_associate': 100,
      'foreign_associate': 1000,
      'corporate': 100,
      'honorary': 0,
    },
    optionalItems: [
      _uniform('safety_boot', 'Safety boot', 200, corporate: 0, requiresSize: true),
      _uniform('safety_helmet', 'Safety helmet', 40, corporate: 0),
      _uniform('moisture_machine', 'Moisture Machine (Innovative Instruments DMM B18)', 2500, corporate: 0),
      _uniform('cutter', 'Cutter', 700, corporate: 0),
      _uniform('kitchen_scale', 'Kitchen scale (balance)', 302, corporate: 0),
      _uniform('scooper', '5 Scoopers', 25, corporate: 0),
      _uniform('gloves', 'Gloves (monthly consumable)', 70, corporate: 0),
      _uniform('kit_bag', '1 CQAAG Kit Bag', 242, corporate: 0),
    ],
  );

  /// Builds a row priced the same for every fee-paying category.
  ///
  /// Honorary Members are always zero, and Corporate can be overridden because
  /// the schedule prices organizational members differently for kit items.
  static FeeLineItem _uniform(
    String key,
    String label,
    double amount, {
    double? corporate,
    bool requiresSize = false,
  }) {
    return FeeLineItem(
      key: key,
      label: label,
      amounts: {
        'full': amount,
        'national_associate': amount,
        'foreign_associate': amount,
        'corporate': corporate ?? amount,
        'honorary': 0,
      },
      requiresSize: requiresSize,
    );
  }

  /// Registration Fee for [category] — the sum of its components, or the
  /// discounted rate for existing members who paid the earlier GH₵60.
  double registrationFeeFor(FeeCategory category, {bool isExistingMember = false}) {
    if (category.isExempt) return 0;
    if (isExistingMember && category == FeeCategory.full) {
      return existingMemberRegistrationFee;
    }
    return registrationComponents.fold<double>(
      0,
      (sum, item) => sum + (item.amountFor(category) ?? 0),
    );
  }

  /// Annual Dues for [category].
  double annualDuesFor(FeeCategory category) {
    if (category.isExempt) return 0;
    return annualDues[category.key] ?? 0;
  }

  /// 60% Chapter share of Annual Dues (Constitution Art. 2)
  double chapterDuesShareFor(FeeCategory category) {
    return annualDuesFor(category) * chapterDuesSharePercentage;
  }

  /// 40% National Association share of Annual Dues (Constitution Art. 2)
  double nationalDuesShareFor(FeeCategory category) {
    return annualDuesFor(category) * nationalDuesSharePercentage;
  }

  /// Equipment Cost portion of the Registration Fee build-up (Lacoste, Reflectors, Card, Misc: GH₵250)
  double equipmentCostSubtotalFor(FeeCategory category) {
    return registrationComponents
        .where((item) => item.key != 'association_margin')
        .fold<double>(0, (sum, item) => sum + (item.amountFor(category) ?? 0));
  }

  /// Margin for Association's activities in the Registration Fee build-up (GH₵70)
  double associationMarginFor(FeeCategory category) {
    final item = registrationComponents.firstWhere(
      (i) => i.key == 'association_margin',
      orElse: () => const FeeLineItem(key: '', label: ''),
    );
    return item.amountFor(category) ?? 0.0;
  }

  /// One-time kit subtotal (excluding monthly gloves)
  double oneTimeKitSubtotalFor(FeeCategory category) {
    return optionalItems
        .where((item) => item.key != 'gloves' && item.isAvailableTo(category))
        .fold<double>(0, (sum, item) => sum + (item.amountFor(category) ?? 0));
  }

  /// Optional items [category] may actually choose from.
  List<FeeLineItem> optionalItemsFor(FeeCategory category) {
    return optionalItems.where((item) => item.isAvailableTo(category)).toList();
  }

  /// Optional items that exist in the schedule but have no Board-approved
  /// price for [category] yet, so applicants are not offered them.
  List<FeeLineItem> unpricedOptionalItemsFor(FeeCategory category) {
    if (category.isExempt) return const [];
    return optionalItems.where((item) => item.amountFor(category) == null).toList();
  }

  /// What [category] owes before any optional items are added.
  double mandatoryTotalFor(FeeCategory category, {bool isExistingMember = false}) {
    return registrationFeeFor(category, isExistingMember: isExistingMember) + annualDuesFor(category);
  }

  /// The schedule's Grand Total — everything, including every priced optional
  /// item. Shown for reference; applicants are only charged what they choose.
  double grandTotalFor(FeeCategory category, {bool isExistingMember = false}) {
    final optional = optionalItemsFor(category).fold<double>(
      0,
      (sum, item) => sum + (item.amountFor(category) ?? 0),
    );
    return mandatoryTotalFor(category, isExistingMember: isExistingMember) + optional;
  }

  /// Prices a specific applicant's choices.
  FeeQuote quote(
    FeeCategory category, {
    List<SelectedFeeItem> selectedOptionalItems = const [],
    bool isExistingMember = false,
  }) {
    final items = category.isExempt ? const <SelectedFeeItem>[] : selectedOptionalItems;
    final regFee = registrationFeeFor(category, isExistingMember: isExistingMember);
    final components = (isExistingMember && category == FeeCategory.full)
        ? [
            const SelectedFeeItem(
              key: 'existing_registration',
              label: 'Registration Fee (Existing Member — earlier GH₵60 credited)',
              amount: existingMemberRegistrationFee,
            ),
          ]
        : registrationComponents
            .where((item) => (item.amountFor(category) ?? 0) > 0)
            .map((item) => SelectedFeeItem(key: item.key, label: item.label, amount: item.amountFor(category)!))
            .toList();

    return FeeQuote(
      category: category,
      registrationFee: regFee,
      annualDues: annualDuesFor(category),
      registrationComponents: components,
      optionalItems: items,
    );
  }

  FeeSchedule copyWith({
    List<FeeLineItem>? registrationComponents,
    Map<String, double?>? annualDues,
    List<FeeLineItem>? optionalItems,
  }) {
    return FeeSchedule(
      registrationComponents: registrationComponents ?? this.registrationComponents,
      annualDues: annualDues ?? this.annualDues,
      optionalItems: optionalItems ?? this.optionalItems,
    );
  }

  factory FeeSchedule.fromJson(Map<String, dynamic> json) {
    List<FeeLineItem> parseItems(Object? raw, List<FeeLineItem> fallback) {
      if (raw is! List || raw.isEmpty) return fallback;
      return raw
          .whereType<Map>()
          .map((e) => FeeLineItem.fromJson(Map<String, dynamic>.from(e)))
          .where((item) => item.key.isNotEmpty)
          .toList();
    }

    final rawDues = json['annual_dues'];
    final dues = <String, double?>{};
    if (rawDues is Map) {
      for (final entry in rawDues.entries) {
        final value = entry.value;
        dues[entry.key.toString()] = value is num ? value.toDouble() : null;
      }
    }

    return FeeSchedule(
      registrationComponents: parseItems(json['registration_components'], defaults.registrationComponents),
      annualDues: dues.isEmpty ? defaults.annualDues : dues,
      optionalItems: parseItems(json['optional_items'], defaults.optionalItems),
    );
  }

  Map<String, dynamic> toJson() => {
    'registration_components': registrationComponents.map((e) => e.toJson()).toList(),
    'annual_dues': annualDues,
    'optional_items': optionalItems.map((e) => e.toJson()).toList(),
  };
}

/// What one applicant is actually being asked to pay, itemised.
///
/// Snapshotted onto the application so later schedule changes never rewrite
/// what somebody was quoted.
class FeeQuote {
  const FeeQuote({
    required this.category,
    required this.registrationFee,
    required this.annualDues,
    this.registrationComponents = const [],
    this.optionalItems = const [],
  });

  final FeeCategory category;
  final double registrationFee;
  final double annualDues;
  final List<SelectedFeeItem> registrationComponents;
  final List<SelectedFeeItem> optionalItems;

  double get optionalTotal => optionalItems.fold<double>(0, (sum, item) => sum + item.amount);

  double get total => registrationFee + annualDues + optionalTotal;

  bool get isExempt => category.isExempt;
}
