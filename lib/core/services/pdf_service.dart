import 'dart:typed_data';

import 'package:cqaag_app/index.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  PdfService({Future<pw.Font> Function()? regularFont, Future<pw.Font> Function()? boldFont})
    : _regularFont = regularFont ?? PdfGoogleFonts.openSansRegular,
      _boldFont = boldFont ?? PdfGoogleFonts.openSansBold;

  final Future<pw.Font> Function() _regularFont;
  final Future<pw.Font> Function() _boldFont;

  Future<Uint8List> generateReport(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    // Load Logos
    final logoSvg = await rootBundle.loadString(Assets.svgLogoBlack);

    pw.MemoryImage? cqaagLogoImage;
    try {
      final cqaagLogoBytes = await rootBundle.load('assets/images/cqaag_logo.png');
      cqaagLogoImage = pw.MemoryImage(cqaagLogoBytes.buffer.asUint8List());
    } catch (_) {}

    pw.MemoryImage? tcdaLogoImage;
    try {
      final tcdaLogoBytes = await rootBundle.load('assets/images/tcda_logo.jpg');
      tcdaLogoImage = pw.MemoryImage(tcdaLogoBytes.buffer.asUint8List());
    } catch (_) {}

    pw.MemoryImage? ccgLogoImage;
    try {
      final ccgLogoBytes = await rootBundle.load('assets/images/ccg_logo.jpeg');
      ccgLogoImage = pw.MemoryImage(ccgLogoBytes.buffer.asUint8List());
    } catch (_) {}

    // An approved Export certificate carries the seal copied on at approval:
    // the signed seal admins uploaded, or failing that the association logo.
    final approvalStatus = (data['approvalStatus'] ?? 'not_required').toString();
    pw.ImageProvider? sealImage;
    if (approvalStatus == 'approved') {
      final sealUrl = (data['approvalSealUrl'] ?? '').toString();
      if (sealUrl.startsWith('http')) {
        try {
          sealImage = await networkImage(sealUrl);
        } catch (_) {}
      }
      sealImage ??= cqaagLogoImage;
    }

    final font = await _regularFont();
    final fontBold = await _boldFont();

    final theme = pw.ThemeData.withFont(
      base: font,
      bold: fontBold,
    );

    final isExport = (data['analysisType'] ?? '').toString().toLowerCase().contains('export');

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          buildForeground: isExport && approvalStatus != 'approved'
              ? (context) => _buildNotValidWatermark(approvalStatus == 'declined')
              : null,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(logoSvg, ccgLogoImage, tcdaLogoImage, data, isExport),
              pw.SizedBox(height: 8),
              if (isExport) ...[
                _buildExportInfoBlock(data),
              ] else ...[
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(child: _buildInfoBlock(data)),
                    pw.SizedBox(width: 12),
                    pw.Container(
                      width: 90,
                      height: 90,
                      child: pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: 'inspection:${data['inspectionId'] ?? data['id']}',
                      ),
                    ),
                  ],
                ),
              ],
              pw.SizedBox(height: 10),
              _buildAnalysisTable(data),
              pw.SizedBox(height: 10),
              _buildKORAndCertBlock(data),
              pw.SizedBox(height: 10),
              _buildStandaloneTcdaSection(tcdaLogoImage),
              pw.SizedBox(height: 10),
              _buildSignatures(data, isExport),
              if (isExport) ...[
                pw.SizedBox(height: 8),
                _buildApprovalBlock(data, approvalStatus, sealImage),
                pw.SizedBox(height: 4),
                pw.Text(
                  "*NOTE: Export has to be authorised and required cutting pictures.*",
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.red900,
                  ),
                ),
              ],
              pw.Spacer(),
              _buildProtocolFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(
    String logoSvg,
    pw.MemoryImage? ccgImage,
    pw.MemoryImage? tcdaImage,
    Map<String, dynamic> data,
    bool isExport,
  ) {
    final rawAnalysisType = (data['analysisType'] ?? '').toString().trim();
    final String certificateTitle = isExport
        ? "EXPORT RCN QUALITY CERTIFICATE"
        : (rawAnalysisType.isNotEmpty
            ? "RCN QUALITY CERTIFICATE - ${rawAnalysisType.toUpperCase()}"
            : "RCN QUALITY CERTIFICATE");

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // Cashew Council of Ghana first, then the association's own logo.
        pw.Container(
          width: 46,
          height: 46,
          child: ccgImage != null
              ? pw.Image(ccgImage, fit: pw.BoxFit.contain)
              : pw.Center(child: pw.Text('CCG', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
        ),
        pw.SizedBox(width: 4),
        pw.Container(
          width: 46,
          height: 46,
          child: pw.SvgImage(svg: logoSvg),
        ),
        pw.SizedBox(width: 6),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                "CASHEW QUALITY ANALYSTS' ASSOCIATION, GHANA (C.Q.A.A.G)",
                style: pw.TextStyle(
                  fontSize: 11.5,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green900,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Motto: "Guardians of Ghana\'s Cashew Quality"',
                style: pw.TextStyle(
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.green800,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 3),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 2.5),
                decoration: const pw.BoxDecoration(color: PdfColors.black),
                child: pw.Text(
                  certificateTitle,
                  style: pw.TextStyle(
                    fontSize: 10.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 6),
        if (tcdaImage != null)
          pw.Container(
            width: 46,
            height: 46,
            child: pw.Image(tcdaImage, fit: pw.BoxFit.contain),
          )
        else
          pw.SizedBox(width: 46),
      ],
    );
  }

  /// CQAAG APPROVAL block of an Export certificate: the official seal (with
  /// the president's signature embedded when the signed seal is on file) and
  /// the date and time of approval.
  pw.Widget _buildApprovalBlock(Map<String, dynamic> data, String approvalStatus, pw.ImageProvider? seal) {
    final approved = approvalStatus == 'approved';
    final declined = approvalStatus == 'declined';
    final includesSignature = data['approvalSealIncludesSignature'] == true;
    final approvedAt = DateTime.tryParse((data['approvedAt'] ?? '').toString());

    final statusLine = approved
        ? 'CQAAG APPROVED — VALID CERTIFICATE'
        : (declined ? 'NOT APPROVED BY CQAAG — NOT A VALID CERTIFICATE' : 'PENDING CQAAG APPROVAL — NOT YET VALID');
    final color = approved ? PdfColors.green900 : PdfColors.red900;

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 1, color: color)),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (approved && seal != null) ...[
            pw.SizedBox(width: 72, height: 72, child: pw.Image(seal, fit: pw.BoxFit.contain)),
            pw.SizedBox(width: 10),
          ],
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('CQAAG APPROVAL', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                pw.SizedBox(height: 2),
                pw.Text(statusLine, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: color)),
                if (approved) ...[
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Approved on: ${approvedAt == null ? '-' : AgreementPdfService.formatSignedAt(approvedAt)}',
                    style: const pw.TextStyle(fontSize: 8.5),
                  ),
                  if ((data['approvedByName'] ?? '').toString().isNotEmpty)
                    pw.Text('Approved by: ${data['approvedByName']}', style: const pw.TextStyle(fontSize: 8.5)),
                  pw.Text(
                    includesSignature
                        ? 'Official seal of the Association with the signature of the President embedded.'
                        : 'Official seal of the Association.',
                    style: pw.TextStyle(fontSize: 7.5, fontStyle: pw.FontStyle.italic),
                  ),
                ] else if (declined && (data['declineReason'] ?? '').toString().isNotEmpty)
                  pw.Text('Reason: ${data['declineReason']}', style: const pw.TextStyle(fontSize: 8.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildNotValidWatermark(bool declined) {
    return pw.FullPage(
      ignoreMargins: true,
      child: pw.Center(
        child: pw.Transform.rotate(
          angle: 0.6,
          child: pw.Opacity(
            opacity: 0.12,
            child: pw.Text(
              declined ? 'NOT APPROVED' : 'PENDING CQAAG APPROVAL',
              style: pw.TextStyle(fontSize: 54, fontWeight: pw.FontWeight.bold, color: PdfColors.red900),
            ),
          ),
        ),
      ),
    );
  }

  /// Standard Quality Certificate Info Block
  pw.Widget _buildInfoBlock(Map<String, dynamic> data) {
    final qcCode = data['qcCode'] ?? (data['id'] ?? '').toString().toUpperCase();

    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.5),
      ),
      child: pw.Column(
        children: [
          _buildInfoRow('QC-CODE : CERTIFICATE NO.', qcCode),
          _buildInfoRow('SUPPLIER /COMPANY NAME:', data['company'] ?? ''),
          _buildInfoRow('BUYER /COMPANY NAME:', data['buyerName'] ?? ''),
          _buildInfoRow('ORIGIN (COUNTRY):', 'GHANA'),
          _buildInfoRow(
            'ORIGIN (REGION-DISTRICT-TOWN):',
            [data['chapter'], data['district'], data['town']]
                .where((e) => e != null && e.toString().isNotEmpty && e != 'null')
                .join(' - '),
          ),
          _buildInfoRow('WAYBILL OR B/L N°:', data['waybillNumber'] ?? data['blNumber'] ?? ''),
          _buildInfoRow('ANALYSIS TYPE:', data['analysisType'] ?? ''),
          pw.Row(
            children: [
              pw.Expanded(child: _buildInfoRow('QUANTITY (KG):', data['quantity'] ?? '')),
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

  /// Dedicated EXPORT RCN QUALITY CERTIFICATE Details Block
  pw.Widget _buildExportInfoBlock(Map<String, dynamic> data) {
    final qcCode = data['qcCode'] ?? (data['id'] ?? '').toString().toUpperCase();

    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.8),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            children: [
              pw.Expanded(child: _buildInfoRow('QC-CODE :', qcCode)),
              pw.SizedBox(width: 15),
              pw.Expanded(child: _buildInfoRow('B/L No. :', data['blNumber'] ?? data['waybillNumber'] ?? '')),
            ],
          ),
          pw.Row(
            children: [
              pw.Expanded(child: _buildInfoRow('SHIPPER DETAILS :', data['shipperDetails'] ?? data['company'] ?? '')),
              pw.SizedBox(width: 15),
              pw.Expanded(child: _buildInfoRow('CONSIGNEE DETAILS :', data['consigneeDetails'] ?? data['buyerName'] ?? '')),
            ],
          ),
          pw.Row(
            children: [
              pw.Expanded(child: _buildInfoRow('ORIGIN (COUNTRY) :', data['originCountry'] ?? 'GHANA')),
              pw.SizedBox(width: 15),
              pw.Expanded(child: _buildInfoRow('DESTINATION (COUNTRY) :', data['destinationCountry'] ?? '')),
            ],
          ),
          _buildInfoRow('NAME AND DESCRIPTION OF TRANSPORT :', data['transportDescription'] ?? data['truckNumber'] ?? ''),
          pw.Row(
            children: [
              pw.Expanded(child: _buildInfoRow('POL (Port Of Loading) :', data['pol'] ?? 'PORT OF TEMA')),
              pw.SizedBox(width: 15),
              pw.Expanded(child: _buildInfoRow('POD (Port of Destination) :', data['pod'] ?? '')),
            ],
          ),
          pw.Row(
            children: [
              pw.Expanded(child: _buildInfoRow('NUMBER OF CONTAINERS & SIZES :', data['containerCountAndSizes'] ?? '')),
              pw.SizedBox(width: 15),
              pw.Expanded(child: _buildInfoRow('PACKAGES :', data['packageDescription'] ?? '${data['bagCount'] ?? ''} Bags')),
            ],
          ),
          pw.Row(
            children: [
              pw.Expanded(child: _buildInfoRow('GROSS WEIGHT :', '${data['grossWeight'] ?? data['quantity'] ?? ''} KG')),
              pw.SizedBox(width: 15),
              pw.Expanded(child: _buildInfoRow('NET WEIGHT :', '${data['netWeight'] ?? data['quantity'] ?? ''} KG')),
            ],
          ),
          pw.Row(
            children: [
              pw.Expanded(child: _buildInfoRow('PLACE AND DATE OF SAMPLE :', data['samplePlaceAndDate'] ?? '${data['location']} - ${data['date']}')),
              pw.SizedBox(width: 15),
              pw.Expanded(child: _buildInfoRow('PLACE AND DATE OF CUTTING TEST :', data['cuttingTestPlaceAndDate'] ?? '${data['location']} - ${data['date']}')),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(width: 4),
          pw.Expanded(
            child: pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(width: 0.5, style: pw.BorderStyle.dotted)),
              ),
              child: pw.Text(
                value,
                style: const pw.TextStyle(fontSize: 8.5),
                maxLines: 1,
                overflow: pw.TextOverflow.clip,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildAnalysisTable(Map<String, dynamic> data) {
    final rawCuts = (data['cutTests'] as List<CutTest>?) ?? const <CutTest>[];
    final cuts = rawCuts.where((c) => !c.isEmpty).toList();
    const slots = 3;

    String headingFor(int slot) {
      return switch (slot) {
        0 => '1st Cutting',
        1 => '2nd Cutting',
        2 => '3rd Cutting',
        _ => 'Cutting ${slot + 1}',
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
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: headers
              .map(
                (h) => pw.Padding(
                  padding: const pw.EdgeInsets.all(3),
                  child: pw.Center(
                    child: pw.Text(h, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7.5)),
                  ),
                ),
              )
              .toList(),
        ),
        _buildDataRow('MOISTURE CONTENT (%)', cuts, (c) => c.moistureContent),
        _buildDataRow('NUT COUNT (per Kg)', cuts, (c) => c.nutCount.toDouble(), decimals: 0),
        _buildDataRow('FULLY DAMAGED NUTS (gm)', cuts, (c) => c.fullyDamagedNuts, isGroupHeading: true),
        _buildDataRow('  VOID NUTS (gm)', cuts, (c) => c.voidNuts),
        _buildDataRow('  OIL NUTS (gm)', cuts, (c) => c.oilNuts),
        _buildDataRow('  TOTAL (gm)', cuts, (c) => c.totalDamaged, isBold: true),
        _buildDataRow('SPOTTED/PARTLY SOUND NUTS (gm)', cuts, (c) => c.spottedNuts, isGroupHeading: true),
        _buildDataRow('  IMMATURE NUTS (gm)', cuts, (c) => c.immatureNuts),
        _buildDataRow('  TOTAL (gm)', cuts, (c) => c.totalSpotted, isBold: true),
        _buildDataRow('  50% of above TOTAL (gm)', cuts, (c) => c.halfTotalSpotted),
        _buildDataRow('GOOD KERNELS (gm)', cuts, (c) => c.goodKernels),
        _buildDataRow('TOTAL YIELD (gm)', cuts, (c) => c.totalYield, isBold: true),
        _buildDataRow('EMPTY SHELLS (gm)', cuts, (c) => c.emptyShells),
        _buildDataRow('TOTAL (gm)', cuts, (c) => c.total, isBold: true),
        _buildDataRow('OUTTURN (KOR) - LBS', cuts, (c) => c.kor, isBold: true, decimals: 2),
      ],
    );
  }

  pw.TableRow _buildDataRow(
    String label,
    List<CutTest> cuts,
    double Function(CutTest) select, {
    bool isBold = false,
    bool isGroupHeading = false,
    int decimals = 1,
  }) {
    const slots = 3;

    String format(double value) => value.toStringAsFixed(decimals);

    final activeCuts = cuts.where((c) => !c.isEmpty).toList();
    final average = activeCuts.isEmpty ? null : activeCuts.map(select).reduce((a, b) => a + b) / activeCuts.length;
    final emphasised = isBold || isGroupHeading;

    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 1.5, horizontal: 3),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 7.5,
              fontWeight: emphasised ? pw.FontWeight.bold : null,
              fontStyle: isGroupHeading ? pw.FontStyle.italic : null,
            ),
          ),
        ),
        for (var i = 0; i < slots; i++)
          _buildValueCell(i < activeCuts.length ? format(select(activeCuts[i])) : '-', isBold: emphasised),
        _buildValueCell(average == null ? '-' : format(average), isBold: true),
      ],
    );
  }

  pw.Widget _buildValueCell(String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(1.5),
      child: pw.Center(
        child: pw.Text(value, style: pw.TextStyle(fontSize: 7.5, fontWeight: isBold ? pw.FontWeight.bold : null)),
      ),
    );
  }

  pw.Widget _buildKORAndCertBlock(Map<String, dynamic> data) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1, color: PdfColors.green900),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
        color: PdfColors.grey100,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            "OUTTURN (KOR) - LBS: ",
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            data['kor'] ?? '',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green900),
          ),
        ],
      ),
    );
  }

  /// Standalone TCDA Authority Section
  pw.Widget _buildStandaloneTcdaSection(pw.MemoryImage? tcdaImage) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.8, color: PdfColors.green900),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
        color: PdfColors.green50,
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (tcdaImage != null) ...[
            pw.Container(
              width: 32,
              height: 32,
              child: pw.Image(tcdaImage, fit: pw.BoxFit.contain),
            ),
            pw.SizedBox(width: 8),
          ] else ...[
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: const pw.BoxDecoration(
                color: PdfColors.green900,
              ),
              child: pw.Text(
                "TCDA",
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              ),
            ),
            pw.SizedBox(width: 8),
          ],
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "TREE CROP DEVELOPMENT AUTHORITY (TCDA) - STATUTORY REGULATORY AUTHORITY",
                  style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.green900),
                ),
                pw.SizedBox(height: 1),
                pw.Text(
                  "Conforms to official Cashew Quality Regulations established under the Tree Crop Development Authority Act (Act 1010). Certified and recognized nationwide.",
                  style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSignatures(Map<String, dynamic> data, bool isExport) {
    final qcCode = data['qcCode'] ?? '';
    final inspector = data['inspector'] ?? '';

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "Quality Analyst (QC): $inspector ${qcCode.isNotEmpty ? '($qcCode)' : ''}",
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            if (data['signature'] != null && data['signature'].toString().isNotEmpty)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Sign:", style: const pw.TextStyle(fontSize: 7.5)),
                  pw.Text(
                    data['signature'],
                    style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              )
            else
              pw.Text("Sign: ___________________", style: const pw.TextStyle(fontSize: 8)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              isExport ? "AUTHORIZED SIGNATURE / EXPORT REP:" : "Export / Buyer Rep: ___________________",
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text("Sign: ___________________", style: const pw.TextStyle(fontSize: 8)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildProtocolFooter() {
    return pw.Column(
      children: [
        pw.Divider(thickness: 0.5),
        pw.Text(
          '"Guardians of Ghana\'s Cashew Quality"',
          style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, fontStyle: pw.FontStyle.italic),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          "CQAAG Standardized Cut Test Protocol: Quantities <= 10 Tons: 1 mandatory cut test. > 10 Tons: Minimum 2 tests average required.",
          style: const pw.TextStyle(fontSize: 7),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          "Wenchi, Bono Region-Ghana  Tel: +233553330931  Email: ghcashewqualityanalyst@gmail.com",
          style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }
}
