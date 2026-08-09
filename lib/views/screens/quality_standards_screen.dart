import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';
import 'package:go_router/go_router.dart';

class QualityStandardsScreen extends StatelessWidget {
  static const String id = 'quality_standards_screen';

  const QualityStandardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkRed,
        title: const CustomText(
          'Quality Standards',
          variant: TextVariant.bodyLarge,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                children: <Widget>[
                  // Title Header
                  Center(
                    child: CustomText(
                      'Our Inspection Process',
                      variant: TextVariant.displaySmall,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  Gap(12.h),
                  CustomText(
                    'Seven rigorous steps to ensure quality excellence',
                    variant: TextVariant.bodyMedium,
                    color: AppColors.darkBrown.withValues(alpha: 0.7),
                    textAlign: TextAlign.center,
                  ),
                  Gap(32.h),

                  // Inspection Process Steps (Grid)
                  _buildInspectionSteps(),
                ],
              ),
            ),

            // Interactive KOR Calculator Widget Block
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: const _InteractiveKorCalculatorCard(),
            ),

            // Key Inspection Metrics Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
              child: Column(
                children: [
                  CustomText(
                    'Key Inspection Metrics',
                    variant: TextVariant.displaySmall,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrown,
                    textAlign: TextAlign.center,
                  ),
                  Gap(12.h),
                  CustomText(
                    'Our rigorous standards for quality assurance',
                    variant: TextVariant.bodyMedium,
                    color: AppColors.darkBrown.withValues(alpha: 0.7),
                    textAlign: TextAlign.center,
                  ),
                  Gap(32.h),
                  _buildMetricsGrid(),
                ],
              ),
            ),

            // Sample Results Section
            Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                children: <Widget>[
                  CustomText(
                    'Sample Inspection Results',
                    variant: TextVariant.displaySmall,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrown,
                    textAlign: TextAlign.center,
                  ),
                  Gap(12.h),
                  CustomText(
                    'Real-world quality analysis data from recent batch inspections',
                    variant: TextVariant.bodyMedium,
                    color: AppColors.darkBrown.withValues(alpha: 0.7),
                    textAlign: TextAlign.center,
                  ),
                  Gap(32.h),
                  _buildResultsTable(),
                  Gap(16.h),
                  CustomText(
                    '* All measurements based on standard 1000g sample size. KOR calculated using CQAAG formula: Useful Kernel (g) = Good (g) + (0.5 × Spotted g); KOR (lbs) = Useful Kernel × 0.188.',
                    variant: TextVariant.bodySmall,
                    color: Colors.grey.shade600,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Grade Classifications Criteria
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
              child: Column(
                children: <Widget>[
                  CustomText(
                    'Grade Classifications',
                    variant: TextVariant.displaySmall,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrown,
                    textAlign: TextAlign.center,
                  ),
                  Gap(12.h),
                  CustomText(
                    'International standard cashew kernel grades',
                    variant: TextVariant.bodyMedium,
                    color: AppColors.darkBrown.withValues(alpha: 0.7),
                    textAlign: TextAlign.center,
                  ),
                  Gap(32.h),
                  _buildGradesGrid(),
                ],
              ),
            ),

            // Good Kernels and KOR Cards
            Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                children: [
                  _buildSummaryCard(
                    title: 'Good Kernels',
                    subtitle: '≥ 230 gm per sample',
                    description: 'Weight of premium quality kernels free from defects, ready for export-grade classification',
                    icon: Icons.check,
                    iconColor: AppColors.darkBrown, // Bronze-ish from design
                    criteria: [
                      _CriteriaRow(label: 'Pass', value: '≥ 230 gm', status: _Status.pass),
                      _CriteriaRow(label: 'Conditional', value: '220-229 gm', status: _Status.conditional),
                      _CriteriaRow(label: 'Fail', value: '< 220 gm', status: _Status.fail),
                    ],
                  ),
                  Gap(24.h),
                  _buildSummaryCard(
                    title: 'KOR (Kernel Outturn Ratio)',
                    subtitle: '≥ 40%',
                    description: 'Calculated as K/(Sh+0.75*Tk), the most critical indicator of processing efficiency and economic value',
                    icon: Icons.donut_large, // Target icon analogy
                    iconColor: AppColors.darkBrown,
                    criteria: [
                      _CriteriaRow(label: 'Pass', value: '≥ 43%', status: _Status.pass),
                      _CriteriaRow(label: 'Conditional', value: '40-42.9%', status: _Status.conditional),
                      _CriteriaRow(label: 'Fail', value: '< 40%', status: _Status.fail),
                    ],
                  ),
                ],
              ),
            ),

            // CTA Footer
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 24.w),
              color: AppColors.darkBrown, // Dark brown footer
              child: Column(
                children: <Widget>[
                  const CustomText(
                    'Ready to Get Certified?',
                    variant: TextVariant.headlineMedium,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  Gap(16.h),
                  CustomText(
                    'Contact us to schedule an inspection and ensure your cashews meet international standards',
                    variant: TextVariant.bodyMedium,
                    color: Colors.white.withValues(alpha: 0.9),
                    textAlign: TextAlign.center,
                  ),
                  Gap(32.h),
                  CustomButton(
                    text: 'Schedule Inspection',
                    onPressed: () {
                      // Link to Contact Us
                      context.pushNamed(ContactUsScreen.id);
                    },
                    backgroundColor: AppColors.bronze, // Bronze button color
                    textColor: Colors.white,
                    width: 200.w,
                    height: 48.h,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectionSteps() {
    final steps = [
      {'num': '01', 'title': 'Sample Collection', 'desc': 'Random sampling from production batches'},
      {'num': '02', 'title': 'Visual Inspection', 'desc': 'Assessment of color, size, and defects'},
      {'num': '03', 'title': 'Moisture Testing', 'desc': 'Precise moisture content measurement'},
      {'num': '04', 'title': 'Weight Analysis', 'desc': 'KOR calculation and verification'},
      {'num': '05', 'title': 'Defect Count', 'desc': 'Detailed categorization of imperfections'},
      {'num': '06', 'title': 'Grade Assignment', 'desc': 'Classification based on standards'},
      {'num': '07', 'title': 'Certification', 'desc': 'Digital certificate issuance'},
    ];

    return Wrap(
      spacing: 16.w,
      runSpacing: 16.h,
      children: steps.map((step) {
        return Container(
          width: 1.sw > 600 ? (1.sw - 48.w - 32.w) / 4 : (1.sw - 48.w - 16.w) / 2, // Responsive grid
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.lightPeach, // Light Peach
                  borderRadius: BorderRadius.circular(50.r), // Standard circle
                ),
                width: 50.r,
                height: 50.r,
                alignment: Alignment.center,
                child: CustomText(
                  step['num']!,
                  variant: TextVariant.headlineSmall,
                  fontWeight: FontWeight.bold,
                  color: AppColors.bronze,
                ),
              ),
              Gap(16.h),
              CustomText(
                step['title']!,
                variant: TextVariant.bodyMedium,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBrown,
              ),
              Gap(8.h),
              CustomText(
                step['desc']!,
                variant: TextVariant.bodySmall,
                color: Colors.brown.shade800.withValues(alpha: 0.7),
                // height: 1.3, // Removed unsupported height parameter
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricsGrid() {
    // Data for metrics
    final metrics = [
      _MetricData(
        title: 'Moisture Content',
        subtitle: '≤ 10%',
        desc: 'Critical parameter affecting storage life, mold prevention, and overall kernel quality during processing',
        icon: Icons.water_drop,
        rows: [
          _CriteriaRow(label: 'Pass', value: '≤ 10%', status: _Status.pass),
          _CriteriaRow(label: 'Conditional', value: '10-14%', status: _Status.conditional),
          _CriteriaRow(label: 'Fail', value: '> 14%', status: _Status.fail),
        ],
      ),
      _MetricData(
        title: 'Count per kg (Out Count)',
        subtitle: '160-180 kernels/kg',
        desc: 'Number of kernels per kilogram indicating size uniformity and grade classification standards',
        icon: Icons.scale,
        rows: [
          _CriteriaRow(label: 'Pass', value: '160-180', status: _Status.pass),
          _CriteriaRow(label: 'Conditional', value: '145-159 or 181-195', status: _Status.conditional),
          _CriteriaRow(label: 'Fail', value: '195', status: _Status.fail), // Simplified from image
        ],
      ),
      _MetricData(
        title: 'Fully Damaged Nuts',
        subtitle: '< 85 gm per sample',
        desc: 'Weight of kernels with severe damage including mold, insect damage, and mechanical breakage',
        icon: Icons.pest_control,
        rows: [
          _CriteriaRow(label: 'Pass', value: '< 85 gm', status: _Status.pass),
          _CriteriaRow(label: 'Conditional', value: '85-95 gm', status: _Status.conditional),
          _CriteriaRow(label: 'Fail', value: '> 95 gm', status: _Status.fail),
        ],
      ),
      _MetricData(
        title: 'Void & Oil Nuts',
        subtitle: '< 20 gm combined',
        desc: 'Void nuts (empty shells) and oil-damaged kernels affecting processing efficiency and quality',
        icon: Icons.do_not_disturb_alt,
        rows: [
          _CriteriaRow(label: 'Pass', value: '< 20 gm', status: _Status.pass),
          _CriteriaRow(label: 'Conditional', value: '20-35 gm', status: _Status.conditional),
          _CriteriaRow(label: 'Fail', value: '> 35 gm', status: _Status.fail),
        ],
      ),
      _MetricData(
        title: 'Total Damage (M+O+G)',
        subtitle: '< 80 gm per sample',
        desc: 'Combined weight of moldy, oily, and germinated nuts indicating overall defect levels',
        icon: Icons.report_problem,
        rows: [
          _CriteriaRow(label: 'Pass', value: '< 80 gm', status: _Status.pass),
          _CriteriaRow(label: 'Conditional', value: '80-96 gm', status: _Status.conditional),
          _CriteriaRow(label: 'Fail', value: '> 96 gm', status: _Status.fail),
        ],
      ),
      _MetricData(
        title: 'Spotted/Immature Nuts',
        subtitle: '< 18 gm combined',
        desc: 'Partially sound nuts with spots and immature kernels that may affect final grade classification',
        icon: Icons.thumb_down,
        rows: [
          _CriteriaRow(label: 'Pass', value: '< 18 gm', status: _Status.pass),
          _CriteriaRow(label: 'Conditional', value: '18-25 gm', status: _Status.conditional),
          _CriteriaRow(label: 'Fail', value: '> 25 gm', status: _Status.fail),
        ],
      ),
    ];

    return Wrap(
      spacing: 24.w,
      runSpacing: 24.h,
      children: metrics.map((m) => _buildMetricCard(m)).toList(),
    );
  }

  Widget _buildMetricCard(_MetricData data) {
    return Container(
      width: 1.sw > 900 ? (1.sw - 48.w - 24.w) / 2 : double.infinity, // 2 columns on wide screens
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.darkBrown.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(data.icon, color: AppColors.darkBrown, size: 28.r),
              ),
              Gap(16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(data.title, variant: TextVariant.bodyLarge, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                    CustomText(data.subtitle, variant: TextVariant.bodySmall, color: AppColors.bronze, fontWeight: FontWeight.bold),
                  ],
                ),
              ),
            ],
          ),
          Gap(16.h),
          CustomText(data.desc, variant: TextVariant.bodySmall, color: Colors.grey.shade700 /*, height: 1.4 */),
          Gap(20.h),

          // Criteria Rows
          ...data.rows.map((row) => _buildCriteriaRow(row)),
        ],
      ),
    );
  }

  Widget _buildCriteriaRow(_CriteriaRow row) {
    Color bgColor;
    Color iconColor;
    IconData icon;

    switch (row.status) {
      case _Status.pass:
        bgColor = AppColors.passGreen.withValues(alpha: 0.5); // Light Green
        iconColor = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case _Status.conditional:
        bgColor = AppColors.conditionalYellow.withValues(alpha: 0.5); // Light Amber/Yellow
        // Use a generic light yellow if Color code is elusive. Let's use generic Amber.light
        bgColor = Colors.amber.shade50;
        iconColor = Colors.amber.shade800;
        icon = Icons.warning_amber_rounded;
        break;
      case _Status.fail:
        bgColor = AppColors.failRed.withValues(alpha: 0.5); // Light Red
        iconColor = Colors.red;
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20.r, color: iconColor),
          Gap(12.w),
          CustomText(row.label, variant: TextVariant.bodySmall, fontWeight: FontWeight.bold, color: iconColor),
          const Spacer(),
          CustomText(row.value, variant: TextVariant.bodySmall, fontWeight: FontWeight.bold, color: Colors.black87),
        ],
      ),
    );
  }

  Widget _buildResultsTable() {
    // Hardcoded dummy data matching image
    final rows = [
      ['4000', '47', '17%', '182', '85', '10', '22', '96', '230', '991', '40.128%', 'Pass'],
      ['4000', '47', '18%', '162', '85.5', '8', '9', '92', '230', '809', '43.742%', 'Pass'],
      ['4000', '47', '14%', '163', '85.5', '8', '35', '96.5', '223', '395', '40.92%', 'Pass'],
      ['4000', '70', '9%', '174', '92', '10', '12', '72', '242', '907', '43.736%', 'Pass'],
      ['4000', '70', '10%', '174', '94', '11', '9', '80', '237', '800', '41.586%', 'Pass'],
      ['4000', '70', '10%', '173', '47.5', '12.5', '9', '69', '238.5', '493.5', '43.46%', 'Pass'],
    ];

    TextStyle headerStyle = TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold);
    TextStyle cellStyle = TextStyle(color: Colors.black87, fontSize: 10.sp, fontWeight: FontWeight.bold);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.tableHeaderBrown), // Dark Brown
            columnSpacing: 16.w,
            dataRowMinHeight: 32.h,
            dataRowMaxHeight: 32.h,
            columns: [
              DataColumn(label: Text('Qty (kg)', style: headerStyle)),
              DataColumn(label: Text('Bags', style: headerStyle)),
              DataColumn(label: Text('Moisture', style: headerStyle)),
              DataColumn(label: Text('Count/kg', style: headerStyle)),
              DataColumn(label: Text('Damaged (g)', style: headerStyle)),
              DataColumn(label: Text('Void (g)', style: headerStyle)),
              DataColumn(label: Text('Oil (g)', style: headerStyle)),
              DataColumn(label: Text('Total Dmg', style: headerStyle)),
              DataColumn(label: Text('Good (g)', style: headerStyle)),
              DataColumn(label: Text('Shells (g)', style: headerStyle)),
              DataColumn(label: Text('KOR', style: headerStyle)),
              DataColumn(label: Text('Status', style: headerStyle)),
            ],
            rows: rows.map((row) {
              return DataRow(
                color: WidgetStateProperty.resolveWith((states) => AppColors.lightOrange.withValues(alpha: 0.05)), // Very light bg
                cells: [
                  ...row.sublist(0, 11).map((cell) => DataCell(Text(cell, style: cellStyle))),
                  DataCell(
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4.r)),
                      child: Text(
                        row[11],
                        style: cellStyle.copyWith(color: Colors.green.shade800, fontSize: 9.sp),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildGradesGrid() {
    final grades = [
      {'code': 'W-180', 'title': 'Whole White - 160-180\nkernels per kg', 'kor': 'KOR ≥ 43%', 'color': Colors.green.shade100},
      {'code': 'W-180', 'title': 'Whole White - 185-210\nkernels per kg', 'kor': 'KOR ≥ 42%', 'color': AppColors.lightOrangeCard}, // Light Orange
      {'code': 'W-180', 'title': 'Whole White - 220-240\nkernels per kg', 'kor': 'KOR ≥ 41%', 'color': AppColors.lightOrangeCard},
      {'code': 'W-180', 'title': 'Whole White - 300-320\nkernels per kg', 'kor': 'KOR ≥ 40%', 'color': AppColors.lightOrangeCard},
      {'code': 'W-180', 'title': 'Scorched - 160-180 kernels\nper kg', 'kor': 'KOR 38-40%', 'color': AppColors.lightOrangeCard},
      {'code': 'W-180', 'title': 'Scorched - 220-240 kernels\nper kg', 'kor': 'KOR 38-40%', 'color': AppColors.lightOrangeCard},
      {'code': 'W-180', 'title': 'Large White Pieces -\nPremium broken', 'kor': 'KOR ≥ 35%', 'color': AppColors.lightOrangeCard},
      {'code': 'W-180', 'title': 'Small White Pieces -\nStandard broken', 'kor': 'KOR ≥ 32%', 'color': AppColors.lightOrangeCard},
    ];

    return Wrap(
      spacing: 16.w,
      runSpacing: 16.h,
      children: grades.map((grade) {
        return Container(
          width: 1.sw > 600 ? (1.sw - 48.w - 48.w) / 4 : (1.sw - 48.w - 16.w) / 2,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.beigeBackground, // Beige/Light Brown bg
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: (grade['title'] as String).contains('Whole White') ? Colors.green.shade100 : Colors.yellow.shade100, // Dynamic color based on type
                  borderRadius: BorderRadius.circular(4.r),
                ),
                // The 'code' in design seems generic 'W-180' or similar headers, using dynamic
                child: Text(
                  (grade['title'] as String).contains('Pieces') ? 'W-180' : 'W-180', // Placeholder logic for badge
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                ),
              ),
              Gap(12.h),
              CustomText(
                grade['title'] as String,
                variant: TextVariant.bodySmall,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBrown,
              ),
              Gap(12.h),
              CustomText(
                grade['kor'] as String,
                variant: TextVariant.bodySmall,
                textAlign: TextAlign.center,
                color: AppColors.darkBrown.withValues(alpha: 0.7),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color iconColor,
    required List<_CriteriaRow> criteria,
  }) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(color: AppColors.lightOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 32.r),
              ),
              Gap(16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(title, variant: TextVariant.headlineSmall, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                    CustomText(subtitle, variant: TextVariant.bodyMedium, fontWeight: FontWeight.bold, color: AppColors.bronze),
                  ],
                ),
              ),
            ],
          ),
          Gap(16.h),
          CustomText(description, variant: TextVariant.bodyMedium, color: Colors.grey.shade700),
          Gap(24.h),
          ...criteria.map((c) => _buildCriteriaRow(c)),
        ],
      ),
    );
  }
}

