import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'dart:io';

import 'package:cqaag_app/index.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart'; // For PDF preview/printing
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QualityResultScreen extends ConsumerStatefulWidget {
  static const String id = 'quality_result_screen';

  final Inspection inspection;

  const QualityResultScreen({super.key, required this.inspection});

  @override
  ConsumerState<QualityResultScreen> createState() => _QualityResultScreenState();
}

class _QualityResultScreenState extends ConsumerState<QualityResultScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final i = widget.inspection;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: <Widget>[
          // 1. Hero Header
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 40.h),
              decoration: BoxDecoration(
                color: colorScheme.onSurface, // darkRed
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50.r),
                  bottomRight: Radius.circular(50.r),
                ),
              ),
              child: Column(
                children: [
                  _buildTopBar(context),
                  Gap(30.h),
                  // KOR Circular Indicator
                  Container(
                    width: 140.r,
                    height: 140.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 8.w),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(
                            i.kor.toStringAsFixed(1),
                            variant: TextVariant.displayLarge,
                            color: Colors.white,
                          ),
                          CustomText(
                            "KOR",
                            variant: TextVariant.bodySmall,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(24.h),
                  // Export Ready Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: i.kor >= 48.0 ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          i.kor >= 48.0 ? Icons.check_circle_outline : Icons.info_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                        Gap(8.w),
                        CustomText(
                          i.kor >= 48.0 ? "EXPORT READY" : "BELOW STANDARD",
                          variant: TextVariant.labelLarge,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  Gap(16.h),
                  CustomText(
                    "Nut Count: ${i.nutCount} • ${i.batchId ?? 'No Batch ID'}",
                    variant: TextVariant.bodySmall,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),

          // 2. Data Sections
          SliverPadding(
            padding: EdgeInsets.all(24.r),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader("Report Information"),
                _buildReportInfoCard(colorScheme, i),
                Gap(24.h),

                // Standalone TCDA Authority Banner
                _buildTcdaAuthorityCard(colorScheme),
                Gap(24.h),

                _buildSectionHeader("Quality Parameters"),
                _buildParametersGrid(i),
                Gap(24.h),

                _buildSectionHeader("Digital Certificate & CCQ"),
                _buildCertificateCard(colorScheme, i),
                Gap(32.h),

                // 3. Action Buttons
                CustomButton(
                  text: "View Batch Traceability",
                  leadingIcon: const Icon(Icons.account_tree_outlined, color: Colors.white),
                  onPressed: () => context.pushNamed(
                    TraceabilityScreen.id,
                    extra: i,
                  ),
                ),
                Gap(16.h),
                Row(
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          return CustomButton(
                            text: "Share",
                            variant: ButtonVariant.outlined,
                            leadingIcon: Icon(Icons.share_outlined, color: colorScheme.primary),
                            onPressed: () => _shareReport(context, i),
                          );
                        },
                      ),
                    ),
                    Gap(8.w),
                    Expanded(
                      child: CustomButton(
                        text: "PDF",
                        variant: ButtonVariant.outlined,
                        leadingIcon: Icon(Icons.picture_as_pdf_outlined, color: colorScheme.primary),
                        onPressed: () => _downloadReport(context, i),
                      ),
                    ),
                    Gap(8.w),
                    Expanded(
                      child: CustomButton(
                        text: "Excel",
                        variant: ButtonVariant.outlined,
                        leadingIcon: const Icon(Icons.explicit_outlined, color: Colors.green),
                        onPressed: () => _exportSingleExcel(context, i),
                      ),
                    ),
                  ],
                ),
                Gap(16.h),

                // Raise Correction Ticket Button
                CustomButton(
                  text: "Report Mistake / Raise Ticket",
                  variant: ButtonVariant.outlined,
                  borderColor: Colors.redAccent,
                  textColor: Colors.redAccent,
                  leadingIcon: const Icon(Icons.support_agent_outlined, color: Colors.redAccent),
                  onPressed: () => RaiseTicketModal.show(
                    context,
                    prefilledInspectionId: i.inspectionId ?? i.id,
                    prefilledBatchId: i.batchId,
                  ),
                ),
                Gap(40.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Build Methods ---
  Widget _buildTopBar(BuildContext context) {
    final rawType = widget.inspection.analysisType ?? '';
    final title = rawType.isNotEmpty ? "RCN Quality - ${rawType.toUpperCase()}" : "Quality Result";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: CustomText(
            title,
            variant: TextVariant.headlineMedium,
            color: Colors.white,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () => _shareReport(context, widget.inspection),
        ),
      ],
    );
  }

  Widget _buildTcdaAuthorityCard(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8F4),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFF2D5F2E).withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: const Color(0xFF2D5F2E),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: const CustomText(
              "TCDA",
              variant: TextVariant.bodyMedium,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  "Tree Crop Development Authority (TCDA)",
                  variant: TextVariant.bodyMedium,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D5F2E),
                ),
                Gap(4.h),
                CustomText(
                  "Statutory Regulatory Authority for Cashew in Ghana (Act 1010). Certified under official CQAAG & TCDA Quality Regulations.",
                  variant: TextVariant.bodySmall,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportInfoCard(ColorScheme colorScheme, Inspection i) {
    final isExport = (i.analysisType ?? '').toLowerCase().contains('export');

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _InfoRow(
            label: "Analysis Type",
            value: (i.analysisType != null && i.analysisType!.isNotEmpty) ? i.analysisType! : "Arrival",
          ),
          const Divider(),
          _InfoRow(
            label: "QC-CODE",
            value: i.qcCode ?? i.inspectorId,
          ),
          const Divider(),
          if (isExport) ...[
            _InfoRow(label: "B/L No.", value: i.blNumber ?? i.waybillNumber ?? "N/A"),
            const Divider(),
            _InfoRow(label: "Shipper Details", value: i.shipperDetails ?? i.company ?? "N/A"),
            const Divider(),
            _InfoRow(label: "Consignee Details", value: i.consigneeDetails ?? i.buyerName ?? "N/A"),
            const Divider(),
            _InfoRow(label: "Origin", value: i.originCountry),
            const Divider(),
            _InfoRow(label: "Destination", value: i.destinationCountry ?? "N/A"),
            const Divider(),
            _InfoRow(label: "Transport", value: i.transportDescription ?? i.truckNumber ?? "N/A"),
            const Divider(),
            _InfoRow(label: "Port of Loading (POL)", value: i.pol ?? "Port of Tema"),
            const Divider(),
            _InfoRow(label: "Port of Destination (POD)", value: i.pod ?? "N/A"),
            const Divider(),
            _InfoRow(label: "Containers & Sizes", value: i.containerCountAndSizes ?? "N/A"),
            const Divider(),
            _InfoRow(label: "Gross Weight", value: "${i.grossWeight ?? i.quantity} KG"),
            const Divider(),
            _InfoRow(label: "Net Weight", value: "${i.netWeight ?? i.quantity} KG"),
            const Divider(),
            _InfoRow(label: "Packages", value: i.packageDescription ?? "${i.quantityBags} Bags"),
            const Divider(),
            _InfoRow(label: "Authorized", value: i.isAuthorized ? "YES" : "Pending"),
          ] else ...[
            _InfoRow(
              label: "Truck Number",
              value: i.truckNumber ?? "N/A",
            ),
            const Divider(),
            _InfoRow(label: "Supplier / Supplying Company", value: i.company ?? "N/A"),
            const Divider(),
            _InfoRow(label: "Buyer / Company Name", value: i.buyerName ?? "N/A"),
            const Divider(),
            _InfoRow(label: "Waybill / B/L No.", value: i.waybillNumber ?? "N/A"),
            const Divider(),
            _InfoRow(label: "Quantity", value: "${i.quantity} KG (${i.quantityBags} Bags)"),
          ],
        ],
      ),
    );
  }

  Widget _buildParametersGrid(Inspection i) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16.r,
      crossAxisSpacing: 16.r,
      childAspectRatio: 1.1,
      children: [
        ParameterCard(
          label: "Moisture",
          value: i.moistureContent.toString(),
          unit: "%",
          status: i.moistureContent <= 10.0 ? "Pass" : "High",
        ),
        ParameterCard(
          label: "Nut Count",
          value: i.nutCount.toString(),
          unit: "g",
          status: "Pass",
        ),
        ParameterCard(
          label: "Void",
          value: i.voidKernels.toString(),
          unit: "g",
          status: "Pass",
        ),
        ParameterCard(
          label: "Oil",
          value: i.oilyKernels.toString(),
          unit: "g",
          status: "Pass",
        ),
        ParameterCard(
          label: "Total Defective",
          value: i.totalDefective.toString(),
          unit: "g",
          status: "Pass",
        ),
        ParameterCard(
          label: "Spotted",
          value: i.spottedKernels.toString(),
          unit: "g",
          status: "Pass",
        ),
        ParameterCard(
          label: "KOR",
          value: i.kor.toStringAsFixed(1),
          unit: "lbs",
          status: "Pass",
        ),
      ],
    );
  }

  Widget _buildCertificateCard(ColorScheme colorScheme, Inspection i) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 130.r,
                height: 130.r,
                padding: EdgeInsets.all(1.r),
                decoration: BoxDecoration(
                  // color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(1.r),
                  border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.7)),
                ),
                child: QrImageView(
                  data: 'inspection:${i.inspectionId ?? i.id}',
                  version: QrVersions.auto,
                  size: 80.0,
                ),
              ),
              Gap(20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      i.inspectorId.substring(0, i.inspectorId.length > 10 ? 10 : null), // Temp
                      variant: TextVariant.bodyLarge,
                      fontWeight: FontWeight.bold,
                    ),
                    CustomText("Inspector", variant: TextVariant.bodySmall, color: colorScheme.secondary),
                    Gap(8.h),
                    CustomText(
                      i.completedAt?.toString().split('.')[0] ?? "Unknown Date",
                      variant: TextVariant.bodySmall,
                    ),
                    CustomText(
                      i.location ?? "Unknown District",
                      variant: TextVariant.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(20.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText("Certificate ID:", variant: TextVariant.bodySmall, color: colorScheme.secondary),
                Expanded(
                  child: CustomText(
                    i.id.substring(0, 8).toUpperCase(), // Shortened ID
                    variant: TextVariant.bodySmall,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _prepareReportData(Inspection i) async {
    // Cut tests drive the I / II / III columns and the AVERAGE column. Older
    // inspections that only stored averages surface as a single cut test.
    final cuts = i.effectiveCutTests;

    return {
      'cutTests': cuts,
      'batchId': i.batchId ?? 'N/A',
      'date': i.completedAt?.toString().split(' ')[0] ?? DateTime.now().toString().split(' ')[0],
      'location': i.exactLocation?.isNotEmpty == true ? i.exactLocation : (i.location ?? 'N/A'),
      'company': i.company ?? 'N/A',
      'buyerName': i.buyerName ?? '',
      'waybillNumber': i.waybillNumber ?? '',
      'analysisType': i.analysisType ?? '',
      'truckNumber': i.truckNumber ?? 'N/A',
      'quantity': i.quantity.toString(),
      'bagCount': i.quantityBags.toString(),
      'nutCount': i.nutCount.toString(),
      'nutCountStatus': 'Pass', // Logic for status can be refined
      'moisture': '${i.moistureContent}%',
      'moistureStatus': i.moistureContent <= 10.0 ? 'Pass' : 'Fail',
      'kor': '${cuts.averageKor.toStringAsFixed(2)} lbs',
      'korStatus': cuts.averageKor >= 48.0 ? 'Pass' : 'Fail',
      'defectiveRate': '${i.totalDefective}%', // Assuming percentage or needing conversion
      'defectiveStatus': 'Pass', // Logic for status
      'voidKernels': i.voidKernels.toString(),
      'spottedKernels': i.spottedKernels.toString(),
      'oilyKernels': i.oilyKernels.toString(),
      'immatureKernels': i.immatureKernels.toString(),
      'goodKernels': i.goodKernels.toString(),
      'fullyDamagedKernels': i.fullyDamagedKernels.toString(),
      'emptyShells': i.emptyShells.toString(),
      'totalDefective': i.totalDefective.toString(),
      'totalSpotted': i.totalSpotted.toString(),
      'town': i.town ?? '',
      'chapter': i.chapter ?? '',
      'inspector': _getInspectorFullName(),
      'qcCode': i.qcCode ?? (ref.read(currentUserProfileProvider).value?.effectiveQcCode ?? i.inspectorId),
      'inspectionId': i.inspectionId,
      'id': i.id,
      'blNumber': i.blNumber,
      'shipperDetails': i.shipperDetails,
      'consigneeDetails': i.consigneeDetails,
      'originCountry': i.originCountry,
      'destinationCountry': i.destinationCountry,
      'transportDescription': i.transportDescription,
      'pod': i.pod,
      'pol': i.pol,
      'containerCountAndSizes': i.containerCountAndSizes,
      'grossWeight': i.grossWeight?.toString(),
      'netWeight': i.netWeight?.toString(),
      'packageDescription': i.packageDescription,
      'samplePlaceAndDate': i.samplePlaceAndDate,
      'cuttingTestPlaceAndDate': i.cuttingTestPlaceAndDate,
      'isAuthorized': i.isAuthorized,
      'authorizedSignature': i.authorizedSignature,
      'conclusion': i.kor >= 48.0
          ? 'This batch meets all export quality standards for Grade A raw cashew nuts. Approved for shipment.'
          : 'This batch is below standard for export quality.',
    };
  }

  Future<void> _shareReport(BuildContext context, Inspection i) async {
    try {
      // Ask if user wants to sign digitally
      final signature = await _showSignatureDialog(context);
      if (signature == null) return; // User cancelled

      final pdfService = PdfService();
      final data = await _prepareReportData(i);
      if (signature.isNotEmpty) {
        data['signature'] = signature;
      }
      final pdfBytes = await pdfService.generateReport(data);

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/analysis_report_${i.batchId ?? 'temp'}.pdf');
      await file.writeAsBytes(pdfBytes);

      if (!context.mounted) return;

      // Get the render box of the button that triggered this action
      final box = context.findRenderObject() as RenderBox?;

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Analysis Report for Batch ${i.batchId ?? 'N/A'}',
        sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      );
    } catch (e) {
      debugPrint('Error sharing report: $e');
    }
  }

  Future<void> _downloadReport(BuildContext context, Inspection i) async {
    try {
      // Ask if user wants to sign digitally
      final signature = await _showSignatureDialog(context);
      if (signature == null) return; // User cancelled

      final pdfService = PdfService();
      final data = await _prepareReportData(i);
      if (signature.isNotEmpty) {
        data['signature'] = signature;
      }
      final pdfBytes = await pdfService.generateReport(data);

      if (kIsWeb) {
        await Printing.layoutPdf(
          onLayout: (format) async => pdfBytes,
          name: 'analysis_report_${i.batchId ?? 'temp'}.pdf',
        );
      } else {
        // Save file to temp directory first
        final directory = await getTemporaryDirectory();
        final fileName = 'analysis_report_${i.batchId ?? 'temp'}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(pdfBytes);

        // Ask user where to save the file
        final params = SaveFileDialogParams(sourceFilePath: file.path);
        final filePath = await FlutterFileDialog.saveFile(params: params);

        if (context.mounted && filePath != null) {
          CustomSnackBar.success(
            context,
            message: 'Report saved',
            duration: const Duration(seconds: 4),
          );

          await OpenFilex.open(filePath);
        }
      }
    } catch (e) {
      debugPrint('Error downloading report: $e');
      if (context.mounted) {
        CustomSnackBar.error(
          context,
          message: 'Failed to save report: $e',
        );
      }
    }
  }

  Future<String?> _showSignatureDialog(BuildContext context) async {
    final user = ref.read(currentUserProfileProvider).value;
    final defaultInitials = _getUserInitials(user);

    final controller = TextEditingController(text: defaultInitials);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Digital Signature'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Would you like to sign this report digitally?'),
            const SizedBox(height: 16),
            const Text('Enter your initials (optional):', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'e.g., J.D.',
                border: OutlineInputBorder(),
              ),
              maxLength: 10,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Sign'),
          ),
        ],
      ),
    );
  }

  String _getInspectorFullName() {
    final user = ref.read(currentUserProfileProvider).value;
    if (user != null) {
      return '${user.firstName} ${user.lastName}'.trim();
    }
    return widget.inspection.inspectorId;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: CustomText(
        title,
        variant: TextVariant.headlineSmall,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Future<void> _exportSingleExcel(BuildContext context, Inspection i) async {
    try {
      final user = ref.read(currentUserProfileProvider).value;
      if (user == null) {
        CustomSnackBar.error(context, message: 'User profile not found');
        return;
      }
      await ExcelExportService.exportInspections(
        inspections: [i],
        currentUser: user,
        filenamePrefix: 'inspection_${i.batchId ?? i.id}',
      );
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.error(context, message: 'Export failed: $e');
      }
    }
  }

  String _getUserInitials(AppUser? user) {
    if (user == null) return '';
    final firstInitial = user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '';
    final lastInitial = user.lastName.isNotEmpty ? user.lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(label, variant: TextVariant.bodyMedium, color: Theme.of(context).colorScheme.secondary),
          CustomText(value, variant: TextVariant.bodyMedium, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }
}
