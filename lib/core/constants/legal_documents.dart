/// The association's governing documents, as approved for the app.
///
/// One source of truth for the text: the reading screens render it, and the
/// signing flow prints it into the A4 PDF that is filed in the agreements
/// database. Editing a document here therefore changes both at once, which is
/// why [LegalDocuments.version] must be bumped with any wording change — every
/// signed record stores the version it was signed against.
library;

/// The documents an applicant reads and accepts, by digital signature or by
/// tick box.
enum LegalDocumentType {
  membershipAgreement('membership-agreement', 'agreement', 'Membership Agreement'),
  codeOfEthics('code-of-ethics', 'ethics', 'Code of Ethics'),
  termsOfService('terms-of-service', 'terms', 'Terms of Service'),
  privacyPolicy('privacy-policy', 'privacy', 'Privacy Policy'),
  membershipDeclaration('membership-declaration', 'declaration', 'Membership Declaration');

  const LegalDocumentType(this.slug, this.shortKey, this.title);

  /// Slug the agreements database files the document under, shared with the
  /// website.
  final String slug;

  /// Key of the document in a membership record's `signed_documents` map.
  final String shortKey;

  final String title;

  static LegalDocumentType fromSlug(String? slug) {
    return LegalDocumentType.values.firstWhere(
      (t) => t.slug == slug || t.shortKey == slug,
      orElse: () => LegalDocumentType.membershipAgreement,
    );
  }
}

/// A run of text, or a bulleted list, within a section.
class LegalBlock {
  const LegalBlock.text(String this.text) : bullets = null;
  const LegalBlock.bullets(List<String> this.bullets) : text = null;

  final String? text;
  final List<String>? bullets;
}

class LegalSection {
  const LegalSection(this.heading, this.blocks);

  /// Null for untitled opening paragraphs.
  final String? heading;
  final List<LegalBlock> blocks;
}

class LegalDocument {
  const LegalDocument({
    required this.type,
    required this.organisation,
    required this.sections,
    this.introduction = const [],
    this.declaration,
    this.closing,
    this.showsLastUpdated = false,
  });

  final LegalDocumentType type;

  /// Organisation line under the title, worded as in the source document.
  final String organisation;

  /// Untitled paragraphs before the first section.
  final List<String> introduction;

  final List<LegalSection> sections;

  /// The statement the applicant signs or agrees to, when there is one.
  final String? declaration;

  /// Closing line after the signature block.
  final String? closing;

  /// Terms of Service and Privacy Policy carry a "Last Updated" date too.
  final bool showsLastUpdated;

  String get title => type.title;
}

class LegalDocuments {
  LegalDocuments._();

  /// Version of the wording below. Stored on every signed record.
  static const String version = '2026-10-05';

  /// Effective / last-updated date of the Terms of Service and Privacy Policy.
  static final DateTime publishedOn = DateTime(2026, 10, 5);

  static const String contactLine = 'Email: info@cqaaggh.org — Phone: +233 55 333 0931';

  static LegalDocument of(LegalDocumentType type) => switch (type) {
    LegalDocumentType.membershipAgreement => membershipAgreement,
    LegalDocumentType.codeOfEthics => codeOfEthics,
    LegalDocumentType.termsOfService => termsOfService,
    LegalDocumentType.privacyPolicy => privacyPolicy,
    LegalDocumentType.membershipDeclaration => membershipDeclaration,
  };

  /// The order an applicant goes through them. The Declaration is always last:
  /// it is the single consent gate that submits the application.
  static const List<LegalDocumentType> signingOrder = [
    LegalDocumentType.membershipAgreement,
    LegalDocumentType.codeOfEthics,
    LegalDocumentType.termsOfService,
    LegalDocumentType.privacyPolicy,
    LegalDocumentType.membershipDeclaration,
  ];

  /// Plain-text rendering of a document, used for the signed A4 copy.
  static List<String> plainParagraphs(LegalDocument document) {
    final out = <String>[...document.introduction];
    for (final section in document.sections) {
      if (section.heading != null) out.add('## ${section.heading}');
      for (final block in section.blocks) {
        if (block.text != null) out.add(block.text!);
        for (final bullet in block.bullets ?? const <String>[]) {
          out.add('• $bullet');
        }
      }
    }
    return out;
  }

