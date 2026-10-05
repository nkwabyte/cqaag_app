/// The kinds of quality analysis a certificate can be issued for, and the
/// rules that hang off each.
class AnalysisTypes {
  AnalysisTypes._();

  static const String arrivalUpcountry = 'Arrival Upcountry Warehouse';
  static const String moistureControl = 'Moisture Control';
  static const String dispatch = 'Dispatch';
  static const String arrivalPort = 'Arrival Port Warehouse';
  static const String arbitration = 'Arbitration';
  static const String export = 'Export';

  /// In the order offered on the inspection form.
  static const List<String> all = [
    arrivalUpcountry,
    moistureControl,
    dispatch,
    arrivalPort,
    arbitration,
    export,
  ];

  /// Types whose certificate must be paid for before it can be submitted.
  /// Same list as the website.
  static const Set<String> paid = {moistureControl, dispatch, arbitration, export};

  /// Temporary flat certificate fee, in Ghana Cedis, until the Board sets
  /// per-type fees. Same figure as the website.
  static const double reportFeeCedis = 100;

  static bool isExport(String? type) => (type ?? '').toLowerCase().contains('export');

  static bool requiresPayment(String? type) => paid.contains(type);

  /// Only Export certificates go to the CQAAG approval desk.
  static bool requiresApproval(String? type) => isExport(type);
}
