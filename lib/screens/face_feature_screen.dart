import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../models/question_model.dart';
import '../providers/face_feature_provider.dart';
import 'questionnaire_screen.dart';
import 'widgets/assessment_step_badge.dart';

class FaceFeatureScreen extends ConsumerStatefulWidget {
  const FaceFeatureScreen({super.key});

  @override
  ConsumerState<FaceFeatureScreen> createState() => _FaceFeatureScreenState();
}

class _FaceFeatureScreenState extends ConsumerState<FaceFeatureScreen> {
  void _goBack() {
    final controller = ref.read(faceFeatureProvider.notifier);
    final state = ref.read(faceFeatureProvider);

    if (state.isFirstQuestion) {
      Navigator.of(context).pop();
      return;
    }

    controller.previousQuestion();
  }

  void _goNext(FaceFeatureState state) {
    final controller = ref.read(faceFeatureProvider.notifier);
    final selectedOption = state.selectedOptionIndex;
    if (selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose one option to continue.')),
      );
      return;
    }

    if (!state.isLastQuestion) {
      controller.nextQuestion();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const QuestionnaireScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(faceFeatureProvider);
    final question = state.currentQuestion;
    final selectedOptionIndex = state.selectedOptionIndex;
    final totalQuestions = state.questions.length;
    final progress = state.progress;
    final remaining = totalQuestions - state.currentIndex - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _goBack,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'Face Features',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const AssessmentStepBadge(
                      step: 3,
                      totalSteps: 4,
                      backgroundColor: Color(0xFFFFFBF1),
                      activeColor: AppColors.primary,
                      inactiveColor: Color(0xFFE2DCCA),
                      textColor: Color(0xFF7B715C),
                      borderColor: Color(0xFFE9DFC9),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFDF7EA), Color(0xFFF5E7C8)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFE8D8B3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFE7DECA),
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Text(
                            'Face question ${state.currentIndex + 1} of $totalQuestions',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            '$remaining remaining',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Pick the closest visual match',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'These choices help us capture appearance-based traits before the lifestyle questionnaire.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  question.question,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: question.options.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, optionIndex) {
                    final option = question.options[optionIndex];
                    return _FeatureOptionCard(
                      isSelected: selectedOptionIndex == optionIndex,
                      option: option,
                      questionId: question.id,
                      optionIndex: optionIndex,
                      onTap: () {
                        ref
                            .read(faceFeatureProvider.notifier)
                            .selectOption(optionIndex);
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _goNext(state),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedOptionIndex == null
                          ? const Color(0xFFD5CFBF)
                          : AppColors.primary,
                      foregroundColor: selectedOptionIndex == null
                          ? AppColors.textSecondary
                          : Colors.white,
                    ),
                    child: Text(
                      state.isLastQuestion
                          ? 'Continue to Questionnaire'
                          : 'Next',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureOptionCard extends StatelessWidget {
  const _FeatureOptionCard({
    required this.isSelected,
    required this.option,
    required this.questionId,
    required this.optionIndex,
    required this.onTap,
  });

  final bool isSelected;
  final QuestionOption option;
  final String questionId;
  final int optionIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFFCF4) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : const Color(0xFFE7DFCF),
              width: isSelected ? 1.8 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _FeatureVisualChip(
                questionId: questionId,
                optionIndex: optionIndex,
                isSelected: isSelected,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  option.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFC9C2B4),
                    width: 1.6,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureVisualChip extends StatelessWidget {
  const _FeatureVisualChip({
    required this.questionId,
    required this.optionIndex,
    required this.isSelected,
  });

  final String questionId;
  final int optionIndex;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final spec = _featureVisuals[questionId]![optionIndex];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 84,
      height: 72,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: spec.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.65),
        ),
      ),
      child: Center(
        child: _FeatureSwatch(spec: spec),
      ),
    );
  }
}

class _FeatureSwatch extends StatelessWidget {
  const _FeatureSwatch({required this.spec});

