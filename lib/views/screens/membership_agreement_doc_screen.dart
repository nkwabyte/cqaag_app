import 'package:flutter/material.dart';
import 'package:cqaag_app/index.dart';

class MembershipAgreementDocScreen extends StatelessWidget {
  static const String id = 'membership_agreement_doc_screen';

  const MembershipAgreementDocScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentReader(type: LegalDocumentType.membershipAgreement);
  }
}
