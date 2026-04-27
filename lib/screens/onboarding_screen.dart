import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  late final List<OnboardingPage> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _pages = [
      OnboardingPage(
        title: 'Vata',
        description:
            'Vata consists mostly of the two elements air and space (also known as ether) and is generally described as cold, light, dry, rough, flowing, and spacious. Autumn represents vata for its cool, crisp days.\n\nThose with the vata dosha are usually described as slim, energetic, and creative. They\'re known for thinking outside the box but can become easily distracted. What\'s more, their mood is highly dependent on the weather, people around them, and foods they eat',
        backgroundColor: const Color(0xFFE3F2FD),
        icon: _buildVataIcon(),
      ),
      OnboardingPage(
        title: 'Pitta',
        description:
            'Pitta known for being associated with a tenacious personality, the pitta dosha is based on fire and water. It\'s commonly described as hot, light, sharp, oily, liquid, and mobile. Summer is known as pitta season for its sunny, hot days.\n\nPeople with pitta are said to usually have a muscular build, be very athletic, and serve as strong leaders. They\'re highly motivated, goal-oriented, and competitive. Still, their aggressive and tenacious nature can be off-putting to some people, which can lead to conflict',
        backgroundColor: const Color(0xFFFFF3E0),
        icon: _buildPittaIcon(),
      ),
      OnboardingPage(
        title: 'Kapha',
        description:
            'Kapha is based on earth and water. It can be described as steady, stable, heavy, slow, cold, and soft. Spring is known as kapha season, as many parts of the world slowly exit hibernation.\n\nPeople with this dosha are described as strong, thick-boned, and caring. They\'re known for keeping things together and being a support system for others. Kapha-dominant people rarely get upset, think before acting, and go through life in a slow, deliberate manner',
        backgroundColor: const Color(0xFFF1F8E9),
        icon: _buildKaphaIcon(),
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Mark onboarding as completed
      await ref.read(onboardingCompletedProvider.notifier).completeOnboarding();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemCount: _pages.length,
        itemBuilder: (context, index) {
          return _buildOnboardingPage(_pages[index]);
        },
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return SafeArea(
      child: Container(
        color: page.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon at the top
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: page.icon,
              ),
              // Content in the middle
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        page.title,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        page.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF333333),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Indicators and button at the bottom
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => Container(
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentPage == index
                                ? _getIndicatorColor(index)
                                : Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Next Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? 'Start Assessment'
                              : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getIndicatorColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFF1976D2); // Blue for Vata
      case 1:
        return const Color(0xFFFFA500); // Orange for Pitta
      case 2:
        return const Color(0xFF4CAF50); // Green for Kapha
      default:
        return Colors.grey;
    }
  }

  static Widget _buildVataIcon() {
    return Image.asset(
      'assets/Logo1.png',
      width: 120,
      height: 120,
      fit: BoxFit.contain,
    );
  }

  static Widget _buildPittaIcon() {
    return Image.asset(
      'assets/Logo2.png',
      width: 120,
      height: 120,
      fit: BoxFit.contain,
    );
  }

  static Widget _buildKaphaIcon() {
    return Image.asset(
      'assets/Logo3.png',
      width: 120,
      height: 120,
      fit: BoxFit.contain,
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final Color backgroundColor;
  final Widget icon;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.icon,
  });
}
