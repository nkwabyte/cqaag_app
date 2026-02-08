import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:cqaag_app/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AboutScreen extends ConsumerWidget {
  static const String id = 'about_screen';

  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.darkRed,
        title: const CustomText(
          'About Us',
          variant: TextVariant.bodyLarge,
          color: Colors.white,
        ),
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
              child: Column(
                children: [
                  const CustomText(
                    'About Us',
                    variant: TextVariant.displayMedium,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  Gap(8.h),
                  const CustomText(
                    'C.Q.A.A.G',
                    variant: TextVariant.headlineMedium,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  Gap(8.h),
                  CustomText(
                    'Guardians Of Ghana\'s Cashew Quality',
                    variant: TextVariant.bodyMedium,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                children: [
                  // Non-Profit Status
                  _buildContentSection(
                    context,
                    title: 'Non-Profit Status',
                    content:
                        'The Cashew Quality Analysts\' Association, Ghana (C.Q.A.A.G) is proudly established as a non-profit organization, registered under the laws of the Republic of Ghana.\n\nOperating exclusively for charitable, educational, and scientific purposes, the association channels all its resources toward advancing professional standards in cashew quality control, empowering rural communities, promoting sustainable practices, and elevating Ghana\'s cashew industry on the global stage.\n\nNo part of its net earnings ever benefits any private individual. Instead, every contribution—whether from membership dues, grants, training programs, or donations—is reinvested into fulfilling its missions: building professional capacity, advocating for equitable practices, fostering research and innovation, and collaborating with stakeholders like the Tree Crops Development Authority (TCDA).\n\nIn the event of dissolution, all remaining assets would be distributed to similar non-profit organizations dedicated to comparable causes, ensuring that the association\'s commitment to the common good endures beyond its existence.',
                    imageKey: 'non-profit', // Placeholder for image logic
                  ),

                  Gap(48.h),

                  // Headquarters
                  _buildContentSection(
                    context,
                    title: 'Our Headquarters',
                    content:
                        'The headquarters of the Cashew Quality Analysts\' Association, Ghana (C.Q.A.A.G) is proudly situated in Wenchi, a vibrant town in the Bono Region that serves as a cornerstone of Ghana\'s thriving cashew industry.\n\nNestled in the heart of one of the country\'s leading cashew production zones, Wenchi is home to key agricultural research facilities, including the renowned Wenchi Agricultural Station, which plays a pivotal role in developing improved seedlings, advancing good agricultural practices, and supporting farmers through initiatives like the USDA PRO-Cashew project.\n\n Surrounded by vast cashew plantations that contribute significantly to the Bono Region\'s status as Ghana\'s top producer of raw cashew nuts, the headquarters in Wenchi positions C.Q.A.A.G at the epicenter of quality control, professional training, and sustainable innovation.\n\nFrom this strategic base, the association coordinates its national efforts, collaborates closely with regulators like the Tree Crops Development Authority (TCDA), and champions the motto "Guardians of Ghana\'s Cashew Quality"—ensuring that every nut from these fertile lands upholds the highest standards for the benefit of farmers, processors, and the nation.',
                    imageKey: 'headquarters',
                  ),

                  Gap(48.h),

                  // Chapters
                  _buildContentSection(
                    context,
                    title: 'Our Chapters',
                    content:
                        'The Cashew Quality Analysts\' Association, Ghana (C.Q.A.A.G) operates through four regional chapters, strategically organized around Ghana\'s key cashew production zones and logistical hubs to ensure effective local engagement while maintaining national cohesion.\n\nThese semi-autonomous units function under the overarching guidelines of the national headquarters in Wenchi, allowing each chapter to adapt activities—such as training, data collection, and member recruitment—to regional needs, yet aligning fully with the association\'s constitution, core values, and objectives for unified standards and advocacy.',
                    bullets: [
                      'Sampa Chapter — Covers the western frontier areas, including Jaman North, Banda, Tain, Berekum East and West districts, and Sunyani — serves as a vital gateway near the Côte d\'Ivoire border, supporting cross-border trade and quality control in emerging high-yield plantations.',
                      'Drobo-Dormaa Chapter — Encompasses Jaman South, Dormaa districts, the entire Western North, and Ahafo Region — thrives in the fertile Brong-Ahafo heartland, home to many processing facilities and dense cashew farms that drive local value addition.',
                      'Techiman-Bole Chapter — Spans Wenchi, Bono East, Savannah, and Northern Regions — anchors the association\'s headquarters and reaches into the northern savannah zones, where vast plantations and markets like Techiman fuel Ghana\'s position as a top producer.',
                      'Tema-Port Chapter — Covers Volta to Eastern, Ashanti to Western, and Greater Accra Regions — focuses on the vital export and processing logistics chain, linking inland production to international markets through Tema\'s bustling port warehouses.',
                    ],
                    footer:
                        'This semi-autonomous structure empowers chapters to respond nimbly to local challenges—like moisture control or arbitration—while contributing reports, dues, and insights to the national body, ensuring C.Q.A.A.G remains a strong, unified guardian of Ghana\'s cashew quality from farm to port.',
                    imageKey: 'chapters',
                  ),

                  Gap(48.h),

                  // Vision
                  _buildSectionHeader('Our Vision'),
                  Gap(12.h),
                  const CustomText(
                    'The principles that guide our every action at Ghana where every Cashew nut meets global excellence standards through skilled, ethical, and innovative quality practices and analysis, driving sustainable prosperity for farmers, Traders, Processors, and the nation',
                    variant: TextVariant.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  Gap(24.h),
                  _buildGridList([
                    {
                      'icon': Icons.gps_fixed,
                      'title': 'Vision 1',
                      'desc': 'Establish Ghana as a Global Benchmark for Cashew Quality',
                    },
                    {
                      'icon': Icons.groups,
                      'title': 'Vision 2',
                      'desc': 'Foster Sustainable and Resilient Cashew Ecosystems',
                    },
                    {
                      'icon': Icons.lightbulb,
                      'title': 'Vision 3',
                      'desc': 'Help Advance Professional Excellence Among Cashew Controllers',
                    },
                    {
                      'icon': Icons.business,
                      'title': 'Vision 4',
                      'desc': 'Promote Value Addition and Economic Empowerment',
                    },
                    {
                      'icon': Icons.account_tree,
                      'title': 'Vision 5',
                      'desc': 'Build Collaborative Networks for Advocacy and',
                    },
                  ]),

                  Gap(48.h),

                  // Mission
                  _buildSectionHeader('Mission'),
                  Gap(12.h),
                  const CustomText(
                    'Guided by our commitment to excellence and sustainability, the Cashew Quality Analysts\' Association, Ghana (C.Q.A.A.G) pursues five core missions:',
                    variant: TextVariant.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  Gap(24.h),
                  _buildGridList([
                    {
                      'icon': Icons.gps_fixed,
                      'desc':
                          'To establish, uphold, and enforce rigorous quality standards in close collaboration with regulators such as the Tree Crops Development Authority (TCDA), the Cashew Council of Ghana (CCG), and security agencies.',
                    },
                    {
                      'icon': Icons.groups,
                      'desc':
                          'To build professional capacity through education, examinations, and contribute to the licensing of all cashew quality controllers practicing in Ghana.',
                    },
                    {
                      'icon': Icons.lightbulb,
                      'desc': 'To advocate for sustainable and equitable practices across the cashew value chain.',
                    },
                    {
                      'icon': Icons.business,
                      'desc':
                          'To facilitate collaborations and policy advocacy that enhance both the quality and quantity of Ghana\'s cashew production.',
                    },
                    {
                      'icon': Icons.business_center,
                      'desc':
                          'To promote research, particularly in quality data collection, and drive innovation in cashew quality analysis.',
                    },
                  ], showTitle: false),

                  Gap(48.h),

                  // Core Values
                  _buildSectionHeader('Our Core Values'),
                  Gap(12.h),
                  const CustomText(
                    'The principles that guide our every action at Ghana where every Cashew nut meets global excellence standards through skilled, ethical, and innovative quality practices and analysis, driving sustainable prosperity for farmers, Traders, Processors, and the nation',
                    variant: TextVariant.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  Gap(24.h),
                  _buildGridList([
                    {
                      'icon': Icons.groups,
                      'title': 'Integrity',
                      'desc':
                          'Unbiased and accurate analysis.\n\nWe uphold unwavering honesty, transparency, and ethical conduct in all cashew control activities and we ensure accurate inspections free from bias or corruption.',
                    },
                    {
                      'icon': Icons.gps_fixed,
                      'title': 'Excellence',
                      'desc': 'We strive for the highest standards of professionalism and precision in cashew',
                    },
                    {
                      'icon': Icons.lightbulb,
                      'title': 'Sustainability',
                      'desc':
                          'We promote environmentally responsible and resilient practices that protect the ecosystems and the long-term viability of cashew farming.',
                    },
                    {
                      'icon': Icons.work,
                      'title': 'Professionalism',
                      'desc':
                          'CQAAG foster competence, respect, and ongoing development among cashew controllers through education and ethical standards.',
                    },
                    {
                      'icon': Icons.account_tree,
                      'title': 'Collaboration',
                      'desc':
                          'We value partnerships and unity among stakeholders to advance shared goals in the cashew value chain.',
                    },
                    {
                      'icon': Icons.business,
                      'title': 'Community Empowerment',
                      'desc':
                          'Our Members prioritize equitable benefits, supporting rural farmers, women, and youth through fair practices and knowledge sharing',
                    },
                  ]),

                  Gap(48.h),

                  // Objectives
                  _buildSectionHeader('Our Objectives'),
                  Gap(24.h),
                  _buildGridList(
                    [
                      {'title': 'Objective 1', 'desc': 'Development and Advocacy for National Quality Guidelines.'},
                      {
                        'title': 'Objective 2',
                        'desc':
                            'Identify available Cashew Quality Control Standards in Ghana and Practices to achieve 100% adoption of standardized inspection protocols (e.g., sampling, cut testing, moisture analysis, and aflatoxin screening) among members and certified facilities by 2027, reducing domestic trade and export arbitrations by 80%.',
                      },
                      {
                        'title': 'Objective 3',
                        'desc':
                            'Help create quality arbitration centers in the various productions areas and encourage the functioning of dispute committee of CCG and TCDA to resolve arbitration matters',
                      },
                      {
                        'title': 'Objective 4',
                        'desc':
                            'address and implement a moisture control project at all declared export and processing warehouses starting from the year 2026',
                      },
                      {
                        'title': 'Objective 5',
                        'desc':
                            'Train and License 500 Cashew Controllers by 2028 prioritizing women and youth in cashew quality control techniques, sustainable handling, and ethical practices in collaboration with the TCDA',
                      },
                      {
                        'title': 'Objective 6',
                        'desc':
                            'Organize annual conferences, forums, workshops, and a digital resource platform for the stakeholders',
                      },
                      {
                        'title': 'Objective 7',
                        'desc':
                            'Promote ethical practices through a Code of Ethics, compliance, sanctions, research on sustainable quality control and run awareness campaigns on good agricultural practices (GAP).',
                      },
                      {
                        'title': 'Objective 8',
                        'desc':
                            'Help Increase Local Value Addition and Certifications for stakeholders with Certification Bodies',
                      },
                      {
                        'title': 'Objective 9',
                        'desc':
                            'Conduct Research and Knowledge Sharing and publish annual reports on cashew quality trends then facilitate knowledge exchange through a digital platform for members by 2027.',
                      },
                    ],
                    showIcon: false,
                    isCardColor: true,
                  ),

                  Gap(48.h),

                  // Explore CQAAG Navigation
                  _buildSectionHeader('Explore C.Q.A.A.G'),
                  Gap(24.h),
                  _buildNavigationGrid(context, ref),

                  Gap(40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationGrid(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);
    final isLoggedIn = userAsync.value != null;

    final navItems = [
      {
        'title': 'Membership',
        'icon': Icons.card_membership,
        'onTap': () {
          if (isLoggedIn) {
            context.pushNamed(MembershipApplicationScreen.id);
          } else {
            context.pushNamed(RegisterScreen.id);
          }
        },
      },
      {
        'title': 'Chapters',
        'icon': Icons.map,
        'onTap': () => context.pushNamed(ChaptersScreen.id),
      },
      {
        'title': 'Partners',
        'icon': Icons.handshake,
        'onTap': () => context.pushNamed(PartnersScreen.id),
      },
      {
        'title': 'Quality Standards',
        'icon': Icons.verified,
        'onTap': () => context.pushNamed(QualityStandardsScreen.id),
      },
    ];

    return Wrap(
      spacing: 16.w,
      runSpacing: 16.h,
      children: navItems.map((item) {
        return GestureDetector(
          onTap: item['onTap'] as VoidCallback,
          child: Container(
            width: (1.sw - 64.w) / 2,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: AppColors.darkRed.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item['icon'] as IconData, size: 32.r, color: AppColors.darkRed),
                Gap(12.h),
                CustomText(
                  item['title'] as String,
                  variant: TextVariant.bodyMedium,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBrown,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContentSection(
    BuildContext context, {
    required String title,
    required String content,
    List<String>? bullets,
    String? footer,
    String? imageKey,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          title,
          variant: TextVariant.headlineMedium,
          fontWeight: FontWeight.bold,
          color: AppColors.darkBrown,
        ),
        Gap(16.h),
        CustomText(
          content,
          variant: TextVariant.bodyMedium,
          textAlign: TextAlign.left,
        ),
        if (bullets != null) ...[
          Gap(12.h),
          ...bullets.map(
            (bullet) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText('• ', variant: TextVariant.bodyMedium, fontWeight: FontWeight.bold),
                  Expanded(
                    child: CustomText(bullet, variant: TextVariant.bodyMedium, textAlign: TextAlign.left),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (footer != null) ...[
          Gap(12.h),
          CustomText(
            footer,
            variant: TextVariant.bodyMedium,
            textAlign: TextAlign.left,
          ),
        ],
        if (imageKey != null && (imageKey == 'non-profit' || imageKey == 'headquarters')) ...[
          Gap(24.h),
          Container(
            height: 200.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16.r),
              image: DecorationImage(
                image: AssetImage(
                  imageKey == 'non-profit' ? Assets.imagesAboutImageOne : Assets.imagesAboutImageTwo,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Center(
      child: CustomText(
        title,
        variant: TextVariant.displaySmall,
        fontWeight: FontWeight.bold,
        color: AppColors.darkBrown,
      ),
    );
  }

  Widget _buildGridList(
    List<Map<String, dynamic>> items, {
    bool showTitle = true,
    bool showIcon = true,
    int crossAxisCount = 1,
    bool isCardColor = false,
  }) {
    return Wrap(
      spacing: 16.w,
      runSpacing: 16.h,
      children: items.map((item) {
        return Container(
          width: crossAxisCount == 1 ? double.infinity : (1.sw - 64.w) / 2, // Approximate width
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: isCardColor ? const Color(0xFFF5EBE0) : const Color(0xFFF9F4EF), // Light beige colors
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              if (showIcon && item['icon'] != null) ...[
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFC07747), // Muted orange/brown
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(12.r),
                  child: Icon(item['icon'], color: Colors.white, size: 28.r),
                ),
                Gap(16.h),
              ],
              if (showTitle && item['title'] != null) ...[
                CustomText(
                  item['title'],
                  variant: TextVariant.bodyLarge,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                  color: AppColors.darkBrown,
                ),
                Gap(8.h),
              ],
              CustomText(
                item['desc'],
                variant: TextVariant.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
