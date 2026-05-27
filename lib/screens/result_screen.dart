import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/question_model.dart';
import 'detailed_report_screen.dart';
import 'dashboard_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    required this.result,
    super.key,
  });

  final PrakritiAssessmentResult result;

  static const Map<String, String> _suggestions = {
    'Vata':
        'As a Vata-dominant individual, you are guided by movement, creativity, and sensitivity. You often think quickly, adapt fast, and bring originality into the way you work and relate to others.\n\nYou tend to feel best with warmth, rhythm, nourishment, and enough rest to balance your naturally light and changeable energy. Grounding routines can help your strongest qualities stay clear and sustainable.',
    'Pitta':
        'As a Pitta-dominant individual, you are shaped by focus, drive, and transformative energy. You often bring clarity, leadership, and strong decision-making to the people and goals around you.\n\nYou tend to thrive when intensity is balanced with cooling habits, steady meals, and moments of pause. When that balance is in place, your confidence and discipline become powerful assets without tipping into overexertion.',
    'Kapha':
        'As a Kapha-dominant individual, you are supported by steadiness, resilience, and emotional calm. You often offer patience, loyalty, and dependable energy, making you a stabilizing presence for yourself and others.\n\nYou tend to feel brightest when daily life includes movement, stimulation, and variety. Lightness in routine helps your natural strength stay energized rather than heavy or stagnant.',
  };

  static const Map<String, List<String>> _characteristics = {
    'Vata': [
      'Creative, curious, and quick to respond',
      'Expressive energy with a fast-moving mind',
      'Benefits from grounding, warmth, and consistency',
    ],
    'Pitta': [
      'Strong focus, motivation, and follow-through',
      'Sharp digestion and decisive leadership energy',
      'Benefits from cooling habits and balanced intensity',
    ],
    'Kapha': [
      'Steady endurance and dependable energy',
      'Calm, loyal, and naturally supportive nature',
      'Benefits from stimulation, movement, and lightness',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final dominant = result.finalPrakriti;
    final insight = _suggestions[dominant] ??
        'Your prakruti shows a meaningful blend of strengths. Support it with consistent routines, balanced nourishment, and habits that keep your energy steady and clear.';
    final characteristics = _characteristics[dominant] ??
        const [
          'A mixed constitution with complementary strengths',
          'Responsive to steady routine and mindful nourishment',
          'Benefits from habits that maintain balance across energy types',
        ];

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(30, 26, 30, 28),
          child: Column(
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: const BoxDecoration(
                  color: Color(0xFF82E869),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                '$dominant Dominant',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                _headlineDescription(dominant),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF4A4A4A),
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 250,
                height: 250,
                child: CustomPaint(
                  painter: _PrakritiChartPainter(result),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_dominantPercent(result).round()}%',
                          style:
                              Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        Text(
                          dominant,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: const Color(0xFF676767),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _LegendItem(
                    color: AppColors.secondary,
                    label: 'Pitta',
                    value: '${result.pittaPercent.round()}%',
                  ),
                  _LegendItem(
                    color: AppColors.tertiary,
                    label: 'Vata',
                    value: '${result.vataPercent.round()}%',
                  ),
                  _LegendItem(
                    color: AppColors.kapha,
                    label: 'Kapha',
                    value: '${result.kaphaPercent.round()}%',
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _ResultSectionCard(
                title: 'Your Prakruti Insight',
                child: Text(
                  insight,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF2E2E2E),
                        height: 1.58,
                      ),
                ),
              ),
              const SizedBox(height: 22),
              _ResultSectionCard(
                title: 'Key Characteristics',
                tinted: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < characteristics.length; i++) ...[
                      _CharacteristicRow(text: characteristics[i]),
                      if (i != characteristics.length - 1)
                        const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => DetailedReportScreen(result: result),
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
                    'View Detailed Report',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (_) => const DashboardScreen(initialIndex: 0),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    color: Color(0xFF9DA787),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _headlineDescription(String dominant) {
    switch (dominant) {
      case 'Pitta':
        return 'Your constitution is primarily influenced by the Pitta dosha, representing fire & water';
      case 'Vata':
        return 'Your constitution is primarily influenced by the Vata dosha, representing air & space';
      case 'Kapha':
        return 'Your constitution is primarily influenced by the Kapha dosha, representing earth & water';
      default:
        return 'Your constitution is primarily influenced by the $dominant dosha.';
    }
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
}

class _ResultSectionCard extends StatelessWidget {
  const _ResultSectionCard({
    required this.title,
    required this.child,
    this.tinted = false,
  });

  final String title;
  final Widget child;
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: tinted ? const Color(0xFFF3F8EC) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: tinted ? const Color(0xFFD6E3C9) : const Color(0xFFECEEE7),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _CharacteristicRow extends StatelessWidget {
  const _CharacteristicRow({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            '•',
            style: TextStyle(fontSize: 18, color: Colors.black87),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF2F2F2F),
                ),
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
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
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

class _PrakritiChartPainter extends CustomPainter {
  const _PrakritiChartPainter(this.result);

  final PrakritiAssessmentResult result;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 16.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (math.min(size.width, size.height) / 2) - strokeWidth;

    final backgroundPaint = Paint()
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
      final paint = Paint()
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
  bool shouldRepaint(covariant _PrakritiChartPainter oldDelegate) {
    return oldDelegate.result != result;
  }
}
