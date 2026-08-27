import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:cqaag_app/models/inspection/inspection.dart';
import 'package:cqaag_app/models/user/app_user.dart';

class ExcelExportService {
  static const List<String> analysisSheets = [
    'Arrival Upcountry Warehouse',
    'Dispatch',
    'Arrival Port Warehouse',
    'Arbitration',
    'Export',
  ];

  /// Export inspections to multi-sheet Excel (.xlsx) format based on user permissions.
  /// 
  /// - Individual QC users can ONLY export their own inspections.
  /// - Admin users can export all inspections across QCs.
  /// - Each Analysis Type is separated into its own dedicated worksheet:
  ///   1. Arrival Upcountry Warehouse
  ///   2. Dispatch
  ///   3. Arrival Port Warehouse
  ///   4. Arbitration
  ///   5. Export
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

    // 2. Initialize Excel Workbook
    final xlsio.Workbook workbook = xlsio.Workbook();

    // Map helper to match analysis types flexibly
    String resolveSheetName(String? rawType) {
      if (rawType == null || rawType.isEmpty) return 'Arrival Upcountry Warehouse';
      final lower = rawType.toLowerCase().trim();
      if (lower.contains('dispatch')) return 'Dispatch';
      if (lower.contains('port')) return 'Arrival Port Warehouse';
      if (lower.contains('arbitration')) return 'Arbitration';
      if (lower.contains('export')) return 'Export';
      if (lower.contains('arrival') || lower.contains('upcountry')) return 'Arrival Upcountry Warehouse';
      return 'Arrival Upcountry Warehouse';
    }

    // 3. Create all 5 requested sheets
    // Workbook initializes with 1 worksheet at index 0
    final Map<String, xlsio.Worksheet> sheetsMap = {};

    for (int i = 0; i < analysisSheets.length; i++) {
      final sheetName = analysisSheets[i];
      final xlsio.Worksheet sheet = (i == 0)
          ? workbook.worksheets[0]
          : workbook.worksheets.addWithName(sheetName);
      sheet.name = sheetName;
      sheetsMap[sheetName] = sheet;

      // Populate headers according to sheet type
      if (sheetName == 'Export') {
        _buildExportHeaders(sheet);
      } else {
        _buildStandardHeaders(sheet);
      }
    }

    // 4. Distribute inspections to their respective sheets
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final Map<String, int> rowCounters = {
      for (final s in analysisSheets) s: 2, // Data starts at row 2 (row 1 is header)
    };

    for (final inspection in exportData) {
      final targetSheetName = resolveSheetName(inspection.analysisType);
      final sheet = sheetsMap[targetSheetName] ?? sheetsMap['Arrival Upcountry Warehouse']!;
      final currentRow = rowCounters[targetSheetName]!;

      final dateStr = inspection.completedAt != null
          ? dateFormat.format(inspection.completedAt!)
          : (inspection.createdAt != null ? dateFormat.format(inspection.createdAt!) : 'N/A');

      final effectiveQcCode = inspection.qcCode ?? currentUser.effectiveQcCode;

      if (targetSheetName == 'Export') {
        _writeExportRow(sheet, currentRow, inspection, dateStr, effectiveQcCode);
      } else {
        _writeStandardRow(sheet, currentRow, inspection, dateStr, effectiveQcCode);
      }

      rowCounters[targetSheetName] = currentRow + 1;
    }

