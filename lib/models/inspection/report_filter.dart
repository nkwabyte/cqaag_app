import 'package:cqaag_app/models/inspection/inspection.dart';

class ReportFilterCriteria {
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minKOR;
  final double? maxKOR;
  final double? minMoisture;
  final double? maxMoisture;
  final int? minNutCount;
  final int? maxNutCount;
  final double? minQuantity;
  final double? maxQuantity;
  final double? maxDefectRate;
  final InspectionStatus? status;
  final String? analysisType;
  final String? location;
  final String? chapter;
  final String? inspectorId;

  const ReportFilterCriteria({
    this.searchQuery,
    this.startDate,
    this.endDate,
    this.minKOR,
    this.maxKOR,
    this.minMoisture,
    this.maxMoisture,
    this.minNutCount,
    this.maxNutCount,
    this.minQuantity,
    this.maxQuantity,
    this.maxDefectRate,
    this.status,
    this.analysisType,
    this.location,
    this.chapter,
    this.inspectorId,
  });

  bool get isEmpty =>
      (searchQuery == null || searchQuery!.isEmpty) &&
      startDate == null &&
      endDate == null &&
      minKOR == null &&
      maxKOR == null &&
      minMoisture == null &&
      maxMoisture == null &&
      minNutCount == null &&
      maxNutCount == null &&
      minQuantity == null &&
      maxQuantity == null &&
      maxDefectRate == null &&
      status == null &&
      (analysisType == null || analysisType!.isEmpty) &&
      (location == null || location!.isEmpty) &&
      (chapter == null || chapter!.isEmpty) &&
      (inspectorId == null || inspectorId!.isEmpty);

  bool get isNotEmpty => !isEmpty;

  int get activeFilterCount {
    int count = 0;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    if (startDate != null || endDate != null) count++;
    if (minKOR != null || maxKOR != null) count++;
    if (minMoisture != null || maxMoisture != null) count++;
    if (minNutCount != null || maxNutCount != null) count++;
    if (minQuantity != null || maxQuantity != null) count++;
    if (maxDefectRate != null) count++;
    if (status != null) count++;
    if (analysisType != null && analysisType!.isNotEmpty) count++;
    if (location != null && location!.isNotEmpty) count++;
    if (chapter != null && chapter!.isNotEmpty) count++;
    if (inspectorId != null && inspectorId!.isNotEmpty) count++;
    return count;
  }

  ReportFilterCriteria copyWith({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    double? minKOR,
    double? maxKOR,
    double? minMoisture,
    double? maxMoisture,
    int? minNutCount,
    int? maxNutCount,
    double? minQuantity,
    double? maxQuantity,
    double? maxDefectRate,
    InspectionStatus? status,
    String? analysisType,
    String? location,
    String? chapter,
    String? inspectorId,
  }) {
    return ReportFilterCriteria(
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minKOR: minKOR ?? this.minKOR,
      maxKOR: maxKOR ?? this.maxKOR,
      minMoisture: minMoisture ?? this.minMoisture,
      maxMoisture: maxMoisture ?? this.maxMoisture,
      minNutCount: minNutCount ?? this.minNutCount,
      maxNutCount: maxNutCount ?? this.maxNutCount,
      minQuantity: minQuantity ?? this.minQuantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      maxDefectRate: maxDefectRate ?? this.maxDefectRate,
      status: status ?? this.status,
      analysisType: analysisType ?? this.analysisType,
      location: location ?? this.location,
      chapter: chapter ?? this.chapter,
      inspectorId: inspectorId ?? this.inspectorId,
    );
  }

  List<Inspection> apply(List<Inspection> list) {
    return list.where((i) {
      // 1. Search Query
      if (searchQuery != null && searchQuery!.isNotEmpty) {
        final q = searchQuery!.toLowerCase();
        final batch = (i.batchId ?? '').toLowerCase();
        final farmer = (i.farmerName ?? '').toLowerCase();
        final loc = (i.location ?? '').toLowerCase();
        final insp = i.inspectorId.toLowerCase();
        final truck = (i.truckNumber ?? '').toLowerCase();
        final waybill = (i.waybillNumber ?? '').toLowerCase();

        final matches = batch.contains(q) ||
            farmer.contains(q) ||
            loc.contains(q) ||
            insp.contains(q) ||
            truck.contains(q) ||
            waybill.contains(q);
        if (!matches) return false;
      }

      // 2. Date Range
      if (startDate != null || endDate != null) {
        final date = i.completedAt ?? i.createdAt;
        if (date == null) return false;
        if (startDate != null && date.isBefore(startDate!)) return false;
        if (endDate != null && date.isAfter(endDate!.add(const Duration(days: 1)))) return false;
      }

      // 3. KOR Range
      if (minKOR != null && i.kor < minKOR!) return false;
      if (maxKOR != null && i.kor > maxKOR!) return false;

      // 4. Moisture Range
      if (minMoisture != null && i.moistureContent < minMoisture!) return false;
      if (maxMoisture != null && i.moistureContent > maxMoisture!) return false;

      // 5. Nut Count Range
      if (minNutCount != null && i.nutCount < minNutCount!) return false;
      if (maxNutCount != null && i.nutCount > maxNutCount!) return false;

      // 6. Quantity Range
      if (minQuantity != null && i.quantity < minQuantity!) return false;
      if (maxQuantity != null && i.quantity > maxQuantity!) return false;

      // 7. Max Defect Rate
      if (maxDefectRate != null && i.totalDefective > maxDefectRate!) return false;

      // 8. Status
      if (status != null && i.status != status) return false;

      // 9. Analysis Type
      if (analysisType != null && analysisType!.isNotEmpty && i.analysisType != null) {
        if (!i.analysisType!.toLowerCase().contains(analysisType!.toLowerCase())) {
          return false;
        }
      }

      // 10. Location
      if (location != null && location!.isNotEmpty && i.location != null) {
        if (!i.location!.toLowerCase().contains(location!.toLowerCase())) {
          return false;
        }
      }

      // 11. Chapter
      if (chapter != null && chapter!.isNotEmpty && i.chapter != null) {
        if (!i.chapter!.toLowerCase().contains(chapter!.toLowerCase())) {
          return false;
        }
      }

      // 12. Inspector ID
      if (inspectorId != null && inspectorId!.isNotEmpty) {
        if (i.inspectorId.toLowerCase() != inspectorId!.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
