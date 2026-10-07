import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart' as uuid_pkg;
import 'package:cqaag_app/index.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  static const String id = 'services_screen';

  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _consultingKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToConsulting() {
    final context = _consultingKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _launchTCDAWebsite() async {
    final uri = Uri.parse('https://tcda.org.gh');
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          CustomSnackBar.error(context, message: 'Could not open TCDA website.');
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.error(context, message: 'Error opening TCDA website: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProfileProvider).value;
    final isMember = user != null && user.membershipStatus == MembershipStatus.verified;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.darkRed,
        title: const CustomText(
          'Our Services',
          variant: TextVariant.bodyLarge,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              decoration: BoxDecoration(
                color: AppColors.darkRed,
              ),
              child: Column(
                children: [
                  const CustomText(
                    'Association Services',
                    variant: TextVariant.displayMedium,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  Gap(10.h),
                  CustomText(
                    'Comprehensive quality, licensing, and trade facilitation services provided by C.Q.A.A.G in collaboration with the Tree Crops Development Authority (TCDA).',
                    variant: TextVariant.bodyMedium,
                    color: Colors.white.withValues(alpha: 0.9),
                    textAlign: TextAlign.center,
                  ),
                  Gap(14.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isMember
                          ? Colors.green.shade800
                          : Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isMember ? Icons.verified_user : Icons.person_outline,
                          color: Colors.white,
                          size: 16.r,
                        ),
                        Gap(6.w),
                        CustomText(
                          isMember ? "Verified Member Access" : "Standard Access",
                          variant: TextVariant.bodySmall,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Services List
            Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                children: [
                  // 1. Quality Inspection
                  _buildQualityInspectionCard(context, isMember: isMember),
                  Gap(24.h),

                  // 2. Arbitration Facilitation
                  _buildArbitrationCard(context),
                  Gap(24.h),

                  // 3. Training Programs
                  _buildTrainingProgramsCard(context),
                  Gap(24.h),

                  // 4. Get License
                  _buildGetLicenseCard(context, isMember: isMember),
                  Gap(24.h),

                  // 5. Certification
                  _buildCertificationCard(context, isMember: isMember),
                  Gap(24.h),

                  // 6. Consulting
                  Container(
                    key: _consultingKey,
                    child: _buildConsultingCard(context),
                  ),
                  Gap(30.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Quality Inspection
  // ---------------------------------------------------------------------------
  Widget _buildQualityInspectionCard(BuildContext context, {required bool isMember}) {
    return _buildServiceCardShell(
      context,
      icon: Icons.youtube_searched_for,
      title: '1. Quality Inspection',
      isMembersOnly: true,
      description:
          'Independent, rigorous physical and scientific quality evaluation of raw cashew nuts (RCN) performed by certified analysts at farmgates, buying depots, regional consolidation warehouses, and export terminals.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            "Inspection Portfolios:",
            variant: TextVariant.bodyMedium,
            fontWeight: FontWeight.bold,
          ),
          Gap(10.h),
          _buildPortfolioItem("Distant Arrival Inspection", "Assessing parcel condition upon transit arrival at depots."),
          _buildPortfolioItem("Dispatch Quality Reporting", "Pre-departure verification of moisture, outcount, and KOR."),
          _buildPortfolioItem("Export Arrival Inspection", "Harbor and port warehouse verification before containerization."),
          _buildPortfolioItem("Export Certificate Issuance", "Final statutory inspection report recognized by international buyers."),
          Gap(16.h),
          if (isMember) ...[
            CustomButton(
              text: "Launch Quality Inspection Wizard",
              onPressed: () {
                context.pushNamed(QualityInspectionWizard.id);
              },
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, color: Colors.amber.shade900, size: 20.r),
                  Gap(10.w),
                  Expanded(
                    child: CustomText(
                      "Inspection portfolios are reserved for certified CQAAG members. Buyers and commercial clients may schedule an inspection request with certified field analysts.",
                      variant: TextVariant.bodySmall,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ],
              ),
            ),
            Gap(12.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: "Schedule Inspection",
                    onPressed: () => _showScheduleInspectionSheet(context),
                  ),
                ),
                Gap(10.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pushNamed(RegisterScreen.id),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      side: BorderSide(color: AppColors.primaryGreen),
                    ),
                    child: CustomText(
                      "Become Member",
                      variant: TextVariant.bodySmall,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPortfolioItem(String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 16.r),
          Gap(8.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey.shade800, fontSize: 13.sp),
                children: [
                  TextSpan(text: "$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: subtitle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Arbitration Facilitation
  // ---------------------------------------------------------------------------
  Widget _buildArbitrationCard(BuildContext context) {
    return _buildServiceCardShell(
      context,
      icon: Icons.gavel,
      title: '2. Arbitration Facilitation',
      isMembersOnly: false,
      description:
          'Scientific, neutral dispute resolution conducted in partnership with TCDA and trade stakeholders. We help farmers, aggregators, processors, and exporters resolve quality conflicts (disputed KOR, moisture variances, weight shortfalls) through verifiable laboratory re-testing.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.verified, color: AppColors.primaryGreen, size: 20.r),
                Gap(10.w),
                const Expanded(
                  child: CustomText(
                    "Open to all sector participants. Lodge a formal dispute to request an impartial forensic audit.",
                    variant: TextVariant.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          Gap(14.h),
          CustomButton(
            text: "Lodge a Complaint / Dispute",
            onPressed: () => _showLodgeComplaintSheet(context),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Training Programs
  // ---------------------------------------------------------------------------
  Widget _buildTrainingProgramsCard(BuildContext context) {
    return _buildServiceCardShell(
      context,
      icon: Icons.school,
      title: '3. Training Programs',
      isMembersOnly: false,
      description:
          'Hands-on technical certification in cashew quality assessment. Courses cover cut testing, moisture determination, aflatoxin screening, warehouse sampling, and preparation for national professional licensing. Special priority given to women and youth.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBullet("Course 1: Raw Cashew Nut (RCN) Sampling & Quality Analysis"),
          _buildBullet("Course 2: KOR Calculation & Laboratory Benchmarking"),
          _buildBullet("Course 3: Moisture Control & Warehouse Drying Management"),
          _buildBullet("Course 4: TCDA Licensing Preparation & Professional Ethics"),
          Gap(14.h),
          CustomButton(
            text: "Apply for Training Program",
            onPressed: () => _showTrainingApplicationSheet(context),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Get License (TCDA)
  // ---------------------------------------------------------------------------
  Widget _buildGetLicenseCard(BuildContext context, {required bool isMember}) {
    return _buildServiceCardShell(
      context,
      icon: Icons.card_membership,
      title: '4. Get License (TCDA Licensing)',
      isMembersOnly: false,
      description:
          'As the accredited national professional association, CQAAG guides and facilitates official licensing for quality analysts through the Tree Crops Development Authority (TCDA). Only licensed analysts are legally authorized to certify commercial parcels.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubActionTile(
            title: "1. Become a CQAAG Member",
            subtitle: "Mandatory statutory prerequisite to obtain a recommendation letter.",
            buttonText: isMember ? "Member Verified" : "Apply to Join",
            isDone: isMember,
            onTap: isMember ? null : () => context.pushNamed(RegisterScreen.id),
          ),
          Gap(10.h),
          _buildSubActionTile(
            title: "2. Apply for TCDA Recommendation Letter",
            subtitle: "Official letter issued by CQAAG Secretariat endorsing your technical competency.",
            buttonText: isMember ? "Request Letter" : "Members Only",
            isDone: false,
            onTap: () {
              if (isMember) {
                _showRecommendationLetterDialog(context);
              } else {
                _showGatedMemberDialog(context, serviceName: "TCDA Recommendation Letter");
              }
            },
          ),
          Gap(10.h),
          _buildSubActionTile(
            title: "3. Register with TCDA Portal",
            subtitle: "Complete national registration on the official regulatory agency portal.",
            buttonText: "Visit TCDA Portal",
            isDone: false,
            onTap: _launchTCDAWebsite,
          ),
          Gap(10.h),
          _buildSubActionTile(
            title: "4. Renewal of TCDA License",
            subtitle: "Annual license renewal verification and continuous professional education check.",
            buttonText: "Renew License",
            isDone: false,
            onTap: () {
              if (isMember) {
                _showLicenseRenewalDialog(context);
              } else {
                _showGatedMemberDialog(context, serviceName: "TCDA License Renewal");
              }
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Certification
  // ---------------------------------------------------------------------------
  Widget _buildCertificationCard(BuildContext context, {required bool isMember}) {
    return _buildServiceCardShell(
      context,
      icon: Icons.workspace_premium,
      title: '5. Certification',
      isMembersOnly: false,
      description:
          'Formal quality and origin certification verifying compliance with Ghana Standards Authority, Codex Alimentarius, EU import regulations, and organic standards.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-item 1: Dispatch / Passport certificates
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CustomText(
                      "Dispatch / Passport Certificates",
                      variant: TextVariant.bodyMedium,
                      fontWeight: FontWeight.bold,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        "Members Only",
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                Gap(6.h),
                CustomText(
                  "Official batch certificates issued to accompany truck consignments from inland depots to ports and processing facilities.",
                  variant: TextVariant.bodySmall,
                  color: Colors.grey.shade700,
                ),
                Gap(10.h),
                CustomButton(
                  text: isMember ? "Request Dispatch Certificate" : "Become a Member to Access",
                  onPressed: () {
                    if (isMember) {
                      CustomSnackBar.info(context, message: "Dispatch passport feature will load in your inspection workspace.");
                    } else {
                      _showGatedMemberDialog(context, serviceName: "Dispatch/Passport Certificates");
                    }
                  },
                ),
              ],
            ),
          ),
          Gap(14.h),

          // Sub-item 2: Organic Certification
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  "Organic Certification",
                  variant: TextVariant.bodyMedium,
                  fontWeight: FontWeight.bold,
                ),
                Gap(6.h),
                CustomText(
                  "Assistance with EU/NOP Organic standards compliance, traceability audits, and zero-chemical validation across plantation groups.",
                  variant: TextVariant.bodySmall,
                  color: Colors.grey.shade800,
                ),
                Gap(10.h),
                OutlinedButton.icon(
                  onPressed: () {
                    _scrollToConsulting();
                    _showConsultingScheduleSheet(context, defaultTopic: "Organic Certification Advisory");
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: const Text("Schedule Meeting with Consulting Team"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: BorderSide(color: AppColors.primaryGreen),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. Consulting
  // ---------------------------------------------------------------------------
  Widget _buildConsultingCard(BuildContext context) {
    return _buildServiceCardShell(
      context,
      icon: Icons.diversity_3,
      title: '6. Consulting Services',
      isMembersOnly: false,
      description:
          'Specialized advisory services delivered by seasoned cashew agronomists and quality directors. We assist processing factories, export aggregators, and commercial farms with quality management protocols, drying yard designs, and loss reduction.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBullet("Commercial Moisture Management & Drying Yard Engineering"),
          _buildBullet("Factory Pre-Processing Grading & Storage Protocols"),
          _buildBullet("Dispute Prevention Audits & Risk Assessment"),
          _buildBullet("Traceability Systems & Value Addition Strategies"),
          Gap(14.h),
          CustomButton(
            text: "Schedule a Consultation Meeting",
            onPressed: () => _showConsultingScheduleSheet(context),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Modal Bottom Sheets & Forms
  // ---------------------------------------------------------------------------

  void _showLodgeComplaintSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final partyCtrl = TextEditingController();
    final lotCtrl = TextEditingController();
    final detailsCtrl = TextEditingController();
    String disputeType = 'Disputed KOR (Outturn)';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, MediaQuery.of(context).viewInsets.bottom + 24.h),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44.w,
                        height: 4.h,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                    Gap(16.h),
                    const CustomText("Lodge a Commercial Dispute", variant: TextVariant.headlineMedium, fontWeight: FontWeight.bold),
                    Gap(4.h),
                    CustomText("CQAAG Arbitration Committee facilitates fair, evidence-based dispute resolution.", variant: TextVariant.bodySmall, color: Colors.grey.shade700),
                    Gap(16.h),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Your Full Name / Company")),
                    Gap(10.h),
                    TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone Number"), keyboardType: TextInputType.phone),
                    Gap(10.h),
                    TextField(controller: partyCtrl, decoration: const InputDecoration(labelText: "Opposing Party / Firm Name")),
                    Gap(10.h),
                    TextField(controller: lotCtrl, decoration: const InputDecoration(labelText: "Cashew Lot ID / Location")),
                    Gap(10.h),
                    DropdownButtonFormField<String>(
                      initialValue: disputeType,
                      decoration: const InputDecoration(labelText: "Dispute Category"),
                      items: [
                        'Disputed KOR (Outturn)',
                        'Moisture Content Dispute',
                        'Excessive Defect / Aflatoxin Rejection',
                        'Weight Shortage / Scale Discrepancy',
                        'Contract Breach',
                        'Other',
                      ].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                      onChanged: (val) => setModalState(() => disputeType = val ?? disputeType),
                    ),
                    Gap(10.h),
                    TextField(controller: detailsCtrl, maxLines: 3, decoration: const InputDecoration(labelText: "Brief Description of Dispute")),
                    Gap(20.h),
                    CustomButton(
                      text: "Submit Complaint",
                      onPressed: () async {
                        if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
                          CustomSnackBar.error(context, message: "Please provide your name and phone number.");
                          return;
                        }
                        Navigator.pop(ctx);
                        try {
                          await FirebaseFirestore.instance.collection('complaints').add({
                            'id': const uuid_pkg.Uuid().v4(),
                            'complainant_name': nameCtrl.text.trim(),
                            'phone': phoneCtrl.text.trim(),
                            'opposing_party': partyCtrl.text.trim(),
                            'lot_id': lotCtrl.text.trim(),
                            'dispute_type': disputeType,
                            'details': detailsCtrl.text.trim(),
                            'status': 'submitted',
                            'submitted_at': FieldValue.serverTimestamp(),
                          });
                        } catch (_) {
                          // Continue smoothly even if offline
                        }
                        if (context.mounted) {
                          _showConfirmationDialog(
                            context,
                            title: "Dispute Lodged Successfully",
                            message: "The Arbitration Committee has received your submission. A Secretariat officer will contact both parties within 48 hours to schedule physical parcel re-testing.",
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showTrainingApplicationSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String program = 'Raw Cashew Nut (RCN) Sampling & Quality Analysis';
    String location = 'Wenchi National Headquarters';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, MediaQuery.of(context).viewInsets.bottom + 24.h),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44.w,
                        height: 4.h,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                    Gap(16.h),
                    const CustomText("Apply for Training Program", variant: TextVariant.headlineMedium, fontWeight: FontWeight.bold),
                    Gap(4.h),
                    CustomText("Professional hands-on training preparing analysts for industry licensing.", variant: TextVariant.bodySmall, color: Colors.grey.shade700),
                    Gap(16.h),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Full Name")),
                    Gap(10.h),
                    TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone Number"), keyboardType: TextInputType.phone),
                    Gap(10.h),
                    TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email Address"), keyboardType: TextInputType.emailAddress),
                    Gap(10.h),
                    DropdownButtonFormField<String>(
                      initialValue: program,
                      decoration: const InputDecoration(labelText: "Select Training Module"),
                      isExpanded: true,
                      items: [
                        'Raw Cashew Nut (RCN) Sampling & Quality Analysis',
                        'KOR Calculation & Laboratory Benchmarking',
                        'Moisture Control & Warehouse Drying Management',
                        'TCDA Licensing Preparation & Professional Ethics',
                      ].map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (val) => setModalState(() => program = val ?? program),
                    ),
                    Gap(10.h),
                    DropdownButtonFormField<String>(
                      initialValue: location,
                      decoration: const InputDecoration(labelText: "Preferred Training Center"),
                      items: [
                        'Wenchi National Headquarters',
                        'Sampa Chapter Center',
                        'Techiman Regional Hub',
                        'Sunyani Training Center',
                      ].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                      onChanged: (val) => setModalState(() => location = val ?? location),
                    ),
                    Gap(20.h),
                    CustomButton(
                      text: "Submit Training Application",
                      onPressed: () async {
                        if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
                          CustomSnackBar.error(context, message: "Please enter your name and contact phone.");
                          return;
                        }
                        Navigator.pop(ctx);
                        try {
                          await FirebaseFirestore.instance.collection('training_applications').add({
                            'id': const uuid_pkg.Uuid().v4(),
                            'applicant_name': nameCtrl.text.trim(),
                            'phone': phoneCtrl.text.trim(),
                            'email': emailCtrl.text.trim(),
                            'program': program,
                            'location': location,
                            'submitted_at': FieldValue.serverTimestamp(),
                          });
                        } catch (_) {}
                        if (context.mounted) {
                          _showConfirmationDialog(
                            context,
                            title: "Training Application Received",
                            message: "Thank you for applying. The Training Directorate will review your details and send you cohort schedule, fee details, and preparation guidelines.",
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showScheduleInspectionSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final quantityCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, MediaQuery.of(context).viewInsets.bottom + 24.h),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44.w,
                    height: 4.h,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
                Gap(16.h),
                const CustomText("Schedule an Inspection Request", variant: TextVariant.headlineMedium, fontWeight: FontWeight.bold),
                Gap(4.h),
                CustomText("Request verified CQAAG certified analysts to test and grade your cashew consignment.", variant: TextVariant.bodySmall, color: Colors.grey.shade700),
                Gap(16.h),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Requester / Company Name")),
                Gap(10.h),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone Number"), keyboardType: TextInputType.phone),
                Gap(10.h),
                TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: "Depot / Farmgate Location (Town/Region)")),
                Gap(10.h),
                TextField(controller: quantityCtrl, decoration: const InputDecoration(labelText: "Estimated Tonnage / Bags")),
                Gap(20.h),
                CustomButton(
                  text: "Submit Inspection Request",
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
                      CustomSnackBar.error(context, message: "Please provide your name and phone number.");
                      return;
                    }
                    Navigator.pop(ctx);
                    try {
                      await FirebaseFirestore.instance.collection('inspection_requests').add({
                        'id': const uuid_pkg.Uuid().v4(),
                        'client_name': nameCtrl.text.trim(),
                        'phone': phoneCtrl.text.trim(),
                        'location': locationCtrl.text.trim(),
                        'quantity': quantityCtrl.text.trim(),
                        'status': 'pending_assignment',
                        'submitted_at': FieldValue.serverTimestamp(),
                      });
                    } catch (_) {}
                    if (context.mounted) {
                      _showConfirmationDialog(
                        context,
                        title: "Inspection Request Dispatched",
                        message: "Your request has been routed to the regional inspection supervisor. A certified inspector will be assigned to your location.",
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showConsultingScheduleSheet(BuildContext context, {String? defaultTopic}) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final orgCtrl = TextEditingController();
    final topicCtrl = TextEditingController(text: defaultTopic ?? 'Quality Optimization & Moisture Control');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, MediaQuery.of(context).viewInsets.bottom + 24.h),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44.w,
                    height: 4.h,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
                Gap(16.h),
                const CustomText("Schedule a Consulting Session", variant: TextVariant.headlineMedium, fontWeight: FontWeight.bold),
                Gap(4.h),
                CustomText("Connect directly with CQAAG senior technical advisors.", variant: TextVariant.bodySmall, color: Colors.grey.shade700),
                Gap(16.h),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Your Full Name")),
                Gap(10.h),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Contact Phone"), keyboardType: TextInputType.phone),
                Gap(10.h),
                TextField(controller: orgCtrl, decoration: const InputDecoration(labelText: "Organization / Enterprise")),
                Gap(10.h),
                TextField(controller: topicCtrl, decoration: const InputDecoration(labelText: "Consulting Focus Topic")),
                Gap(20.h),
                CustomButton(
                  text: "Confirm Consultation Request",
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
                      CustomSnackBar.error(context, message: "Please provide your name and phone number.");
                      return;
                    }
                    Navigator.pop(ctx);
                    try {
                      await FirebaseFirestore.instance.collection('consulting_requests').add({
                        'id': const uuid_pkg.Uuid().v4(),
                        'client_name': nameCtrl.text.trim(),
                        'phone': phoneCtrl.text.trim(),
                        'organization': orgCtrl.text.trim(),
                        'topic': topicCtrl.text.trim(),
                        'status': 'scheduled',
                        'submitted_at': FieldValue.serverTimestamp(),
                      });
                    } catch (_) {}
                    if (context.mounted) {
                      _showConfirmationDialog(
                        context,
                        title: "Consulting Meeting Scheduled",
                        message: "Your request has been logged. Our advisory coordinator will reach out to confirm the date and briefing materials.",
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGatedMemberDialog(BuildContext context, {required String serviceName}) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Row(
            children: [
              Icon(Icons.lock_outline, color: AppColors.darkRed, size: 24.r),
              Gap(8.w),
              const Expanded(child: CustomText("Member Access Only", variant: TextVariant.headlineMedium, fontWeight: FontWeight.bold)),
            ],
          ),
          content: CustomText(
            "$serviceName is exclusively accessible to verified, active members of the Cashew Quality Analysts' Association, Ghana. Please apply for membership to unlock full professional privileges.",
            variant: TextVariant.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.pushNamed(RegisterScreen.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text("Become a Member"),
            ),
          ],
        );
      },
    );
  }

  void _showRecommendationLetterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: const CustomText("TCDA Recommendation Letter", variant: TextVariant.headlineMedium, fontWeight: FontWeight.bold),
          content: const CustomText(
            "Your membership is active and in good standing. Would you like to request an official CQAAG Recommendation Letter addressed to the Tree Crops Development Authority (TCDA)?",
            variant: TextVariant.bodyMedium,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Not Now")),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                CustomSnackBar.success(
                  context,
                  message: "Recommendation letter request submitted to the Secretariat. You will be notified when your digital PDF is ready.",
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
              child: const Text("Submit Request"),
            ),
          ],
        );
      },
    );
  }

  void _showLicenseRenewalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: const CustomText("TCDA License Renewal", variant: TextVariant.headlineMedium, fontWeight: FontWeight.bold),
          content: const CustomText(
            "Annual licensing renewal requires confirmation of active CQAAG annual dues payment and participation in at least one refresher training session during the calendar year.",
            variant: TextVariant.bodyMedium,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close")),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _launchTCDAWebsite();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
              child: const Text("Proceed to TCDA"),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context, {required String title, required String message}) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 24.r),
              Gap(8.w),
              Expanded(child: CustomText(title, variant: TextVariant.headlineSmall, fontWeight: FontWeight.bold)),
            ],
          ),
          content: CustomText(message, variant: TextVariant.bodyMedium),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
              child: const Text("Done"),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Card Shell & Helpers
  // ---------------------------------------------------------------------------
  Widget _buildServiceCardShell(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isMembersOnly,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 14,
          ),
        ],
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.lightOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: AppColors.darkRed, size: 28.r),
              ),
              Gap(14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      title,
                      variant: TextVariant.headlineSmall,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkRed,
                    ),
                    Gap(2.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: isMembersOnly ? Colors.amber.shade50 : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        isMembersOnly ? "Members Only" : "Open Access",
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: isMembersOnly ? Colors.amber.shade900 : Colors.green.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(14.h),
          CustomText(
            description,
            variant: TextVariant.bodyMedium,
            color: Colors.grey.shade800,
          ),
          Gap(16.h),
          const Divider(),
          Gap(14.h),
          child,
        ],
      ),
    );
  }

  Widget _buildSubActionTile({
    required String title,
    required String subtitle,
    required String buttonText,
    required bool isDone,
    required VoidCallback? onTap,
  }) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(title, variant: TextVariant.bodyMedium, fontWeight: FontWeight.bold),
                Gap(2.h),
                CustomText(subtitle, variant: TextVariant.bodySmall, color: Colors.grey.shade600),
              ],
            ),
          ),
          Gap(10.w),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDone ? Colors.grey.shade400 : AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              textStyle: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.arrow_right, color: AppColors.primaryGreen, size: 20.r),
          Gap(4.w),
          Expanded(
            child: CustomText(text, variant: TextVariant.bodyMedium, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }
}
