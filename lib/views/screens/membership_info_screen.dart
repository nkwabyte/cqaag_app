import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';
import 'package:go_router/go_router.dart';

class MembershipInfoScreen extends StatelessWidget {
  static const String id = 'membership_info_screen';

  const MembershipInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const CustomText('Membership', variant: TextVariant.bodyLarge, color: Colors.white),
        backgroundColor: AppColors.darkRed,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
              decoration: BoxDecoration(
                color: AppColors.darkRed,
              ),
              child: const Center(
                child: CustomText(
                  'Membership',
                  variant: TextVariant.displayMedium,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview
                  Center(
                    child: CustomText(
                      'Membership Portal Overview',
                      variant: TextVariant.headlineMedium,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Gap(16.h),
                  const CustomText(
                    'The Cashew Quality Analysts\' Association, Ghana (C.Q.A.A.G) Membership Portal is the central hub for our professional community. This secure platform handles registration, authentication, member management, and restricted features like quality report submissions. It ensures compliance with the Association\'s non-profit ethos, ethical standards, and Ghanaian data protection laws.',
                    variant: TextVariant.bodyMedium,
                    textAlign: TextAlign.justify,
                  ),
                  Gap(12.h),
                  const CustomText(
                    'Upon registration approval by the Membership Committee, the system generates a unique Member ID and access code, allowing for secure onboarding and national-level monitoring.',
                    variant: TextVariant.bodyMedium,
                    textAlign: TextAlign.justify,
                  ),
                  Gap(24.h),
                  const Divider(),
                  Gap(24.h),

                  // 1. Eligibility
                  _buildSectionHeader('1. Eligibility & Membership Categories'),
                  Gap(16.h),
                  _buildSubHeader('Eligibility Criteria'),
                  Gap(12.h),
                  _buildBulletPoint('Age: Applicants must be at least 16 years of age or of legal majority.'),
                  _buildBulletPoint('Agreements: Must abide by the Constitution, Code of Ethics, and Membership Agreement.'),
                  _buildBulletPoint('No Conflicting History: Applicants must have no history of ethical violations or convictions relevant to the industry.'),
                  Gap(16.h),

                  // Eligibility Declaration Box
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(
                        left: BorderSide(color: Colors.green.shade800, width: 4.w),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText('Ethical Eligibility Declaration (Preview)', variant: TextVariant.bodyMedium, fontWeight: FontWeight.bold),
                        Gap(8.h),
                        CustomText(
                          'All applicants are required to sign the "No Conflicting History Acknowledgement Declaration" confirming they have no prior history of actions conflicting with C.Q.A.A.G objectives, including fraud, corruption, or professional misconduct in quality control. False declarations lead to immediate rejection or termination.',
                          variant: TextVariant.bodySmall,
                          fontStyle: FontStyle.italic,
                        ),
                      ],
                    ),
                  ),
                  Gap(24.h),

                  // Membership Categories
                  _buildSubHeader('Membership Categories'),
                  Gap(12.h),
                  _buildCategoryItem(
                    '1. Full Members',
                    'Experienced quality analysts in cashew quality control with voting rights. Only Full Members are qualified to be licensed by the TCDA to practice cashew quality control.',
                  ),
                  _buildCategoryItem(
                    '2. Associate Members',
                    'Individuals interested in the Association\'s work (e.g., students, trainees) who do not meet full eligibility. Associate members can attend events but do not have voting rights and cannot hold executive office.',
                  ),
                  _buildCategoryItem('3. Corporate Members', 'Laboratories, processors, business companies, or organizations supporting quality efforts. Non-voting status.'),
                  _buildCategoryItem('4. Honorary Members', 'Distinguished individuals nominated by the Board for significant contributions. Non-voting and exempt from dues.'),

                  Gap(24.h),
                  const Divider(),
                  Gap(24.h),

                  // Rights & Duties
                  _buildSectionHeader('Rights & Duties of Members'),
                  Gap(16.h),

                  // Use Wrap or Column for mobile for the 2 columns layout
                  // To mimic 2 columns, we can use a Row if width > 600, else Column
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Ensure readable on mobile
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSubHeader('Rights'),
                          Gap(8.h),
                          _buildBulletPoint('Attend general meetings, workshops, and sponsored events.'),
                          _buildBulletPoint('Possess a valid Membership Card.'),
                          _buildBulletPoint('Receive publications, newsletters, and updates.'),
                          _buildBulletPoint('Vote on matters specified by membership class.'),
                          _buildBulletPoint('Access member-exclusive resources and directories.'),
                          Gap(24.h),
                          _buildSubHeader('Duties'),
                          Gap(8.h),
                          _buildBulletPoint('Uphold the principles and objectives of the Association.'),
                          _buildBulletPoint('Pay dues promptly as established by the Board.'),
                          _buildBulletPoint('Comply with all rules, ethical standards, and decisions.'),
                          _buildBulletPoint('Notify the Secretary of any changes in contact information.'),
                        ],
                      );
                    },
                  ),

                  Gap(24.h),
                  const Divider(),
                  Gap(24.h),

                  // 2. Application & Admission
                  _buildSectionHeader('2. Application & Admission'),
                  Gap(8.h),
                  const CustomText(
                    'Applications are processed via our Online Multi-step Form. Below is an overview of the requirements.',
                    variant: TextVariant.bodyMedium,
                  ),
                  Gap(16.h),

                  _buildSubHeader('Application Form Requirements'),
                  Gap(12.h),
                  _buildBulletPoint('Personal Info: Full Name, Contact Details, Ghana Card ID.'),
                  _buildBulletPoint('Professional Info: Job Title, Industry Sector, Years of Experience, Educational Qualifications.'),
                  _buildBulletPoint('Documents: Upload CV, Certificates (PDF).'),
                  _buildBulletPoint('Declarations:'),
                  Padding(
                    padding: EdgeInsets.only(left: 16.w),
                    child: Column(
                      children: [
                        _buildBulletPoint('Standard Statement of Interest (Commitment to Association values).'),
                        _buildBulletPoint('No Conflicting History Declaration.'),
                        _buildBulletPoint('Data Protection Consent.'),
                      ],
                    ),
                  ),

                  Gap(24.h),
                  // Interest Preview Box
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Column(
                      children: [
                        CustomText('Standard Statement of Interest (Preview)', variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                        Gap(12.h),
                        CustomText(
                          '"I am deeply committed to advancing the highest standards of quality, integrity, and sustainability in Ghana\'s cashew industry... I pledge to uphold the Association\'s core values of Integrity, Excellence, Sustainability, Professionalism, Collaboration, and Community Empowerment."',
                          variant: TextVariant.bodyMedium,
                          fontStyle: FontStyle.italic,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Gap(12.h),
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.sp),
                      children: const [
                        TextSpan(
                          text: 'Processing: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'Applications are reviewed by the Membership Committee within 30 days. Upon approval, you will receive a Welcome Packet and login credentials.',
                        ),
                      ],
                    ),
                  ),

                  Gap(32.h),
                  CustomText('Honorary Membership Nomination', variant: TextVariant.headlineSmall, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                  Gap(12.h),
                  const CustomText(
                    'Use the dedicated online form to nominate distinguished individuals who have made exceptional contributions to the industry. Nominations are reviewed by the Board and approved by the General Assembly.',
                    variant: TextVariant.bodyMedium,
                  ),
                  Gap(12.h),
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.sp),
                      children: const [
                        TextSpan(
                          text: 'Required Info: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: 'Nominator details, Nominee bio-data, Nomination Statement (300-600 words), and Supporting Documents (Letters, Awards, Reports).'),
                      ],
                    ),
                  ),

                  Gap(24.h),
                  const Divider(),
                  Gap(24.h),

                  // 3. Member Portal Dashboard
                  _buildSectionHeader('3. Member Portal Dashboard'),
                  Gap(8.h),
                  const CustomText('Once logged in, members access a personalized dashboard featuring:', variant: TextVariant.bodyMedium),
                  Gap(12.h),
                  _buildBulletPoint('Status View: Membership standing, card validity, and uniform status.', boldPrefix: true),
                  _buildBulletPoint('Dues Management: Secure online payment via Mobile Money or Card.', boldPrefix: true),
                  _buildBulletPoint('Quality Reports (Full/Corporate Only): Submission forms for Arrival, Dispatch, and Export metrics.', boldPrefix: true),
                  _buildBulletPoint('Resources: Exclusive access to directories, forums, and technical publications.', boldPrefix: true),
                  _buildBulletPoint('Profile Management: Update contact info and professional details.', boldPrefix: true),

                  Gap(32.h),
                  // Data Protection
                  Center(
                    child: CustomText(
                      'Data Protection and Privacy Compliance',
                      variant: TextVariant.headlineSmall,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Gap(16.h),
                  _buildSubHeader('Commitment to Minimal Data Storage', color: AppColors.darkBrown),
                  Gap(8.h),
                  const CustomText(
                    'The Cashew Quality Analysts\' Association, Ghana (C.Q.A.A.G) adheres strictly to the Data Protection Act, 2012 (Act 843). We collect only the minimum data necessary for membership administration, licensing support, and quality reporting.',
                    variant: TextVariant.bodySmall,
                  ),
                  Gap(16.h),
                  _buildSubHeader('Data Handling Principles', color: AppColors.darkBrown),
                  Gap(8.h),
                  _buildBulletPoint('Purpose Limitation: Data is used only for stated Association purposes.', boldPrefix: true),
                  _buildBulletPoint('Retention: Data is retained only as long as necessary.', boldPrefix: true),
                  _buildBulletPoint('Security: All data is encrypted and access-controlled.', boldPrefix: true),
                  _buildBulletPoint('No Sharing: Data is never sold. It is shared only where legally required (e.g., TCDA licensing).', boldPrefix: true),

                  Gap(24.h),
                  // No Private Earnings Box
                  Container(
                    padding: EdgeInsets.all(16.r),
                    color: Colors.green.shade50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText('No Private Earnings Assurance', variant: TextVariant.headlineSmall, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                        Gap(8.h),
                        CustomText(
                          'C.Q.A.A.G operates exclusively as a non-profit organization. No part of the Association\'s earnings or portal fees shall inure to the benefit of any private individual. All funds are dedicated to charitable, educational, and professional objectives.',
                          variant: TextVariant.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  Gap(24.h),
                  const Divider(),
                  Gap(24.h),

                  // Governance
                  Center(
                    child: CustomText(
                      'Governance Structure',
                      variant: TextVariant.headlineMedium,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Gap(24.h),
                  _buildSubHeader('General Assembly', color: AppColors.darkBrown),
                  Gap(4.h),
                  const CustomText(
                    'The supreme governing body representing all members. It approves policies, elects the Board, and holds leadership accountable. Meets annually at the AGM.',
                    variant: TextVariant.bodyMedium,
                  ),
                  Gap(16.h),
                  _buildSubHeader('National Leadership', color: AppColors.darkBrown),
                  Gap(8.h),
                  _buildBulletPoint('National Executive Officers: President, Vice-President, General Secretary, Organizer, Treasurer. Elected every 4 years.', boldPrefix: true),
                  _buildBulletPoint('Board of Directors: Provides strategic oversight. Includes Executives, Chapter Reps, TCDA Rep, and experts.', boldPrefix: true),
                  Gap(16.h),
                  _buildSubHeader('Committees', color: AppColors.darkBrown),
                  Gap(4.h),
                  const CustomText(
                    'Standing committees supporting operations include: Membership, Finance, Programs & Events, Elections, Ethics & Disciplinary, and Data Research.',
                    variant: TextVariant.bodyMedium,
                  ),
                  Gap(16.h),
                  _buildSubHeader('Regional Chapters', color: AppColors.darkBrown),
                  Gap(4.h),
                  const CustomText(
                    'Four semi-autonomous chapters (Sampa, Drobo-Dormaa, Techiman-Bole, Tema-Port) manage localized activities and welfare.',
                    variant: TextVariant.bodyMedium,
                  ),
                  Gap(24.h),

                  Center(
                    child: CustomText(
                      'National Executives & Committee Chairpersons Directory',
                      variant: TextVariant.headlineSmall,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrown,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Gap(8.h),
                  const Center(child: CustomText('For More information on the chapters visit the chapters page.', variant: TextVariant.bodySmall)),
                  Gap(16.h),
                  Center(
                    child: CustomButton(
                      text: 'Read more on Chapters',
                      onPressed: () => context.pushNamed(ChaptersScreen.id),
                      backgroundColor: const Color(0xFFC07747),
                      textColor: Colors.white,
                      width: 220.w,
                      height: 40.h,
                      trailingIcon: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                    ),
                  ),

                  Gap(24.h),
                  const Divider(),
                  Gap(24.h),

                  // Dues & Fees Table
                  _buildSectionHeader('Dues & Fees Structure'),
                  Gap(16.h),
                  _buildDuesTable(),

                  Gap(24.h),
                  const Divider(),
                  Gap(24.h),

                  // Membership Card & Uniform
                  _buildSectionHeader('Membership Card & Uniform'),
                  Gap(8.h),
                  const CustomText(
                    'To ensure uniformity, security, and proper monitoring, all membership identifiers are produced centrally at the National Executive Level (Headquarters in Wenchi).',
                    variant: TextVariant.bodyMedium,
                  ),
                  Gap(16.h),
                  _buildSubHeader('Membership Card'),
                  Gap(8.h),
                  _buildBulletPoint('Production: Centralised at HQ to prevent duplication.', boldPrefix: true),
                  _buildBulletPoint('Content: Includes Bio-data, Member ID, Chapter Affiliation, and Security Features.', boldPrefix: true),
                  _buildBulletPoint('Validity: Valid for 5 years; renewable annually upon dues payment.', boldPrefix: true),
                  _buildBulletPoint('Cost: Covered within Registration Fees/Annual Dues.', boldPrefix: true),
                  Gap(16.h),
                  _buildSubHeader('Association Uniform & Kits'),
                  Gap(8.h),
                  _buildBulletPoint('Design: Approved by the Board and Membership.', boldPrefix: true),
                  _buildBulletPoint('Eligibility: Available to all members in good standing.', boldPrefix: true),
                  _buildBulletPoint('Purpose: Promotes professional identity and visibility during fieldwork.', boldPrefix: true),

                  Gap(24.h),
                  const Divider(),
                  Gap(24.h),

                  // Termination & Discipline
                  _buildSectionHeader('Termination & Discipline Procedures'),
                  Gap(8.h),
                  const CustomText(
                    'Membership is a privilege that carries responsibilities. Procedures are fair, transparent, and conducted in accordance with Article 2 of the Constitution.',
                    variant: TextVariant.bodyMedium,
                  ),
                  Gap(16.h),
                  _buildSubHeader('Disciplinary Process'),
                  Gap(8.h),
                  _buildNumberedItem('1. Initiation: Complaint lodged in writing to the General Secretary or Ethics Committee.'),
                  _buildNumberedItem('2. Preliminary Review: Ethics Committee assesses merit.'),
                  _buildNumberedItem('3. Formal Investigation: Accused member notified and evidence gathered.'),
                  _buildNumberedItem('4. Hearing: Member presents defense and calls witnesses.'),
                  _buildNumberedItem('5. Decision: Board votes based on Committee recommendations (Dismissal, Warning, Suspension, or Termination).'),
                  _buildNumberedItem('6. Notification: Member informed within 14 days. TCDA notified within 30 days if terminated.'),
                  Gap(16.h),
                  _buildSubHeader('Appeals & Reinstatement'),
                  Gap(8.h),
                  _buildBulletPoint('Appeal: Submit to General Assembly within 30 days of notice.', boldPrefix: true),
                  _buildBulletPoint('Reinstatement: Submit new application, pay outstanding dues, and demonstrate remediation.', boldPrefix: true),

                  Gap(60.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return CustomText(
      title,
      variant: TextVariant.headlineSmall,
      fontWeight: FontWeight.bold,
      color: AppColors.darkBrown,
    );
  }

  Widget _buildSubHeader(String title, {Color? color}) {
    return CustomText(
      title,
      variant: TextVariant.bodyLarge,
      fontWeight: FontWeight.bold,
      color: color ?? Colors.green.shade700,
    );
  }

  Widget _buildBulletPoint(String text, {bool boldPrefix = false}) {
    String prefix = '';
    String content = text;

    if (boldPrefix && text.contains(':')) {
      final split = text.split(':');
      prefix = '${split[0]}:';
      content = split.sublist(1).join(':');
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText('• ', variant: TextVariant.bodyMedium, fontWeight: FontWeight.bold, color: Colors.black),
          Expanded(
            child: boldPrefix
                ? RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 13.sp), // Assuming bodyMedium size
                      children: [
                        TextSpan(
                          text: prefix,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                        ),
                        TextSpan(text: content),
                      ],
                    ),
                  )
                : CustomText(text, variant: TextVariant.bodyMedium, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: CustomText(text, variant: TextVariant.bodyMedium, color: Colors.black87),
    );
  }

  Widget _buildCategoryItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(title, variant: TextVariant.bodyMedium, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
          Gap(4.h),
          CustomText(description, variant: TextVariant.bodySmall, color: Colors.black87),
        ],
      ),
    );
  }

  Widget _buildDuesTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFF2E7D32)), // Green header
          dataRowColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
            // Alternating colors logic if needed, or simple greyish
            return Colors.grey.shade100;
          }),
          columns: const [
            DataColumn(
              label: Text(
                'Category',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Registration Fee (GHS)',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Annual Dues (GHS)',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Notes',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: const [
            DataRow(
              cells: [
                DataCell(Text('Full Member')),
                DataCell(Text('[Determined by Board]')),
                DataCell(Text('[Determined by Board]')),
                DataCell(Text('Full payment required.')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text('Associate Member')),
                DataCell(Text('200')),
                DataCell(Text('75')),
                DataCell(Text('Half dues.')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text('Corporate Member')),
                DataCell(Text('500')),
                DataCell(Text('250')),
                DataCell(Text('Organizational rate.')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text('Honorary Member')),
                DataCell(Text('Waived')),
                DataCell(Text('Waived')),
                DataCell(Text('No financial obligations.')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