    // 5. Save and Export the File
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final prefix = filenamePrefix ?? (currentUser.isAdmin ? 'cqaag_all_analysis' : 'cqaag_qc_analysis');
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = '${prefix}_$timestamp.xlsx';

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);

    // 6. Share / Open Excel file
    final xFile = XFile(
      file.path,
      mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      name: fileName,
    );

    await Share.shareXFiles(
      [xFile],
      text: 'CQAAG Analysis Multi-Sheet Report (${exportData.length} records across 5 Analysis Sheets)',
      subject: 'CQAAG Quality Analysis Excel Export',
    );

    return file;
  }

  static void _buildStandardHeaders(xlsio.Worksheet sheet) {
    final headers = [
      'Inspection ID',
      'Date & Time',
      'QC-CODE',
      'Status',
      'Batch ID',
      'Supplier / Farmer',
      'Region / District',
      'Town',
      'Chapter / Zone',
      'Truck Number',
      'Supplier / Company',
      'Buyer Name',
      'Waybill / B/L No.',
      'Analysis Type',
      'Quantity (KG)',
      'Quantity (Bags)',
      'Moisture (%)',
      'Nut Count',
      'KOR (lbs)',
      'Good Kernels (g)',
      'Spotted Kernels (g)',
      'Immature Kernels (g)',
      'Oily Kernels (g)',
      'Void Kernels (g)',
      'Fully Damaged (g)',
      'Empty Shells (g)',
      'Total Defective (g)',
      'Total Spotted (g)',
      'Notes',
    ];

    for (int col = 0; col < headers.length; col++) {
      final cell = sheet.getRangeByIndex(1, col + 1);
      cell.setText(headers[col]);
      cell.cellStyle.bold = true;
      cell.cellStyle.backColor = '#2D5F2E';
      cell.cellStyle.fontColor = '#FFFFFF';
    }
  }

  static void _writeStandardRow(
    xlsio.Worksheet sheet,
    int row,
    Inspection i,
    String dateStr,
    String qcCode,
  ) {
    sheet.getRangeByIndex(row, 1).setText(i.inspectionId ?? i.id);
    sheet.getRangeByIndex(row, 2).setText(dateStr);
    sheet.getRangeByIndex(row, 3).setText(qcCode);
    sheet.getRangeByIndex(row, 4).setText(i.status.name.toUpperCase());
    sheet.getRangeByIndex(row, 5).setText(i.batchId ?? '');
    sheet.getRangeByIndex(row, 6).setText(i.farmerName ?? '');
    sheet.getRangeByIndex(row, 7).setText(i.location ?? '');
    sheet.getRangeByIndex(row, 8).setText(i.town ?? '');
    sheet.getRangeByIndex(row, 9).setText(i.chapter ?? '');
    sheet.getRangeByIndex(row, 10).setText(i.truckNumber ?? '');
    sheet.getRangeByIndex(row, 11).setText(i.company ?? '');
    sheet.getRangeByIndex(row, 12).setText(i.buyerName ?? '');
    sheet.getRangeByIndex(row, 13).setText(i.waybillNumber ?? '');
    sheet.getRangeByIndex(row, 14).setText(i.analysisType ?? '');
    sheet.getRangeByIndex(row, 15).setNumber(i.quantity);
    sheet.getRangeByIndex(row, 16).setNumber(i.quantityBags.toDouble());
    sheet.getRangeByIndex(row, 17).setNumber(i.moistureContent);
    sheet.getRangeByIndex(row, 18).setNumber(i.nutCount.toDouble());
    sheet.getRangeByIndex(row, 19).setNumber(i.kor);
    sheet.getRangeByIndex(row, 20).setNumber(i.goodKernels);
    sheet.getRangeByIndex(row, 21).setNumber(i.spottedKernels);
    sheet.getRangeByIndex(row, 22).setNumber(i.immatureKernels);
    sheet.getRangeByIndex(row, 23).setNumber(i.oilyKernels);
    sheet.getRangeByIndex(row, 24).setNumber(i.voidKernels);
    sheet.getRangeByIndex(row, 25).setNumber(i.fullyDamagedKernels);
    sheet.getRangeByIndex(row, 26).setNumber(i.emptyShells);
    sheet.getRangeByIndex(row, 27).setNumber(i.totalDefective);
    sheet.getRangeByIndex(row, 28).setNumber(i.totalSpotted);
    sheet.getRangeByIndex(row, 29).setText(i.notes ?? '');
  }

  static void _buildExportHeaders(xlsio.Worksheet sheet) {
    final headers = [
      'Inspection ID',
      'Date & Time',
      'QC-CODE',
      'B/L No.',
      'Shipper Details',
      'Consignee Details',
      'Origin (Country)',
      'Destination (Country)',
      'Name & Description of Transport',
      'POD (Port of Destination)',
      'POL (Port of Loading)',
      'Number of Containers & Sizes',
      'Gross Weight (KG)',
      'Net Weight (KG)',
      'Number & Description of Packages',
      'Place & Date of Sample',
      'Place & Date of Cutting Test',
      'Authorized',
      'Authorized By',
      'Moisture (%)',
      'Nut Count',
      'KOR (lbs)',
      'Good Kernels (g)',
      'Spotted (g)',
      'Immature (g)',
      'Void (g)',
      'Oil (g)',
      'Fully Damaged (g)',
      'Empty Shells (g)',
      'Total Defective (g)',
      'Total Spotted (g)',
      'Status',
      'Notes',
    ];

    for (int col = 0; col < headers.length; col++) {
      final cell = sheet.getRangeByIndex(1, col + 1);
      cell.setText(headers[col]);
      cell.cellStyle.bold = true;
      cell.cellStyle.backColor = '#8B0000';
      cell.cellStyle.fontColor = '#FFFFFF';
    }
  }

  static void _writeExportRow(
    xlsio.Worksheet sheet,
    int row,
    Inspection i,
    String dateStr,
    String qcCode,
  ) {
    sheet.getRangeByIndex(row, 1).setText(i.inspectionId ?? i.id);
    sheet.getRangeByIndex(row, 2).setText(dateStr);
    sheet.getRangeByIndex(row, 3).setText(qcCode);
    sheet.getRangeByIndex(row, 4).setText(i.blNumber ?? i.waybillNumber ?? '');
    sheet.getRangeByIndex(row, 5).setText(i.shipperDetails ?? i.company ?? '');
    sheet.getRangeByIndex(row, 6).setText(i.consigneeDetails ?? i.buyerName ?? '');
    sheet.getRangeByIndex(row, 7).setText(i.originCountry.isNotEmpty ? i.originCountry : 'GHANA');
    sheet.getRangeByIndex(row, 8).setText(i.destinationCountry ?? '');
    sheet.getRangeByIndex(row, 9).setText(i.transportDescription ?? i.truckNumber ?? '');
    sheet.getRangeByIndex(row, 10).setText(i.pod ?? '');
    sheet.getRangeByIndex(row, 11).setText(i.pol ?? '');
    sheet.getRangeByIndex(row, 12).setText(i.containerCountAndSizes ?? '');
    sheet.getRangeByIndex(row, 13).setNumber(i.grossWeight ?? i.quantity);
    sheet.getRangeByIndex(row, 14).setNumber(i.netWeight ?? i.quantity);
    sheet.getRangeByIndex(row, 15).setText(i.packageDescription ?? '${i.quantityBags} Bags');
    sheet.getRangeByIndex(row, 16).setText(i.samplePlaceAndDate ?? '${i.location} - $dateStr');
    sheet.getRangeByIndex(row, 17).setText(i.cuttingTestPlaceAndDate ?? '${i.location} - $dateStr');
    sheet.getRangeByIndex(row, 18).setText(i.isAuthorized ? 'YES' : 'NO');
    sheet.getRangeByIndex(row, 19).setText(i.authorizedBy ?? '');
    sheet.getRangeByIndex(row, 20).setNumber(i.moistureContent);
    sheet.getRangeByIndex(row, 21).setNumber(i.nutCount.toDouble());
    sheet.getRangeByIndex(row, 22).setNumber(i.kor);
    sheet.getRangeByIndex(row, 23).setNumber(i.goodKernels);
    sheet.getRangeByIndex(row, 24).setNumber(i.spottedKernels);
    sheet.getRangeByIndex(row, 25).setNumber(i.immatureKernels);
    sheet.getRangeByIndex(row, 26).setNumber(i.voidKernels);
    sheet.getRangeByIndex(row, 27).setNumber(i.oilyKernels);
    sheet.getRangeByIndex(row, 28).setNumber(i.fullyDamagedKernels);
    sheet.getRangeByIndex(row, 29).setNumber(i.emptyShells);
    sheet.getRangeByIndex(row, 30).setNumber(i.totalDefective);
    sheet.getRangeByIndex(row, 31).setNumber(i.totalSpotted);
    sheet.getRangeByIndex(row, 32).setText(i.status.name.toUpperCase());
    sheet.getRangeByIndex(row, 33).setText(i.notes ?? '');
  }
}
