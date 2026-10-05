import 'package:flutter/material.dart';
import 'package:cqaag_app/index.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  static const String id = 'privacy_policy_screen';

  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentReader(type: LegalDocumentType.privacyPolicy);
  }
}
