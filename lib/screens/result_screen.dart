import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/question_model.dart';
import 'history_screen.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    required this.result,
    super.key,
  });

  final PrakritiAssessmentResult result;

  static const Map<String, String> _suggestions = {
    'Vata':
        'Favor warmth, regular meals, grounding routines, and calming rest to balance light and mobile Vata energy.',
    'Pitta':
        'Support your fire with cooling foods, mindful pauses, hydration, and non-competitive movement.',
    'Kapha':
        'Keep energy moving with light meals, stimulating exercise, early rising, and variety in your routine.',
  };

  @override
  Widget build(BuildContext context) {
    final dominant = result.finalPrakriti;
    final insight = _suggestions[dominant] ??
        'Maintain a balanced daily routine and choose foods and activities that keep your energy steady.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Result'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 44,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '$dominant Dominant',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Your constitution is primarily influenced by the $dominant dosha.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: 240,
                height: 240,
                child: CustomPaint(
                  painter: _PrakritiChartPainter(result),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_dominantPercent(result).round()}%',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          dominant,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
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
              const SizedBox(height: AppSpacing.xl),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Prakriti Insight',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        insight,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (_) => const HomeScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text('Back to Home'),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const HistoryScreen(),
                    ),
                  );
                },
                child: const Text('View History'),
              ),
            ],
          ),
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
        const SizedBox(width: AppSpacing.xs),
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
    const strokeWidth = 18.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (math.min(size.width, size.height) / 2) - strokeWidth;

    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = AppColors.border;

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
        ..strokeCap = StrokeCap.round
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
