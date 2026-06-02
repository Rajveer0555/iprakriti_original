import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'face_scan_screen.dart';
import 'widgets/assessment_step_badge.dart';

class AssessmentIntroScreen extends StatelessWidget {
  const AssessmentIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: const TextScaler.linear(1),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        'Prakruti Assessment',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const AssessmentStepBadge(
                      step: 1,
                      totalSteps: 4,
                      backgroundColor: Color(0xFFF6F6F6),
                      activeColor: AppColors.primary,
                      inactiveColor: Color(0xFFD8D8D8),
                      textColor: Color(0xFF757575),
                      borderColor: Color(0xFFE7E7E7),
                    ),
                  ],
                ),
                const Spacer(),
                Center(
                  child: Image.asset(
                    'assets/face_scan.jpg',
                    width: 252,
                    height: 252,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 38),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Begin Your Prakruti Analysis',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F6B2A),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Discover your unique Ayurvedic constitution\nthrough a guided assessment',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF58715C),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Center(child: _AssessmentPoint(text: 'AI-powered facial scan')),
                const SizedBox(height: 12),
                const Center(child: _AssessmentPoint(text: 'Lifestyle questionnaire')),
                const SizedBox(height: 12),
                const Center(child: _AssessmentPoint(text: 'Personalized dosha report')),
                const SizedBox(height: 26),
                const Center(child: _AssessmentPager()),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Step 1 of 4',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF62706A),
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const FaceScanScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Start Scan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    'Your data is private and secure',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF1C1C1C),
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

class _AssessmentPoint extends StatelessWidget {
  const _AssessmentPoint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: Color(0xFF5D8464),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 11),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF59715B),
          ),
        ),
      ],
    );
  }
}

class _AssessmentPager extends StatelessWidget {
  const _AssessmentPager();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 6),
        _pagerDot(),
        const SizedBox(width: 6),
        _pagerDot(),
        const SizedBox(width: 6),
        _pagerDot(),
      ],
    );
  }

  Widget _pagerDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFFD7D9D5),
        shape: BoxShape.circle,
      ),
    );
  }
}
