import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../models/question_model.dart';
import '../providers/auth_provider.dart';
import '../providers/face_feature_provider.dart';
import '../providers/question_provider.dart';
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

  Future<void> _handleNext(QuestionnaireState state) async {
    final controller = ref.read(questionnaireProvider.notifier);
    final hasSelection = state.selectedOptionIndex != null;

    if (!hasSelection) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option to continue.')),
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
      final result = controller.calculateResult(
        faceFeatureAnswers: faceFeatureAnswers,
      );
      final userId = ref.read(authControllerProvider).session?.user.id;
      if (userId != null) {
        await ref.read(resultServiceProvider).saveResult(
              userId: userId,
              result: result,
            );
        ref.invalidate(dashboardResultsProvider);
      }

      if (!mounted) {
        return;
      }

      controller.reset();
      ref.read(faceFeatureProvider.notifier).reset();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ProcessingScreen(result: result),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
                          ref.read(questionnaireProvider.notifier).previousQuestion();
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const Spacer(),
                        Text(
                          '$remaining remaining',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
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
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: question.options.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
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
                      backgroundColor: state.selectedOptionIndex == null
                          ? AppColors.surfaceMuted
                          : AppColors.primary,
                      foregroundColor: state.selectedOptionIndex == null
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
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(state.isLastQuestion ? 'See Result' : 'Next'),
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
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                      ),
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
