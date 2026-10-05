import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:cqaag_app/index.dart';

/// Curved header shared by every governing-document screen.
class LegalDocumentHeader extends StatelessWidget {
  const LegalDocumentHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.backLabel = 'Back',
    this.onBack,
    this.showBack = true,
  });

  final String title;
  final String? subtitle;
  final String backLabel;
  final VoidCallback? onBack;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 36.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(44.r),
          bottomRight: Radius.circular(44.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showBack) ...[
            InkWell(
              onTap: onBack ?? () => Navigator.maybePop(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back, color: Colors.white, size: 20.r),
                  Gap(8.w),
                  CustomText(backLabel, color: Colors.white),
                ],
              ),
            ),
            Gap(20.h),
          ],
          CustomText(title, variant: TextVariant.displaySmall, color: Colors.white),
          if (subtitle != null) ...[
            Gap(6.h),
            CustomText(subtitle!, variant: TextVariant.bodySmall, color: Colors.white.withValues(alpha: 0.75)),
          ],
        ],
      ),
    );
  }
}

/// Renders the body of a [LegalDocument]: introduction, sections and closing.
///
/// The declaration and signature are left to the caller, because the reading
/// screens and the signing flow present them differently.
class LegalDocumentBody extends StatelessWidget {
  const LegalDocumentBody({super.key, required this.document});

  final LegalDocument document;

  /// "Effective Date: …" line, using the document's publication date.
  static String effectiveDateLine(LegalDocument document, {DateTime? effectiveDate}) {
    final format = DateFormat('MMMM dd, yyyy');
    final date = format.format(effectiveDate ?? LegalDocuments.publishedOn);
    if (!document.showsLastUpdated) return 'Effective Date: $date';
    return 'Effective Date: $date  •  Last Updated: ${format.format(LegalDocuments.publishedOn)}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          document.organisation,
          variant: TextVariant.bodyMedium,
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
        Gap(16.h),
        for (final paragraph in document.introduction) ...[
          CustomText(paragraph, variant: TextVariant.bodyMedium),
          Gap(12.h),
        ],
        if (document.introduction.isNotEmpty) Gap(8.h),
        for (final section in document.sections) ...[
          if (section.heading != null) ...[
            CustomText(section.heading!, variant: TextVariant.headlineMedium, fontWeight: FontWeight.bold),
            Gap(8.h),
          ],
          for (final block in section.blocks) _buildBlock(block, colorScheme),
          Gap(16.h),
        ],
      ],
    );
  }

  Widget _buildBlock(LegalBlock block, ColorScheme colorScheme) {
    final bullets = block.bullets;
    if (bullets == null) {
      return Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: CustomText(block.text!, variant: TextVariant.bodyMedium),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Column(
        children: [
          for (final bullet in bullets)
            Padding(
              padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 7.h),
                    child: Container(
                      width: 5.r,
                      height: 5.r,
                      decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                    ),
                  ),
                  Gap(10.w),
                  Expanded(child: CustomText(bullet, variant: TextVariant.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A complete read-only screen for one governing document.
class LegalDocumentReader extends StatelessWidget {
  const LegalDocumentReader({super.key, required this.type, this.footer, this.showBack = true});

  final LegalDocumentType type;

  /// Pinned below the content, e.g. an acceptance button.
  final Widget? footer;

  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final document = LegalDocuments.of(type);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          LegalDocumentHeader(
            title: document.title,
            subtitle: LegalDocumentBody.effectiveDateLine(document),
            showBack: showBack,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LegalDocumentBody(document: document),
                  if (document.declaration != null) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
                      ),
                      child: CustomText(document.declaration!, variant: TextVariant.bodyMedium),
                    ),
                    Gap(16.h),
                  ],
                  if (document.closing != null)
                    CustomText(
                      document.closing!,
                      variant: TextVariant.bodySmall,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  Gap(40.h),
                ],
              ),
            ),
          ),
          ?footer,
        ],
      ),
    );
  }
}
