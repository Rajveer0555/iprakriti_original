import 'package:flutter/material.dart';

import '../models/question_model.dart';

class PersonalizedRecommendationsScreen extends StatelessWidget {
  const PersonalizedRecommendationsScreen({
    required this.result,
    super.key,
  });

  final PrakritiAssessmentResult result;

  static const Map<String, Map<String, dynamic>> _content = {
    'Pitta': {
      'sleep': [
        'Maintain a cool bedroom environment',
        'Follow a consistent sleep schedule',
        'Aim for 7-8 hours of quality sleep',
        'Practice evening relaxation rituals',
        'Avoid stimulating activities before bed',
      ],
      'activities': [
        'Swimming and water-based exercises',
        'Gentle yoga (avoid hot yoga)',
        'Evening walks in cool weather',
        'Meditation and mindfulness practices',
        'Creative arts and relaxing hobbies',
      ],
      'tips': [
        'Stay well-hydrated throughout the day',
        'Avoid direct sun during peak hours',
      ],
      'note':
          'Consistency is key to experiencing the benefits of Ayurvedic practices.',
    },
    'Vata': {
      'sleep': [
        'Keep a warm and calming bedroom setup',
        'Go to bed at the same time each night',
        'Favor deep rest over late-night stimulation',
        'Try gentle stretches before sleeping',
        'Reduce screen time close to bedtime',
      ],
      'activities': [
        'Grounding yoga and mobility work',
        'Nature walks in calm surroundings',
        'Breathwork and guided meditation',
        'Light strength training with recovery days',
        'Journaling or quiet creative hobbies',
      ],
      'tips': [
        'Choose warm meals and regular mealtimes',
        'Protect your energy with structured routines',
      ],
      'note':
          'Gentle rhythm and consistency help Vata feel centered and supported.',
    },
    'Kapha': {
      'sleep': [
        'Wake up early and avoid oversleeping',
        'Keep your room fresh and energizing',
        'Maintain a consistent night routine',
        'Limit heavy meals late in the evening',
        'Use light stretching to start and end the day',
      ],
      'activities': [
        'Brisk walks and energizing cardio',
        'Dynamic yoga or dance-based movement',
        'Outdoor activities that build momentum',
        'Group workouts for motivation',
        'New hobbies that keep you mentally engaged',
      ],
      'tips': [
        'Favor lighter foods and active mornings',
        'Break long periods of sitting with movement',
      ],
      'note':
          'A little daily activation goes a long way for Kapha balance.',
    },
  };

  @override
  Widget build(BuildContext context) {
    final dominant = result.finalPrakriti;
    final content = _content[dominant] ?? _content['Pitta']!;
    final completedAt = result.createdAt ?? DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 14, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                          'Personalized Recommendations',
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontSize: 19,
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
                ],
              ),
              const SizedBox(height: 22),
              _RecommendationCard(
                backgroundColor: const Color(0xFFE9E9F8),
                borderColor: const Color(0xFFBFC1E2),
                title: 'Sleep & Recovery',
                icon: Icons.nightlight_round,
                items: List<String>.from(content['sleep'] as List),
              ),
              const SizedBox(height: 22),
              _RecommendationCard(
                backgroundColor: const Color(0xFFF8F8E7),
                borderColor: const Color(0xFFD1D3B2),
                title: 'Recommended Activities',
                icon: Icons.graphic_eq_rounded,
                items: List<String>.from(content['activities'] as List),
              ),
              const SizedBox(height: 22),
              _QuickTipsCard(
                tips: List<String>.from(content['tips'] as List),
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7EF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFCFE0CC)),
                ),
                child: Text(
                  'These recommendations are personalized for your unique constitution. ${content['note']}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF363636),
                        height: 1.7,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.backgroundColor,
    required this.borderColor,
    required this.title,
    required this.icon,
    required this.items,
  });

  final Color backgroundColor;
  final Color borderColor;
  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor),
      ),
      child: Column(
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
                child: Icon(icon, size: 16, color: const Color(0xFF8B8B8B)),
              ),
              const SizedBox(width: 14),
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
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  _RecommendationBullet(text: items[i]),
                  if (i != items.length - 1) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTipsCard extends StatelessWidget {
  const _QuickTipsCard({
    required this.tips,
  });

  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8ECE3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Balancing Tips',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < tips.length; i++) ...[
            _QuickTipRow(
              icon: i == 0 ? Icons.water_drop_outlined : Icons.wb_sunny_outlined,
              text: tips[i],
            ),
            if (i != tips.length - 1) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _QuickTipRow extends StatelessWidget {
  const _QuickTipRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFFF4F4F4),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: const Color(0xFFA5A5A5)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF2E2E2E),
                  height: 1.5,
                ),
          ),
        ),
      ],
    );
  }
}

class _RecommendationBullet extends StatelessWidget {
  const _RecommendationBullet({
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
          child: Icon(Icons.circle, size: 5, color: Colors.black87),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF242424),
                  height: 1.75,
                ),
          ),
        ),
      ],
    );
  }
}