class _MetricData {
  final String title;
  final String subtitle;
  final String desc;
  final IconData icon;
  final List<_CriteriaRow> rows;

  _MetricData({required this.title, required this.subtitle, required this.desc, required this.icon, required this.rows});
}

class _CriteriaRow {
  final String label;
  final String value;
  final _Status status;

  _CriteriaRow({required this.label, required this.value, required this.status});
}

enum _Status { pass, conditional, fail }

class _InteractiveKorCalculatorCard extends StatefulWidget {
  const _InteractiveKorCalculatorCard();

  @override
  State<_InteractiveKorCalculatorCard> createState() => _InteractiveKorCalculatorCardState();
}

class _InteractiveKorCalculatorCardState extends State<_InteractiveKorCalculatorCard> {
  final _goodController = TextEditingController(text: '225');
  final _spottedController = TextEditingController(text: '35');
  final _immatureController = TextEditingController(text: '15');
  final _sampleWeightController = TextEditingController(text: '1000');
  final _moistureController = TextEditingController(text: '8.0');
  final _outCountController = TextEditingController(text: '172');

  double _usefulKernel = 242.5;
  double _korLbs = 45.59;
  String _gradeLabel = "SECOND CLASS";
  Color _gradeBg = const Color(0xFFBE6735);
  String _tradeDesc = "Standard Export Grade. Fully approved for standard international export shipments.";
  String _nutSizeLabel = "Medium Nuts (172 nuts/kg)";
  String _moistureLabel = "Optimal (8.0%)";
  double _meterPercent = 0.75;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _goodController.dispose();
    _spottedController.dispose();
    _immatureController.dispose();
    _sampleWeightController.dispose();
    _moistureController.dispose();
    _outCountController.dispose();
    super.dispose();
  }

  void _calculate() {
    final goodG = double.tryParse(_goodController.text) ?? 0;
    final spottedG = double.tryParse(_spottedController.text) ?? 0;
    final sampleW = double.tryParse(_sampleWeightController.text) ?? 1000;
    final moisture = double.tryParse(_moistureController.text) ?? 0;
    final outCount = int.tryParse(_outCountController.text) ?? 0;

    final useful = goodG + (0.5 * spottedG);
    final actualSample = sampleW > 0 ? sampleW : 1000;
    final kor = (useful / actualSample) * 0.188 * 80;

    String label = "REJECT";
    Color bg = const Color(0xFFDC2626);
    String desc = "Fails export standards. Restricted to local extraction or heavy discount processing.";

    if (kor >= 48) {
      label = "FIRST CLASS";
      bg = AppColors.darkBrown;
      desc = "Premium Export Quality. Eligible for top-tier international contract pricing.";
    } else if (kor >= 45) {
      label = "SECOND CLASS";
      bg = const Color(0xFFBE6735);
      desc = "Standard Export Grade. Fully approved for standard international export shipments.";
    } else if (kor >= 40) {
      label = "UNDERGRADE";
      bg = Colors.amber.shade800;
      desc = "Conditional Quality. Subject to local processing discount or price adjustment.";
    }

    String nutSize = "Medium Nuts";
    if (outCount > 0 && outCount < 180) {
      nutSize = "Large Nuts ($outCount nuts/kg)";
    } else if (outCount >= 180 && outCount <= 210) {
      nutSize = "Medium Nuts ($outCount nuts/kg)";
    } else if (outCount > 210) {
      nutSize = "Small Nuts ($outCount nuts/kg)";
    }

    String moistureText = "Optimal (${moisture.toStringAsFixed(1)}%)";
    if (moisture > 10.0) {
      moistureText = "⚠️ High Risk (${moisture.toStringAsFixed(1)}%) - Redrying Required";
    } else if (moisture > 8.0) {
      moistureText = "⚠️ Caution (${moisture.toStringAsFixed(1)}%) - Drying Advised";
    }

    setState(() {
      _usefulKernel = useful;
      _korLbs = kor;
      _gradeLabel = label;
      _gradeBg = bg;
      _tradeDesc = desc;
      _nutSizeLabel = nutSize;
      _moistureLabel = moistureText;
      _meterPercent = (kor / 60.0).clamp(0.05, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.darkBrown.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.lightPeach,
                borderRadius: BorderRadius.circular(99.r),
                border: Border.all(color: AppColors.bronze.withValues(alpha: 0.2)),
              ),
              child: CustomText(
                'INTERACTIVE KOR CALCULATOR',
                variant: TextVariant.bodySmall,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBrown,
              ),
            ),
          ),
          Gap(12.h),
          CustomText(
            'Cut-Test Metric Calculator',
            variant: TextVariant.headlineMedium,
            fontWeight: FontWeight.bold,
            color: AppColors.darkBrown,
            textAlign: TextAlign.center,
          ),
          Gap(4.h),
          CustomText(
            'Adjust field cut-test weights to compute real-time KOR and trade classification.',
            variant: TextVariant.bodySmall,
            color: Colors.grey.shade700,
            textAlign: TextAlign.center,
          ),
          Gap(24.h),

          // Inputs Grid
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: 'Good Kernels (g) *',
                  controller: _goodController,
                ),
              ),
              Gap(12.w),
              Expanded(
                child: _buildInputField(
                  label: 'Spotted Kernels (g) *',
                  controller: _spottedController,
                ),
              ),
            ],
          ),
          Gap(12.h),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: 'Immature (g)',
                  controller: _immatureController,
                ),
              ),
              Gap(12.w),
              Expanded(
                child: _buildInputField(
                  label: 'Sample Weight (g)',
                  controller: _sampleWeightController,
                ),
              ),
            ],
          ),
          Gap(12.h),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: 'Moisture (%) *',
                  controller: _moistureController,
                ),
              ),
              Gap(12.w),
              Expanded(
                child: _buildInputField(
                  label: 'Out Count (nuts/kg) *',
                  controller: _outCountController,
                ),
              ),
            ],
          ),
          Gap(20.h),

          // Results Output Card
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.beigeBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.darkBrown.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          'CALCULATED OUTTURN RATIO',
                          variant: TextVariant.bodySmall,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                        Gap(2.h),
                        CustomText(
                          '${_korLbs.toStringAsFixed(2)} lbs',
                          variant: TextVariant.displaySmall,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkBrown,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: _gradeBg,
                            borderRadius: BorderRadius.circular(99.r),
                          ),
                          child: CustomText(
                            _gradeLabel,
                            variant: TextVariant.bodySmall,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Gap(4.h),
                        CustomText(
                          'Useful: ${_usefulKernel.toStringAsFixed(1)}g',
                          variant: TextVariant.bodySmall,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ],
                ),
                Gap(16.h),

                // Visual Gauge Progress Meter
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText('0 lbs', variant: TextVariant.bodySmall, color: Colors.grey.shade600),
                        CustomText('40 lbs', variant: TextVariant.bodySmall, color: Colors.grey.shade600),
                        CustomText('45 lbs', variant: TextVariant.bodySmall, color: Colors.grey.shade600),
                        CustomText('48+ lbs', variant: TextVariant.bodySmall, color: Colors.grey.shade600),
                      ],
                    ),
                    Gap(4.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99.r),
                      child: LinearProgressIndicator(
                        value: _meterPercent,
                        minHeight: 10.h,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(_gradeBg),
                      ),
                    ),
                  ],
                ),
                Gap(16.h),

                // Detail Matrix Chips
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText('Nut Size', variant: TextVariant.bodySmall, color: Colors.grey.shade600),
                            Gap(2.h),
                            CustomText(
                              _nutSizeLabel,
                              variant: TextVariant.bodySmall,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBrown,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Gap(8.w),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText('Moisture', variant: TextVariant.bodySmall, color: Colors.grey.shade600),
                            Gap(2.h),
                            CustomText(
                              _moistureLabel,
                              variant: TextVariant.bodySmall,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBrown,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Gap(12.h),

                // Recommendation Note
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border(left: BorderSide(color: _gradeBg, width: 4.w)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        'COMMERCIAL TRADE RECOMMENDATION',
                        variant: TextVariant.bodySmall,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                      ),
                      Gap(2.h),
                      CustomText(
                        _tradeDesc,
                        variant: TextVariant.bodySmall,
                        color: Colors.grey.shade800,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          label,
          variant: TextVariant.bodySmall,
          fontWeight: FontWeight.bold,
          color: AppColors.darkBrown,
        ),
        Gap(4.h),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => _calculate(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.darkBrown,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            filled: true,
            fillColor: AppColors.creamBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.darkBrown.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.darkBrown.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: AppColors.darkBrown, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
