import 'dart:convert';
import 'dart:typed_data';
import 'package:cqaag_app/models/moisture/moisture_pass.dart';

/// Service for formatting and generating 58mm ESC/POS thermal receipts
/// (Spec Section 88, Figures 22, 43–44; Rule R5; Tests 2.9, 2.10, 22.2)
class ThermalPosService {
  // Standard 58mm thermal printers have 32 characters per line at normal font (Font A)
  static const int kColumns58mm = 32;

  // ESC/POS Command Constants
  static const List<int> cmdInit = [0x1B, 0x40]; // ESC @ (Initialize printer)
  static const List<int> cmdAlignLeft = [0x1B, 0x61, 0x00]; // ESC a 0
  static const List<int> cmdAlignCenter = [0x1B, 0x61, 0x01]; // ESC a 1
  static const List<int> cmdAlignRight = [0x1B, 0x61, 0x02]; // ESC a 2
  static const List<int> cmdBoldOn = [0x1B, 0x45, 0x01]; // ESC E 1 (Bold ON)
  static const List<int> cmdBoldOff = [0x1B, 0x45, 0x00]; // ESC E 0 (Bold OFF)
  static const List<int> cmdDoubleHeightOn = [0x1B, 0x21, 0x10]; // ESC ! 16
  static const List<int> cmdDoubleHeightOff = [0x1B, 0x21, 0x00]; // ESC ! 0
  static const List<int> cmdFeedAndCut = [0x1D, 0x56, 0x41, 0x10]; // GS V A 16 (Feed and cut)
  static const List<int> cmdLineFeed = [0x0A]; // LF

  /// Generates the human-readable text layout formatted for a 32-column 58mm slip
  static String generateSlipText({
    required MoisturePass pass,
    bool isPracticeMode = false,
  }) {
    final buffer = StringBuffer();
    final divider = '=' * kColumns58mm;
    final singleLine = '-' * kColumns58mm;

    // Header
    buffer.writeln(divider);
    buffer.writeln(_center('CASHEW QUALITY ANALYSTS\''));
    buffer.writeln(_center('ASSOCIATION GHANA'));
    buffer.writeln(_center('CQAAG / TCDA RECOGNISED'));
    buffer.writeln(divider);

    if (isPracticeMode) {
      buffer.writeln(_center('*** PRACTICE MODE ***'));
      buffer.writeln(_center('TRAINING ONLY - NO LEGAL VALUE'));
      buffer.writeln(singleLine);
    }

    // Document Title
    final title = pass.isPass ? 'MOISTURE CONTROL PASS' : 'FAILED PASS - NOT VALID';
    buffer.writeln(_center(title));
    buffer.writeln(singleLine);

    // Document Identifiers
    buffer.writeln('Pass No:   ${pass.passNumber}');
    buffer.writeln('Lot No:    ${pass.lotCode}');
    buffer.writeln('Date/Time: ${_formatDateTime(pass.timestamp)}');
    buffer.writeln('Facility:  ${pass.facilityId}');
    buffer.writeln(singleLine);

    // Statutory TCDA Parties & Vehicle (Must be in BOLD per Test 2.9)
    buffer.writeln('VEHICLE:    ${pass.vehiclePlate}');
    buffer.writeln('SELLER TCDA:${pass.sellerTcda}');
    buffer.writeln('BUYER TCDA: ${pass.buyerTcda}');
    buffer.writeln(singleLine);

    // Metrology Results
    buffer.writeln('Meter S/N: ${pass.meterSerialNumber}');
    if (pass.isManualReading) {
      buffer.writeln('Reading:   MANUAL VERIFIED');
    }
    buffer.writeln('');
    buffer.writeln(_center('MOISTURE CONTENT: ${pass.moistureContent.toStringAsFixed(1)} %'));
    buffer.writeln(_center('MAX SAFE LIMIT:   ${pass.maxSafeLimit.toStringAsFixed(1)} %'));
    buffer.writeln('');

    if (pass.isPass) {
      buffer.writeln(_center('*** PASSED (<= 10.0%) ***'));
      buffer.writeln(_center('VALID FOR ARRIVAL CUTTING'));
    } else {
      buffer.writeln(_center('*** FAILED (> 10.0%) ***'));
      buffer.writeln(_center('CUT-TEST LOCKED'));
      buffer.writeln(_center('REASON: MOISTURE EXCEEDS LIMIT'));
    }

    buffer.writeln(singleLine);

    if (isPracticeMode) {
      buffer.writeln(_center('[ NO QR CODE - PRACTICE ]'));
    } else {
      buffer.writeln(_center('SCAN QR CODE TO VERIFY'));
      buffer.writeln(_center('cqaaggh.org/p/'));
      buffer.writeln(_center(pass.passNumber));
      buffer.writeln(_center('Token: ${pass.signatureHash}'));
    }

    buffer.writeln(divider);
    buffer.writeln(_center('Act 772 / Act 843 Statutory Slip'));
    buffer.writeln(_center('Official CQAAG POS Output'));
    buffer.writeln(divider);

    return buffer.toString();
  }

