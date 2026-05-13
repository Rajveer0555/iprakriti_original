import 'package:flutter/material.dart';

import '../models/question_model.dart';

class DoshaDetailsScreen extends StatelessWidget {
  const DoshaDetailsScreen({super.key, required this.dosha});

  final Dosha dosha;

  static const _doshaData = {
    Dosha.vata: _DoshaDetailData(
      title: 'Vata Dosha',
      elements: 'Air & Space',
      description:
          'Vata dosha represents the energy of movement and communication. It governs breathing, circulation, nerve impulses, and elimination. People with dominant Vata are characterized by their creative nature, quick thinking, and energetic movement.',
      physicalTraits: [
        'Slim or light frame with quick movement',
        'Dry, cool, or rough skin and hair',
        'Variable appetite and digestion',
        'Cold hands and feet with irregular sleep',
        'Energetic bursts followed by fatigue',
        'Bright eyes with expressive features',
      ],
      mentalTraits: [
        'Creative and curious with a quick mind',
        'Adaptable and enthusiastic',
        'Imaginative and intuitive',
        'Sensitive to change and environment',
        'Fast learning with quick idea generation',
        'Energetic communication and expression',
      ],
      balancedTraits: [
        'Creative inspiration and flexible thinking',
        'Natural enthusiasm and spontaneity',
        'Quick response to new situations',
        'Lightness, agility, and alertness',
        'Strong intuition and imagination',
        'Joyful movement and expressive energy',
      ],
      whenImbalanced: [
        'Anxiety, worry, or fear',
        'Restlessness, insomnia, or racing thoughts',
        'Dry skin, constipation, or bloating',
        'Cold sensitivity and irregular appetite',
        'Difficulty focusing and feeling scattered',
        'Irregular routines and depleted energy',
      ],
      lifestyleSummary: [
        'Follow a warm, regular routine',
        'Choose nourishing, grounding foods',
        'Stay warm, hydrated, and well-rested',
        'Practice gentle, steady movement',
        'Cultivate calm and consistency',
        'Create quiet space for deep rest',
      ],
      icon: Icons.air_rounded,
      headerColor: Color(0xFFDDF8FF),
      iconBackgroundColor: Color(0xFFC9F2FF),
      accentColor: Color(0xFF5288E7),
      accentSoftColor: Color(0xFFEAFBFF),
      accentBorderColor: Color(0xFF79DDF5),
    ),
    Dosha.pitta: _DoshaDetailData(
      title: 'Pitta Dosha',
      elements: 'Fire & Water',
      description:
          'Pitta dosha represents the energy of transformation and metabolism. It governs digestion, absorption, nutrition, and body temperature. People with dominant Pitta are characterized by their fiery nature, sharp intellect, and strong digestive capacity.',
      physicalTraits: [
        'Medium, athletic build with good muscle definition',
        'Warm body temperature, tendency to feel hot',
        'Soft, warm skin with tendency towards oiliness',
        'Strong appetite and efficient digestion',
        'Moderate weight, maintains steady body mass',
        'Penetrating eyes, often light colored',
      ],
      mentalTraits: [
        'Sharp, focused intellect and quick comprehension',
        'Natural leadership abilities and confidence',
        'Goal-oriented, ambitious, and competitive',
        'Excellent organizational and planning skills',
        'Strong decision-making capabilities',
        'Articulate communication and persuasive speech',
      ],
      balancedTraits: [
        'Strong digestive fire and healthy metabolism',
        'Clear, radiant complexion',
        'Sharp memory and mental clarity',
        'Effective time management and productivity',
        'Courageous and confident in actions',
        'Balanced body temperature regulation',
      ],
      whenImbalanced: [
        'Excessive heat, inflammation, or acid reflux',
        'Skin irritations, rashes, or acne',
        'Irritability, anger, or frustration',
        'Perfectionism and critical tendencies',
        'Digestive issues like heartburn',
        'Impatience and demanding behavior',
      ],
      lifestyleSummary: [
        'Favor cooling, calming activities and environments',
        'Practice moderation in work and competition',
        'Include sweet, bitter, and astringent tastes in diet',
        'Engage in cooling exercises like swimming',
        'Maintain regular meal times to support digestion',
        'Cultivate patience, compassion, and relaxation',
      ],
      icon: Icons.local_fire_department_outlined,
      headerColor: Color(0xFFFFEBCF),
      iconBackgroundColor: Color(0xFFFFCDB4),
      accentColor: Color(0xFFFF5A2D),
      accentSoftColor: Color(0xFFFFF3E8),
      accentBorderColor: Color(0xFFFFB47F),
    ),
    Dosha.kapha: _DoshaDetailData(
      title: 'Kapha Dosha',
      elements: 'Earth & Water',
      description:
          'Kapha dosha represents the energy of structure and nourishment. It governs strength, lubrication, immunity, and endurance. People with dominant Kapha are characterized by their calm nature, steady energy, and compassionate presence.',
      physicalTraits: [
        'Strong, sturdy build with good endurance',
        'Cool, moist skin and smooth hair',
        'Steady digestion and slow metabolism',
        'Calm energy with good physical strength',
        'Balanced weight and easy muscle tone',
        'Large, calm eyes and soft features',
      ],
      mentalTraits: [
        'Patient, compassionate, and nurturing',
        'Stable, loyal, and emotionally grounded',
        'Good memory and practical thinking',
        'Calm under pressure and reliable',
        'Steady focus and thoughtful decisions',
        'Supportive communication and kindness',
      ],
      balancedTraits: [
        'Strong stamina and grounded energy',
        'Healthy immunity and physical resilience',
        'Calm, steady emotional presence',
        'Consistent habits and dependable routines',
        'Compassionate care for self and others',
        'Balanced strength and nourishment',
      ],
      whenImbalanced: [
        'Sluggishness, weight gain, or congestion',
        'Excess mucus or heaviness',
        'Lethargy, attachment, or resistance to change',
        'Depression or low motivation',
        'Slow digestion and feeling slow-moving',
        'Oversleeping and emotional stagnation',
      ],
      lifestyleSummary: [
        'Choose light, warming, and stimulating foods',
        'Move regularly with energizing exercise',
        'Avoid excess sleep and heavy sedentary habits',
        'Create variety and mental stimulation',
        'Keep the body warm, dry, and active',
        'Practice letting go and embracing change',
      ],
      icon: Icons.water_drop_outlined,
      headerColor: Color(0xFFD9FFD1),
      iconBackgroundColor: Color(0xFFADF8B6),
      accentColor: Color(0xFF65C879),
      accentSoftColor: Color(0xFFF0FAEE),
      accentBorderColor: Color(0xFF43EE39),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final data = _doshaData[dosha]!;
    final headerHeight = _headerHeightFor(context, data);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(28, headerHeight + 16, 28, 40),
            child: Column(
              children: [
                _SectionCard(
                  title: 'Physical Traits',
                  items: data.physicalTraits,
                  backgroundColor: Colors.white,
                  borderColor: const Color(0xFFE4E4E1),
                  icon: Icons.person_outline_rounded,
                  iconColor: data.accentColor,
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Mental Traits',
                  items: data.mentalTraits,
                  backgroundColor: Colors.white,
                  borderColor: const Color(0xFFE4E4E1),
                  icon: Icons.psychology_outlined,
                  iconColor: data.accentColor,
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Mental Traits',
                  items: data.balancedTraits,
                  backgroundColor: data.accentSoftColor,
                  borderColor: data.accentBorderColor,
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: data.accentColor,
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'When Imbalanced',
                  items: data.whenImbalanced,
                  backgroundColor: const Color(0xFFFFF3F1),
                  borderColor: const Color(0xFFFFB4A6),
                  icon: Icons.warning_amber_rounded,
                  iconColor: const Color(0xFFFF6D58),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Lifestyle Summary',
                  items: data.lifestyleSummary,
                  backgroundColor: data.accentSoftColor,
                  borderColor: data.accentBorderColor,
                  icon: Icons.lightbulb_outline_rounded,
                  iconColor: data.accentColor,
                ),
              ],
            ),
          ),
          _PinnedHeader(data: data, height: headerHeight),
        ],
      ),
    );
  }

  double _headerHeightFor(BuildContext context, _DoshaDetailData data) {
    final mediaQuery = MediaQuery.of(context);
    final textScale = mediaQuery.textScaler.scale(1);
    final descriptionWidth = mediaQuery.size.width - 94;
    final descriptionStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontSize: 12.8,
      height: 1.43,
      letterSpacing: 0,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: data.description, style: descriptionStyle),
      textDirection: TextDirection.ltr,
      textScaler: mediaQuery.textScaler,
      maxLines: null,
    )..layout(maxWidth: descriptionWidth);

    final descriptionCardHeight = textPainter.height + 48;
    final contentHeight = 28 + 51 + 24 + descriptionCardHeight + 37;
    final minimumHeaderHeight = 298 + mediaQuery.viewPadding.top;
    final responsiveHeaderHeight =
        contentHeight + mediaQuery.viewPadding.top + ((textScale - 1) * 18);

    return responsiveHeaderHeight.clamp(minimumHeaderHeight, double.infinity);
  }
}

