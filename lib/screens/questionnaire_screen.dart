import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../models/question_model.dart';
import '../providers/auth_provider.dart';
import '../providers/question_provider.dart';
import 'dashboard_screen.dart';
import 'processing_screen.dart';

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
      final result = controller.calculateResult();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lifestyle Questions'),
        leading: IconButton(
          onPressed: () {
            if (state.isFirstQuestion) {
              Navigator.of(context).pop();
            } else {
              ref.read(questionnaireProvider.notifier).previousQuestion();
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(14),
          child: LinearProgressIndicator(
            value: state.progress,
            minHeight: 3,
            backgroundColor: AppColors.border,
            color: AppColors.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question ${state.currentIndex + 1} of ${state.questions.length}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                question.question,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: ListView.separated(
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
