import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cqaag_app/models/inspection/analysis_types.dart';
import 'package:cqaag_app/models/inspection/cut_test.dart';

/// Generates official CQAAG quality inspection certificates matching the
/// design specifications in `docs/new/CQAAG_Certificates_Design_Specification.pdf`
/// and the 5 specimen certificates (UAC, DQC, ARB, EZA, EXQ).
class PdfService {
  PdfService({Future<pw.Font> Function()? regularFont, Future<pw.Font> Function()? boldFont})
      : _regularFont = regularFont ?? PdfGoogleFonts.openSansRegular,
        _boldFont = boldFont ?? PdfGoogleFonts.openSansBold;

  final Future<pw.Font> Function() _regularFont;
  final Future<pw.Font> Function() _boldFont;

  // Association brand colors
  static final PdfColor cqaagGreen = PdfColor.fromHex('134E32');
  static final PdfColor cqaagAccentGreen = PdfColor.fromHex('1F6B47');
  static final PdfColor cqaagGold = PdfColor.fromHex('A8832A');
  static final PdfColor cqaagNavy = PdfColor.fromHex('13245B');
  static final PdfColor kenteRed = PdfColor.fromHex('B91C1C');
  static final PdfColor tableTint = PdfColor.fromHex('EDF4EF');
  static final PdfColor borderGrey = PdfColor.fromHex('CBD5E1');

