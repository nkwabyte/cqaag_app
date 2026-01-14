import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';

class QualityResultScreen extends StatefulWidget {
  static const String id = 'quality_result_screen';

  final Inspection inspection;

  const QualityResultScreen({super.key, required this.inspection});

  @override
  State<QualityResultScreen> createState() => _QualityResultScreenState();
}

class _QualityResultScreenState extends State<QualityResultScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final i = widget.inspection;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: <Widget>[
          // 1. Hero Header
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 40.h),
              decoration: BoxDecoration(
                color: colorScheme.onSurface, // darkRed
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50.r),
                  bottomRight: Radius.circular(50.r),
                ),
              ),
              child: Column(
                children: [
                  _buildTopBar(context),
                  Gap(30.h),
                  // KOR Circular Indicator
                  Container(
                    width: 140.r,
                    height: 140.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 8.w),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(
                            i.kor.toStringAsFixed(1),
                            variant: TextVariant.displayLarge,
                            color: Colors.white,
                          ),
                          CustomText("KOR", variant: TextVariant.bodySmall, color: Colors.white70),
                        ],
                      ),
                    ),
                  ),
                  Gap(24.h),
                  // Export Ready Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: i.kor >= 48.0 ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          i.kor >= 48.0 ? Icons.check_circle_outline : Icons.info_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                        Gap(8.w),
                        CustomText(
                          i.kor >= 48.0 ? "EXPORT READY" : "BELOW STANDARD",
                          variant: TextVariant.labelLarge,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  Gap(16.h),
                  CustomText(
                    "Nut Count: ${i.nutCount} • ${i.batchId ?? 'No Batch ID'}",
                    variant: TextVariant.bodySmall,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),

          // 2. Data Sections
          SliverPadding(
            padding: EdgeInsets.all(24.r),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader("Report Information"),
                _buildReportInfoCard(colorScheme, i),
                Gap(32.h),

                _buildSectionHeader("Quality Parameters"),
                _buildParametersGrid(i),
                Gap(32.h),

                _buildSectionHeader("Digital Certificate"),
                _buildCertificateCard(colorScheme, i),
                Gap(32.h),

                // 3. Action Buttons
                CustomButton(
                  text: "View Batch Traceability",
                  leadingIcon: const Icon(Icons.account_tree_outlined, color: Colors.white),
                  onPressed: () => context.pushNamed(
                    TraceabilityScreen.id,
                    extra: i,
                  ),
                ),
                Gap(16.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: "Share",
                        variant: ButtonVariant.outlined,
                        leadingIcon: Icon(Icons.share_outlined, color: colorScheme.primary),
                        onPressed: () {},
                      ),
                    ),
                    Gap(16.w),
                    Expanded(
                      child: CustomButton(
                        text: "PDF",
                        variant: ButtonVariant.outlined,
                        leadingIcon: Icon(Icons.picture_as_pdf_outlined, color: colorScheme.primary),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                Gap(40.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Build Methods ---
  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const CustomText("Quality Result", variant: TextVariant.headlineMedium, color: Colors.white),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: CustomText(title, variant: TextVariant.headlineMedium, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildReportInfoCard(ColorScheme colorScheme, Inspection i) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const _InfoRow(label: "Report Type", value: "Arrival"), // Static for now
          const Divider(),
          _InfoRow(label: "Truck Number", value: i.truckNumber ?? "N/A"),
          const Divider(),
          _InfoRow(label: "Company", value: i.company ?? "N/A"),
          const Divider(),
          _InfoRow(label: "Quantity", value: "${i.quantity} MT"),
        ],
      ),
    );
  }

  Widget _buildParametersGrid(Inspection i) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16.r,
      crossAxisSpacing: 16.r,
      childAspectRatio: 1.1,
      children: [
        ParameterCard(
          label: "Moisture",
          value: i.moistureContent.toString(),
          unit: "%",
          status: i.moistureContent <= 10.0 ? "Pass" : "High",
        ),
        ParameterCard(
          label: "Nut Count",
          value: i.nutCount.toString(),
          unit: "g",
          status: "Pass",
        ),
        ParameterCard(
          label: "Void",
          value: i.voidKernels.toString(),
          unit: "g",
          status: "Pass",
        ),
        ParameterCard(
          label: "Oil",
          value: i.oilyKernels.toString(),
          unit: "g",
          status: "Pass",
        ),
        ParameterCard(
          label: "Total Defective",
          value: i.totalDefective.toString(),
          unit: "g",
          status: "Pass",
        ),
        ParameterCard(
          label: "Spotted",
          value: i.spottedKernels.toString(),
          unit: "g",
          status: "Pass",
        ),
      ],
    );
  }

  Widget _buildCertificateCard(ColorScheme colorScheme, Inspection i) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 100.r,
                height: 100.r,
                color: Colors.grey.withValues(alpha: 0.1),
                child: const Icon(Icons.qr_code_2, size: 80),
              ),
              Gap(20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      i.inspectorId.substring(0, i.inspectorId.length > 10 ? 10 : null), // Temp
                      variant: TextVariant.bodyLarge,
                      fontWeight: FontWeight.bold,
                    ),
                    CustomText("Inspector", variant: TextVariant.bodySmall, color: colorScheme.secondary),
                    Gap(8.h),
                    CustomText(
                      i.completedAt?.toString().split('.')[0] ?? "Unknown Date",
                      variant: TextVariant.bodySmall,
                    ),
                    CustomText(
                      i.location ?? "Unknown District",
                      variant: TextVariant.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(20.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText("Certificate ID:", variant: TextVariant.bodySmall, color: colorScheme.secondary),
                Expanded(
                  child: CustomText(
                    i.id.substring(0, 8).toUpperCase(), // Shortened ID
                    variant: TextVariant.bodySmall,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(label, variant: TextVariant.bodyMedium, color: Theme.of(context).colorScheme.secondary),
          CustomText(value, variant: TextVariant.bodyMedium, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }
}
