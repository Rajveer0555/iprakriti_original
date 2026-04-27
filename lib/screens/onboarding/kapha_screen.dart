import 'package:flutter/material.dart';

import 'dosha_content.dart';

class KaphaScreen extends StatelessWidget {
  const KaphaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DoshaContent(
      assetPath: 'assets/Logo3.png',
      title: 'Kapha',
      titleColor: Color(0xFF39C95C),
      gradientColors: [
        Color(0xFFFFFFFF),
        Color(0xFFF7FCF5),
        Color(0xFFCDEBC0),
      ],
      description: [
        'Kapha is based on earth and water. It can be described as steady, stable, heavy, slow, cold, and soft. Spring is known as kapha season, as many parts of the world slowly exit hibernation.',
        'People with this dosha are described as strong, thick-boned, and caring. They\'re known for keeping things together and being a support system for others. Kapha-dominant people rarely get upset, think before acting, and go through life in a slow, deliberate manner',
      ],
    );
  }
}
