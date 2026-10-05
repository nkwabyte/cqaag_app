import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cqaag_app/core/constants/legal_documents.dart';

/// How an applicant accepted a document.
enum AcceptanceMethod {
  /// A signature drawn on the screen.
  signature('signature'),

  /// The "I accept" tick box.
  tick('tick');

  const AcceptanceMethod(this.value);

  /// Stored value, shared with the website.
  final String value;
}

/// The applicant identity printed on every accepted document. It comes from
/// the application itself and is never re-typed on the document.
class ApplicantIdentity {
  const ApplicantIdentity({
    required this.fullName,
    required this.dateOfBirth,
    required this.placeOfBirth,
    this.ghanaCardNumber,
    this.nationalIdNumber,
  });

  final String fullName;

  /// `yyyy-MM-dd`, as the website stores it on the packet.
  final String dateOfBirth;
  final String placeOfBirth;
  final String? ghanaCardNumber;
  final String? nationalIdNumber;

  String get idNumber => ghanaCardNumber ?? nationalIdNumber ?? '';

  @override
  bool operator ==(Object other) =>
      other is ApplicantIdentity &&
      other.fullName == fullName &&
      other.dateOfBirth == dateOfBirth &&
      other.placeOfBirth == placeOfBirth &&
      other.ghanaCardNumber == ghanaCardNumber &&
      other.nationalIdNumber == nationalIdNumber;

  @override
  int get hashCode => Object.hash(fullName, dateOfBirth, placeOfBirth, ghanaCardNumber, nationalIdNumber);
}

/// One accepted document: the A4 copy plus what the membership record keeps
/// about it. Same shape as the website's signed packet.
class SignedPacket {
  const SignedPacket({
    required this.type,
    required this.method,
    required this.identity,
    required this.signedAt,
    required this.pdfBytes,
  });

  final LegalDocumentType type;
  final AcceptanceMethod method;
  final ApplicantIdentity identity;
  final DateTime signedAt;
  final Uint8List pdfBytes;

  String get pdfBase64 => base64Encode(pdfBytes);

  /// What the agreements database is sent for this document.
  Map<String, String> toFiling() => {
    'slug': type.slug,
    'acceptance_method': method.value,
    'signed_at': signedAt.toUtc().toIso8601String(),
    'pdf_base64': pdfBase64,
  };

  /// What the membership record keeps: everything but the PDF itself, which
  /// lives only in the agreements database.
  Map<String, dynamic> toPublicJson() => {
    'slug': type.slug,
    'acceptance_method': method.value,
    'signature': identity.fullName,
    'signed_at': signedAt.toUtc().toIso8601String(),
    'signed_at_display': AgreementPdfService.formatSignedAt(signedAt),
    'full_name': identity.fullName,
    'date_of_birth': identity.dateOfBirth,
    'place_of_birth': identity.placeOfBirth,
    'ghana_card_number': identity.ghanaCardNumber,
    'national_id_number': identity.nationalIdNumber,
  };
}

/// Builds the A4 copy of an accepted governing document: the full text, the
/// applicant identity block, how and when it was accepted, and the drawn
/// signature when there is one. The applicant's name is printed automatically.
class AgreementPdfService {
  AgreementPdfService({Future<pw.Font> Function()? regularFont, Future<pw.Font> Function()? boldFont})
    : _regularFont = regularFont ?? PdfGoogleFonts.openSansRegular,
      _boldFont = boldFont ?? PdfGoogleFonts.openSansBold;

  final Future<pw.Font> Function() _regularFont;
  final Future<pw.Font> Function() _boldFont;

  /// The agreements database refuses anything larger, base64-encoded.
  static const int maxBase64Length = 700000;

  /// Accra keeps GMT all year, so UTC is the association's local time.
  static String formatSignedAt(DateTime time) {
    return '${DateFormat('d MMMM yyyy, HH:mm').format(time.toUtc())} GMT';
  }

