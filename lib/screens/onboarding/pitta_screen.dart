import 'package:flutter/material.dart';

import 'dosha_content.dart';

class PittaScreen extends StatelessWidget {
  const PittaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DoshaContent(
      assetPath: 'assets/Logo2.png',
      title: 'Pitta',
      titleColor: Color(0xFFD2A31A),
      gradientColors: [
        Color(0xFFFFFFFF),
        Color(0xFFFFFBF1),
        Color(0xFFFBE2A7),
      ],
      description: [
        'Pitta known for being associated with a tenacious personality, the pitta dosha is based on fire and water. It\'s commonly described as hot, light, sharp, oily, liquid, and mobile. Summer is known as pitta season for its sunny, hot days.',
        'People with pitta are said to usually have a muscular build, be very athletic, and serve as strong leaders. They\'re highly motivated, goal-oriented, and competitive. Still, their aggressive and tenacious nature can be off-putting to some people, which can lead to conflict',
      ],
    );
  }
}
