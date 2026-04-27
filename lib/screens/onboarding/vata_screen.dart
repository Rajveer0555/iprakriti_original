import 'package:flutter/material.dart';

import 'dosha_content.dart';

class VataScreen extends StatelessWidget {
  const VataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DoshaContent(
      assetPath: 'assets/Logo1.png',
      title: 'Vata',
      titleColor: Color(0xFF3556D6),
      gradientColors: [
        Color(0xFFFFFFFF),
        Color(0xFFF7FBFF),
        Color(0xFFB9DEFA),
      ],
      description: [
        'Vata consists mostly of the two elements air and space (also known as ether) and is generally described as cold, light, dry, rough, flowing, and spacious. Autumn represents vata for its cool, crisp days.',
        'Those with the vata dosha are usually described as slim, energetic, and creative. They\'re known for thinking outside the box but can become easily distracted. What\'s more, their mood is highly dependent on the weather, people around them, and foods they eat',
      ],
    );
  }
}