  Future<SignedPacket> build({
    required LegalDocumentType type,
    required AcceptanceMethod method,
    required ApplicantIdentity identity,
    required DateTime signedAt,
    Uint8List? signaturePng,
    List<String> extraLines = const [],
  }) async {
    final document = LegalDocuments.of(type);
    final font = await _regularFont();
    final fontBold = await _boldFont();

    pw.MemoryImage? logo;
    try {
      final bytes = await rootBundle.load('assets/images/cqaag_logo.png');
      logo = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {}

    final signature = method == AcceptanceMethod.signature && signaturePng != null ? pw.MemoryImage(signaturePng) : null;
    final effectiveDate = DateFormat('MMMM dd, yyyy').format(signedAt);
    final published = DateFormat('MMMM dd, yyyy').format(LegalDocuments.publishedOn);

    final pdf = pw.Document(
      title: '${document.title} — ${identity.fullName}',
      author: 'Cashew Quality Analysts’ Association, Ghana',
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(54),
          // Italics map to the embedded fonts too: the built-in fallback has no
          // curly quotes or dashes.
          theme: pw.ThemeData.withFont(base: font, bold: fontBold, italic: font, boldItalic: fontBold),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            '${document.title} — ${identity.fullName} — Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
          ),
        ),
        build: (context) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (logo != null) ...[
                pw.SizedBox(width: 46, height: 46, child: pw.Image(logo)),
                pw.SizedBox(width: 12),
              ],
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(document.title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
                    pw.Text(document.organisation, style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(
                      document.showsLastUpdated
                          ? 'Effective Date: $effectiveDate  •  Last Updated: $published'
                          : 'Effective Date: $effectiveDate',
                      style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.Divider(thickness: 0.6, color: PdfColors.green900),
          pw.SizedBox(height: 6),
          for (final paragraph in LegalDocuments.plainParagraphs(document)) _paragraph(paragraph),
          if (document.declaration != null) ...[
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.6, color: PdfColors.green900)),
              child: pw.Text(document.declaration!, style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 2)),
            ),
          ],
          pw.SizedBox(height: 14),
          _identityBlock(identity, method, signedAt, signature, extraLines),
          if (document.closing != null) ...[
            pw.SizedBox(height: 10),
            pw.Text(document.closing!, style: pw.TextStyle(fontSize: 8.5, fontStyle: pw.FontStyle.italic)),
          ],
          pw.SizedBox(height: 8),
          pw.Text(
            'Document version ${LegalDocuments.version}. Filed in the CQAAG agreements database.',
            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    final packet = SignedPacket(type: type, method: method, identity: identity, signedAt: signedAt, pdfBytes: bytes);
    if (packet.pdfBase64.length > maxBase64Length) {
      throw Exception('The ${document.title} file is too large. Clear the signature and draw it again, or use the tick box.');
    }
    return packet;
  }

  pw.Widget _paragraph(String text) {
    if (text.startsWith('## ')) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8, bottom: 3),
        child: pw.Text(text.substring(3), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
      );
    }
    final isBullet = text.startsWith('• ');
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 4, left: isBullet ? 10 : 0),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 2)),
    );
  }

  pw.Widget _identityBlock(
    ApplicantIdentity identity,
    AcceptanceMethod method,
    DateTime signedAt,
    pw.MemoryImage? signature,
    List<String> extraLines,
  ) {
    pw.Widget line(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(text: '$label: ', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(text: value.isEmpty ? '—' : value, style: const pw.TextStyle(fontSize: 9.5)),
          ],
        ),
      ),
    );

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(color: PdfColors.grey100, border: pw.Border.all(width: 0.5, color: PdfColors.grey500)),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Applicant identity', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          line('Full Name', identity.fullName),
          line('Date of Birth', identity.dateOfBirth),
          line('Place of Birth', identity.placeOfBirth),
          line('Ghana Card / National ID Number', identity.idNumber),
          pw.SizedBox(height: 6),
          pw.Text(
            method == AcceptanceMethod.tick
                ? '[x] Accepted by tick box in the name of ${identity.fullName}'
                : 'Accepted by digital signature in the name of ${identity.fullName}',
            style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: PdfColors.green900),
          ),
          if (signature != null) ...[
            pw.SizedBox(height: 4),
            pw.Container(
              height: 60,
              width: 200,
              decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.6))),
              child: pw.Image(signature, fit: pw.BoxFit.contain),
            ),
          ],
          pw.SizedBox(height: 4),
          line('Printed name', identity.fullName),
          line('Date and time', formatSignedAt(signedAt)),
          for (final extra in extraLines) pw.Text(extra, style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }
}