  final _FeatureVisualSpec spec;

  @override
  Widget build(BuildContext context) {
    switch (spec.type) {
      case _FeatureVisualType.color:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: spec.colors
              .map(
                (color) => Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      case _FeatureVisualType.texture:
        return CustomPaint(
          size: const Size(52, 36),
          painter: _TexturePainter(
            lineColor: spec.colors.first,
            accentColor: spec.colors.length > 1
                ? spec.colors[1]
                : spec.colors.first.withValues(alpha: 0.55),
            mode: spec.textureMode,
          ),
        );
      case _FeatureVisualType.lip:
        return CustomPaint(
          size: const Size(54, 30),
          painter: _LipPainter(
            color: spec.colors.first,
            thickness: spec.thickness,
          ),
        );
      case _FeatureVisualType.forehead:
        return CustomPaint(
          size: const Size(48, 36),
          painter: _ForeheadPainter(
            lineColor: spec.colors.first,
            widthFactor: spec.sizeFactor,
          ),
        );
    }
  }
}

class _TexturePainter extends CustomPainter {
  const _TexturePainter({
    required this.lineColor,
    required this.accentColor,
    required this.mode,
  });

  final Color lineColor;
  final Color accentColor;
  final _TextureMode mode;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..color = accentColor.withValues(alpha: 0.18);
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = mode == _TextureMode.glossy ? 3.4 : 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final base = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(14),
    );
    canvas.drawRRect(base, fillPaint);

    if (mode == _TextureMode.rough) {
      for (var i = 0; i < 4; i++) {
        final y = 8 + (i * 7.0);
        final path = Path()
          ..moveTo(6, y)
          ..lineTo(18, y - 3)
          ..lineTo(30, y + 3)
          ..lineTo(46, y - 2);
        canvas.drawPath(path, linePaint);
      }
      return;
    }

    if (mode == _TextureMode.soft) {
      for (var i = 0; i < 3; i++) {
        final top = 7 + (i * 9.0);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(8, top, 36, 5),
            const Radius.circular(99),
          ),
          Paint()..color = lineColor.withValues(alpha: 0.75),
        );
      }
      return;
    }

    final glossyPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.92),
          accentColor.withValues(alpha: 0.0),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(7, 6, 25, 12),
        const Radius.circular(16),
      ),
      glossyPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, 18, 34, 8),
        const Radius.circular(99),
      ),
      Paint()..color = lineColor.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant _TexturePainter oldDelegate) {
    return lineColor != oldDelegate.lineColor ||
        accentColor != oldDelegate.accentColor ||
        mode != oldDelegate.mode;
  }
}

class _LipPainter extends CustomPainter {
  const _LipPainter({required this.color, required this.thickness});

  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final topHeight = 8 + (thickness * 7);
    final bottomHeight = 9 + (thickness * 9);

    final top = Path()
      ..moveTo(4, size.height / 2)
      ..quadraticBezierTo(size.width * 0.26, 2, size.width * 0.5, topHeight)
      ..quadraticBezierTo(size.width * 0.74, 2, size.width - 4, size.height / 2)
      ..quadraticBezierTo(size.width * 0.74, topHeight + 4, size.width * 0.5, topHeight + 2)
      ..quadraticBezierTo(size.width * 0.26, topHeight + 4, 4, size.height / 2);

    final bottom = Path()
      ..moveTo(5, size.height / 2)
      ..quadraticBezierTo(size.width * 0.28, size.height - bottomHeight, size.width * 0.5, size.height - 4)
      ..quadraticBezierTo(size.width * 0.72, size.height - bottomHeight, size.width - 5, size.height / 2)
      ..quadraticBezierTo(size.width * 0.72, size.height - 6, size.width * 0.5, size.height - 8)
      ..quadraticBezierTo(size.width * 0.28, size.height - 6, 5, size.height / 2);

    canvas.drawPath(top, paint);
    canvas.drawPath(bottom, paint);
  }

  @override
  bool shouldRepaint(covariant _LipPainter oldDelegate) {
    return color != oldDelegate.color || thickness != oldDelegate.thickness;
  }
}

