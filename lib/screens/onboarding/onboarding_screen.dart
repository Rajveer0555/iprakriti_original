import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _pages = [
    _OnboardingPageData(
      title: 'Vata',
      logo: 'assets/Logo1.png',
      titleColor: Color(0xFF466DDA),
      activeDotColor: Color(0xFF249AF4),
      gradientEnd: Color(0xFF88CEF0),
      description:
          'Vata consists mostly of the two elements air and space (also known as ether) and is generally described as cold, light, dry, rough, flowing, and spacious. Autumn represents vata for its cool, crisp days.\n\nThose with the vata dosha are usually described as slim, energetic, and creative. They\'re known for thinking outside the box but can become easily distracted. What\'s more, their mood is highly dependent on the weather, people around them, and foods they eat',
    ),
    _OnboardingPageData(
      title: 'Pitta',
      logo: 'assets/Logo2.png',
      titleColor: Color(0xFFD0AA33),
      activeDotColor: Color(0xFFFFB12B),
      gradientEnd: Color(0xFFF1CB7D),
      description:
          'Pitta known for being associated with a tenacious personality, the pitta dosha is based on fire and water. It\'s commonly described as hot, light, sharp, oily, liquid, and mobile. Summer is known as pitta season for its sunny, hot days.\n\nPeople with pitta are said to usually have a muscular build, be very athletic, and serve as strong leaders. They\'re highly motivated, goal-oriented, and competitive. Still, their aggressive and tenacious nature can be off-putting to some people, which can lead to conflict',
    ),
    _OnboardingPageData(
      title: 'Kapha',
      logo: 'assets/Logo3.png',
      titleColor: Color(0xFF41CF61),
      activeDotColor: Color(0xFF13C447),
      gradientEnd: Color(0xFFA5DFAE),
      description:
          'Kapha is based on earth and water. It can be described as steady, stable, heavy, slow, cold, and soft. Spring is known as kapha season, as many parts of the world slowly exit hibernation.\n\nPeople with this dosha are described as strong, thick-boned, and caring. They\'re known for keeping things together and being a support system for others. Kapha-dominant people rarely get upset, think before acting, and go through life in a slow, deliberate manner',
    ),
  ];

  int _currentPage = 0;

  Future<void> _nextPage() async {
    if (_currentPage < _pages.length - 1) {
      setState(() {
        _currentPage += 1;
      });
      return;
    }

    await ref.read(onboardingCompletedProvider.notifier).completeOnboarding();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, 0.48, 1],
            colors: [Colors.white, const Color(0xFFFBFDFD), page.gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(31, 0, 31, 41),
            child: Column(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: _OnboardingContent(
                      key: ValueKey(page.title),
                      data: page,
                    ),
                  ),
                ),
                _PageDots(
                  activeIndex: _currentPage,
                  count: _pages.length,
                  activeColor: page.activeDotColor,
                ),
                const SizedBox(height: 66),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16641F),
                      foregroundColor: Colors.white,
                      elevation: 10,
                      shadowColor: Colors.black.withValues(alpha: 0.25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentPage == _pages.length - 1
                              ? 'Start Assessment'
                              : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right_rounded, size: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  const _OnboardingContent({super.key, required this.data});

  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 28),
        Image.asset(data.logo, width: 116, height: 116, fit: BoxFit.contain),
        const SizedBox(height: 18),
        Text(
          data.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: data.titleColor,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          data.description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15.8,
            fontWeight: FontWeight.w400,
            height: 1.34,
          ),
        ),
        const Spacer(flex: 18),
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.activeIndex,
    required this.count,
    required this.activeColor,
  });

  final int activeIndex;
  final int count;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: isActive ? 20 : 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          decoration: BoxDecoration(
            color: isActive ? activeColor : const Color(0xFF8D8D8D),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.logo,
    required this.description,
    required this.titleColor,
    required this.activeDotColor,
    required this.gradientEnd,
  });

  final String title;
  final String logo;
  final String description;
  final Color titleColor;
  final Color activeDotColor;
  final Color gradientEnd;
}