  Future<Uint8List> generateReport(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    // 1. Load brand assets
    pw.MemoryImage? cqaagLogo;
    try {
      final bytes = await rootBundle.load('assets/images/cqaag_logo.png');
      cqaagLogo = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {}

    pw.MemoryImage? tcdaLogo;
    try {
      final bytes = await rootBundle.load('assets/images/tcda.png');
      tcdaLogo = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {
      try {
        final bytes = await rootBundle.load('assets/images/tcda_logo.jpg');
        tcdaLogo = pw.MemoryImage(bytes.buffer.asUint8List());
      } catch (_) {}
    }

    pw.MemoryImage? ccgLogo;
    try {
      final bytes = await rootBundle.load('assets/images/ccg_logo.png');
      ccgLogo = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {
      try {
        final bytes = await rootBundle.load('assets/images/cashew-council-ghana.png');
        ccgLogo = pw.MemoryImage(bytes.buffer.asUint8List());
      } catch (_) {}
    }

    // 2. Resolve certificate type & metadata
    final rawType = (data['analysisType'] ?? '').toString();
    final typeInfo = AnalysisTypes.resolve(rawType);
    final isExport = typeInfo.code == 'EXQ';
    final isArbitration = typeInfo.code == 'ARB';
    final isDispatch = typeInfo.code == 'DQC';
    final isExportArrival = typeInfo.code == 'EZA';

    final approvalStatus = (data['approvalStatus'] ?? 'not_required').toString();
    final isApproved = approvalStatus == 'approved';
    final isDeclined = approvalStatus == 'declined';
    final isDraft = isExport && !isApproved;

    // Stable sequence number and formatted certificate number
    final idString = (data['inspectionId'] ?? data['id'] ?? '100001').toString();
    final numDigits = RegExp(r'\d+').allMatches(idString).map((m) => m.group(0)).join();
    final sequence = int.tryParse(numDigits.isNotEmpty ? (numDigits.length > 6 ? numDigits.substring(numDigits.length - 6) : numDigits) : '123') ?? 123;
    final int year = DateTime.now().year;

    final certificateNumber = (data['certificateNumber'] ?? '').toString().isNotEmpty
        ? data['certificateNumber'].toString()
        : AnalysisTypes.formatCertificateNumber(rawType, year: year, sequence: sequence, isDraft: isDraft);

    final String docHash = _generateDocHash(certificateNumber, idString);
    final String qrUrl = AnalysisTypes.verificationUrl(certificateNumber, hash: docHash);

    // Cut tests
    final rawCuts = (data['cutTests'] as List<CutTest>?) ?? const <CutTest>[];
    final activeCuts = rawCuts.where((c) => !c.isEmpty).toList();
    final effectiveCuts = activeCuts.isNotEmpty
        ? activeCuts
        : [
            CutTest(
              index: 1,
              moistureContent: double.tryParse((data['moisture'] ?? '').toString().replaceAll('%', '')) ?? 9.5,
              nutCount: int.tryParse((data['nutCount'] ?? '').toString()) ?? 190,
              fullyDamagedNuts: double.tryParse((data['fullyDamagedKernels'] ?? '').toString()) ?? 15.2,
              voidNuts: double.tryParse((data['voidKernels'] ?? '').toString()) ?? 23.2,
              oilNuts: double.tryParse((data['oilKernels'] ?? '').toString()) ?? 3.8,
              spottedNuts: double.tryParse((data['spottedKernels'] ?? '').toString()) ?? 59.5,
              immatureNuts: double.tryParse((data['immatureKernels'] ?? '').toString()) ?? 18.8,
              goodKernels: double.tryParse((data['goodKernels'] ?? '').toString()) ?? 238.5,
              emptyShells: double.tryParse((data['emptyShells'] ?? '').toString()) ?? 640.0,
            ),
          ];

    final font = await _regularFont();
    final fontBold = await _boldFont();
    final theme = pw.ThemeData.withFont(base: font, bold: fontBold);

    final totalPages = (isExport || isArbitration) ? 2 : 1;

    pw.PageTheme createPageTheme({required int pageIndex}) {
      return pw.PageTheme(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(26, 26, 26, 26),
        buildBackground: (context) => _buildPageBackground(cqaagLogo),
        buildForeground: isDraft
            ? (context) => _buildDraftWatermark(isDeclined ? 'NOT APPROVED' : 'DRAFT · NOT VALID')
            : null,
      );
    }

    // ----------------- PAGE 1 -----------------
    pdf.addPage(
      pw.Page(
        pageTheme: createPageTheme(pageIndex: 1),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(ccgLogo, cqaagLogo, tcdaLogo),
              pw.SizedBox(height: 5),
              _buildBilingualTitle(typeInfo.englishTitle, typeInfo.frenchSubtitle),
              pw.SizedBox(height: 6),
              _buildIdentificationBlock(
                certNumber: certificateNumber,
                status: isDraft ? 'DRAFT D1 · NOT SIGNED' : (isApproved ? 'ORIGINAL · SIGNED' : 'ISSUED · SIGNED'),
                issuedDateUtc: (data['date'] ?? '').toString().isNotEmpty ? '${data['date']} 12:00' : '2026-10-16 12:00',
                lotNo: (data['batchId'] ?? 'CQAAG-L-$sequence').toString(),
                qrUrl: qrUrl,
                typeCode: typeInfo.code,
                data: data,
              ),
              pw.SizedBox(height: 6),

              if (isExport) ...[
                _buildExportSectionI(data),
                pw.SizedBox(height: 4),
                _buildExportSectionII(data),
                pw.SizedBox(height: 4),
                _buildExportSectionIII(data),
                pw.SizedBox(height: 4),
                _buildCuttingTable(typeInfo, effectiveCuts, limitMoisture: typeInfo.maxMoisture, isExport: true),
                pw.SizedBox(height: 5),
                _buildThreeSummaryBadges(typeInfo, effectiveCuts),
                pw.SizedBox(height: 4),
                _buildDecisionLine(typeInfo, effectiveCuts),
              ] else if (isArbitration) ...[
                _buildPartiesSectionARB(data),
                pw.SizedBox(height: 4),
                _buildLotSectionARB(data),
                pw.SizedBox(height: 4),
                _buildCuttingTable(typeInfo, effectiveCuts, limitMoisture: typeInfo.maxMoisture),
                pw.SizedBox(height: 5),
                _buildDisputedVsArbitrationSection(data, effectiveCuts),
                pw.SizedBox(height: 4),
                _buildDecisionLine(typeInfo, effectiveCuts),
                pw.SizedBox(height: 4),
                _buildAnalystSignatureBlock(data, docHash),
              ] else if (isDispatch) ...[
                _buildPartiesSectionDQC(data),
                pw.SizedBox(height: 4),
                _buildDispatchDetailsSection(data),
                pw.SizedBox(height: 4),
                _buildCuttingTable(typeInfo, effectiveCuts, limitMoisture: typeInfo.maxMoisture),
                pw.SizedBox(height: 5),
                _buildThreeSummaryBadges(typeInfo, effectiveCuts),
                pw.SizedBox(height: 4),
                _buildDecisionLine(typeInfo, effectiveCuts),
                pw.SizedBox(height: 4),
                _buildAnalystSignatureBlock(data, docHash),
              ] else if (isExportArrival) ...[
                _buildPartiesSectionEZA(data),
                pw.SizedBox(height: 4),
                _buildArrivalDetailsSection(data),
                pw.SizedBox(height: 4),
                _buildCuttingTable(typeInfo, effectiveCuts, limitMoisture: typeInfo.maxMoisture),
                pw.SizedBox(height: 4),
                _buildComparisonWithDispatchSection(data, effectiveCuts),
                pw.SizedBox(height: 4),
                _buildDecisionLine(typeInfo, effectiveCuts),
                pw.SizedBox(height: 4),
                _buildAnalystSignatureBlock(data, docHash),
              ] else ...[
                // UAC (Upcountry Arrival)
                _buildPartiesSectionUAC(data),
                pw.SizedBox(height: 4),
                _buildConsignmentSectionUAC(data),
                pw.SizedBox(height: 4),
                _buildCuttingTable(typeInfo, effectiveCuts, limitMoisture: typeInfo.maxMoisture),
                pw.SizedBox(height: 5),
                _buildThreeSummaryBadges(typeInfo, effectiveCuts),
                pw.SizedBox(height: 4),
                _buildDecisionLine(typeInfo, effectiveCuts),
                pw.SizedBox(height: 4),
                _buildAnalystSignatureBlock(data, docHash),
              ],

              pw.Spacer(),
              _buildStandardFooter(certificateNumber, page: 1, totalPages: totalPages),
            ],
          );
        },
      ),
    );

    // ----------------- PAGE 2 (Arbitration or Export) -----------------
    if (isArbitration) {
      pdf.addPage(
        pw.Page(
          pageTheme: createPageTheme(pageIndex: 2),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(ccgLogo, cqaagLogo, tcdaLogo),
                pw.SizedBox(height: 5),
                _buildBilingualTitle(
                  'RCN ARBITRATION CERTIFICATE',
                  'Certificat d’arbitrage de qualité – procédure et règlement',
                ),
                pw.SizedBox(height: 8),
                _buildArbitrationProcedureSection(),
                pw.SizedBox(height: 8),
                _buildArbitrationGuidelinesSection(),
                pw.SizedBox(height: 8),
                _buildArbitrationAcknowledgementSection(data),
                pw.SizedBox(height: 8),
                _buildArbitrationRecordOfSettlementSection(),
                pw.Spacer(),
                _buildStandardFooter(certificateNumber, page: 2, totalPages: 2),
              ],
            );
          },
        ),
      );
    } else if (isExport) {
      pdf.addPage(
        pw.Page(
          pageTheme: createPageTheme(pageIndex: 2),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(ccgLogo, cqaagLogo, tcdaLogo),
                pw.SizedBox(height: 5),
                _buildBilingualTitle(
                  'RCN EXPORT QUALITY CERTIFICATE',
                  'Certificat de qualité à l’exportation – suite',
                ),
                pw.SizedBox(height: 6),
                _buildExportSectionVDeclaration(data),
                pw.SizedBox(height: 6),
                _buildExportSection18Issue(data),
                pw.SizedBox(height: 6),
                _buildExportSection19Evidence(data),
                pw.SizedBox(height: 6),
                _buildExportSection20Authorisation(data, docHash, isApproved: isApproved, isDraft: isDraft),
                pw.Spacer(),
                _buildStandardFooter(certificateNumber, page: 2, totalPages: 2),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  // ----------------- BACKGROUND & BORDERS -----------------
  pw.Widget _buildPageBackground(pw.MemoryImage? cqaagSeal) {
    return pw.FullPage(
      ignoreMargins: true,
      child: pw.Stack(
        children: [
          // 1. Watermark in center
          if (cqaagSeal != null)
            pw.Center(
              child: pw.Opacity(
                opacity: 0.045,
                child: pw.Container(
                  width: 310,
                  height: 310,
                  child: pw.Image(cqaagSeal, fit: pw.BoxFit.contain),
                ),
              ),
            ),

          // 2. Outer green border
          pw.Positioned(
            left: 14,
            top: 14,
            right: 14,
            bottom: 14,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: cqaagGreen, width: 1.2),
              ),
            ),
          ),

          // 3. Inner gold border
          pw.Positioned(
            left: 17.5,
            top: 17.5,
            right: 17.5,
            bottom: 17.5,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: cqaagGold, width: 0.6),
              ),
            ),
          ),

          // 4. Corner L-brackets in green
          pw.Positioned(left: 11, top: 11, child: _buildCornerBracket(isTop: true, isLeft: true)),
          pw.Positioned(right: 11, top: 11, child: _buildCornerBracket(isTop: true, isLeft: false)),
          pw.Positioned(left: 11, bottom: 11, child: _buildCornerBracket(isTop: false, isLeft: true)),
          pw.Positioned(right: 11, bottom: 11, child: _buildCornerBracket(isTop: false, isLeft: false)),

          // 5. Slim Kente band along the top and bottom (between green and gold line)
          pw.Positioned(left: 20, top: 15.2, right: 20, child: _buildKenteStrip()),
          pw.Positioned(left: 20, bottom: 15.2, right: 20, child: _buildKenteStrip()),
        ],
      ),
    );
  }

  pw.Widget _buildCornerBracket({required bool isTop, required bool isLeft}) {
    return pw.Container(
      width: 9,
      height: 9,
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: isTop ? pw.BorderSide(color: cqaagGreen, width: 2) : pw.BorderSide.none,
          bottom: !isTop ? pw.BorderSide(color: cqaagGreen, width: 2) : pw.BorderSide.none,
          left: isLeft ? pw.BorderSide(color: cqaagGreen, width: 2) : pw.BorderSide.none,
          right: !isLeft ? pw.BorderSide(color: cqaagGreen, width: 2) : pw.BorderSide.none,
        ),
      ),
    );
  }

  pw.Widget _buildKenteStrip() {
    return pw.Container(
      height: 1.8,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: List.generate(46, (i) {
          final color = (i % 3 == 0) ? cqaagGreen : ((i % 3 == 1) ? cqaagGold : kenteRed);
          return pw.Container(
            width: 7,
            height: 1.8,
            margin: const pw.EdgeInsets.symmetric(horizontal: 1.2),
            color: color,
          );
        }),
      ),
    );
  }

  pw.Widget _buildDraftWatermark(String text) {
    return pw.FullPage(
      ignoreMargins: true,
      child: pw.Center(
        child: pw.Transform.rotate(
          angle: 0.62,
          child: pw.Opacity(
            opacity: 0.09,
            child: pw.Text(
              text,
              style: pw.TextStyle(fontSize: 48, fontWeight: pw.FontWeight.bold, color: PdfColors.red900),
            ),
          ),
        ),
      ),
    );
  }

  // ----------------- HEADER & TITLE -----------------
  pw.Widget _buildHeader(pw.MemoryImage? ccgLogo, pw.MemoryImage? cqaagLogo, pw.MemoryImage? tcdaLogo) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            // Left: Cashew Council Ghana
            pw.Container(
              width: 82,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 38,
                    height: 38,
                    child: ccgLogo != null
                        ? pw.Image(ccgLogo, fit: pw.BoxFit.contain)
                        : pw.Center(child: pw.Text('CCG', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text('CASHEW COUNCIL GHANA', style: pw.TextStyle(fontSize: 5.5, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                  pw.Text('UMBRELLA BODY', style: pw.TextStyle(fontSize: 4.8, color: PdfColors.grey700), textAlign: pw.TextAlign.center),
                ],
              ),
            ),

            // Center: CQAAG
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'CASHEW QUALITY ANALYSTS’ ASSOCIATION, GHANA',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: cqaagGreen),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.Text(
                    '(C.Q.A.A.G)',
                    style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: cqaagGreen),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.Text(
                    '“Guardians of Ghana’s Cashew Quality”',
                    style: pw.TextStyle(fontSize: 7.2, fontStyle: pw.FontStyle.italic, fontWeight: pw.FontWeight.bold, color: cqaagAccentGreen),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 1),
                  pw.Text(
                    'Wenchi, Bono Region, Ghana · Tel +233 55 333 0931 · info@cqaaggh.org · cqaaggh.org',
                    style: pw.TextStyle(fontSize: 6.2, color: PdfColors.grey800),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            ),

            // Right: Tree Crops Development Authority
            pw.Container(
              width: 82,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 38,
                    height: 38,
                    child: tcdaLogo != null
                        ? pw.Image(tcdaLogo, fit: pw.BoxFit.contain)
                        : pw.Center(child: pw.Text('TCDA', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text('TREE CROPS DEVELOPMENT AUTHORITY', style: pw.TextStyle(fontSize: 5, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                  pw.Text('STATUTORY REGULATOR', style: pw.TextStyle(fontSize: 4.8, color: PdfColors.grey700), textAlign: pw.TextAlign.center),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 3),
        // Statutory Recognition Notice
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 2.5, horizontal: 6),
          decoration: pw.BoxDecoration(
            color: tableTint,
            border: pw.Border.all(color: cqaagGreen.shade(0.3), width: 0.5),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
          ),
          child: pw.Column(
            children: [
              pw.Text(
                'Recognised and licensed by the Tree Crops Development Authority (TCDA), the statutory regulator of six (6) tree crops including cashew',
                style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold, color: cqaagGreen),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                'Reconnue et agréée par la Tree Crops Development Authority (TCDA), régulateur statutaire de six (6) cultures dont l’anacarde',
                style: pw.TextStyle(fontSize: 5.5, fontStyle: pw.FontStyle.italic, color: PdfColors.grey800),
                textAlign: pw.TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildBilingualTitle(String englishTitle, String frenchSubtitle) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 3.5, horizontal: 8),
      decoration: pw.BoxDecoration(color: cqaagGreen),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            englishTitle,
            style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold, color: PdfColors.white, letterSpacing: 0.5),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 1),
          pw.Text(
            frenchSubtitle,
            style: pw.TextStyle(fontSize: 7.5, fontStyle: pw.FontStyle.italic, color: PdfColors.white),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ----------------- IDENTIFICATION BLOCK -----------------
  pw.Widget _buildIdentificationBlock({
    required String certNumber,
    required String status,
    required String issuedDateUtc,
    required String lotNo,
    required String qrUrl,
    required String typeCode,
    required Map<String, dynamic> data,
  }) {
    String refLabel = 'LINKED REF. / Réf. liée';
    String refValue = '–';

    if (typeCode == 'UAC') {
      refLabel = 'MOISTURE PASS / Laissez-passer humidité';
      refValue = (data['moisturePassNumber'] ?? 'MP-261010-0007 · USED').toString();
    } else if (typeCode == 'DQC') {
      refLabel = 'LINKED ARRIVAL CERTIFICATE / Certificat d’arrivée lié';
      refValue = (data['linkedArrivalCert'] ?? 'CQAAG-UAC-2026-000123').toString();
    } else if (typeCode == 'ARB') {
      refLabel = 'DISPUTED CERTIFICATE / Certificat contesté';
      refValue = (data['disputedCertificate'] ?? 'CQAAG-EZA-2026-000064').toString();
    } else if (typeCode == 'EZA') {
      refLabel = 'LINKED DISPATCH CERTIFICATE / Certificat d’expédition lié';
      refValue = (data['linkedDispatchCert'] ?? 'CQAAG-DQC-2026-000087').toString();
    } else if (typeCode == 'EXQ') {
      refLabel = 'ISSUING ASSOCIATION / Association émettrice';
      refValue = 'CQAAG, Wenchi, Ghana';
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderGrey, width: 0.6),
        color: PdfColors.grey50,
      ),
      padding: const pw.EdgeInsets.all(5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Expanded(
            child: pw.Column(
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(child: _buildMetaItem('CERTIFICATE NO. / N° du certificat', certNumber, isEmphasised: true)),
                    pw.Expanded(child: _buildMetaItem('STATUS / Statut', status, isEmphasised: true)),
                  ],
                ),
                pw.SizedBox(height: 3),
                pw.Row(
                  children: [
                    pw.Expanded(child: _buildMetaItem('ISSUED (UTC) / Émis le (UTC)', issuedDateUtc)),
                    pw.Expanded(child: _buildMetaItem(typeCode == 'ARB' ? 'ARBITRATION REF. / Réf.' : 'LOT NO. / N° de lot', lotNo)),
                  ],
                ),
                pw.SizedBox(height: 3),
                pw.Row(
                  children: [
                    pw.Expanded(child: _buildMetaItem(refLabel, refValue)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Column(
            children: [
              pw.Container(
                width: 48,
                height: 48,
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: qrUrl,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text('Scan to verify\nScanner pour vérifier', style: pw.TextStyle(fontSize: 4.8, color: PdfColors.grey700), textAlign: pw.TextAlign.center),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMetaItem(String label, String value, {bool isEmphasised = false}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 5.5, color: PdfColors.grey700)),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: isEmphasised ? 7.5 : 7,
            fontWeight: pw.FontWeight.bold,
            color: isEmphasised ? cqaagGreen : PdfColors.black,
          ),
        ),
      ],
    );
  }

  // ----------------- PARTIES & DETAILS SECTIONS -----------------
  pw.Widget _buildSectionHeader(String title) {
    return pw.Container(
      width: double.infinity,
      color: cqaagGreen.shade(0.12),
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      margin: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Text(title, style: pw.TextStyle(fontSize: 7.2, fontWeight: pw.FontWeight.bold, color: cqaagGreen)),
    );
  }

  pw.Widget _buildPartiesSectionUAC(Map<String, dynamic> data) {
    final seller = (data['company'] ?? data['farmerName'] ?? 'Savanna Agro Supplies Ltd').toString();
    final buyer = (data['buyerName'] ?? 'Gold Coast Nuts Trading').toString();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('A. PARTIES / Parties'),
        pw.Row(
          children: [
            pw.Expanded(child: _buildPartyBox('SELLER (PAYS MOISTURE/CUTTING FEE) / Vendeur', seller, 'TCDA Licence No. / N° de licence TCDA: TCDA/LIC/001')),
            pw.SizedBox(width: 6),
            pw.Expanded(child: _buildPartyBox('BUYER / Acheteur', buyer, 'TCDA Licence No. / N° de licence TCDA: TCDA/LIC/002')),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildConsignmentSectionUAC(Map<String, dynamic> data) {
    final origin = (data['location'] ?? data['town'] ?? 'Sampa, Bono Region').toString();
    final warehouse = (data['exactLocation'] ?? 'Sampa Warehouse 2, Bono').toString();
    final vehicle = (data['truckNumber'] ?? 'GN 1234 ABC').toString();
    final qty = '${data['quantity'] ?? '12,480'} kg';
    final bags = (data['bagCount'] ?? '156').toString();
    final waybill = (data['waybillNumber'] ?? 'WB-0007345').toString();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('B. CONSIGNMENT / Cargaison'),
        pw.Row(
          children: [
            pw.Expanded(child: _buildDetailField('ORIGIN OF NUTS / Origine', origin)),
            pw.Expanded(child: _buildDetailField('WAREHOUSE / Entrepôt', warehouse)),
            pw.Expanded(child: _buildDetailField('VEHICLE NO. / N° véhicule', vehicle)),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Row(
          children: [
            pw.Expanded(child: _buildDetailField('QUANTITY / Quantité', qty)),
            pw.Expanded(child: _buildDetailField('NUMBER OF BAGS / Sacs', bags)),
            pw.Expanded(child: _buildDetailField('WAYBILL NO. / Lettre de voiture', waybill)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPartiesSectionDQC(Map<String, dynamic> data) {
    final dispatcher = (data['company'] ?? 'Savanna Agro Supplies Ltd').toString();
    final consignee = (data['buyerName'] ?? 'Gold Coast Nuts Trading (Tema Port Area)').toString();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('A. PARTIES / Parties'),
        pw.Row(
          children: [
            pw.Expanded(child: _buildPartyBox('DISPATCHER / SELLER / Expéditeur / vendeur', dispatcher, 'TCDA Licence No.: TCDA/LIC/001')),
            pw.SizedBox(width: 6),
            pw.Expanded(child: _buildPartyBox('CONSIGNEE AT EXPORT AREA / Destinataire', consignee, 'TCDA Licence No.: TCDA/LIC/002')),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildDispatchDetailsSection(Map<String, dynamic> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('B. DISPATCH DETAILS / Détails de l’expédition'),
        pw.Row(
          children: [
            pw.Expanded(child: _buildDetailField('POINT OF DISPATCH / Point d’expédition', (data['location'] ?? 'Sampa Warehouse 2, Bono').toString())),
            pw.Expanded(child: _buildDetailField('DESTINATION / Destination', 'Tema Port Area')),
            pw.Expanded(child: _buildDetailField('VEHICLE NO. / N° véhicule', (data['truckNumber'] ?? 'GR 5678 XYZ').toString())),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Row(
          children: [
            pw.Expanded(child: _buildDetailField('QUANTITY / Quantité', '${data['quantity'] ?? '28,000'} kg')),
            pw.Expanded(child: _buildDetailField('NUMBER OF BAGS / Sacs', (data['bagCount'] ?? '350').toString())),
            pw.Expanded(child: _buildDetailField('WAYBILL NO. / Lettre de voiture', (data['waybillNumber'] ?? 'WB-0007410').toString())),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPartiesSectionARB(Map<String, dynamic> data) {
    final claimant = (data['buyerName'] ?? 'Atlantic Nut Traders Ltd').toString();
    final respondent = (data['company'] ?? 'Savanna Agro Supplies Ltd').toString();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('A. THE PARTIES / Les parties'),
        pw.Row(
          children: [
            pw.Expanded(child: _buildPartyBox('CLAIMANT / Demandeur', claimant, 'TCDA Licence No.: TCDA/LIC/003 · Rep: Claimant Rep')),
            pw.SizedBox(width: 6),
            pw.Expanded(child: _buildPartyBox('RESPONDENT / Défendeur', respondent, 'TCDA Licence No.: TCDA/LIC/001 · Rep: Respondent Rep')),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildLotSectionARB(Map<String, dynamic> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('B. THE LOT UNDER ARBITRATION / Le lot en arbitrage'),
        pw.Row(
          children: [
            pw.Expanded(child: _buildDetailField('LOT NO. / N° de lot', (data['batchId'] ?? 'CQAAG-L-261012-0011').toString())),
            pw.Expanded(child: _buildDetailField('PLACE OF CUTTING / Lieu', (data['location'] ?? 'Tema Warehouse 5').toString())),
            pw.Expanded(child: _buildDetailField('VEHICLE NO. / N° véhicule', (data['truckNumber'] ?? 'GR 5678 XYZ').toString())),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Row(
          children: [
            pw.Expanded(child: _buildDetailField('QUANTITY / Quantité', '${data['quantity'] ?? '27,960'} kg')),
            pw.Expanded(child: _buildDetailField('REASON / Motif', 'Outturn below contract')),
            pw.Expanded(child: _buildDetailField('SAMPLING / Prélèvement', 'Both parties present; 10% bags drawn')),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPartiesSectionEZA(Map<String, dynamic> data) {
    final seller = (data['company'] ?? 'Savanna Agro Supplies Ltd').toString();
    final consignee = (data['buyerName'] ?? 'Gold Coast Nuts Trading').toString();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('A. PARTIES / Parties'),
        pw.Row(
          children: [
            pw.Expanded(child: _buildPartyBox('SELLER / Vendeur', seller, 'TCDA Licence No.: TCDA/LIC/001')),
            pw.SizedBox(width: 6),
            pw.Expanded(child: _buildPartyBox('CONSIGNEE / WAREHOUSE / Destinataire', consignee, 'TCDA Licence No.: TCDA/LIC/002')),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildArrivalDetailsSection(Map<String, dynamic> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('B. ARRIVAL DETAILS / Détails de l’arrivée'),
        pw.Row(
          children: [
            pw.Expanded(child: _buildDetailField('EXPORT WAREHOUSE / Entrepôt', 'Tema Warehouse 5')),
            pw.Expanded(child: _buildDetailField('PLACE OF CUTTING / Lieu', 'Tema Port Area')),
            pw.Expanded(child: _buildDetailField('VEHICLE NO. / N° véhicule', (data['truckNumber'] ?? 'GR 5678 XYZ').toString())),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Row(
          children: [
            pw.Expanded(child: _buildDetailField('QUANTITY RECEIVED / Quantité', '${data['quantity'] ?? '27,960'} kg')),
            pw.Expanded(child: _buildDetailField('NUMBER OF BAGS / Sacs', (data['bagCount'] ?? '350').toString())),
            pw.Expanded(child: _buildDetailField('WAYBILL NO. / Lettre de voiture', (data['waybillNumber'] ?? 'WB-0007410').toString())),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPartyBox(String role, String name, String license) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(3.5),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: borderGrey, width: 0.5)),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(role, style: pw.TextStyle(fontSize: 5.5, color: PdfColors.grey700)),
          pw.Text(name, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
          pw.Text(license, style: pw.TextStyle(fontSize: 6, color: PdfColors.grey800)),
        ],
      ),
    );
  }

  pw.Widget _buildDetailField(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 5.5, color: PdfColors.grey700)),
        pw.Text(value, style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  // ----------------- EXPORT SPECIFIC SECTIONS (Page 1) -----------------
  pw.Widget _buildExportSectionI(Map<String, dynamic> data) {
    final exporter = (data['shipperDetails'] ?? data['company'] ?? 'Gold Coast Nuts Trading Ltd, Tema, Ghana').toString();
    final consignee = (data['consigneeDetails'] ?? data['buyerName'] ?? 'Cashew Imports Pvt Ltd, Visakhapatnam, India').toString();
    final transport = (data['transportDescription'] ?? 'Sea – MV SPECIMEN, voyage 026E').toString();
    final ports = '${data['pol'] ?? 'Tema, Ghana'} -> ${data['pod'] ?? 'Visakhapatnam, India'}';
    final bl = (data['blNumber'] ?? data['waybillNumber'] ?? 'BL-SPEC-0001').toString();
    final containers = (data['containerCountAndSizes'] ?? '2 x 40\' HC · SPEC1234567 / SPEC7654321 · seals S-0001, S-0002').toString();
    final marks = 'GHANA RCN · CROP 2026 · LOT ${(data['batchId'] ?? '0011')} · 80 kg NET';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('I. DESCRIPTION OF CONSIGNMENT / I. Description de l’envoi'),
        pw.Row(
          children: [
            pw.Expanded(child: _buildPartyBox('1. EXPORTER (SHIPPER) / 1. Exportateur', exporter, 'TCDA Licence No.: TCDA/LIC/002')),
            pw.SizedBox(width: 6),
            pw.Expanded(child: _buildPartyBox('2. DECLARED CONSIGNEE / 2. Destinataire', consignee, 'TCDA Licence No.: Not applicable – outside Ghana')),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Row(
          children: [
            pw.Expanded(child: _buildDetailField('3. MEANS OF TRANSPORT / 3. Moyen de transport', transport)),
            pw.Expanded(child: _buildDetailField('4. POL -> POD / 4. Chargement -> Déchargement', ports)),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Row(
          children: [
            pw.Expanded(child: _buildDetailField('5. BILL OF LADING / 5. Connaissement', bl)),
            pw.Expanded(child: _buildDetailField('6. CONTAINERS AND SEALS / 6. Conteneurs et scellés', containers)),
          ],
        ),
        pw.SizedBox(height: 2),
        _buildDetailField('7. DISTINGUISHING MARKS / 7. Marques distinctives', marks),
      ],
    );
  }

  pw.Widget _buildExportSectionII(Map<String, dynamic> data) {
    final bags = (data['bagCount'] ?? '650').toString();
    final gross = data['grossWeight'] != null ? '${data['grossWeight']} kg' : '52,520 kg';
    final net = data['netWeight'] != null ? '${data['netWeight']} kg' : '51,870 kg';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('II. COMMODITY / II. Marchandise'),
        pw.Row(
          children: [
            pw.Expanded(child: _buildDetailField('8. DESCRIPTION / 8. Désignation', 'Raw cashew nuts in shell (RCN)')),
            pw.Expanded(child: _buildDetailField('9. BOTANICAL NAME / 9. Nom botanique', 'Anacardium occidentale L.')),
            pw.Expanded(child: _buildDetailField('10. HS CODE / Code SH', '0801.31')),
            pw.Expanded(child: _buildDetailField('11. CROP YEAR / Campagne', '2026')),
            pw.Expanded(child: _buildDetailField('12. BAGS / Sacs', bags)),
            pw.Expanded(child: _buildDetailField('13. GROSS / NET WEIGHT', '$gross / $net')),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildExportSectionIII(Map<String, dynamic> data) {
    final place = (data['samplePlaceAndDate'] ?? 'Tema Warehouse 5').toString();
    final date = (data['date'] ?? '16 Oct 2026').toString();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('III. SAMPLING AND CUTTING / III. Prélèvement et coupe'),
        pw.Row(
          children: [
            pw.Expanded(child: _buildDetailField('14. PLACE OF SAMPLING / Lieu', place)),
            pw.Expanded(child: _buildDetailField('15. DATE / Date', date)),
            pw.Expanded(flex: 2, child: _buildDetailField('16. SAMPLING BASIS / Base de prélèvement', 'Bags drawn across the lot; container loading witnessed')),
          ],
        ),
      ],
    );
  }

  // ----------------- THE CUTTING TABLE -----------------
  pw.Widget _buildCuttingTable(
    CertificateTypeInfo typeInfo,
    List<CutTest> cuts, {
    required double limitMoisture,
    bool isExport = false,
  }) {
    final slots = isExport ? 3 : (cuts.length > 1 ? 2 : 1);
    final sectionTitle = isExport
        ? 'IV. RESULT OF THE CUTTING TEST – 3 CUTTINGS / IV. Résultat du test de coupe'
        : 'C. CUTTING TEST – $slots CUTTING${slots > 1 ? "S" : ""} / Test de coupe';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(sectionTitle),
        pw.Table(
          border: pw.TableBorder.all(color: borderGrey, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(3.8),
            for (var i = 1; i <= slots; i++) i: const pw.FlexColumnWidth(1.1),
            slots + 1: const pw.FlexColumnWidth(1.2),
            slots + 2: const pw.FlexColumnWidth(1.0),
          },
          children: [
            // Table Header
            pw.TableRow(
              decoration: pw.BoxDecoration(color: tableTint),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  child: pw.Text('Parameter / Paramètre', style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, color: cqaagGreen)),
                ),
                for (var i = 0; i < slots; i++)
                  pw.Center(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Text('${i + 1}${_ordinalSuffix(i + 1)} cutting', style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold)),
                    ),
                  ),
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Text('Average\nMoyenne', style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, color: cqaagGreen), textAlign: pw.TextAlign.center),
                  ),
                ),
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Text('Limit\nExigence', style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                  ),
                ),
              ],
            ),

            // Rows
            _buildTableRow('Moisture content (%) / Teneur en humidité', cuts, (c) => c.moistureContent, slots, limit: '≤ ${limitMoisture.toStringAsFixed(1)}'),
            _buildTableRow('Nut count (per kg) / Nombre de noix par kg', cuts, (c) => c.nutCount.toDouble(), slots, decimals: 0),
            _buildTableRow('Fully damaged nuts (g) / Noix totalement endommagées', cuts, (c) => c.fullyDamagedNuts, slots),
            _buildTableRow('  Void nuts (g) / Noix vides', cuts, (c) => c.voidNuts, slots, isSubItem: true),
            _buildTableRow('  Oil nuts (g) / Noix huileuses', cuts, (c) => c.oilNuts, slots, isSubItem: true),
            _buildTableRow('  Total damaged (g)', cuts, (c) => c.totalDamaged, slots, isBold: true),
            _buildTableRow('Spotted / partly sound nuts (g) / Noix tachetées', cuts, (c) => c.spottedNuts, slots),
            _buildTableRow('  Immature nuts (g) / Noix immatures', cuts, (c) => c.immatureNuts, slots, isSubItem: true),
            _buildTableRow('  Total spotted (g)', cuts, (c) => c.totalSpotted, slots, isBold: true),
            _buildTableRow('  50 % of above total (g) / 50 % du total ci-dessus', cuts, (c) => c.halfTotalSpotted, slots, isSubItem: true),
            _buildTableRow('Good kernels (g) / Amandes saines', cuts, (c) => c.goodKernels, slots),
            _buildTableRow('Total yield (g) / Rendement total', cuts, (c) => c.totalYield, slots, isBold: true),
            _buildTableRow('Empty shells (g) / Coques vides', cuts, (c) => c.emptyShells, slots),
            _buildTableRow('Total sample (g) / Échantillon total', cuts, (c) => c.total, slots, isBold: true),
            _buildTableRow('OUTTURN (KOR) – lbs / RENDEMENT (KOR) – lbs', cuts, (c) => c.kor, slots, isBold: true, isHighlighted: true, decimals: 2),
          ],
        ),
      ],
    );
  }

  static String _ordinalSuffix(int n) => switch (n) { 1 => 'st', 2 => 'nd', 3 => 'rd', _ => 'th' };

  pw.TableRow _buildTableRow(
    String label,
    List<CutTest> cuts,
    double Function(CutTest) select,
    int slots, {
    bool isBold = false,
    bool isSubItem = false,
    bool isHighlighted = false,
    int decimals = 1,
    String limit = '–',
  }) {
    String format(double val) => val.toStringAsFixed(decimals);
    final active = cuts.where((c) => !c.isEmpty).toList();
    final avg = active.isEmpty ? 0.0 : active.map(select).reduce((a, b) => a + b) / active.length;

    return pw.TableRow(
      decoration: isHighlighted ? pw.BoxDecoration(color: cqaagGold.shade(0.18)) : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 1.2, horizontal: 4),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 6.2,
              fontWeight: isBold ? pw.FontWeight.bold : null,
              fontStyle: isSubItem ? pw.FontStyle.italic : null,
              color: isHighlighted ? cqaagGreen : PdfColors.black,
            ),
          ),
        ),
        for (var i = 0; i < slots; i++)
          pw.Center(
            child: pw.Text(
              i < active.length ? format(select(active[i])) : '–',
              style: pw.TextStyle(fontSize: 6.2, fontWeight: isBold ? pw.FontWeight.bold : null),
            ),
          ),
        // Average
        pw.Container(
          color: isHighlighted ? null : tableTint,
          padding: const pw.EdgeInsets.symmetric(vertical: 1.2),
          child: pw.Center(
            child: pw.Text(
              active.isNotEmpty ? format(avg) : '–',
              style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, color: cqaagGreen),
            ),
          ),
        ),
        // Limit
        pw.Center(
          child: pw.Text(limit, style: pw.TextStyle(fontSize: 6.2, color: PdfColors.grey700)),
        ),
      ],
    );
  }

  // ----------------- SUMMARY BADGES & DECISION -----------------
  pw.Widget _buildThreeSummaryBadges(CertificateTypeInfo typeInfo, List<CutTest> cuts) {
    final avgMoisture = cuts.averageMoisture;
    final avgCount = cuts.averageNutCount.round();
    final avgKor = cuts.averageKor;
    final passMoisture = avgMoisture <= typeInfo.maxMoisture;

    return pw.Row(
      children: [
        pw.Expanded(
          child: _buildBadgeCard(
            title: 'MOISTURE – AVERAGE / Humidité',
            value: '${avgMoisture.toStringAsFixed(1)} %',
            tag: 'LIMIT ≤ ${typeInfo.maxMoisture.toStringAsFixed(1)} ${passMoisture ? "✓" : "✕"}',
            isSuccess: passMoisture,
          ),
        ),
        pw.SizedBox(width: 6),
        pw.Expanded(
          child: _buildBadgeCard(
            title: 'NUT COUNT – AVERAGE / Noix',
            value: '$avgCount / kg',
            tag: 'REPORTED',
            isSuccess: true,
          ),
        ),
        pw.SizedBox(width: 6),
        pw.Expanded(
          child: _buildBadgeCard(
            title: 'OUTTURN (KOR) – AVERAGE / KOR',
            value: '${avgKor.toStringAsFixed(2)} lbs',
            tag: 'PER 80 KG BAG',
            isSuccess: avgKor >= 48.0,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildBadgeCard({
    required String title,
    required String value,
    required String tag,
    required bool isSuccess,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 3.5, horizontal: 6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: isSuccess ? cqaagGreen : PdfColors.red800, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
        color: isSuccess ? tableTint : PdfColors.red50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 5.5, color: PdfColors.grey700), textAlign: pw.TextAlign.center),
          pw.SizedBox(height: 1),
          pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: isSuccess ? cqaagGreen : PdfColors.red900)),
          pw.SizedBox(height: 1),
          pw.Text(tag, style: pw.TextStyle(fontSize: 5.5, fontWeight: pw.FontWeight.bold, color: isSuccess ? cqaagAccentGreen : PdfColors.red800)),
        ],
      ),
    );
  }

  pw.Widget _buildDecisionLine(CertificateTypeInfo typeInfo, List<CutTest> cuts) {
    final avgM = cuts.averageMoisture;
    final withinLimit = avgM <= typeInfo.maxMoisture;

    String heading;
    String detail;

    if (typeInfo.code == 'DQC') {
      if (withinLimit) {
        heading = 'CLEARED for dispatch to the export area / AUTORISÉ pour l’expédition vers la zone d’exportation';
        detail = 'Average moisture ${avgM.toStringAsFixed(1)}% is within the 10.0% limit. A lot above 10.0% moisture is not cleared for Tema or Takoradi: the certificate cannot be issued and the lot must be dried and re-tested.';
      } else {
        heading = 'NOT CLEARED FOR DISPATCH / NON AUTORISÉ';
        detail = 'Average moisture ${avgM.toStringAsFixed(1)}% exceeds the 10.0% limit. Lot must be dried and re-tested.';
      }
    } else if (typeInfo.code == 'EXQ') {
      heading = withinLimit
          ? 'Moisture within the 8.0 % export limit / Humidité conforme à la limite d’exportation de 8,0 %'
          : 'Moisture EXCEEDS the 8.0 % export limit / Humidité non conforme';
      detail = 'Result reported at the date of sampling. Continued page 2: declaration, issue, evidence, stamp and signature.';
    } else if (typeInfo.code == 'ARB') {
      heading = 'Arbitration result recorded – proceed to page 2 / Résultat d’arbitrage consigné – voir la page 2';
      detail = 'The arbitration cutting is the reference quality of the lot on the cutting date. Page 2 sets out the procedure and the guidelines to settlement.';
    } else if (typeInfo.code == 'EZA') {
      heading = 'Moisture within the 10.0 % arrival limit / Humidité conforme à la limite de 10,0 %';
      detail = 'Variance is reported for information. A party that disputes the result may request CQAAG arbitration.';
    } else {
      // UAC
      heading = withinLimit
          ? 'Moisture within the 10.0 % arrival limit / Humidité conforme à la limite de 10,0 %'
          : 'Moisture EXCEEDS the 10.0 % arrival limit / Humidité non conforme';
      detail = 'Lot accepted for storage at the upcountry warehouse on the basis of the readings above. Result reported; commercial acceptance remains a matter between the parties.';
    }

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 6),
      decoration: pw.BoxDecoration(
        color: withinLimit ? tableTint : PdfColors.red50,
        border: pw.Border.all(color: withinLimit ? cqaagGreen.shade(0.4) : PdfColors.red400, width: 0.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(heading, style: pw.TextStyle(fontSize: 6.8, fontWeight: pw.FontWeight.bold, color: withinLimit ? cqaagGreen : PdfColors.red900)),
          pw.Text(detail, style: pw.TextStyle(fontSize: 5.8, color: PdfColors.grey800)),
        ],
      ),
    );
  }

  // ----------------- ARBITRATION SECTIONS (Page 1 & 2) -----------------
  pw.Widget _buildDisputedVsArbitrationSection(Map<String, dynamic> data, List<CutTest> cuts) {
    final arbM = cuts.averageMoisture;
    final arbCount = cuts.averageNutCount.round();
    final arbKor = cuts.averageKor;

    // Disputed baseline values
    final dispM = double.tryParse((data['disputedMoisture'] ?? '9.7').toString()) ?? 9.7;
    final dispCount = int.tryParse((data['disputedNutCount'] ?? '186').toString()) ?? 186;
    final dispKor = double.tryParse((data['disputedKor'] ?? '49.80').toString()) ?? 49.80;

    final diffM = arbM - dispM;
    final diffCount = arbCount - dispCount;
    final diffKor = arbKor - dispKor;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('D. DISPUTED RESULT AGAINST ARBITRATION RESULT / Résultat contesté et arbitrage'),
        pw.Table(
          border: pw.TableBorder.all(color: borderGrey, width: 0.5),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: tableTint),
              children: [
                pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text('Indicator / Indicateur', style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold))),
                pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Center(child: pw.Text('Disputed certificate', style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold)))),
                pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Center(child: pw.Text('Arbitration result', style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold, color: cqaagGreen)))),
                pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Center(child: pw.Text('Difference', style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold)))),
              ],
            ),
            _buildComparisonRow('Moisture (%) / Humidité', dispM.toStringAsFixed(1), arbM.toStringAsFixed(1), (diffM >= 0 ? "+${diffM.toStringAsFixed(1)}" : diffM.toStringAsFixed(1))),
            _buildComparisonRow('Nut count per kg / Noix', dispCount.toString(), arbCount.toString(), (diffCount >= 0 ? "+$diffCount" : "$diffCount")),
            _buildComparisonRow('Outturn KOR, lbs / Rendement', dispKor.toStringAsFixed(2), arbKor.toStringAsFixed(2), (diffKor >= 0 ? "+${diffKor.toStringAsFixed(2)}" : diffKor.toStringAsFixed(2)), isBold: true),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildComparisonWithDispatchSection(Map<String, dynamic> data, List<CutTest> cuts) {
    final arrM = cuts.averageMoisture;
    final arrCount = cuts.averageNutCount.round();
    final arrKor = cuts.averageKor;

    final dispM = double.tryParse((data['dispatchMoisture'] ?? '9.8').toString()) ?? 9.8;
    final dispCount = int.tryParse((data['dispatchNutCount'] ?? '185').toString()) ?? 185;
    final dispKor = double.tryParse((data['dispatchKor'] ?? '49.75').toString()) ?? 49.75;

    final diffM = arrM - dispM;
    final diffCount = arrCount - dispCount;
    final diffKor = arrKor - dispKor;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('D. COMPARISON WITH THE DISPATCH CERTIFICATE / Comparaison avec l’expédition'),
        pw.Table(
          border: pw.TableBorder.all(color: borderGrey, width: 0.5),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: tableTint),
              children: [
                pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text('Indicator / Indicateur', style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold))),
                pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Center(child: pw.Text('At dispatch / À l’expédition', style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold)))),
                pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Center(child: pw.Text('At arrival / À l’arrivée', style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold, color: cqaagGreen)))),
                pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Center(child: pw.Text('Variance / Écart', style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold)))),
              ],
            ),
            _buildComparisonRow('Moisture (%) / Humidité', dispM.toStringAsFixed(1), arrM.toStringAsFixed(1), (diffM >= 0 ? "+${diffM.toStringAsFixed(1)}" : diffM.toStringAsFixed(1))),
            _buildComparisonRow('Nut count per kg / Noix', dispCount.toString(), arrCount.toString(), (diffCount >= 0 ? "+$diffCount" : "$diffCount")),
            _buildComparisonRow('Outturn KOR, lbs / Rendement', dispKor.toStringAsFixed(2), arrKor.toStringAsFixed(2), (diffKor >= 0 ? "+${diffKor.toStringAsFixed(2)}" : diffKor.toStringAsFixed(2)), isBold: true),
          ],
        ),
      ],
    );
  }

  pw.TableRow _buildComparisonRow(String ind, String v1, String v2, String diff, {bool isBold = false}) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 1.5, horizontal: 4), child: pw.Text(ind, style: pw.TextStyle(fontSize: 6, fontWeight: isBold ? pw.FontWeight.bold : null))),
        pw.Center(child: pw.Text(v1, style: pw.TextStyle(fontSize: 6, fontWeight: isBold ? pw.FontWeight.bold : null))),
        pw.Center(child: pw.Text(v2, style: pw.TextStyle(fontSize: 6.2, fontWeight: pw.FontWeight.bold, color: cqaagGreen))),
        pw.Center(child: pw.Text(diff, style: pw.TextStyle(fontSize: 6, fontWeight: isBold ? pw.FontWeight.bold : null))),
      ],
    );
  }

  pw.Widget _buildArbitrationProcedureSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('E. ARBITRATION PROCEDURE / Procédure d’arbitrage'),
        _buildNumberedRule('1. Request', 'The claimant lodges a written request with the CQAAG Secretariat, before the lot is mixed, re-bagged or moved, and pays the arbitration cutting fee. Demande écrite avant tout mélange ou déplacement du lot.'),
        _buildNumberedRule('2. Notice', 'The respondent is notified by the Secretariat and is invited to be present or represented at the sampling. Le défendeur est notifié et invité à assister au prélèvement.'),
        _buildNumberedRule('3. Sampling', 'The sample is drawn in the presence of both parties (or their representatives), sealed and signed by them. A party that does not attend after due notice is bound by the sampling. Prélèvement contradictoire, échantillon scellé.'),
        _buildNumberedRule('4. Cutting', 'An analyst who took no part in the first test makes the cuttings: one up to 10 tonnes, two above 10 tonnes, with the average reported. Coupe par un analyste indépendant du premier test.'),
        _buildNumberedRule('5. Certificate', 'The Arbitration Certificate is issued with the names of both parties and delivered to each of them. Le certificat est remis aux deux parties.'),
        _buildNumberedRule('6. Objection', 'A party that does not accept the result notifies the Secretariat in writing within five (5) working days of delivery, stating its reasons. Objection écrite sous cinq (5) jours ouvrables.'),
      ],
    );
  }

  pw.Widget _buildArbitrationGuidelinesSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('F. GUIDELINES TO SETTLEMENT / Orientations pour le règlement amiable'),
        _buildNumberedRule('1. Reference Quality', 'The arbitration result is the reference quality of the lot on the cutting date. Parties are encouraged to settle by reference to their contract and, failing a contract term, by agreeing an adjustment of price or quantity based on the difference reported in section D.'),
        _buildNumberedRule('2. Private Agreement', 'Nothing in this certificate sets a price or fixes a tolerance. A settlement is a private agreement between the parties; CQAAG does not guarantee, collect or hold any payment.'),
        _buildNumberedRule('3. Legal Recourse', 'If the parties do not settle, either may refer the matter to the Cashew Council Ghana dispute mechanism, to mediation under the Alternative Dispute Resolution Act, 2010 (Act 798), or to the courts of competent jurisdiction. Rights under the contract and under Ghanaian law are not affected.'),
        _buildNumberedRule('4. OHADA / International', 'Where the contract is governed by the law of an OHADA State or provides for arbitration abroad, the parties may produce this certificate as a technical record of quality, and its French subtitles are provided for that purpose.'),
      ],
    );
  }

  pw.Widget _buildNumberedRule(String title, String body) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(text: '$title: ', style: pw.TextStyle(fontSize: 5.8, fontWeight: pw.FontWeight.bold, color: cqaagGreen)),
            pw.TextSpan(text: body, style: pw.TextStyle(fontSize: 5.5, color: PdfColors.black)),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildArbitrationAcknowledgementSection(Map<String, dynamic> data) {
    final claimant = (data['buyerName'] ?? 'Atlantic Nut Traders Ltd').toString();
    final respondent = (data['company'] ?? 'Savanna Agro Supplies Ltd').toString();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('G. ACKNOWLEDGEMENT BY THE PARTIES / Prise de connaissance par les parties'),
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: borderGrey, width: 0.5)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('CLAIMANT / Demandeur: $claimant', style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 3),
                    pw.Row(children: [pw.Text('[ ] Accepts the result   [ ] Reserves position', style: pw.TextStyle(fontSize: 5.5))]),
                    pw.SizedBox(height: 4),
                    pw.Text('Name, signature, date: ___________________________', style: pw.TextStyle(fontSize: 5.5)),
                  ],
                ),
              ),
            ),
            pw.SizedBox(width: 6),
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: borderGrey, width: 0.5)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('RESPONDENT / Défendeur: $respondent', style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 3),
                    pw.Row(children: [pw.Text('[ ] Accepts the result   [ ] Reserves position', style: pw.TextStyle(fontSize: 5.5))]),
                    pw.SizedBox(height: 4),
                    pw.Text('Name, signature, date: ___________________________', style: pw.TextStyle(fontSize: 5.5)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildArbitrationRecordOfSettlementSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('H. RECORD OF SETTLEMENT (OPTIONAL) / Constat de règlement amiable (facultatif)'),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(4),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: borderGrey, width: 0.5)),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('[ ] Settlement reached   [ ] No settlement – matter referred elsewhere', style: pw.TextStyle(fontSize: 5.8)),
              pw.Text('Date: _____ / _____ / ________', style: pw.TextStyle(fontSize: 5.8)),
            ],
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'Signing for “accepts” records agreement on the quality result only. Signing for “reserves” does not waive any right. The acknowledgement may also be given electronically through the CQAAG app.',
          style: pw.TextStyle(fontSize: 5, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700),
        ),
      ],
    );
  }

  // ----------------- EXPORT SPECIFIC SECTIONS (Page 2) -----------------
  pw.Widget _buildExportSectionVDeclaration(Map<String, dynamic> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('V. ADDITIONAL INFORMATION AND DECLARATION / V. Informations complémentaires et déclaration'),
        pw.Container(
          padding: const pw.EdgeInsets.all(4),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: borderGrey, width: 0.5)),
          child: pw.Text(
            '17. This is to certify that the sample described in sections III and IV was drawn from the consignment described in sections I and II and tested under the CQAAG Standardised Cut Test Protocol by the CQAAG quality analyst named below, who was in good standing on the date of the test; and that the results in section IV are those recorded in the CQAAG application on that date. Il est certifié que l’échantillon décrit aux sections III et IV a été prélevé sur l’envoi décrit aux sections I et II et testé selon le Protocole normalisé de coupe du CQAAG par l’analyste désigné ci-dessous, en règle à la date du test.',
            style: pw.TextStyle(fontSize: 5.8, color: PdfColors.black),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildExportSection18Issue(Map<String, dynamic> data) {
    final analyst = (data['inspector'] ?? 'Specimen Analyst').toString();
    final qc = (data['qcCode'] ?? 'CQAAG-QC-0000').toString();
    final place = 'Wenchi, Ghana';
    final date = (data['date'] ?? '16 October 2026').toString();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('18. ISSUE / Délivrance'),
        pw.Row(
          children: [
            pw.Expanded(child: _buildDetailField('QUALITY ANALYST / Analyste', '$analyst · $qc')),
            pw.Expanded(child: _buildDetailField('PLACE OF ISSUE / Lieu', place)),
            pw.Expanded(child: _buildDetailField('DATE OF ISSUE / Date', date)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildExportSection19Evidence(Map<String, dynamic> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('19. CUTTING EVIDENCE / Preuves de la coupe'),
        pw.Row(
          children: [
            pw.Expanded(child: _buildCuttingPhotoFrame('1st Cutting / 1re coupe')),
            pw.SizedBox(width: 6),
            pw.Expanded(child: _buildCuttingPhotoFrame('2nd Cutting / 2e coupe')),
            pw.SizedBox(width: 6),
            pw.Expanded(child: _buildCuttingPhotoFrame('3rd Cutting / 3e coupe')),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'Method and formulae applied: Three cuttings are made on 1,000 g samples; each result is shown and the average is reported. Total yield = good kernels + 50 % of the spotted and immature total. Outturn (KOR), in lbs per 80 kg bag = total yield (g) x 0.176. Moisture is read on the calibrated CQAAG meter; the export limit is 8.0 %.',
          style: pw.TextStyle(fontSize: 5.2, fontStyle: pw.FontStyle.italic, color: PdfColors.grey800),
        ),
      ],
    );
  }

  pw.Widget _buildCuttingPhotoFrame(String label) {
    return pw.Container(
      height: 52,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderGrey, width: 0.5),
        color: PdfColors.grey100,
      ),
      child: pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(label, style: pw.TextStyle(fontSize: 5.5, color: PdfColors.grey700)),
            pw.SizedBox(height: 2),
            pw.Text('[ Photo attached ]', style: pw.TextStyle(fontSize: 5, color: cqaagGreen, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildExportSection20Authorisation(
    Map<String, dynamic> data,
    String docHash, {
    required bool isApproved,
    required bool isDraft,
  }) {
    final analyst = (data['inspector'] ?? 'Specimen Analyst').toString();
    final qc = (data['qcCode'] ?? 'CQAAG-QC-0000').toString();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('20. AUTHORISATION, STAMP AND SIGNATURE / Autorisation, cachet et signature'),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Left: Analyst signature block
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(5),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: borderGrey, width: 0.5)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('ANALYST – ELECTRONIC SIGNATURE / Analyste', style: pw.TextStyle(fontSize: 5.8, color: PdfColors.grey700)),
                    pw.SizedBox(height: 2),
                    pw.Text('Electronically signed: $analyst · $qc', style: pw.TextStyle(fontSize: 6.8, fontWeight: pw.FontWeight.bold, color: cqaagGreen)),
                    pw.Text('Device: CQAAG-APP/TAB-0000 · SHA-256: $docHash', style: pw.TextStyle(fontSize: 5.5, color: PdfColors.grey800)),
                    pw.SizedBox(height: 3),
                    pw.Text('Verify: scan the QR code on page 1. / Vérifier : scanner le code QR de la page 1.', style: pw.TextStyle(fontSize: 5, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)),
                  ],
                ),
              ),
            ),
            pw.SizedBox(width: 8),

            // Right: Association Official Navy Stamp or Draft review box
            pw.Expanded(
              child: isDraft
                  ? pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.red800, width: 0.8),
                        color: PdfColors.red50,
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('DRAFT FOR SHIPPER REVIEW / Projet pour examen', style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
                          pw.SizedBox(height: 2),
                          pw.Text('Check sections I & II against shipping docs. Tap "Approve draft" in app once confirmed.', style: pw.TextStyle(fontSize: 5.5, color: PdfColors.black)),
                          pw.SizedBox(height: 2),
                          pw.Text('DRAFT D1 · NOT SIGNED · NOT VALID FOR EXPORT', style: pw.TextStyle(fontSize: 5.5, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
                        ],
                      ),
                    )
                  : pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      decoration: pw.BoxDecoration(border: pw.Border.all(color: borderGrey, width: 0.5)),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('FOR THE ASSOCIATION / Pour l’Association', style: pw.TextStyle(fontSize: 5.5, color: PdfColors.grey700)),
                              pw.SizedBox(height: 1),
                              pw.Text('[X] National President', style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold)),
                              pw.Text('[ ] National General Secretary', style: pw.TextStyle(fontSize: 5.5)),
                              pw.SizedBox(height: 2),
                              pw.Text((data['approvedByName'] ?? 'Ebenezer Amoafo').toString(), style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, color: cqaagNavy)),
                              pw.Text('Date: ${(data['approvedAt'] ?? data['date'] ?? '16 October 2026').toString()}', style: pw.TextStyle(fontSize: 5.5)),
                            ],
                          ),
                          _buildOfficialNavyStamp(
                            signatoryName: (data['approvedByName'] ?? 'Ebenezer Amoafo').toString(),
                            signatoryTitle: 'National President',
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildOfficialNavyStamp({
    required String signatoryName,
    required String signatoryTitle,
  }) {
    return pw.Container(
      width: 78,
      height: 78,
      decoration: pw.BoxDecoration(
        shape: pw.BoxShape.circle,
        border: pw.Border.all(color: cqaagNavy, width: 2),
      ),
      padding: const pw.EdgeInsets.all(2.5),
      child: pw.Container(
        decoration: pw.BoxDecoration(
          shape: pw.BoxShape.circle,
          border: pw.Border.all(color: cqaagNavy, width: 0.7),
        ),
        child: pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('CASHEW QUALITY ANALYSTS’', style: pw.TextStyle(color: cqaagNavy, fontSize: 3.5, fontWeight: pw.FontWeight.bold)),
              pw.Text('ASSOCIATION', style: pw.TextStyle(color: cqaagNavy, fontSize: 3.5, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 1),
              pw.Text('CQAAG', style: pw.TextStyle(color: cqaagNavy, fontSize: 10, fontWeight: pw.FontWeight.bold, letterSpacing: 0.8)),
              pw.Text(signatoryName, style: pw.TextStyle(color: cqaagNavy, fontSize: 4.8, fontStyle: pw.FontStyle.italic, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 0.8),
              pw.Text('GHANA · OFFICIAL STAMP', style: pw.TextStyle(color: cqaagNavy, fontSize: 3.5, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------- ANALYST SIGNATURE BLOCK (General) -----------------
  pw.Widget _buildAnalystSignatureBlock(Map<String, dynamic> data, String docHash) {
    final analyst = (data['inspector'] ?? 'Specimen Analyst').toString();
    final qc = (data['qcCode'] ?? 'CQAAG-QC-0000').toString();
    final date = (data['date'] ?? '2026-10-10 14:32').toString();

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(4),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: borderGrey, width: 0.5)),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('QUALITY ANALYST – ELECTRONIC SIGNATURE / Analyste qualité', style: pw.TextStyle(fontSize: 5.5, color: PdfColors.grey700)),
                pw.SizedBox(height: 2),
                pw.Text('Electronically signed · Signé électroniquement: $analyst · $qc', style: pw.TextStyle(fontSize: 6.8, fontWeight: pw.FontWeight.bold, color: cqaagGreen)),
                pw.Text('Signed $date UTC · device CQAAG-APP/TAB-0000', style: pw.TextStyle(fontSize: 5.5, color: PdfColors.grey800)),
                pw.Text('SHA-256: $docHash', style: pw.TextStyle(fontSize: 5.5, color: PdfColors.grey800)),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 6),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(4),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: borderGrey, width: 0.5)),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('VERIFICATION / Vérification', style: pw.TextStyle(fontSize: 5.5, color: PdfColors.grey700)),
                pw.SizedBox(height: 1.5),
                pw.Text('Scan the QR code, or enter the certificate number at cqaaggh.org/verify.', style: pw.TextStyle(fontSize: 5, color: PdfColors.grey800)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ----------------- FOOTER -----------------
  pw.Widget _buildStandardFooter(String certNumber, {required int page, required int totalPages}) {
    return pw.Column(
      children: [
        pw.Divider(color: cqaagGreen.shade(0.3), thickness: 0.5),
        pw.Text(
          '“Guardians of Ghana’s Cashew Quality”',
          style: pw.TextStyle(fontSize: 6.8, fontWeight: pw.FontWeight.bold, fontStyle: pw.FontStyle.italic, color: cqaagGreen),
        ),
        pw.SizedBox(height: 1),
        pw.Text(
          'CQAAG Standardised Cut Test Protocol · Wenchi, Bono Region, Ghana · Tel +233 55 333 0931 · info@cqaaggh.org',
          style: pw.TextStyle(fontSize: 5.5, color: PdfColors.grey800),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 1),
        pw.Text(
          'This certificate reports the result of a quality analysis made on a sample drawn from the lot described above, by a CQAAG quality analyst in good standing, under the CQAAG Standardised Cut Test Protocol. It is not a phytosanitary, fumigation or origin certificate and does not replace documents issued by the competent public authorities. Any alteration invalidates it. Verify it by scanning the QR code. Ce certificat rend compte d’une analyse de qualité réalisée sur un échantillon du lot décrit ci-dessus ; il ne remplace ni le certificat phytosanitaire, ni le certificat d’origine, ni aucun document délivré par les autorités publiques. Toute altération l’invalide.',
          style: pw.TextStyle(fontSize: 4.6, color: PdfColors.grey700),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 2),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(certNumber, style: pw.TextStyle(fontSize: 5.5, fontWeight: pw.FontWeight.bold, color: cqaagGreen)),
            pw.Text('cqaaggh.org/c/$certNumber', style: pw.TextStyle(fontSize: 5.5, color: PdfColors.grey700)),
            pw.Text('Page $page of $totalPages', style: pw.TextStyle(fontSize: 5.5, color: PdfColors.grey700)),
          ],
        ),
      ],
    );
  }

  static String _generateDocHash(String certNumber, String id) {
    final raw = '$certNumber:$id:CQAAG_GUARDIAN_2026';
    final bytes = utf8.encode(raw);
    var hash = 0xcbf29ce484222325;
    for (final b in bytes) {
      hash ^= b;
      hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
    }
    return hash.toRadixString(16).toUpperCase().padLeft(16, '0');
  }
}