class _ForeheadPainter extends CustomPainter {
  const _ForeheadPainter({
    required this.lineColor,
    required this.widthFactor,
  });

  final Color lineColor;
  final double widthFactor;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = lineColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = lineColor.withValues(alpha: 0.14);

    final left = size.width * (0.5 - (widthFactor / 2));
    final right = size.width * (0.5 + (widthFactor / 2));
    final top = 6.0;
    final bottom = size.height - 7;

    final path = Path()
      ..moveTo(left, bottom)
      ..quadraticBezierTo(size.width * 0.5, top, right, bottom);

    final fillPath = Path.from(path)
      ..lineTo(right - 5, bottom)
      ..quadraticBezierTo(size.width * 0.5, top + 6, left + 5, bottom)
      ..close();

    canvas.drawPath(fillPath, fill);
    canvas.drawPath(path, stroke);
    canvas.drawLine(
      Offset(left, bottom),
      Offset(right, bottom),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _ForeheadPainter oldDelegate) {
    return lineColor != oldDelegate.lineColor ||
        widthFactor != oldDelegate.widthFactor;
  }
}

enum _FeatureVisualType { color, texture, lip, forehead }

enum _TextureMode { rough, soft, glossy }

class _FeatureVisualSpec {
  const _FeatureVisualSpec({
    required this.type,
    required this.colors,
    required this.background,
    this.textureMode = _TextureMode.soft,
    this.thickness = 0.5,
    this.sizeFactor = 0.5,
  });

  final _FeatureVisualType type;
  final List<Color> colors;
  final Gradient background;
  final _TextureMode textureMode;
  final double thickness;
  final double sizeFactor;
}

