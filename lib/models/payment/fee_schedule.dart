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

  /// The schedule as confirmed by the Board, used until an admin edits it.
  ///
  /// Source: CQAAG — Membership Categories, Fees & Dues Schedule
  /// (all Constitution categories, Art. 2 as amended). Items the Board has not
  /// yet priced are left null rather than guessed at.
  static final FeeSchedule defaults = FeeSchedule(
    registrationComponents: [
      _uniform('lacoste', 'Lacoste', 65),
      _uniform('reflectors', 'Reflectors', 65),
      _uniform('membership_card', 'Membership Card', 50),
      _uniform('miscellaneous', 'Miscellaneous', 70),
    ],
    annualDues: const {
      'full': 200,
      'national_associate': 100,
      'foreign_associate': 1000,
      'corporate': 100,
      'honorary': 0,
    },
    optionalItems: [
      _uniform('quality_cutting_kit', 'Quality Cutting Kit', 600, corporate: 0),
      const FeeLineItem(key: 'safety_boot', label: 'Safety boot', requiresSize: true),
      const FeeLineItem(key: 'safety_helmet', label: 'Safety helmet'),
      const FeeLineItem(key: 'moisture_machine', label: 'Moisture Machine'),
      const FeeLineItem(key: 'cutter', label: 'Cutter'),
      const FeeLineItem(key: 'kitchen_scale', label: 'Kitchen Scale'),
      const FeeLineItem(key: 'scooper', label: '5 Scooper'),
      _uniform('gloves', '1 box of gloves', 70, corporate: 0),
      const FeeLineItem(key: 'kit_bag', label: '1 CQAAG Kit Bag'),
    ],
  );

  /// Builds a row priced the same for every fee-paying category.
  ///
  /// Honorary Members are always zero, and Corporate can be overridden because
  /// the schedule prices organizational members differently for kit items.
  static FeeLineItem _uniform(String key, String label, double amount, {double? corporate}) {
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
    );
  }

  /// Registration Fee for [category] — the sum of its components.
  double registrationFeeFor(FeeCategory category) {
    if (category.isExempt) return 0;
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
  double mandatoryTotalFor(FeeCategory category) {
    return registrationFeeFor(category) + annualDuesFor(category);
  }

  /// The schedule's Grand Total — everything, including every priced optional
  /// item. Shown for reference; applicants are only charged what they choose.
  double grandTotalFor(FeeCategory category) {
    final optional = optionalItemsFor(category).fold<double>(
      0,
      (sum, item) => sum + (item.amountFor(category) ?? 0),
    );
    return mandatoryTotalFor(category) + optional;
  }

  /// Prices a specific applicant's choices.
  FeeQuote quote(FeeCategory category, {List<SelectedFeeItem> selectedOptionalItems = const []}) {
    final items = category.isExempt ? const <SelectedFeeItem>[] : selectedOptionalItems;
    return FeeQuote(
      category: category,
      registrationFee: registrationFeeFor(category),
      annualDues: annualDuesFor(category),
      registrationComponents: registrationComponents
          .where((item) => (item.amountFor(category) ?? 0) > 0)
          .map((item) => SelectedFeeItem(key: item.key, label: item.label, amount: item.amountFor(category)!))
          .toList(),
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
