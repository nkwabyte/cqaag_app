import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cqaag_app/models/inspection/inspection.dart';
import 'package:cqaag_app/models/user/app_user.dart';

class ExcelExportService {
  /// Export inspections to CSV/Excel format based on user permissions.
  /// 
  /// - Individual QC users can ONLY export their own inspections.
  /// - Admin users can export all inspections.
  static Future<File?> exportInspections({
    required List<Inspection> inspections,
    required AppUser currentUser,
    String? filenamePrefix,
  }) async {
    // 1. Enforce RBAC rules
    List<Inspection> exportData;
    if (currentUser.isAdmin) {
      exportData = inspections;
    } else {
      // Individual QC can only export their own inspections
      exportData = inspections.where((i) => i.inspectorId == currentUser.id).toList();
    }

    if (exportData.isEmpty) {
      throw Exception('No inspections available to export for your account.');
    }

    // 2. Build CSV Headers
    final List<List<dynamic>> rows = [
      [
        'Inspection ID',
        'Date & Time',
        'Inspector ID',
        'Status',
        'Batch ID',
        'Farmer / Supplier Name',
        'Location / District',
        'Town',
        'Chapter',
        'Truck Number',
        'Supplier / Supplying Company',
        'Buyer Name',
        'Waybill Number',
        'Analysis Type',
        'Quantity (MT)',
        'Quantity (Bags)',
        'Moisture Content (%)',
        'Nut Count',
        'KOR (lbs/bag)',
        'Good Kernels (%)',
        'Spotted Kernels (%)',
        'Immature Kernels (%)',
        'Oily Kernels (%)',
        'Void Kernels (%)',
        'Fully Damaged Kernels (%)',
        'Empty Shells (%)',
        'Total Defective (%)',
        'Notes',
      ]
    ];

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    // 3. Build CSV Rows
    for (final i in exportData) {
      final dateStr = i.completedAt != null
          ? dateFormat.format(i.completedAt!)
          : (i.createdAt != null ? dateFormat.format(i.createdAt!) : 'N/A');

      rows.add([
        i.inspectionId ?? i.id,
        dateStr,
        i.inspectorId,
        i.status.name,
        i.batchId ?? '',
        i.farmerName ?? '',
        i.location ?? '',
        i.town ?? '',
        i.chapter ?? '',
        i.truckNumber ?? '',
        i.company ?? '',
        i.buyerName ?? '',
        i.waybillNumber ?? '',
        i.analysisType ?? '',
        i.quantity,
        i.quantityBags,
        i.moistureContent,
        i.nutCount,
        i.kor,
        i.goodKernels,
        i.spottedKernels,
        i.immatureKernels,
        i.oilyKernels,
        i.voidKernels,
        i.fullyDamagedKernels,
        i.emptyShells,
        i.totalDefective,
        i.notes ?? '',
      ]);
    }

    // 4. Encode to CSV String
    final csvString = const ListToCsvConverter().convert(rows);

    // 5. Write to File
    final prefix = filenamePrefix ?? (currentUser.isAdmin ? 'all_inspections' : 'my_inspections');
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = '${prefix}_$timestamp.csv';

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(csvString);

    // 6. Share / Export file
    final xFile = XFile(file.path, mimeType: 'text/csv', name: fileName);
    await Share.shareXFiles(
      [xFile],
      text: 'CQAAG Inspection Report Export (${exportData.length} record${exportData.length == 1 ? '' : 's'})',
      subject: 'CQAAG Inspection Data Export',
    );

    return file;
  }
}
