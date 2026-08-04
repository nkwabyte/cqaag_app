import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:cqaag_app/index.dart';
import 'package:url_launcher/url_launcher.dart';

class PartnersScreen extends StatelessWidget {
  static const String id = 'partners_screen';

  const PartnersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const CustomText('Our Partners', variant: TextVariant.bodyLarge, color: Colors.white),
        backgroundColor: AppColors.darkRed,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Background
            Container(
              width: double.infinity,
              height: 250.h,
              decoration: const BoxDecoration(
                color: AppColors.darkRed,
                // image: DecorationImage(
                //   image: AssetImage('assets/images/cashew-bg.jpg'), // Assuming this exists or similar
                //   fit: BoxFit.cover,
                //   colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
                // ),
              ),
              child: Container(
                color: Colors.black.withValues(alpha: 0.6), // Overlay
                padding: EdgeInsets.all(24.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CustomText(
                      'Our Partners',
                      variant: TextVariant.displayMedium,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    Gap(12.h),
                    const CustomText(
                      'Collaborating for Excellence: Guardians of Ghana\'s Cashew Quality',
                      variant: TextVariant.headlineSmall,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.center,
                    ),
                    Gap(12.h),
                    CustomText(
                      'CQAAG works hand-in-hand with regulatory bodies, industry associations, and stakeholders to uphold rigorous standards, promote sustainability, and empower the cashew value chain.',
                      variant: TextVariant.bodySmall,
                      color: Colors.white.withValues(alpha: 0.9),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                children: [
                  const CustomText(
                    'CQAAG is proud to partner with leading organizations in the cashew sector. These collaborations enable us to enforce quality standards, facilitate training and licensing, support arbitration, and drive innovation. Together, we elevate Ghanaian cashews to global excellence while ensuring equitable benefits for farmers, processors, and exporters.',
                    variant: TextVariant.bodyMedium,
                    textAlign: TextAlign.justify,
                  ),
                  Gap(40.h),

                  // Partners Grid
                  _buildPartnersGrid(),

                  Gap(40.h),

                  // Footer Text / Additional Info
                  CustomText(
                    'Primary regulatory partner established under Act 1010 (2019). We collaborate closely on quality inspections, licensing of cashew controllers, standards enforcement, arbitration facilitation, and moisture control initiatives.',
                    variant: TextVariant.bodySmall,
                    color: Colors.grey.shade600,
                    textAlign: TextAlign.center,
                  ),
                  Gap(24.h),
                  const CustomText(
                    'Cashew Council Ghana (CCG)',
                    variant: TextVariant.headlineSmall,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBrown,
                  ),
                  Gap(8.h),
                  const CustomText(
                    'Umbrella body for cashew sector actors. We advocate together for policy reforms, equitable practices, and dispute resolution to benefit all stakeholders.',
                    variant: TextVariant.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnersGrid() {
    final partners = [
      {
        'title': 'Tree crop development Authority (TCDA)',
        'description':
            'The Tree Crops Development Authority (TCDA) is the statutory body established to regulate and develop the production, processing, and trading of six major tree crops in Ghana: Cashew, Shea, Mango, Coconut, Rubber, and Oil Palm.',
        'image': 'assets/images/tcda_logo.jpg',
        'url': 'https://tcda.gov.gh/',
        'isAsset': true,
      },
      {
        'title': 'Ghana Standards Authority (GSA)',
        'description':
            'The Ghana Standards Authority (GSA) is the national statutory body responsible for developing, publishing, and promoting standards in Ghana. Established in 1967 (originally as the Ghana Standards Board), it operates under the Ministry of Trade and Industry.',
        'image': 'assets/images/gsa_logo.png',
        'url': 'https://gsa.gov.gh/',
        'isAsset': true,
      },
      {
        'title': 'Cashew Council of Ghana (CCG)',
        'description':
            'The Cashew Council Ghana (CCG) is the premier advocacy body for the Ghanaian cashew sector, established by industry stakeholders to represent the interests of farmers, processors, and traders. Working alongside the regulatory Tree Crops Development Authority (TCDA), the CCG focuses on improving livelihoods, boosting local processing, and fostering sustainable growth in the industry.',
        'image': '', // Placeholder
        'url': '',
        'isAsset': false,
      },
      {
        'title': 'Cashew Traders and Exporters Association, Ghana (CTEAG)',
        'description':
            'The Cashew Traders and Exporters Association, Ghana (CTEAG) also referred to in some regions as CETAG is a private sector body representing the interests of traders and exporters within Ghana\'s cashew value chain. It is one of the three primary constituent members of the Cashew Council Ghana (CCG), the industry\'s apex umbrella body',
        'image': '', // Placeholder
        'url': '',
        'isAsset': false,
      },
    ];

    return Wrap(
      spacing: 24.w,
      runSpacing: 24.h,
      children: partners.map((partner) => _buildPartnerCard(partner)).toList(),
    );
  }

  Widget _buildPartnerCard(Map<String, dynamic> partner) {
    return Container(
      width: 1.sw > 600 ? (1.sw - 72.w) / 2 : double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            height: 120.h,
            width: 120.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
              image: partner['isAsset'] && (partner['image'] as String).isNotEmpty ? DecorationImage(image: AssetImage(partner['image']), fit: BoxFit.contain) : null,
            ),
            alignment: Alignment.center,
            child: (!partner['isAsset'] || (partner['image'] as String).isEmpty) ? Icon(Icons.business, size: 40.r, color: Colors.grey) : null,
          ),
          Gap(24.h),

          CustomText(
            partner['title'],
            variant: TextVariant.headlineSmall,
            fontWeight: FontWeight.bold,
            color: AppColors.darkBrown,
            textAlign: TextAlign.center,
          ),
          Gap(16.h),

          CustomText(
            partner['description'],
            variant: TextVariant.bodySmall,
            textAlign: TextAlign.center,
          ),
          Gap(24.h),

          if ((partner['url'] as String).isNotEmpty)
            CustomButton(
              text: 'read more',
              width: 140.w,
              height: 40.h,
              backgroundColor: const Color(0xFFC07747), // Bronze/Orange color from design
              textColor: Colors.white,
              trailingIcon: Icon(Icons.arrow_forward, size: 16.r, color: Colors.white),
              onPressed: () => _launchURL(partner['url']),
            ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url)) {
        throw Exception('Could not launch \$url');
      }
    } catch (e) {
      debugPrint('Error launching URL: \$e');
    }
  }
}