  static const LegalDocument membershipAgreement = LegalDocument(
    type: LegalDocumentType.membershipAgreement,
    organisation: 'Cashew Quality Analyst Association of Ghana (CQAAG)',
    introduction: [
      'This Membership Agreement (“Agreement”) is entered into between the Cashew Quality Analyst Association of Ghana (“CQAAG”, “we”, “us”, or “our”) and you (“Member”, “you”) upon submission and approval of your membership application.',
      'By applying for membership, paying any applicable fees, and using member benefits, you agree to be bound by this Agreement, the CQAAG Constitution, the Code of Ethics, the Terms of Service, and the Privacy Policy of our website and App (together, the “Governing Documents”).',
    ],
    sections: [
      LegalSection('1. Membership Categories', [
        LegalBlock.text('CQAAG offers the following membership categories, as set out in Article Two of the Constitution:'),
        LegalBlock.bullets([
          'Full Members: Experienced professionals in cashew quality control who are indigenous (Ghanaian) nationals. Full Members hold voting rights, are eligible to hold executive office, and are qualified to be recommended to the Tree Crops Development Authority (TCDA) for licensing to practice cashew quality control nationwide.',
          'National Associate Members: Indigenous (Ghanaian) individuals or entities interested in the Association’s work but not meeting full eligibility for Full Membership (e.g., students, trainees, affiliates from related fields). National Associate Members may attend Association events but do not have voting rights and are not eligible to hold executive office.',
          'Foreign Associate Members: Foreign cashew quality analysts practicing, or seeking to practice, cashew quality control in Ghana. Together with Full Members, Foreign Associate Members are qualified to be recommended to the TCDA for licensing to practice cashew quality control nationwide. Foreign Associate Members do not have voting rights and are not eligible to hold executive office.',
          'Corporate Members: Laboratories, processors, or organizations supporting quality efforts (non-voting).',
          'Honorary Members: Distinguished individuals nominated by the Board and approved by the membership for significant contributions to the Association’s objectives.',
        ]),
        LegalBlock.text('Full details of eligibility, rights, and benefits for each category are set out in the CQAAG Constitution and are available from the National Secretariat and the Member Portal.'),
      ]),
      LegalSection('2. Membership Benefits', [
        LegalBlock.text('Members in good standing may enjoy:'),
        LegalBlock.bullets([
          'Access to training programs, workshops, and certification courses',
          'Networking opportunities and member directory listing (with consent)',
          'Priority registration for events and conferences',
          'Access to exclusive resources, industry updates, and research materials',
          'Voting rights (for Full Members only)',
          'Advocacy and representation in the cashew quality sector',
          'For eligible categories (Full and Foreign Associate Members), recommendation for TCDA licensing and participation in CQAAG’s joint quality-control programmes with the TCDA, including Project GUARDIAN',
        ]),
        LegalBlock.text('Benefits are subject to change and vary by category.'),
      ]),
      LegalSection('3. Membership Obligations', [
        LegalBlock.text('As a Member, you agree to:'),
        LegalBlock.bullets([
          'Uphold the highest professional standards and ethics in cashew quality analysis',
          'Comply with CQAAG’s Code of Ethics',
          'Pay the Registration Fee',
          'Pay Annual Dues promptly (per category)',
          'Provide accurate and updated personal and professional information',
          'Respect the intellectual property and confidentiality of Association materials and quality data',
          'Promote the objectives of CQAAG, including advancing quality standards in Ghana’s cashew industry',
          'Where practicing cashew quality control (Full and Foreign Associate Members), maintain active registration with CQAAG as a condition of any TCDA licence recommendation issued in your favour',
        ]),
      ]),
      LegalSection('4. Registration Fee and Annual Dues', [
        LegalBlock.bullets([
          'The Registration Fee and Annual Dues for each membership category are determined by the Board of Directors, approved by the membership at the Annual General Meeting, and set out in the CQAAG Membership Fee Schedule, available from the National Secretariat and the Member Portal.',
          'National Associate Members and Corporate Members pay the full Registration Fee and one-half of Annual Dues.',
          'Foreign Associate Members pay a special Registration Fee and/or Annual Dues as determined by the Board of Directors.',
          'Honorary Members are exempt from both the Registration Fee and Annual Dues.',
          'Fees are non-refundable except in exceptional circumstances at CQAAG’s discretion.',
          'Dues renew annually unless terminated.',
          'Failure to pay fees may result in suspension or termination of membership.',
        ]),
      ]),
      LegalSection('5. Term and Renewal', [
        LegalBlock.bullets([
          'Membership commences upon payment and approval and runs for one year.',
          'Automatic renewal occurs upon timely payment of renewal fees.',
          'You may opt out of renewal by notifying us in writing at least 30 days before expiry.',
        ]),
      ]),
      LegalSection('6. Termination', [
        LegalBlock.text('By You: You may terminate your membership at any time by written notice. No refund of fees.'),
        LegalBlock.text('By CQAAG: We may suspend or terminate your membership for:'),
        LegalBlock.bullets([
          'Non-payment of fees',
          'Breach of this Agreement, the Code of Ethics, or the Constitution',
          'Conduct harmful to CQAAG’s reputation or objectives',
          'Upon termination, access to member benefits ceases immediately, and, where termination affects your quality-control licensing status, the TCDA will be notified accordingly.',
        ]),
      ]),
      LegalSection('7. Code of Ethics', [
        LegalBlock.text('Every Member must read, sign, and abide by the CQAAG Code of Ethics, which is presented as a separate document and requires your digital signature. The Code of Ethics covers integrity and impartiality, professional competence, sustainability, fairness and community empowerment, collaboration, and compliance and accountability. Violations may lead to disciplinary action, including suspension or termination of membership.'),
      ]),
      LegalSection('8. Limitation of Liability', [
        LegalBlock.text('CQAAG provides networking, training, and information services but does not guarantee employment or business opportunities. CQAAG shall not be liable for any loss or damage arising from membership, except where required by Ghanaian law.'),
      ]),
      LegalSection('9. Governing Law', [
        LegalBlock.text('This Agreement is governed by the laws of the Republic of Ghana. Any disputes shall be resolved in the courts of Ghana, subject to any internal dispute-resolution mechanism provided for in the CQAAG Constitution.'),
      ]),
      LegalSection('10. Amendments', [
        LegalBlock.text('CQAAG may amend this Agreement. Changes will be communicated via email or the website/App. Continued membership after changes constitutes acceptance.'),
      ]),
      LegalSection('11. Contact Information', [
        LegalBlock.text('For questions or notices: $contactLine'),
      ]),
    ],
    declaration: 'By signing below, you acknowledge that you have read, understood, and agree to this Membership Agreement.',
    closing: 'Cashew Quality Analyst Association, Ghana — Guardians of Ghana’s Cashew Quality.',
  );

