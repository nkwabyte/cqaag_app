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

            // Key Inspection Metrics Section
            Container(
              // Background color separation not explicit in design but good for structure
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
                    '* All measurements based on standard 300g sample size. KOR calculated using formula: K/(Sh+0.75*Tk)',
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
            headingRowColor: MaterialStateProperty.all(AppColors.tableHeaderBrown), // Dark Brown
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
                color: MaterialStateProperty.resolveWith((states) => AppColors.lightOrange.withValues(alpha: 0.05)), // Very light bg
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
