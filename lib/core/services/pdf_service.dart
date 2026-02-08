import 'dart:typed_data';

import 'package:cqaag_app/index.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class PdfService {
  Future<Uint8List> generateReport(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    // Load Logo (SVG)
    final logoSvg = await rootBundle.loadString(Assets.svgLogoBlack);

    final date = DateTime.now();
    final formattedDate = DateFormat('MMMM d, yyyy').format(date);

    // Font setup (using standard fonts for now, custom fonts can be added if needed)
    final theme = pw.ThemeData.withFont(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300, width: 2),
              ),
            ),
          ),
        ),
        header: (context) => _buildHeader(context, logoSvg, formattedDate),
        footer: (context) => _buildFooter(context),
        build: (pw.Context context) => [
          pw.SizedBox(height: 20),
          _buildTitle(data),
          pw.SizedBox(height: 30),
          _buildBatchInfo(data),
          pw.SizedBox(height: 30),
          _buildQualityMetrics(data),
          pw.SizedBox(height: 30),
          _buildConclusion(data),
          pw.SizedBox(height: 40),
          _buildSignatureSection(),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(pw.Context context, String logoSvg, String date) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.SvgImage(svg: logoSvg, width: 80, height: 80),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'CASHEW QUALITY ANALYSTS\'',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
                ),
                pw.Text(
                  'ASSOCIATION OF GHANA (C.Q.A.A.G)',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
                ),
                pw.SizedBox(height: 4),
                pw.Text('Professional Quality Export Report', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                pw.SizedBox(height: 4),
                pw.Text('Date: $date', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: PdfColors.grey400, thickness: 1),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildTitle(Map<String, dynamic> data) {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            'CERTIFICATE OF QUALITY ANALYSIS',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.brown800),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Ref No: ${data['batchId'] ?? 'N/A'}',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildBatchInfo(Map<String, dynamic> data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'BATCH INFORMATION',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem('Date of Inspection', data['date'] ?? 'N/A'),
              _buildInfoItem('Location', data['location'] ?? 'N/A'),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem('Company / Exporter', data['company'] ?? 'N/A'),
              _buildInfoItem('Truck Number', data['truckNumber'] ?? 'N/A'),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem('Quantity', data['quantity'] != null ? '${data['quantity']} MT' : 'N/A'),
              _buildInfoItem('Bag Count', data['bagCount'] ?? 'N/A'),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoItem(String label, String value) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildQualityMetrics(Map<String, dynamic> data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.brown50),
          children: [
            _buildTableHeader('Parameter'),
            _buildTableHeader('Standard'),
            _buildTableHeader('Actual Value'),
            _buildTableHeader('Status'),
          ],
        ),
        // Rows
        _buildTableRow('Nut Count', '170-200 / kg', data['nutCount']?.toString() ?? 'N/A', data['nutCountStatus'] ?? 'Pass'),
        _buildTableRow('Moisture Content', 'Max 10%', '${data['moisture'] ?? 'N/A'}', data['moistureStatus'] ?? 'Pass'),
        _buildTableRow('Kernel Output Ratio (KOR)', 'Min 48 lbs', data['kor']?.toString() ?? 'N/A', data['korStatus'] ?? 'Pass'),
        _buildTableRow('Defective Rate', 'Max 10%', '${data['defectiveRate'] ?? 'N/A'}', data['defectiveStatus'] ?? 'Pass'),
        _buildTableRow('Void Kernels', '-', '${data['voidKernels'] ?? 0} g', 'N/A'),
        _buildTableRow('Spotted Kernels', '-', '${data['spottedKernels'] ?? 0} g', 'N/A'),
      ],
    );
  }

  pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
    );
  }

  pw.TableRow _buildTableRow(String parameter, String standard, String value, String status) {
    // Determine status color/style
    PdfColor statusColor = PdfColors.black;
    if (status == 'Pass' || status == 'EXPORT READY') {
      statusColor = PdfColors.green700;
    } else if (status == 'Fail' || status == 'BELOW STANDARD') {
      statusColor = PdfColors.red700;
    }

    // Formatting value if it looks like a clean number to remove trailing .0 if present for integers
    if (value.endsWith('.0')) {
      value = value.replaceAll('.0', '');
    }

    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(parameter, style: const pw.TextStyle(fontSize: 10)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(standard, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            status,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: statusColor),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildConclusion(Map<String, dynamic> data) {
    final conclusion = data['conclusion'] ?? 'Based on the analysis, this batch meets the requirements for export quality grade Raw Cashew Nuts.';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'REMARKS / CONCLUSION',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
        ),
        pw.SizedBox(height: 5),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            color: PdfColors.grey50,
          ),
          child: pw.Text(conclusion, style: const pw.TextStyle(fontSize: 10)),
        ),
      ],
    );
  }

  pw.Widget _buildSignatureSection() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(width: 150, height: 1, color: PdfColors.black),
            pw.SizedBox(height: 5),
            pw.Text('Authorized Signature', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            pw.Text('Quality Control Manager', style: const pw.TextStyle(fontSize: 8)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(width: 150, height: 1, color: PdfColors.black),
            pw.SizedBox(height: 5),
            pw.Text('Received By', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            pw.Text('Warehouse Manager / Driver', style: const pw.TextStyle(fontSize: 8)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('Generated by C.Q.A.A.G App', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
        pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
      ],
    );
  }
}