  static const LegalDocument codeOfEthics = LegalDocument(
    type: LegalDocumentType.codeOfEthics,
    organisation: 'Cashew Quality Analysts’ Association, Ghana (C.Q.A.A.G)',
    sections: [
      LegalSection('Preamble', [
        LegalBlock.text('Members of the Cashew Quality Analysts’ Association, Ghana (C.Q.A.A.G) proudly serve as Guardians of Ghana’s Cashew Quality. This Code of Ethics establishes the highest standards of professional conduct, rooted in the Association’s core values of Integrity, Excellence, Sustainability, Professionalism, Collaboration, and Community Empowerment.'),
        LegalBlock.text('All members — Full, National Associate, Foreign Associate, Corporate, and Honorary — must uphold this Code in every aspect of their work, aligning with the Association’s missions to enforce rigorous standards, build capacity, advocate for equitable practices, facilitate collaborations, and promote research and innovation.'),
        LegalBlock.text('This Code binds all members and supports enforcement through the Ethics and Disciplinary Committee, as outlined in the Constitution.'),
      ]),
      LegalSection('Article 1: Integrity and Impartiality', [
        LegalBlock.text('1.1 Members shall perform cashew quality analysis (including inspection, testing, grading, and certification) with unwavering honesty, accuracy, and freedom from bias, influence, or corruption.'),
        LegalBlock.text('1.2 Members shall avoid conflicts of interest and decline assignments where personal, financial, or relational ties could compromise objectivity.'),
        LegalBlock.text('1.3 Members shall reject bribes, gifts, favors, or inducements that influence professional judgment.'),
        LegalBlock.text('1.4 Members shall report suspected ethical violations, fraud, or non-compliance with standards to the Ethics and Disciplinary Committee or relevant authorities (e.g., TCDA).'),
      ]),
      LegalSection('Article 2: Professional Excellence and Competence', [
        LegalBlock.text('2.1 Members shall maintain the highest levels of technical competence through ongoing education, training, and adherence to national and international standards (e.g., Ghana Standards Authority).'),
        LegalBlock.text('2.2 Members shall conduct analyses using approved methods (e.g., cut testing, moisture determination, Kernel Outturn Ratio (KOR) assessment, aflatoxin screening) with precision and reliability.'),
        LegalBlock.text('2.3 Members shall pursue continuous professional development and contribute to the Association’s capacity-building efforts, including licensing and examinations.'),
      ]),
      LegalSection('Article 3: Sustainability and Environmental Responsibility', [
        LegalBlock.text('3.1 Members shall promote and support environmentally responsible practices that ensure the long-term viability of cashew farming and ecosystems.'),
        LegalBlock.text('3.2 Members shall advocate for sustainable handling, reduced waste, and good agricultural practices (GAP) among stakeholders.'),
        LegalBlock.text('3.3 Members shall consider the environmental impact of quality-control processes and recommend innovations that minimize harm.'),
      ]),
      LegalSection('Article 4: Fairness, Equity, and Community Empowerment', [
        LegalBlock.text('4.1 Members shall treat all stakeholders — farmers, traders, processors, women, youth, and rural communities — with respect, fairness, and without discrimination.'),
        LegalBlock.text('4.2 Members shall support equitable benefits in the cashew value chain, prioritizing fair returns for farmers and vulnerable groups.'),
        LegalBlock.text('4.3 Members shall foster knowledge sharing and empowerment through ethical practices and awareness campaigns.'),
      ]),
      LegalSection('Article 5: Collaboration and Professional Respect', [
        LegalBlock.text('5.1 Members shall collaborate constructively with fellow members, the Association, regulators (TCDA, CCG), security agencies, and international partners (e.g., African Cashew Alliance).'),
        LegalBlock.text('5.2 Members shall respect the reputation of the profession and avoid actions that discredit the Association or cashew quality control.'),
        LegalBlock.text('5.3 Members shall maintain confidentiality of sensitive information obtained during professional duties, except where disclosure is required by law or Association rules.'),
      ]),
      LegalSection('Article 6: Compliance and Accountability', [
        LegalBlock.text('6.1 Members shall comply with this Code, the Association’s Constitution, and all applicable laws of Ghana.'),
        LegalBlock.text('6.2 Violations of this Code may result in disciplinary actions, including warnings, suspension, or expulsion, as per the Constitution.'),
        LegalBlock.text('6.3 Members shall cooperate fully with investigations by the Ethics and Disciplinary Committee.'),
      ]),
      LegalSection('Adoption and Review', [
        LegalBlock.text('The Ethics and Disciplinary Committee shall recommend this Code to the General Assembly for adoption at an AGM or EGM. The Board shall review it periodically to ensure it remains relevant and effective.'),
        LegalBlock.text('By committing to this Code, members uphold the Association’s vision of establishing Ghana as a global benchmark for cashew quality while driving sustainable prosperity for all stakeholders.'),
      ]),
    ],
    declaration:
        'By submitting this application and upon approval as a member of the Cashew Quality Analysts’ Association, Ghana (C.Q.A.A.G), I hereby declare and agree:\n\n'
        '“I have read, understood, and fully accept the Constitution of the Cashew Quality Analysts’ Association, Ghana (C.Q.A.A.G) and this Code of Ethics. I commit to abide by all provisions, rules, and standards contained therein, to uphold the Association’s core values of Integrity, Excellence, Sustainability, Professionalism, Collaboration, and Community Empowerment, and to faithfully discharge my duties as a member in advancing the objectives and missions of the Association. I understand that any violation may result in disciplinary action, including suspension or termination of membership, in accordance with the Constitution.”\n\n'
        'This declaration shall be binding upon me for the duration of my membership.',
  );

