import 'package:freezed_annotation/freezed_annotation.dart';

part 'cut_test.freezed.dart';
part 'cut_test.g.dart';

/// One cut test performed on a consignment.
///
/// The CQAAG protocol takes one, two or three cut tests depending on quantity
/// and inspection stage, and the RCN Quality Report shows each of them in its
/// own column (I, II, III) alongside the average. Each cut test is therefore
/// stored whole rather than being averaged away at entry time.
///
/// All derived figures (totals, yield, KOR) are computed here so the entry
/// screen, the report table and the average all use one implementation.
@freezed
abstract class CutTest with _$CutTest {
  const CutTest._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CutTest({
    /// Which cut test this is: 1, 2 or 3.
    required int index,

    /// Where the sample was taken, shown as the column heading on the sheet
    /// (e.g. "Sawla"). Falls back to "1st Cutting" when not supplied.
    String? label,

    @Default(0.0) double moistureContent,
    @Default(0) int nutCount,

    // Fully damaged group
    @Default(0.0) double fullyDamagedNuts,
    @Default(0.0) double voidNuts,
    @Default(0.0) double oilNuts,

    // Spotted / partly sound group
    @Default(0.0) double spottedNuts,
    @Default(0.0) double immatureNuts,

    @Default(0.0) double goodKernels,
    @Default(0.0) double emptyShells,
  }) = _CutTest;

  factory CutTest.fromJson(Map<String, dynamic> json) => _$CutTestFromJson(json);

  /// Pounds of kernel per 80kg bag, per gram of yield from a 1kg sample.
  ///
  /// 80kg x 2.2046 lb/kg / 1000g sample. The association's sheet uses 0.176.
  static const double korFactor = 0.176;

  /// Heading for this cut test's column on the report.
  String get displayLabel {
    if (label != null && label!.trim().isNotEmpty) return label!.trim();
    return switch (index) {
      1 => '1st Cutting',
      2 => '2nd Cutting',
      3 => '3rd Cutting',
      _ => 'Cutting $index',
    };
  }

  /// FULLY DAMAGED NUTS + VOID NUTS + OIL NUTS.
  double get totalDamaged => fullyDamagedNuts + voidNuts + oilNuts;

  /// SPOTTED/PARTLY SOUND + IMMATURE NUTS.
  double get totalSpotted => spottedNuts + immatureNuts;

  /// Half the spotted total counts toward yield.
  double get halfTotalSpotted => totalSpotted * 0.5;

  /// GOOD KERNELS + 50% of the spotted total.
  double get totalYield => goodKernels + halfTotalSpotted;

  /// Sum of every weighed group, expected to come to about 1000g.
  double get total => totalDamaged + totalSpotted + goodKernels + emptyShells;

  /// OUTTURN (KOR) in lbs per 80kg bag.
  double get kor => totalYield * korFactor;

  /// True when nothing has been entered, used to skip blank cut tests.
  bool get isEmpty =>
      moistureContent == 0 &&
      nutCount == 0 &&
      fullyDamagedNuts == 0 &&
      voidNuts == 0 &&
      oilNuts == 0 &&
      spottedNuts == 0 &&
      immatureNuts == 0 &&
      goodKernels == 0 &&
      emptyShells == 0;
}

/// Averages across a set of cut tests.
///
/// The report's AVERAGE column is the mean of the cut tests actually performed,
/// so a single cut test yields an average equal to itself.
extension CutTestAverages on List<CutTest> {
  double _mean(double Function(CutTest) select) {
    if (isEmpty) return 0;
    return map(select).reduce((a, b) => a + b) / length;
  }

  double get averageMoisture => _mean((c) => c.moistureContent);
  double get averageNutCount => _mean((c) => c.nutCount.toDouble());
  double get averageFullyDamaged => _mean((c) => c.fullyDamagedNuts);
  double get averageVoidNuts => _mean((c) => c.voidNuts);
  double get averageOilNuts => _mean((c) => c.oilNuts);
  double get averageTotalDamaged => _mean((c) => c.totalDamaged);
  double get averageSpotted => _mean((c) => c.spottedNuts);
  double get averageImmature => _mean((c) => c.immatureNuts);
  double get averageTotalSpotted => _mean((c) => c.totalSpotted);
  double get averageHalfTotalSpotted => _mean((c) => c.halfTotalSpotted);
  double get averageGoodKernels => _mean((c) => c.goodKernels);
  double get averageTotalYield => _mean((c) => c.totalYield);
  double get averageEmptyShells => _mean((c) => c.emptyShells);
  double get averageTotal => _mean((c) => c.total);
  double get averageKor => _mean((c) => c.kor);
}
