import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/question_model.dart';
import 'dashboard_screen.dart';
import 'personalized_recommendations_screen.dart';
import 'share_report_screen.dart';

class DetailedReportScreen extends StatelessWidget {
  const DetailedReportScreen({
    required this.result,
    super.key,
  });

  final PrakritiAssessmentResult result;

  static const Map<String, List<String>> _physicalCharacteristics = {
    'Pitta': [
      'Medium build with good muscle tone',
      'Warm body temperature',
      'Strong appetite and digestion',
      'Tendency to perspire easily',
      'Soft, warm, and slightly oily skin',
    ],
    'Vata': [
      'Light frame with quick movements',
      'Dry or cool skin and hands',
      'Variable appetite and digestion',
      'Easily affected by cold weather',
      'Irregular energy patterns',
    ],
    'Kapha': [
      'Strong and well-built body frame',
      'Smooth, cool, and often oily skin',
      'Steady appetite and slower digestion',
      'Good endurance and stable energy',
      'Tendency to retain water or heaviness',
    ],
  };

  static const Map<String, List<String>> _mentalTendencies = {
    'Pitta': [
      'Sharp intellect and focused mind',
      'Natural leadership qualities',
      'Goal-oriented and ambitious',
      'Quick decision maker',
      'Strong willpower and determination',
    ],
    'Vata': [
      'Highly imaginative and creative',
      'Learns quickly and thinks fast',
      'Can become distracted easily',
      'Emotionally expressive and sensitive',
      'Benefits from calming structure',
    ],
    'Kapha': [
      'Calm, patient, and emotionally steady',
      'Strong long-term memory',
      'Loyal and dependable in relationships',
      'Prefers comfort and consistency',
      'Slow to anger and slow to change',
    ],
  };

  static const Map<String, List<String>> _imbalanceRisks = {
    'Pitta': [
      'Inflammation and acidity issues',
      'Irritability and anger under stress',
      'Skin rashes or sensitivity',
      'Excessive heat in the body',
      'Digestive sensitivity to spicy foods',
    ],
    'Vata': [
      'Anxiety and restlessness',
      'Bloating and irregular digestion',
      'Dry skin and dehydration',
      'Difficulty maintaining sleep',
      'Low stamina during overexertion',
    ],
    'Kapha': [
      'Sluggish digestion and heaviness',
      'Low motivation or lethargy',
      'Congestion and mucus buildup',
      'Water retention and weight gain',
      'Resistance to change or inactivity',
    ],
  };

  static const Map<String, List<String>> _dietRecommendations = {
    'Pitta': [
      'Favor cooling foods like cucumber, coconut, and mint',
      'Avoid excessive spicy, salty, and fried foods',
      'Include sweet fruits like melon and grapes',
      'Drink cool (not ice-cold) beverages',
      'Eat at regular times to maintain digestive fire',
    ],
    'Vata': [
      'Choose warm, cooked, and nourishing foods',
      'Favor healthy fats like ghee and sesame oil',
      'Avoid skipping meals or fasting for long periods',
      'Drink warm water or herbal teas',
      'Include grounding foods like oats, rice, and root vegetables',
    ],
    'Kapha': [
      'Prefer light, warm, and mildly spiced meals',
      'Reduce heavy dairy and overly sweet foods',
      'Choose plenty of vegetables and legumes',
      'Drink warm water through the day',
      'Keep portions moderate and avoid overeating',
    ],
  };