  static const LegalDocument membershipDeclaration = LegalDocument(
    type: LegalDocumentType.membershipDeclaration,
    organisation: 'Cashew Quality Analyst Association of Ghana (CQAAG)',
    sections: [],
    declaration:
        'I hereby apply for membership in the Cashew Quality Analyst Association of Ghana (CQAAG).\n\n'
        'I confirm that the information provided is true and accurate. I agree to abide by the CQAAG Constitution, Code of Conduct, Membership Agreement, and any rules established by the Association. I agree to pay the applicable Registration Fee and annual Dues upon approval. I consent to my name, job title, and employer being listed in the public member directory.',
  );

  static const LegalDocument termsOfService = LegalDocument(
    type: LegalDocumentType.termsOfService,
    organisation: 'Cashew Quality Analyst Association, Ghana (CQAAG)',
    showsLastUpdated: true,
    introduction: [
      'Welcome to the website and mobile application of the Cashew Quality Analyst Association of Ghana (“CQAAG”, “we”, “us”, or “our”). These Terms of Service (“Terms”) govern your access to and use of the CQAAG website and the CQAAG mobile application (together, the “Platform”), including any content, functionality, and services offered on or through the Platform.',
      'By accessing or using the Platform, you agree to be bound by these Terms. If you do not agree, please do not use the Platform.',
    ],
    sections: [
      LegalSection('1. Acceptance of Terms', [
        LegalBlock.text('These Terms constitute a binding agreement between you and CQAAG. We may update these Terms from time to time. Changes will be posted on this page with a revised “Last Updated” date. Your continued use of the Platform after changes constitutes acceptance of the updated Terms.'),
      ]),
      LegalSection('2. Use of the Platform', [
        LegalBlock.text('You may use the Platform for lawful, non-commercial purposes only, including:'),
        LegalBlock.bullets([
          'Viewing information about CQAAG and the cashew quality industry',
          'Applying for membership',
          'Registering for events, training, or certifications',
          'Accessing member resources (if you are a registered member)',
        ]),
        LegalBlock.text('You agree not to:'),
        LegalBlock.bullets([
          'Use the Platform in any way that violates Ghanaian law or any applicable regulations',
          'Interfere with or disrupt the Platform or its servers',
          'Attempt to gain unauthorized access to any part of the Platform',
          'Use automated tools (e.g., bots, scrapers) to collect data without our written permission',
          'Upload viruses or malicious code',
          'Impersonate any person or entity',
        ]),
      ]),
      LegalSection('3. Membership', [
        LegalBlock.text('Certain features (e.g., the member portal, resources, and directories) are available only to registered members. By becoming a member:'),
        LegalBlock.bullets([
          'You agree to provide accurate, current, and complete information',
          'You are responsible for maintaining the confidentiality of your login credentials',
          'You agree to pay any applicable Registration Fee and Annual Dues promptly, as set out in the Membership Agreement and the CQAAG Membership Fee Schedule',
          'Membership may be terminated by CQAAG for violation of these Terms, the Membership Agreement, the Code of Ethics, or Association rules',
        ]),
        LegalBlock.text('CQAAG operates exclusively as a non-profit association. No part of CQAAG’s net earnings or resources — including those generated through the Platform, membership dues, training programmes, or events — inures to the private benefit of any individual, member, or officer; all such resources are applied solely to advancing CQAAG’s objectives.'),
      ]),
      LegalSection('4. Intellectual Property', [
        LegalBlock.text('All content on the Platform, including text, images, logos, documents, and resources (“Content”), is owned by CQAAG or its licensors and protected by copyright, trademark, and other laws.'),
        LegalBlock.text('You may:'),
        LegalBlock.bullets([
          'View and download Content for personal, non-commercial use',
          'Share links to the Platform',
        ]),
        LegalBlock.text('You may not:'),
        LegalBlock.bullets([
          'Reproduce, distribute, modify, or create derivative works without prior written permission',
          'Use CQAAG trademarks or logos without authorization',
        ]),
      ]),
      LegalSection('5. User Contributions', [
        LegalBlock.text('If you submit content (e.g., comments, forum posts, event feedback, or quality reports):'),
        LegalBlock.bullets([
          'You grant CQAAG a perpetual, royalty-free license to use, modify, and display it for Association purposes',
          'You represent that your contributions are lawful, accurate, and do not infringe third-party rights',
        ]),
        LegalBlock.text('We reserve the right to remove any user contribution at our discretion.'),
      ]),
      LegalSection('6. Disclaimer of Warranties', [
        LegalBlock.text('The Platform and its Content are provided “as is” without warranties of any kind, express or implied. CQAAG does not guarantee that the Platform will be uninterrupted, error-free, or free of viruses. Information on the Platform (including industry resources) is for general informational purposes only and should not be relied upon as professional advice.'),
      ]),
      LegalSection('7. Limitation of Liability', [
        LegalBlock.text('To the fullest extent permitted by law, CQAAG shall not be liable for any indirect, incidental, or consequential damages arising from your use of the Platform. Our total liability shall not exceed the amount of membership fees (if any) paid by you in the preceding 12 months.'),
      ]),
      LegalSection('8. Governing Law', [
        LegalBlock.text('These Terms are governed by the laws of the Republic of Ghana. Any disputes shall be resolved exclusively in the courts of Ghana, subject to any internal dispute-resolution mechanism provided for in the CQAAG Constitution.'),
      ]),
      LegalSection('9. Termination', [
        LegalBlock.text('We may suspend or terminate your access to the Platform at any time, without notice, for conduct that we believe violates these Terms or is harmful to other users or CQAAG.'),
      ]),
      LegalSection('10. Contact Information', [
        LegalBlock.text('For questions about these Terms: $contactLine'),
      ]),
      LegalSection('11. Miscellaneous', [
        LegalBlock.bullets([
          'If any provision of these Terms is held invalid, the remainder shall continue in full force.',
        ]),
        LegalBlock.text('These Terms, together with the Membership Agreement, the Code of Ethics, and the Privacy Policy, constitute the entire agreement between you and CQAAG regarding the Platform.'),
      ]),
    ],
    closing: 'Thank you for supporting the Cashew Quality Analyst Association, Ghana. We are committed to advancing quality standards in Ghana’s cashew industry.',
  );

