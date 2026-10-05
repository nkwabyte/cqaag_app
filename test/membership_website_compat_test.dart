import 'package:flutter_test/flutter_test.dart';
import 'package:cqaag_app/core/constants/legal_documents.dart';
import 'package:cqaag_app/models/inspection/analysis_types.dart';
import 'package:cqaag_app/models/inspection/inspection.dart';
import 'package:cqaag_app/models/membership/membership_application.dart';
import 'package:cqaag_app/models/membership/membership_category.dart';
import 'package:cqaag_app/models/payment/payment_settings.dart';
import 'package:cqaag_app/services/membership/membership_service.dart';

/// A members document as the website writes it.
Map<String, dynamic> _websiteMember({Map<String, dynamic> overrides = const {}}) => {
  'id': 'abcDEF1234567890xyz',
  'user_id': 'uid123456789',
  'title': 'mr',
  'first_name': 'Ama',
  'last_name': 'Darko',
  'date_of_birth': '1990-04-02T00:00:00.000',
  'gender': 'female',
  'nationality': 'Ghanaian',
  'place_of_birth': 'Wenchi',
  'phone_number_primary': '+233200000000',
  'email_address': 'ama@example.com',
  'residential_address': 'Techiman',
  'region_district': 'Bono / Wenchi',
  'job_title': 'QC Manager',
  'employer_organization': 'Olam',
  'industry_sectors': ['export', 'other'],
  'industry_sector_other': 'Shipping',
  'years_of_experience': 6,
  'professional_qualifications': 'TCDA training',
  'education': {
    'level': 'other',
    'level_other': 'HND',
    'field_of_study': 'Agronomy',
    'institution': 'UDS',
    'year_obtained': 2015,
  },
  'membership_category': 'full',
  'status': 'approved',
  'payment_status': 'unpaid',
  'payment_amount': 450,
  'credentials_issued_at': '',
  ...overrides,
};

void main() {
  group('MembershipApplication reads website records', () {
    test('maps job_title and the nested education map', () {
      final app = MembershipApplication.fromJson(_websiteMember());
      expect(app.currentJobTitle, 'QC Manager');
      expect(app.highestEducationLevel, 'other');
      expect(app.educationLevelOther, 'HND');
      expect(app.fieldOfStudy, 'Agronomy');
      expect(app.institution, 'UDS');
      expect(app.yearQualificationObtained, '2015');
      expect(app.yearsOfExperience, 6);
      expect(app.credentialsIssuedAt, isNull);
    });

    test('describes sectors and education for people', () {
      final app = MembershipApplication.fromJson(_websiteMember());
      expect(IndustrySectors.describe(app.industrySectors, app.industrySectorOther), 'Export, Other: Shipping');
      expect(EducationLevels.describe(app.highestEducationLevel, app.educationLevelOther), 'HND');
    });

    test('writes the website names alongside its own', () {
      final app = MembershipApplication.fromJson(_websiteMember());
      final json = MembershipService.websiteFields(app);
      expect(json['job_title'], 'QC Manager');
      expect(json['current_job_title'], 'QC Manager');
      expect((json['education'] as Map)['year_obtained'], 2015);
      // Nested fee items must be maps for Firestore.
      expect(json['payment_optional_items'], isA<List>());
    });
  });

  group('Fee and credentials rules mirror the website', () {
    test('an approved, unpaid member still owes the fee', () {
      final app = MembershipApplication.fromJson(_websiteMember());
      expect(app.isFeeDue, isTrue);
      expect(app.mayReceiveCredentials, isFalse);
    });

    test('a submitted payment unlocks the password email', () {
      final app = MembershipApplication.fromJson(_websiteMember(overrides: {'payment_status': 'pending_verification'}));
      expect(app.isFeeDue, isFalse);
      expect(app.mayReceiveCredentials, isTrue);
    });

    test('Honorary Members owe nothing', () {
      final app = MembershipApplication.fromJson(_websiteMember(overrides: {'membership_category': 'honorary'}));
      expect(app.membershipCategory, MembershipCategory.honorary);
      expect(app.mayReceiveCredentials, isTrue);
    });

    test('a rejected payment is owed again', () {
      final app = MembershipApplication.fromJson(_websiteMember(overrides: {'payment_status': 'rejected'}));
      expect(app.payment, PaymentStatus.rejected);
      expect(app.isFeeDue, isTrue);
    });
  });

  group('Certificate types', () {
    test('the four paid types match the website', () {
      expect(AnalysisTypes.all, contains('Moisture Control'));
      for (final type in ['Moisture Control', 'Dispatch', 'Arbitration', 'Export']) {
        expect(AnalysisTypes.requiresPayment(type), isTrue, reason: type);
      }
      expect(AnalysisTypes.requiresPayment('Arrival Upcountry Warehouse'), isFalse);
      expect(AnalysisTypes.reportFeeCedis, 100);
    });

    test('only Export needs approval', () {
      expect(AnalysisTypes.requiresApproval('Export'), isTrue);
      expect(AnalysisTypes.requiresApproval('Dispatch'), isFalse);
    });
  });

  group('Export inspections', () {
    Inspection export({Map<String, dynamic> extra = const {}}) => Inspection.fromJson({
      'id': 'INS-ABC123',
      'inspector_id': 'uid1',
      'analysis_type': 'Export',
      'status': 'pending_approval',
      'approval_status': 'pending',
      'approved_at': '',
      ...extra,
    });

    test('reads the website pending state and is not yet valid', () {
      final i = export();
      expect(i.status, InspectionStatus.pendingApproval);
      expect(i.approval, CertificateApprovalStatus.pending);
      expect(i.isCertificateValid, isFalse);
    });

    test('becomes valid once approved', () {
      final i = export(extra: {'status': 'completed', 'approval_status': 'approved', 'approved_at': '2026-10-05T12:00:00Z'});
      expect(i.isCertificateValid, isTrue);
      expect(i.approvedAtTime, DateTime.utc(2026, 10, 5, 12));
    });

    test('a new Export is written with the empty approval fields the rules require', () {
      final json = const Inspection(
        id: 'x',
        inspectorId: 'uid1',
        analysisType: 'Export',
        approvalStatus: 'pending',
      ).toJson();
      expect(json['approval_status'], 'pending');
      expect(json['approved_at'], '');
      expect(json['approval_seal_url'], '');
    });

    test('unknown statuses from other clients do not break reading', () {
      expect(export(extra: {'status': 'something_new'}).status, InspectionStatus.pending);
    });
  });

  test('legal document slugs match the agreements database', () {
    expect(LegalDocuments.signingOrder.map((t) => t.slug), [
      'membership-agreement',
      'code-of-ethics',
      'terms-of-service',
      'privacy-policy',
      'membership-declaration',
    ]);
    expect(LegalDocumentType.fromSlug('ethics'), LegalDocumentType.codeOfEthics);
  });
}