  /// Generates the raw ESC/POS binary byte stream to send directly to Bluetooth/USB POS printer
  static Uint8List generateEscPosBytes({
    required MoisturePass pass,
    bool isPracticeMode = false,
  }) {
    final bytes = <int>[];

    // Helper to add ascii/utf8 bytes
    void writeText(String text) {
      bytes.addAll(utf8.encode(text));
    }

    void writeLine(String text) {
      writeText(text);
      bytes.addAll(cmdLineFeed);
    }

    // 1. Initialize printer
    bytes.addAll(cmdInit);

    // 2. Centered Header
    bytes.addAll(cmdAlignCenter);
    bytes.addAll(cmdBoldOn);
    writeLine('================================');
    writeLine('CASHEW QUALITY ANALYSTS\'');
    writeLine('ASSOCIATION GHANA');
    bytes.addAll(cmdBoldOff);
    writeLine('CQAAG / TCDA RECOGNISED');
    writeLine('================================');

    if (isPracticeMode) {
      bytes.addAll(cmdBoldOn);
      bytes.addAll(cmdDoubleHeightOn);
      writeLine('*** PRACTICE MODE ***');
      bytes.addAll(cmdDoubleHeightOff);
      bytes.addAll(cmdBoldOff);
      writeLine('--------------------------------');
    }

    // 3. Document Title
    bytes.addAll(cmdBoldOn);
    bytes.addAll(cmdDoubleHeightOn);
    if (pass.isPass) {
      writeLine('MOISTURE PASS');
    } else {
      writeLine('FAILED PASS');
      writeLine('NOT VALID');
    }
    bytes.addAll(cmdDoubleHeightOff);
    bytes.addAll(cmdBoldOff);
    writeLine('--------------------------------');

    // 4. Details (Left-aligned)
    bytes.addAll(cmdAlignLeft);
    writeLine('Pass No:   ${pass.passNumber}');
    writeLine('Lot No:    ${pass.lotCode}');
    writeLine('Date/Time: ${_formatDateTime(pass.timestamp)}');
    writeLine('Facility:  ${pass.facilityId}');
    writeLine('--------------------------------');

    // 5. Parties & Vehicle in BOLD (Test 2.9)
    bytes.addAll(cmdBoldOn);
    writeLine('VEHICLE:    ${pass.vehiclePlate}');
    writeLine('SELLER TCDA:${pass.sellerTcda}');
    writeLine('BUYER TCDA: ${pass.buyerTcda}');
    bytes.addAll(cmdBoldOff);
    writeLine('--------------------------------');

    // 6. Moisture Result Centered & Bold
    bytes.addAll(cmdAlignCenter);
    bytes.addAll(cmdBoldOn);
    bytes.addAll(cmdDoubleHeightOn);
    writeLine('${pass.moistureContent.toStringAsFixed(1)} %');
    bytes.addAll(cmdDoubleHeightOff);
    bytes.addAll(cmdBoldOff);
    writeLine('Safe Max: ${pass.maxSafeLimit.toStringAsFixed(1)} %');

    bytes.addAll(cmdBoldOn);
    if (pass.isPass) {
      writeLine('*** PASSED (<= 10.0%) ***');
      writeLine('VALID FOR ARRIVAL CUTTING');
    } else {
      writeLine('*** FAILED (> 10.0%) ***');
      writeLine('CUT-TEST LOCKED');
    }
    bytes.addAll(cmdBoldOff);
    writeLine('--------------------------------');

    // 7. QR Code generation (ESC/POS QR code command GS ( k)
    if (!isPracticeMode) {
      final qrUrl = pass.verificationUrl;
      final qrBytes = utf8.encode(qrUrl);
      final len = qrBytes.length + 3;
      final pL = len % 256;
      final pH = len ~/ 256;

      // GS ( k pL pH cn fn n1 n2 (Store data in QR code area)
      bytes.addAll([0x1D, 0x28, 0x6B, pL, pH, 0x31, 0x50, 0x30]);
      bytes.addAll(qrBytes);

      // Set QR size: GS ( k 03 00 31 43 06 (size 6)
      bytes.addAll([0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x43, 0x06]);

      // Print QR code: GS ( k 03 00 31 51 30
      bytes.addAll([0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x51, 0x30]);
      bytes.addAll(cmdLineFeed);

      writeLine('SCAN QR TO VERIFY');
      writeLine('Token: ${pass.signatureHash}');
    }

    writeLine('================================');
    writeLine('Official CQAAG POS Slip');
    bytes.addAll(cmdLineFeed);
    bytes.addAll(cmdLineFeed);

    // Feed and partial cut
    bytes.addAll(cmdFeedAndCut);

    return Uint8List.fromList(bytes);
  }

  static String _center(String text) {
    if (text.length >= kColumns58mm) return text;
    final padding = (kColumns58mm - text.length) ~/ 2;
    return ' ' * padding + text;
  }

  static String _formatDateTime(DateTime dt) {
    final y = dt.year;
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $hh:$mm';
  }
}
