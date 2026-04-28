import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/question_model.dart';

class ShareReportScreen extends StatelessWidget {
  const ShareReportScreen({
    required this.result,
    super.key,
  });

  final PrakritiAssessmentResult result;

  @override
  Widget build(BuildContext context) {
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
                          'Share Report',
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Export or share your Prakruti analysis',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF666666),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Report Preview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF656565),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFE7ECE4)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Your Prakruti Analysis',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF555555),
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${result.finalPrakriti} Dominant',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: 136,
                      height: 136,
                      child: CustomPaint(
                        painter: _ShareReportChartPainter(result),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_dominantPercent(result).round()}%',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              Text(
                                result.finalPrakriti,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: const Color(0xFF6B6B6B),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _ShareLegendRow(
                      color: AppColors.secondary,
                      label: 'Pitta',
                      value: '${result.pittaPercent.round()}%',
                    ),
                    const SizedBox(height: 14),
                    _ShareLegendRow(
                      color: AppColors.tertiary,
                      label: 'Vata',
                      value: '${result.vataPercent.round()}%',
                    ),
                    const SizedBox(height: 14),
                    _ShareLegendRow(
                      color: AppColors.kapha,
                      label: 'Kapha',
                      value: '${result.kaphaPercent.round()}%',
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFFE7E7E7)),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: Color(0xFF9C8D8D),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Assessed on ${_formatDate(completedAt)}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF8B8B8B),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PDF export will be added next.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text(
                    'Download PDF',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 56),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Share Options',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF656565),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFE7ECE4)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _ShareOptionRow(
                      backgroundColor: const Color(0xFFE8FAE1),
                      icon: Icons.chat_outlined,
                      title: 'Share via WhatsApp',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('WhatsApp sharing will be added next.'),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFFE9ECE5)),
                    _ShareOptionRow(
                      backgroundColor: const Color(0xFFF2F2F2),
                      icon: Icons.share_outlined,
                      title: 'Share via Other Apps',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('System share will be added next.'),
                          ),
                        );
                      },
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

  static String _formatDate(DateTime date) {
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

class _ShareOptionRow extends StatelessWidget {
  const _ShareOptionRow({
    required this.backgroundColor,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final Color backgroundColor;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF2A2A2A)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _ShareLegendRow extends StatelessWidget {
  const _ShareLegendRow({
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
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF3E3E3E),
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF3E3E3E),
              ),
        ),
      ],
    );
  }
}

class _ShareReportChartPainter extends CustomPainter {
  const _ShareReportChartPainter(this.result);

  final PrakritiAssessmentResult result;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
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
  bool shouldRepaint(covariant _ShareReportChartPainter oldDelegate) {
    return oldDelegate.result != result;
  }
}
