import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_snackbar.dart';
import '../core/theme.dart';
import '../models/question_model.dart';
import '../providers/auth_provider.dart';
import '../providers/face_feature_provider.dart';
import '../providers/question_provider.dart';
import '../services/ml_service.dart';
import 'dashboard_screen.dart';
import 'processing_screen.dart';
import 'widgets/assessment_step_badge.dart';

class QuestionnaireScreen extends ConsumerStatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  ConsumerState<QuestionnaireScreen> createState() =>
      _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends ConsumerState<QuestionnaireScreen> {
  bool _isSaving = false;

  // ---------------------------------------------------------------------------
  // Face feature question index → API feature key mapping
  // Order matches face_feature_provider.dart _questions list exactly
  // ---------------------------------------------------------------------------
  static const _faceFeatureKeys = [
    'Eyes_Colour', // index 0
    'Lips_Texture', // index 1
    'Lips_Thickness', // index 2
    'Lips_Color', // index 3
    'Face_Color', // index 4
    'Face_Texture', // index 5
    'Skin_Color', // index 6
    'Hair_Color', // index 7
    'Hair_Texture', // index 8
    'Forehead_Size', // index 9
  ];

  // Lifestyle question index → API feature key mapping
  // Order matches question_provider.dart _questions list exactly
  static const _lifestyleFeatureKeys = [
    'Appetite', // index 0
    'Meal_Skip_Response', // index 1
    'Stool_Consistency', // index 2
    'Sleep', // index 3
    'Work_Capacity', // index 4
    'Excitement_Response', // index 5
    'Working_Style', // index 6
    'Body_Movements', // index 7
    'Strength', // index 8
    'Problem_Handling', // index 9
    'Control_on_Desires', // index 10
    'Concentration', // index 11
    'Grasping_Power', // index 12
    'Storage', // index 13
    'Memory', // index 14
    // index 15 is body_frame — not in API, ignored
  ];

  /// Builds the ordered 25-integer feature list from face + lifestyle answers.
  /// Face features come first (10), then lifestyle (15 used from 16).
  List<int> _buildFeatureList({
    required Map<int, int> faceAnswers,
    required Map<int, int> lifestyleAnswers,
  }) {
    final features = <int>[];

    // 10 face feature answers (option index = 0/1/2 = Vata/Pitta/Kapha)
    for (var i = 0; i < _faceFeatureKeys.length; i++) {
      features.add(faceAnswers[i] ?? 1); // default to 1 (Pitta) if missing
    }

    // 15 lifestyle answers (skip index 15 = body_frame, not in API)
    for (var i = 0; i < _lifestyleFeatureKeys.length; i++) {
      features.add(lifestyleAnswers[i] ?? 1);
    }

    return features; // length = 25
  }

  Future<void> _handleNext(QuestionnaireState state) async {
    final controller = ref.read(questionnaireProvider.notifier);
    final hasSelection = state.selectedOptionIndex != null;

    if (!hasSelection) {
      showAppSnackBar(
        context,
        message: 'Please select an option to continue.',
        tone: AppSnackBarTone.warning,
      );
      return;
    }

    if (!state.isLastQuestion) {
      controller.nextQuestion();
      return;
    }

    setState(() => _isSaving = true);
    try {
      final faceFeatureAnswers = ref.read(faceFeatureProvider).selectedAnswers;

      // ── Original rule-based result (kept for backward compatibility) ──────
      final result = controller.calculateResult(
        faceFeatureAnswers: faceFeatureAnswers,
      );

      // ── ML API prediction (new) ───────────────────────────────────────────
      PrakritiMLResult? mlResult;
      try {
        final features = _buildFeatureList(
          faceAnswers: faceFeatureAnswers,
          lifestyleAnswers: state.selectedAnswers,
        );
        mlResult = await MLService.instance.predict(features);
        debugPrint(
          '✅ ML Result: ${mlResult?.predictedPrakriti} | Confidence: ${mlResult?.confidence}',
        );
      } catch (mlError) {
        debugPrint('❌ ML API failed: $mlError');
      }

      // ── Build enriched result ─────────────────────────────────────────────
      // If ML prediction succeeded, use it as the primary prakriti label.
      // The rule-based scores are kept for the result screen charts.
      final enrichedResult =
          mlResult != null
              ? PrakritiAssessmentResult(
                vataScore: result.vataScore,
                pittaScore: result.pittaScore,
                kaphaScore: result.kaphaScore,
                finalPrakriti: mlResult.predictedPrakriti,
                mlConfidence: mlResult.confidence,
                mlAllScores:
                    mlResult.allScores
                        .map(
                          (s) => DoshaMLScore(dosha: s.dosha, score: s.score),
                        )
                        .toList(),
                createdAt: DateTime.now(),
              )
              : result;

      // ── Save and navigate ─────────────────────────────────────────────────
      final userId = ref.read(authControllerProvider).session?.user.id;
      if (userId != null) {
        await ref
            .read(resultServiceProvider)
            .saveResult(userId: userId, result: enrichedResult);
        ref.invalidate(dashboardResultsProvider);
      }

      if (!mounted) return;

      controller.reset();
      ref.read(faceFeatureProvider.notifier).reset();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ProcessingScreen(result: enrichedResult),
        ),
      );
    } catch (error) {
      showAppSnackBar(
        context,
        message: error.toString(),
        tone: AppSnackBarTone.error,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questionnaireProvider);
    final question = state.currentQuestion;
    final screenWidth = MediaQuery.of(context).size.width;
    final lifestyleCount = state.questions.length;
    final lifestyleIndex = state.currentIndex;
    final progress = state.progress;
    final completedPercent = (progress * 100).round();
    final remaining = lifestyleCount - lifestyleIndex - 1;

    return Scaffold(
      backgroundColor: Colors.white,
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
                      onPressed: () {
                        if (state.isFirstQuestion) {
                          Navigator.of(context).pop();
                        } else {
                          ref
                              .read(questionnaireProvider.notifier)
                              .previousQuestion();
                        }
                      },
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'Lifestyle Questions',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const AssessmentStepBadge(
                      step: 4,
                      totalSteps: 4,
                      backgroundColor: Color(0xFFF6F6F6),
                      activeColor: AppColors.primary,
                      inactiveColor: Color(0xFFD8D8D8),
                      textColor: Color(0xFF757575),
                      borderColor: Color(0xFFE7E7E7),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 220),
                        builder: (context, value, child) {
                          return LinearProgressIndicator(
                            value: value,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFECECEC),
                            color: AppColors.primary,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '$completedPercent% complete',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
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
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  'Question ${lifestyleIndex + 1} of $lifestyleCount',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  question.question,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: question.options.length,
                  separatorBuilder:
                      (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final option = question.options[index];
                    final isSelected = state.selectedOptionIndex == index;
                    return _QuestionOptionCard(
                      option: option,
                      isSelected: isSelected,
                      onTap: () {
                        ref
                            .read(questionnaireProvider.notifier)
                            .selectOption(index);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: SizedBox(
                  width: screenWidth * 0.88,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () => _handleNext(state),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(300, 56),
                      backgroundColor:
                          state.selectedOptionIndex == null
                              ? AppColors.surfaceMuted
                              : AppColors.primary,
                      foregroundColor:
                          state.selectedOptionIndex == null
                              ? AppColors.textSecondary
                              : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child:
                        _isSaving
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                            : Text(
                              state.isLastQuestion ? 'See Result' : 'Next',
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

class _QuestionOptionCard extends StatelessWidget {
  const _QuestionOptionCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final QuestionOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFFE9F8E6) : AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option.label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
