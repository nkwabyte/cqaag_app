import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';
import 'package:printing/printing.dart'; // For PDF preview/printing/sharing
import 'package:cqaag_app/core/services/pdf_service.dart';

class AnalysisReportScreen extends StatelessWidget {
  static const String id = 'analysis_report_screen';

  final Map<String, dynamic>? reportData;

  const AnalysisReportScreen({super.key, this.reportData});

  @override
  Widget build(BuildContext context) {
    // Dummy data if none passed
    final data =
        reportData ??
        {
          'batchId': 'BATCH-2026-001',
          'date': '2026-02-01',
          'location': 'Wenchi Warehouse A',
          'moisture': '9.5%',
          'moistureStatus': 'Pass',
          'nutCount': '170',
          'nutCountStatus': 'Pass',
          'kor': '48 lbs',
          'korStatus': 'Pass',
          'defectiveRate': '4.2%',
          'defectiveStatus': 'Pass',
          'conclusion': 'This batch meets all export quality standards for Grade A raw cashew nuts. Approved for shipment.',
        };

    return Scaffold(
      appBar: AppBar(
        title: const CustomText('Analysis Report', variant: TextVariant.bodyLarge, color: Colors.white),
        backgroundColor: AppColors.darkRed,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final pdfService = PdfService();
              final pdfBytes = await pdfService.generateReport(data);
              await Printing.sharePdf(bytes: pdfBytes, filename: 'analysis_report.pdf');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Header
            Center(
              child: Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: Colors.green, size: 64.r),
              ),
            ),
            Gap(16.h),
            Center(
              child: CustomText(
                'Analysis Complete',
                variant: TextVariant.headlineMedium,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            Gap(8.h),
            Center(
              child: CustomText(
                'Batch ID: ${data['batchId']}',
                variant: TextVariant.bodyMedium,
                color: Colors.grey.shade600,
              ),
            ),
            Gap(32.h),

            // Report Details Card
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Date', data['date']),
                  _buildDetailRow('Location', data['location']),
                  const Divider(),
                  _buildDetailRow('Moisture', data['moisture'], status: data['moistureStatus']),
                  _buildDetailRow('Nut Count', data['nutCount'], status: data['nutCountStatus']),
                  _buildDetailRow('KOR', data['kor'], status: data['korStatus']),
                  _buildDetailRow('Defects', data['defectiveRate'], status: data['defectiveStatus']),
                ],
              ),
            ),
            Gap(32.h),

            // Actions
            CustomButton(
              text: 'Download / Print PDF',
              onPressed: () async {
                final pdfService = PdfService();
                final pdfBytes = await pdfService.generateReport(data);
                await Printing.layoutPdf(
                  onLayout: (format) async => pdfBytes,
                  name: 'analysis_report.pdf',
                );
              },
              backgroundColor: AppColors.darkBrown,
              textColor: Colors.white,
              trailingIcon: const Icon(Icons.print, color: Colors.white),
            ),
            Gap(16.h),
            CustomButton(
              text: 'Share Report',
              onPressed: () async {
                final pdfService = PdfService();
                final pdfBytes = await pdfService.generateReport(data);
                await Printing.sharePdf(bytes: pdfBytes, filename: 'analysis_report.pdf');
              },
              backgroundColor: Colors.white,
              textColor: AppColors.darkBrown,
              trailingIcon: const Icon(Icons.share, color: AppColors.darkBrown),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {String? status}) {
    Color? statusColor;
    if (status == 'Pass') {
      statusColor = Colors.green;
    } else if (status == 'Fail') {
      statusColor = Colors.red;
    } else if (status == 'Conditional') {
      statusColor = Colors.amber;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(label, variant: TextVariant.bodyMedium, color: Colors.grey.shade700),
          Row(
            children: [
              CustomText(value, variant: TextVariant.bodyMedium, fontWeight: FontWeight.bold),
              if (status != null) ...[
                Gap(8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: statusColor?.withValues(alpha: 0.1) ?? Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: CustomText(
                    status,
                    variant: TextVariant.bodySmall,
                    color: statusColor ?? Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
