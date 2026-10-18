import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cqaag_app/models/user/app_user.dart';

/// Generates an official A6 printable digital membership card PDF per Section 9.1.
class MembershipCardPdfService {
  MembershipCardPdfService();

  Future<Uint8List> generateCardA6(AppUser user) async {
    final doc = pw.Document();

    pw.Font regularFont;
    pw.Font boldFont;
    try {
      regularFont = await PdfGoogleFonts.interRegular();
      boldFont = await PdfGoogleFonts.interBold();
    } catch (_) {
      regularFont = pw.Font.helvetica();
      boldFont = pw.Font.helveticaBold();
    }

    Uint8List? logoBytes;
    try {
      final logoData = await rootBundle.load('assets/images/cqaag_logo.png');
      logoBytes = logoData.buffer.asUint8List();
    } catch (_) {
      logoBytes = null;
    }

    final isGoodStanding = user.isGoodStanding;
    final statusText = isGoodStanding ? 'GOOD STANDING' : 'HIBERNATED';
    final statusColor = isGoodStanding ? PdfColors.green800 : PdfColors.amber800;
    final memberCode = user.effectiveMemberCode;
    final memberName = '${user.firstName} ${user.lastName}'.toUpperCase();
    final category = user.membershipCategory ?? 'Full Member';
    final chapter = user.chapter ?? user.region ?? 'National';
    final memberSince = user.memberSince != null
        ? DateFormat('dd MMM yyyy').format(user.memberSince!)
        : 'Registered Member';
    final timestamp = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now());
    final qrUrl = user.verificationQrUrl;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a6,
        margin: const pw.EdgeInsets.all(12),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.green800, width: 2),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Header green band
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  color: PdfColors.green900,
                  child: pw.Row(
                    children: [
                      if (logoBytes != null)
                        pw.Container(
                          width: 32,
                          height: 32,
                          margin: const pw.EdgeInsets.only(right: 8),
                          child: pw.Image(pw.MemoryImage(logoBytes)),
                        ),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "CASHEW QUALITY ANALYSTS' ASSOC. GHANA",
                              style: pw.TextStyle(
                                font: boldFont,
                                fontSize: 7.5,
                                color: PdfColors.white,
                              ),
                            ),
                            pw.Text(
                              'OFFICIAL DIGITAL MEMBERSHIP CARD',
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 6.5,
                                color: PdfColors.grey300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Card Body
                pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  memberName,
                                  style: pw.TextStyle(
                                    font: boldFont,
                                    fontSize: 10,
                                    color: PdfColors.black,
                                  ),
                                ),
                                pw.SizedBox(height: 3),
                                pw.Container(
                                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  color: PdfColors.grey200,
                                  child: pw.Text(
                                    memberCode,
                                    style: pw.TextStyle(
                                      font: boldFont,
                                      fontSize: 9,
                                      color: PdfColors.green900,
                                    ),
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  'Category: $category',
                                  style: pw.TextStyle(font: regularFont, fontSize: 7.5),
                                ),
                                pw.Text(
                                  'Chapter: $chapter',
                                  style: pw.TextStyle(font: regularFont, fontSize: 7.5),
                                ),
                                if (user.companyName != null && user.companyName!.isNotEmpty)
                                  pw.Text(
                                    'Company: ${user.companyName}',
                                    style: pw.TextStyle(font: regularFont, fontSize: 7.5),
                                  ),
                                pw.Text(
                                  'Member Since: $memberSince',
                                  style: pw.TextStyle(font: regularFont, fontSize: 7),
                                ),
                              ],
                            ),
                          ),
                          // QR code block
                          pw.Column(
                            children: [
                              pw.Container(
                                width: 75,
                                height: 75,
                                padding: const pw.EdgeInsets.all(3),
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(color: PdfColors.grey400),
                                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                                ),
                                child: pw.BarcodeWidget(
                                  barcode: pw.Barcode.qrCode(),
                                  data: qrUrl,
                                  drawText: false,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                'Scan to Verify',
                                style: pw.TextStyle(font: regularFont, fontSize: 6, color: PdfColors.grey700),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 8),

                      // Status chip
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: statusColor,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        ),
                        child: pw.Row(
                          mainAxisSize: pw.MainAxisSize.min,
                          children: [
                            pw.Text(
                              'STATUS: $statusText',
                              style: pw.TextStyle(
                                font: boldFont,
                                fontSize: 8,
                                color: PdfColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                pw.Spacer(),

                // Bottom security strip
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  color: PdfColors.grey100,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Status read: $timestamp',
                        style: pw.TextStyle(font: regularFont, fontSize: 6, color: PdfColors.grey600),
                      ),
                      pw.Text(
                        'Act 772 / Act 843 Compliant',
                        style: pw.TextStyle(font: regularFont, fontSize: 6, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }
}
