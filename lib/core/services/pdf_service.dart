import 'dart:typed_data';

import 'package:cqaag_app/index.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  Future<Uint8List> generateReport(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    // Load Logo
    final logoSvg = await rootBundle.loadString(Assets.svgLogoBlack);

    final font = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    final theme = pw.ThemeData.withFont(
      base: font,
      bold: fontBold,
    );

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(30),
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(logoSvg, data),
              pw.SizedBox(height: 10),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(child: _buildInfoBlock(data)),
                  pw.SizedBox(width: 15),
                  pw.Container(
                    width: 100,
                    height: 100,
                    child: pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: 'inspection:${data['inspectionId'] ?? data['id']}',
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 15),
              _buildAnalysisTable(data),
              pw.SizedBox(height: 15),
              _buildKORBlock(data),
              pw.SizedBox(height: 20),
              _buildSignatures(data),
              pw.Spacer(),
              _buildProtocolFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(String logoSvg, Map<String, dynamic> data) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          width: 60,
          height: 60,
          child: pw.SvgImage(svg: logoSvg),
        ),
        pw.SizedBox(width: 15),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                "CASHEW QUALITY ANALYSTS' ASSOCIATION, GHANA (C.Q.A.A.G)",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green900,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 5),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                decoration: const pw.BoxDecoration(color: PdfColors.black),
                child: pw.Text(
                  "RCN QUALITY REPORT",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildInfoBlock(Map<String, dynamic> data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.5),
      ),
      child: pw.Column(
        children: [
          _buildInfoRow('QC CODE: CERTIFICATE NO.', (data['id'] ?? '').toString().toUpperCase()),
          _buildInfoRow('SUPPLIER /COMPANY NAME:', data['company'] ?? ''),
          _buildInfoRow('BUYER /COMPANY NAME:', data['buyerName'] ?? ''),
          _buildInfoRow('ORIGIN (COUNTRY):', 'GHANA'),
          _buildInfoRow(
            'ORIGIN (REGION-DISTRICT-TOWN):',
            [data['chapter'], data['district'], data['town']].where((e) => e != null && e.toString().isNotEmpty && e != 'null').join(' - '),
          ),
          _buildInfoRow('WAYBILL OR B/L N°:', data['waybillNumber'] ?? ''),
          _buildInfoRow('ANALYSIS TYPE:', data['analysisType'] ?? ''),
          pw.Row(
            children: [
              pw.Expanded(child: _buildInfoRow('QUANTITY (KG/MT):', data['quantity'] ?? '')),
              pw.SizedBox(width: 10),
              pw.Expanded(child: _buildInfoRow('BAGS:', data['bagCount'] ?? '')),
            ],
          ),
          _buildInfoRow('DATE & PLACE OF SAMPLING:', '${data['date']} - ${data['location']}'),
          _buildInfoRow('DATE & PLACE OF CUTTING TEST:', '${data['date']} - ${data['location']}'),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(width: 5),
          pw.Expanded(
            child: pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(width: 0.5, style: pw.BorderStyle.dotted)),
              ),
              child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildAnalysisTable(Map<String, dynamic> data) {
    // Each cut test performed gets its own column; the report always shows
    // three slots so the sheet keeps its familiar shape even when only one or
    // two cut tests were required.
    final cuts = (data['cutTests'] as List<CutTest>?) ?? const <CutTest>[];
    const slots = 3;

    String headingFor(int slot) {
      if (slot < cuts.length) return cuts[slot].displayLabel;
      return switch (slot) {
        1 => '2nd Cutting',
        2 => '3rd Cutting',
        _ => '',
      };
    }

    final headers = <String>[
      'Parameter',
      for (var i = 0; i < slots; i++) headingFor(i),
      'AVERAGE',
    ];

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(4),
        1: const pw.FlexColumnWidth(1.2),
        2: const pw.FlexColumnWidth(1.2),
        3: const pw.FlexColumnWidth(1.2),
        4: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children: headers
              .map(
                (h) => pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Center(
                    child: pw.Text(h, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                  ),
                ),
              )
              .toList(),
        ),

        _buildDataRow('MOISTURE CONTENT (%)', cuts, (c) => c.moistureContent),
        _buildDataRow('NUT COUNT (per Kg)', cuts, (c) => c.nutCount.toDouble(), decimals: 0),

        _buildSectionHeaderRow('FULLY DAMAGED NUTS (gm)'),
        _buildDataRow('  FULLY DAMAGED NUTS (gm)', cuts, (c) => c.fullyDamagedNuts),
        _buildDataRow('  VOID NUTS (gm)', cuts, (c) => c.voidNuts),
        _buildDataRow('  OIL NUTS (gm)', cuts, (c) => c.oilNuts),
        _buildDataRow('  TOTAL (gm)', cuts, (c) => c.totalDamaged, isBold: true),

        _buildSectionHeaderRow('SPOTTED/PARTLY SOUND NUTS (gm)'),
        _buildDataRow('  SPOTTED/PARTLY SOUND (gm)', cuts, (c) => c.spottedNuts),
        _buildDataRow('  IMMATURE NUTS (gm)', cuts, (c) => c.immatureNuts),
        _buildDataRow('  TOTAL (gm)', cuts, (c) => c.totalSpotted, isBold: true),
        _buildDataRow('  50% of above TOTAL (gm)', cuts, (c) => c.halfTotalSpotted),

        _buildDataRow('GOOD KERNELS (gm)', cuts, (c) => c.goodKernels),
        _buildDataRow('TOTAL YIELD (gm)', cuts, (c) => c.totalYield, isBold: true),
        _buildDataRow('EMPTY SHELLS (gm)', cuts, (c) => c.emptyShells),
        _buildDataRow('TOTAL (gm)', cuts, (c) => c.total),
        _buildDataRow('OUTTURN (KOR) - LBS', cuts, (c) => c.kor, isBold: true, decimals: 2),
      ],
    );
  }

  /// One parameter row: a cell per cut test, then the mean of those cut tests.
  ///
  /// Every cell is constructed separately because a pdf widget cannot be laid
  /// out in two places.
  pw.TableRow _buildDataRow(
    String label,
    List<CutTest> cuts,
    double Function(CutTest) select, {
    bool isBold = false,
    int decimals = 1,
  }) {
    const slots = 3;

    String format(double value) => value.toStringAsFixed(decimals);

    final average = cuts.isEmpty ? null : cuts.map(select).reduce((a, b) => a + b) / cuts.length;

    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: pw.Text(label, style: pw.TextStyle(fontSize: 8, fontWeight: isBold ? pw.FontWeight.bold : null)),
        ),
        for (var i = 0; i < slots; i++)
          _buildValueCell(i < cuts.length ? format(select(cuts[i])) : '', isBold: isBold),
        _buildValueCell(average == null ? '-' : format(average), isBold: true),
      ],
    );
  }

  pw.Widget _buildValueCell(String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(2),
      child: pw.Center(
        child: pw.Text(value, style: pw.TextStyle(fontSize: 8, fontWeight: isBold ? pw.FontWeight.bold : null)),
      ),
    );
  }

  pw.Widget _buildEmptyCell() => pw.Container();

  pw.TableRow _buildSectionHeaderRow(String label) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, fontStyle: pw.FontStyle.italic),
          ),
        ),
        _buildEmptyCell(),
        _buildEmptyCell(),
        _buildEmptyCell(),
        _buildEmptyCell(),
      ],
    );
  }

  pw.Widget _buildKORBlock(Map<String, dynamic> data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1),
        color: PdfColors.grey100,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text("OUTTURN (KOR) - LBS: ", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.Text(data['kor'] ?? '', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  pw.Widget _buildSignatures(Map<String, dynamic> data) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Name of Quality Analyst (QC): ${data['inspector'] ?? ''}", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 15),
            if (data['signature'] != null && data['signature'].toString().isNotEmpty)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Sign:", style: const pw.TextStyle(fontSize: 9)),
                  pw.Text(
                    data['signature'],
                    style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              )
            else
              pw.Text("Sign: ___________________", style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Export / Buyer Rep: ___________________", style: const pw.TextStyle(fontSize: 9)),
            pw.SizedBox(height: 15),
            pw.Text("Sign: ___________________", style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildProtocolFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Text(
          '"Guardians of Ghana\'s Cashew Quality"',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, fontStyle: pw.FontStyle.italic),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          "CQAAG Standardized Cut Test Protocol",
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          "Arrival Inspection: Quantities ≤ 10 Tons: Perform one (1) mandatory cut test. > 10 Tons: Two (2) tests average.\nDispatch Inspection: Perform two (2) mandatory cut tests and calculate average.",
          style: const pw.TextStyle(fontSize: 8),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          "Address: Wenchi, Bono Region-Ghana  Tel: +233553330931  Email: ghcashewqualityanalyst@gmail.com",
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }
}