final Map<String, List<_FeatureVisualSpec>> _featureVisuals = {
  'eyes_colour': const [
    _FeatureVisualSpec(
      type: _FeatureVisualType.color,
      colors: [Color(0xFF241613), Color(0xFF3B261E), Color(0xFF5F3C2A)],
      background: LinearGradient(
        colors: [Color(0xFFEEE2D2), Color(0xFFD4BEA3)],
      ),
    ),
    _FeatureVisualSpec(
      type: _FeatureVisualType.color,
      colors: [Color(0xFF6E3728), Color(0xFF8A4A37), Color(0xFFA66146)],
      background: LinearGradient(
        colors: [Color(0xFFF3DCCB), Color(0xFFE4B7A0)],
      ),
    ),
    _FeatureVisualSpec(
      type: _FeatureVisualType.color,
      colors: [Color(0xFFF3ECE5), Color(0xFFD1B4B0), Color(0xFFC7846F)],
      background: LinearGradient(
        colors: [Color(0xFFF7F3EF), Color(0xFFE8DBD5)],
      ),
    ),
  ],
  'lips_texture': const [
    _FeatureVisualSpec(
      type: _FeatureVisualType.texture,
      colors: [Color(0xFF9C4B3B), Color(0xFFE8BEAF)],
      background: LinearGradient(
        colors: [Color(0xFFFBEEE6), Color(0xFFF1D0C0)],
      ),
      textureMode: _TextureMode.rough,
    ),
    _FeatureVisualSpec(
      type: _FeatureVisualType.texture,
      colors: [Color(0xFFC96C63), Color(0xFFF4D8D3)],
      background: LinearGradient(
        colors: [Color(0xFFFFF0EE), Color(0xFFF9DED8)],
      ),
      textureMode: _TextureMode.soft,
    ),
    _FeatureVisualSpec(
      type: _FeatureVisualType.texture,
      colors: [Color(0xFFB34D5B), Color(0xFFF0C8D4)],
      background: LinearGradient(
        colors: [Color(0xFFFFF0F5), Color(0xFFF7DBE5)],
      ),
      textureMode: _TextureMode.glossy,
    ),
  ],
  'lips_thickness': const [
    _FeatureVisualSpec(
      type: _FeatureVisualType.lip,
      colors: [Color(0xFFA95455)],
      background: LinearGradient(
        colors: [Color(0xFFFFF1EF), Color(0xFFF3D2D0)],
      ),
      thickness: 0.2,
    ),
    _FeatureVisualSpec(
      type: _FeatureVisualType.lip,
      colors: [Color(0xFFB85D67)],
      background: LinearGradient(
        colors: [Color(0xFFFFF0F2), Color(0xFFF5D5D8)],
      ),
      thickness: 0.5,
    ),
    _FeatureVisualSpec(
      type: _FeatureVisualType.lip,
      colors: [Color(0xFFB14E60)],
      background: LinearGradient(
        colors: [Color(0xFFFFEEF0), Color(0xFFF0C9D0)],
      ),
      thickness: 0.9,
    ),
  ],
  'lips_colour': const [
    _FeatureVisualSpec(
      type: _FeatureVisualType.color,
      colors: [Color(0xFF5A2D2B), Color(0xFF7C403F), Color(0xFF9E615B)],
      background: LinearGradient(
        colors: [Color(0xFFF7ECE8), Color(0xFFE7CDC4)],
      ),
    ),
    _FeatureVisualSpec(
      type: _FeatureVisualType.color,
      colors: [Color(0xFFB74252), Color(0xFFD45D6D), Color(0xFFE47D8B)],
      background: LinearGradient(
        colors: [Color(0xFFFFEEF0), Color(0xFFF5D4DA)],
      ),
    ),
    _FeatureVisualSpec(
      type: _FeatureVisualType.color,
      colors: [Color(0xFFE1A2B0), Color(0xFFF1BEC9), Color(0xFFF8D8DD)],
      background: LinearGradient(
        colors: [Color(0xFFFFF5F6), Color(0xFFFDE6EA)],
      ),
    ),
  ],
  'face_colour': const [
    _FeatureVisualSpec(
      type: _FeatureVisualType.color,
      colors: [Color(0xFF6D4B38), Color(0xFF8A6247), Color(0xFFA67B5A)],
      background: LinearGradient(
        colors: [Color(0xFFF1E0D0), Color(0xFFD7B694)],
      ),
    ),
    _FeatureVisualSpec(
      type: _FeatureVisualType.color,
      colors: [Color(0xFFB97B59), Color(0xFFD39A72), Color(0xFFEDB38A)],
      background: LinearGradient(
        colors: [Color(0xFFFBE6D4), Color(0xFFF0C7AA)],
      ),
    ),
    _FeatureVisualSpec(
      type: _FeatureVisualType.color,
      colors: [Color(0xFFD49D90), Color(0xFFE9B7AB), Color(0xFFF4D2C8)],
      background: LinearGradient(
        colors: [Color(0xFFFCEBE7), Color(0xFFF5D6CF)],
      ),
    ),
  ],
  'face_texture': const [
    _FeatureVisualSpec(
      type: _FeatureVisualType.texture,
      colors: [Color(0xFF8E725D), Color(0xFFE7D7C6)],
      background: LinearGradient(
        colors: [Color(0xFFFCF4EB), Color(0xFFF0DFC7)],
      ),
      textureMode: _TextureMode.rough,
    ),
    _FeatureVisualSpec(
      type: _FeatureVisualType.texture,
      colors: [Color(0xFFB88264), Color(0xFFF4D1B6)],
      background: LinearGradient(
        colors: [Color(0xFFFFF3E9), Color(0xFFF7DEC9)],
      ),
      textureMode: _TextureMode.soft,
    ),
    _FeatureVisualSpec(
      type: _FeatureVisualType.texture,
      colors: [Color(0xFFC28B73), Color(0xFFF7DAC4)],
      background: LinearGradient(
        colors: [Color(0xFFFFF4EC), Color(0xFFF8E2D2)],
      ),
      textureMode: _TextureMode.glossy,
    ),
  ],
  'skin_colour': const [
    _FeatureVisualSpec(
      type: _FeatureVisualType.color,
      colors: [Color(0xFF705245), Color(0xFF8C6A58), Color(0xFFAB846C)],
      background: LinearGradient(
        colors: [Color(0xFFF3E5DA), Color(0xFFD9C1AB)],
      ),
    ),
    _FeatureVisualSpec(
      type: _FeatureVisualType.color,
      colors: [Color(0xFFC49956), Color(0xFFDAB56B), Color(0xFFECC983)],
      background: LinearGradient(
        colors: [Color(0xFFFFF2D6), Color(0xFFF4DAA4)],
      ),
    ),
    _FeatureVisualSpec(
      type: _FeatureVisualType.color,
      colors: [Color(0xFFE6D3B1), Color(0xFFF1E2C6), Color(0xFFF9EFD7)],
      background: LinearGradient(
        colors: [Color(0xFFFFF8E7), Color(0xFFF6ECD0)],
      ),
    ),
  ],
  'hair_colour': const [
    _FeatureVisualSpec(
      type: _FeatureVisualType.color,
      colors: [Color(0xFF171414), Color(0xFF2A2424), Color(0xFF494040)],
      background: LinearGradient(
        colors: [Color(0xFFEBE6E3), Color(0xFFD4CAC4)],
      ),
    ),
    _FeatureVisualSpec(
      type: _FeatureVisualType.color,
      colors: [Color(0xFF7C6D60), Color(0xFF9A8471), Color(0xFFBAA08A)],
      background: LinearGradient(
        colors: [Color(0xFFF4E9E0), Color(0xFFE4D2C2)],
      ),
    ),
    _FeatureVisualSpec(
      type: _FeatureVisualType.color,
      colors: [Color(0xFF0D0B0C), Color(0xFF1D1A1B), Color(0xFF352F31)],
      background: LinearGradient(
        colors: [Color(0xFFEDE9E9), Color(0xFFD3CCCC)],
      ),
    ),
  ],
  'hair_texture': const [
    _FeatureVisualSpec(
      type: _FeatureVisualType.texture,
      colors: [Color(0xFF4C3D35), Color(0xFFD4C2B8)],
      background: LinearGradient(
        colors: [Color(0xFFF5EFEA), Color(0xFFE7DDD5)],
      ),
      textureMode: _TextureMode.rough,
    ),
    _FeatureVisualSpec(
      type: _FeatureVisualType.texture,
      colors: [Color(0xFF7B6656), Color(0xFFEADDD0)],
      background: LinearGradient(
        colors: [Color(0xFFF9F3EE), Color(0xFFF0E3D7)],
      ),
      textureMode: _TextureMode.soft,
    ),
    _FeatureVisualSpec(
      type: _FeatureVisualType.texture,
      colors: [Color(0xFF43342F), Color(0xFFE4D5CD)],
      background: LinearGradient(
        colors: [Color(0xFFF7F1ED), Color(0xFFEDE1D9)],
      ),
      textureMode: _TextureMode.glossy,
    ),
  ],
  'forehead_size': const [
    _FeatureVisualSpec(
      type: _FeatureVisualType.forehead,
      colors: [Color(0xFF8A6A5D)],
      background: LinearGradient(
        colors: [Color(0xFFF8EEE7), Color(0xFFEDDBCF)],
      ),
      sizeFactor: 0.82,
    ),
    _FeatureVisualSpec(
      type: _FeatureVisualType.forehead,
      colors: [Color(0xFF9A7560)],
      background: LinearGradient(
        colors: [Color(0xFFF9EFE8), Color(0xFFF0DFD1)],
      ),
      sizeFactor: 0.62,
    ),
    _FeatureVisualSpec(
      type: _FeatureVisualType.forehead,
      colors: [Color(0xFFA07A62)],
      background: LinearGradient(
        colors: [Color(0xFFF9F1EA), Color(0xFFF1E2D4)],
      ),
      sizeFactor: 0.42,
    ),
  ],
};
