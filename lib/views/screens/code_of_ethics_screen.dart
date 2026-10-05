import 'package:flutter/material.dart';
import 'package:cqaag_app/index.dart';

class CodeOfEthicsScreen extends StatelessWidget {
  static const String id = 'code_ethics_screen';

  const CodeOfEthicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentReader(type: LegalDocumentType.codeOfEthics);
  }
}
