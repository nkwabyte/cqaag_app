import 'package:cqaag_app/index.dart';

class Event {
  final String id;
  final String title;
  final EventCategory category;
  final String description;
  final String content;
  final String imageUrl;
  final DateTime date;
  final String? author;

  const Event({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.content,
    required this.imageUrl,
    required this.date,
    this.author,
  });

  // Mock data for demonstration
  static List<Event> getMockEvents() {
    return [
      Event(
        id: '1',
        title: 'Recent Quality Data Insights',
        category: EventCategory.insights,
        description: 'Farm-data Snapshot: The 2025 RCN season in Ghana has commenced amid significant challenges stemming from atypical weather patterns attributed to climate...',
        content: '''
# Recent Quality Data Insights

Farm-data Snapshot: The 2025 RCN season in Ghana has commenced amid significant challenges stemming from atypical weather patterns attributed to climate change.

## Key Findings

The cashew industry in Ghana is experiencing unprecedented changes in quality metrics. Our latest analysis reveals several important trends that farmers and processors need to be aware of.

### Weather Impact

Atypical weather patterns have significantly affected the 2025 season. Extended dry periods followed by unexpected rainfall have created challenges for optimal nut development.

### Quality Metrics

Despite weather challenges, our quality analysts have maintained rigorous standards. The pass rate remains strong at 91.5%, demonstrating the resilience of Ghanaian cashew producers.

## Best Practices

1. **Early harvesting**: Monitor nut maturity closely
2. **Proper storage**: Ensure adequate ventilation
3. **Regular inspection**: Work with certified quality analysts
4. **Documentation**: Maintain detailed harvest records

## Looking Ahead

The association continues to work closely with farmers to adapt to changing conditions while maintaining world-class quality standards.
''',
        imageUrl: Assets.imagesCashewBg,
        date: DateTime(2026, 1, 20),
        author: 'CQAAG Research Team',
      ),
      Event(
        id: '2',
        title: 'Nutrition, Health Benefits and Emerging Cashew Value Streams',
        category: EventCategory.news,
        description: 'Cashew kernels boast a powerhouse of nutrients and have burgeoning opportunities. Cashews are low in carbs and high in protein...',
        content: '''
# Nutrition, Health Benefits and Emerging Cashew Value Streams

Cashew kernels boast a powerhouse of nutrients and have burgeoning opportunities. Cashews are low in carbs and high in protein, making them an excellent dietary choice.

## Nutritional Profile

Cashews are packed with essential nutrients that contribute to overall health and wellbeing.

### Key Nutrients

- **Protein**: High-quality plant protein
- **Healthy Fats**: Monounsaturated and polyunsaturated fats
- **Minerals**: Rich in magnesium, zinc, and iron
- **Vitamins**: Good source of vitamin E and K

## Health Benefits

Regular consumption of cashews has been linked to numerous health benefits:

1. **Heart Health**: Supports cardiovascular function
2. **Weight Management**: Promotes satiety
3. **Bone Health**: High mineral content supports bone density
4. **Antioxidant Properties**: Protects against cellular damage

## Emerging Value Streams

The cashew industry is discovering new opportunities beyond traditional kernel sales:

- **Cashew Milk**: Growing demand in plant-based markets
- **Cashew Butter**: Premium spread alternative
- **Cashew Oil**: Culinary and cosmetic applications
- **Shell Liquid**: Industrial applications

## Market Opportunities

Ghana is well-positioned to capitalize on these emerging value streams, creating additional income opportunities for farmers and processors.
''',
        imageUrl: Assets.imagesCashewBg,
        date: DateTime(2026, 1, 18),
        author: 'Dr. Kwame Mensah',
      ),
      Event(
        id: '3',
        title: 'Understanding Cashew Quality and Grading, and What It Means for Farmers',
        category: EventCategory.insights,
        description: 'Exploring the physical properties and grading systems that shape cashew value. Understanding nut size, color, and quality standards...',
        content: '''
# Understanding Cashew Quality and Grading, and What It Means for Farmers

Exploring the physical properties and grading systems that shape cashew value. Understanding nut size, color, and quality standards is crucial for maximizing returns.

## What is Cashew Quality?

Cashew quality encompasses multiple factors that determine the market value and acceptability of the nuts.

### Physical Properties

- **Kernel size and weight**: Larger kernels command premium prices
- **Color uniformity**: White and light ivory grades are most valued
- **Moisture content**: Must be within specified limits
- **Defect levels**: Broken, spotted, or damaged kernels reduce grade

## Cashew Grading Explained

The international grading system provides a standardized way to classify cashew kernels:

### Grade Categories

- **W-180**: Largest whole kernels (180 kernels per pound)
- **W-210**: Premium whole kernels
- **W-240**: Standard whole kernels
- **W-320**: Smaller whole kernels
- **Splits and Pieces**: Various broken kernel grades

## Why Grading Matters for Ghanaian Farmers

Understanding grading helps farmers make informed decisions:

1. **Better Prices**: Higher grades fetch premium prices
2. **Market Access**: Consistent quality opens international markets
3. **Reputation**: Quality builds long-term buyer relationships
4. **Sustainability**: Quality focus supports industry growth

## Best Practices for Quality Improvement

### During Harvest

- **Timing**: Harvest at optimal maturity
- **Handling**: Minimize physical damage
- **Sorting**: Remove defective nuts early

### Post-Harvest

- **Drying**: Achieve proper moisture levels
- **Storage**: Maintain quality during storage
- **Processing**: Work with certified processors

## CQAAG's Role

The Cashew Quality Analysts' Association of Ghana ensures that quality standards are maintained throughout the value chain, protecting the interests of farmers and maintaining Ghana's reputation in global markets.
''',
        imageUrl: Assets.imagesCashewBg,
        date: DateTime(2026, 1, 15),
        author: 'CQAAG Quality Standards Team',
      ),
    ];
  }
}