  static const LegalDocument privacyPolicy = LegalDocument(
    type: LegalDocumentType.privacyPolicy,
    organisation: 'Cashew Quality Analyst Association of Ghana (CQAAG)',
    showsLastUpdated: true,
    introduction: [
      'The Cashew Quality Analyst Association, Ghana (“CQAAG”, “we”, “us”, or “our”) is committed to protecting the privacy of individuals who visit our website, use our mobile application, become members, or interact with our services (together, the “Platform”). This Privacy Policy explains how we collect, use, disclose, and protect your personal information in compliance with the Data Protection Act, 2012 (Act 843) of Ghana and other applicable laws.',
      'By using the Platform or providing information to us, you agree to the practices described in this Privacy Policy. If you do not agree, please do not use the Platform or provide personal information.',
      'As a non-profit organisation, CQAAG follows a principle of minimal data collection: we collect and store only the personal data necessary to fulfil our constitutional objectives — membership administration, professional licensing support, event coordination, quality-data collection, and communication — and nothing beyond that.',
    ],
    sections: [
      LegalSection('1. Information We Collect', [
        LegalBlock.text('We collect information in the following ways:'),
        LegalBlock.text('a. Information You Provide Directly: Name, date of birth, place of birth, Ghana Card/National ID number, email address, phone number, postal address, professional qualifications, employment details, and other information when you:'),
        LegalBlock.bullets([
          'Register as a member and sign the Membership Agreement, Code of Ethics, and Membership Declaration',
          'Sign up for events, training, or newsletters',
          'Submit a contact form or inquiry',
          'Apply for certification or resources',
          'Submit quality reports through the Member Portal (Full and Corporate Members)',
        ]),
        LegalBlock.text('b. Automatically Collected Information: IP address, browser/device type, operating system, referral pages, and usage data such as pages visited and time spent on the Platform (via cookies or similar technologies).'),
        LegalBlock.text('c. Information from Third Parties: We may receive information from partners (e.g., event co-organizers) or public sources related to the cashew industry.'),
        LegalBlock.text('We do not collect sensitive personal data (e.g., health, ethnic origin, political opinions) unless strictly necessary and with your explicit consent.'),
      ]),
      LegalSection('2. How We Use Your Information', [
        LegalBlock.text('We use your information for legitimate purposes, including:'),
        LegalBlock.bullets([
          'Processing membership applications and renewals',
          'Communicating about events, training, certifications, news, and industry updates',
          'Managing member directories (with your consent)',
          'Improving the Platform and our services',
          'Complying with legal obligations (e.g., reporting to regulatory bodies such as the Tree Crops Development Authority)',
          'Preventing fraud or misuse of the Platform',
        ]),
        LegalBlock.text('We process data based on your consent, contractual necessity (e.g., membership), or the legitimate interests of CQAAG.'),
      ]),
      LegalSection('3. Sharing of Information', [
        LegalBlock.text('We do not sell your personal information. We may share it only in these limited cases:'),
        LegalBlock.bullets([
          'With service providers (e.g., website/app hosting, email services) who are bound by data protection obligations',
          'With partners for joint events or training (with your consent)',
          'To comply with laws, court orders, or government requests, or disciplinary notifications to the TCDA where applicable',
          'In the event of a merger, reorganization, or transfer of association assets',
        ]),
        LegalBlock.text('Third-party providers must comply with the Data Protection Act, 2012 (Act 843).'),
      ]),
      LegalSection('4. Cookies and Similar Technologies', [
        LegalBlock.text('The Platform uses cookies to enhance user experience (e.g., remembering preferences).'),
        LegalBlock.bullets([
          'Essential cookies: required for site functionality',
          'Analytics cookies: help us understand usage (e.g., via Google Analytics, anonymised where possible)',
        ]),
        LegalBlock.text('You can manage cookies through your browser or device settings. Disabling them may affect Platform functionality.'),
      ]),
      LegalSection('5. Data Security', [
        LegalBlock.text('We implement appropriate technical and organizational measures to protect your information against unauthorized access, loss, or misuse (e.g., encryption, role-based access controls). However, no online transmission is 100% secure.'),
      ]),
      LegalSection('6. Data Retention', [
        LegalBlock.text('We retain personal information only as long as necessary for the purposes stated (e.g., duration of membership plus a reasonable period for records) or as required by law. After that, we securely delete or anonymise it.'),
      ]),
      LegalSection('7. Your Rights under the Data Protection Act, 2012 (Act 843)', [
        LegalBlock.text('You have the right to:'),
        LegalBlock.bullets([
          'Access your personal data',
          'Correct inaccurate data',
          'Object to or restrict processing',
          'Withdraw consent (where applicable)',
          'Request deletion (subject to legal obligations)',
          'Lodge a complaint with the Data Protection Commission (dataprotection.org.gh)',
        ]),
        LegalBlock.text('To exercise these rights, contact us using the details below.'),
      ]),
      LegalSection('8. Links to Third-Party Websites', [
        LegalBlock.text('The Platform may link to external sites (e.g., partners in the cashew industry, TCDA, CCG, ACA). We are not responsible for their privacy practices. Please review their policies separately.'),
      ]),
      LegalSection('9. Children’s Privacy', [
        LegalBlock.text('The Platform is not intended for children under 18. We do not knowingly collect data from minors.'),
      ]),
      LegalSection('10. Changes to This Policy', [
        LegalBlock.text('We may update this Privacy Policy. Changes will be posted here with a revised effective date. Significant changes will be notified via email or Platform notice.'),
      ]),
      LegalSection('11. Contact Us', [
        LegalBlock.text('For questions, requests, or complaints: $contactLine'),
        LegalBlock.text('You may also contact the Data Protection Commission of Ghana for further assistance.'),
      ]),
    ],
    closing: 'Thank you for trusting CQAAG with your information. We are dedicated to maintaining the highest standards of data protection in supporting Ghana’s cashew quality professionals.',
  );
}