class _PinnedHeader extends StatelessWidget {
  const _PinnedHeader({required this.data, required this.height});

  final _DoshaDetailData data;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: data.headerColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(27, 28, 27, 37),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.of(context).pop(),
                    child: const SizedBox(
                      width: 25,
                      height: 28,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.title,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontSize: 17,
                            height: 1.05,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          data.elements,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            height: 1,
                            color: Colors.black,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _DoshaIcon(data: data),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 21, 20, 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFCF8),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFEEDFCB)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x13000000),
                      blurRadius: 13,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  data.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12.8,
                    height: 1.43,
                    color: const Color(0xFF202020),
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoshaIcon extends StatelessWidget {
  const _DoshaIcon({required this.data});

  final _DoshaDetailData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 51,
      height: 51,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [data.iconBackgroundColor, data.accentColor],
        ),
      ),
      child: Icon(data.icon, color: Colors.white, size: 28),
    );
  }
}

class _DoshaDetailData {
  const _DoshaDetailData({
    required this.title,
    required this.elements,
    required this.description,
    required this.physicalTraits,
    required this.mentalTraits,
    required this.balancedTraits,
    required this.whenImbalanced,
    required this.lifestyleSummary,
    required this.icon,
    required this.headerColor,
    required this.iconBackgroundColor,
    required this.accentColor,
    required this.accentSoftColor,
    required this.accentBorderColor,
  });

  final String title;
  final String elements;
  final String description;
  final List<String> physicalTraits;
  final List<String> mentalTraits;
  final List<String> balancedTraits;
  final List<String> whenImbalanced;
  final List<String> lifestyleSummary;
  final IconData icon;
  final Color headerColor;
  final Color iconBackgroundColor;
  final Color accentColor;
  final Color accentSoftColor;
  final Color accentBorderColor;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.items,
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final List<String> items;
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 15),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 17,
                  height: 1.15,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF202020),
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Text(
                      '•',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF161616),
                        fontSize: 14,
                        height: 1.55,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
