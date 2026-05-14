import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/theme.dart';
import '../models/question_model.dart';

class ShareReportScreen extends StatefulWidget {
  const ShareReportScreen({
    required this.result,
    super.key,
  });

  final PrakritiAssessmentResult result;

  @override
  State<ShareReportScreen> createState() => _ShareReportScreenState();
}

class _ShareReportScreenState extends State<ShareReportScreen> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
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
                  onPressed: _isExporting ? null : _downloadPdf,
                  icon:
                      _isExporting
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.download_rounded),
                  label: Text(
                    _isExporting ? 'Preparing PDF...' : 'Download PDF',
                    style: const TextStyle(fontSize: 16),
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

  String _formatDate(DateTime date) {
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

  Future<void> _downloadPdf() async {
    setState(() => _isExporting = true);
    try {
      final file = await _buildPdfFile(widget.result);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('PDF saved to ${file.path}')),
        );
      await OpenFilex.open(file.path);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Unable to generate PDF: $error')),
        );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<File> _buildPdfFile(PrakritiAssessmentResult result) async {
    final document = pw.Document();
    final completedAt = result.createdAt ?? DateTime.now();
    final accent = PdfColor.fromInt(AppColors.primary.value);
    final dominantPercent = _dominantPercent(result).round();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build:
            (_) => [
              pw.Text(
                'IPrakriti Assessment Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: accent,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Generated on ${_formatDate(completedAt)}',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Container(
                padding: const pw.EdgeInsets.all(18),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(18),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${result.finalPrakriti} Dominant',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      '$dominantPercent% of your assessment pattern aligns most strongly with ${result.finalPrakriti}.',
                      style: const pw.TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 22),
              _pdfScoreTable(result),
              pw.SizedBox(height: 22),
              pw.Text(
                'Summary',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: accent,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                _summaryFor(result.finalPrakriti),
                style: const pw.TextStyle(fontSize: 13),
              ),
              pw.SizedBox(height: 22),
              pw.Text(
                'Next step',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: accent,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Review the detailed report in the app for your dosha breakdown, lifestyle guidance, and wellness recommendations.',
                style: const pw.TextStyle(fontSize: 13),
              ),
            ],
      ),
    );

    final bytes = await document.save();
    final safeName = result.finalPrakriti.toLowerCase();
    final preferredDirectory = await _resolvePdfDirectory();
    final preferredFile = File(
      '${preferredDirectory.path}${Platform.pathSeparator}iprakriti_${safeName}_report.pdf',
    );

    try {
      await preferredFile.writeAsBytes(bytes, flush: true);
      return preferredFile;
    } catch (_) {
      final fallbackDirectory = await getApplicationDocumentsDirectory();
      final fallbackFile = File(
        '${fallbackDirectory.path}${Platform.pathSeparator}iprakriti_${safeName}_report.pdf',
      );
      await fallbackFile.writeAsBytes(bytes, flush: true);
      return fallbackFile;
    }
  }

  Future<Directory> _resolvePdfDirectory() async {
    if (Platform.isAndroid) {
      final downloads = Directory('/storage/emulated/0/Download');
      if (await downloads.exists()) {
        return downloads;
      }

      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        return externalDir;
      }
    }

    return getApplicationDocumentsDirectory();
  }

  pw.Widget _pdfScoreTable(PrakritiAssessmentResult result) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        _pdfRow(
          isHeader: true,
          cells: const ['Dosha', 'Percent', 'Score'],
        ),
        _pdfRow(
          cells: [
            'Vata',
            '${result.vataPercent.round()}%',
            result.vataScore.toString(),
          ],
        ),
        _pdfRow(
          cells: [
            'Pitta',
            '${result.pittaPercent.round()}%',
            result.pittaScore.toString(),
          ],
        ),
        _pdfRow(
          cells: [
            'Kapha',
            '${result.kaphaPercent.round()}%',
            result.kaphaScore.toString(),
          ],
        ),
      ],
    );
  }

  pw.TableRow _pdfRow({
    required List<String> cells,
    bool isHeader = false,
  }) {
    return pw.TableRow(
      decoration:
          isHeader
              ? const pw.BoxDecoration(color: PdfColors.grey200)
              : null,
      children:
          cells
              .map(
                (cell) => pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Text(
                    cell,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  String _summaryFor(String dominant) {
    switch (dominant) {
      case 'Pitta':
        return 'Your results suggest a strong Pitta influence, often associated with focus, drive, and metabolic strength. Balanced routines and cooling habits can help keep that intensity steady.';
      case 'Vata':
        return 'Your results suggest a strong Vata influence, often associated with creativity, speed, and adaptability. Grounding routines and regular nourishment can help keep that energy balanced.';
      case 'Kapha':
        return 'Your results suggest a strong Kapha influence, often associated with steadiness, endurance, and calm. Light movement and energizing habits can help maintain balance.';
      default:
        return 'Your assessment highlights the dominant dosha pattern identified during this session.';
    }
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