  static const Map<String, List<String>> _routineRecommendations = {
    'Pitta': [
      'Balance intense work with mindful breaks',
      'Make time for cooling walks or restorative yoga',
      'Avoid peak midday heat when possible',
      'Protect your sleep with a calm evening routine',
      'Practice patience-focused breathwork under stress',
    ],
    'Vata': [
      'Keep a regular wake-up and sleep schedule',
      'Prioritize gentle grounding movement each day',
      'Create calm transitions between activities',
      'Use oil massage or warm baths for relaxation',
      'Build routines that reduce overstimulation',
    ],
    'Kapha': [
      'Wake up early and stay physically active',
      'Choose energizing exercise most days',
      'Avoid long daytime naps',
      'Keep routines dynamic and motivating',
      'Create momentum with small daily goals',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final dominant = result.finalPrakriti;
    final completedAt = result.createdAt ?? DateTime.now();
    final physical = _physicalCharacteristics[dominant] ?? const [];
    final mental = _mentalTendencies[dominant] ?? const [];
    final risks = _imbalanceRisks[dominant] ?? const [];
    final diet = _dietRecommendations[dominant] ?? const [];
    final routine = _routineRecommendations[dominant] ?? const [];

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detailed Report',
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Assessment completed on ${_formatDate(completedAt)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF666666),
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ShareReportScreen(result: result),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share_outlined),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 10, 28, 28),
                child: Column(
                  children: [
                    _ReportCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Dosha Breakdown',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute<void>(
                                      builder:
                                          (_) => const DashboardScreen(
                                            initialIndex: 2,
                                          ),
                                    ),
                                    (route) => false,
                                  );
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      'Learn more',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: const Color(0xFF444444),
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              SizedBox(
                                width: 132,
                                height: 132,
                                child: CustomPaint(
                                  painter: _DetailedReportChartPainter(result),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${_dominantPercent(result).round()}%',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        Text(
                                          dominant,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  children: [
                                    _DoshaLegendRow(
                                      color: AppColors.secondary,
                                      label: 'Pitta',
                                      value: '${result.pittaPercent.round()}%',
                                    ),
                                    const SizedBox(height: 12),
                                    _DoshaLegendRow(
                                      color: AppColors.tertiary,
                                      label: 'Vata',
                                      value: '${result.vataPercent.round()}%',
                                    ),
                                    const SizedBox(height: 12),
                                    _DoshaLegendRow(
                                      color: AppColors.kapha,
                                      label: 'Kapha',
                                      value: '${result.kaphaPercent.round()}%',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    _ReportCard(
                      child: _BulletSection(
                        title: 'Physical Characteristics',
                        items: physical,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _ReportCard(
                      child: _BulletSection(
                        title: 'Mental Tendencies',
                        items: mental,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _ReportCard(
                      warning: true,
                      child: _BulletSection(
                        title: 'Potential Imbalance Risks',
                        items: risks,
                        leadingIcon: Icons.warning_amber_rounded,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _ReportCard(
                      tinted: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lifestyle Recommendations',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: 18),
                          _RecommendationGroup(
                            icon: Icons.spa_outlined,
                            title: 'Diet',
                            items: diet,
                          ),
                          const SizedBox(height: 18),
                          _RecommendationGroup(
                            icon: Icons.refresh_rounded,
                            title: 'Routine',
                            items: routine,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => PersonalizedRecommendationsScreen(
                                result: result,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 56),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: const Text(
                          'See Recommendations',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _dominantPercent(PrakritiAssessmentResult result) {
    final values = [
      result.vataPercent,
      result.pittaPercent,
      result.kaphaPercent,
    ];
    values.sort();
    return values.last;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.child,
    this.tinted = false,
    this.warning = false,
  });

  final Widget child;
  final bool tinted;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color:
            warning
                ? const Color(0xFFFFF9CF)
                : tinted
                ? const Color(0xFFF0F8EB)
                : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color:
              warning
                  ? const Color(0xFFFFB7A8)
                  : tinted
                  ? const Color(0xFFC8DEBC)
                  : const Color(0xFFECEEE7),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _BulletSection extends StatelessWidget {
  const _BulletSection({
    required this.title,
    required this.items,
    this.leadingIcon,
  });

  final String title;
  final List<String> items;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leadingIcon == null)
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          )
        else
          Row(
            children: [
              Icon(leadingIcon, color: const Color(0xFFE0A800), size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),
        for (int i = 0; i < items.length; i++) ...[
          _BulletRow(text: items[i]),
          if (i != items.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _RecommendationGroup extends StatelessWidget {
  const _RecommendationGroup({
    required this.icon,
    required this.title,
    required this.items,
  });

  final IconData icon;
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: const Color(0xFF7A7A7A)),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _BulletRow(text: items[i]),
                if (i != items.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 7),
          child: Icon(
            Icons.circle,
            size: 7,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF262626),
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _DoshaLegendRow extends StatelessWidget {
  const _DoshaLegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF454545),
              fontSize: 15,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF454545),
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _DetailedReportChartPainter extends CustomPainter {
  const _DetailedReportChartPainter(this.result);

  final PrakritiAssessmentResult result;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - strokeWidth;

    final backgroundPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = const Color(0xFFF0F0EA);

    canvas.drawCircle(center, radius, backgroundPaint);

    final segments = <(double, Color)>[
      (result.pittaPercent / 100, AppColors.secondary),
      (result.vataPercent / 100, AppColors.tertiary),
      (result.kaphaPercent / 100, AppColors.kapha),
    ];

    var startAngle = -math.pi / 2;
    for (final segment in segments) {
      final sweepAngle = 2 * math.pi * segment.$1;
      final paint =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.butt
            ..color = segment.$2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DetailedReportChartPainter oldDelegate) {
    return oldDelegate.result != result;
  }
}
