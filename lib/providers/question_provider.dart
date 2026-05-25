import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/question_model.dart';

final questionnaireProvider =
    StateNotifierProvider<QuestionnaireController, QuestionnaireState>((ref) {
  return QuestionnaireController();
});

class QuestionnaireState {
  const QuestionnaireState({
    required this.questions,
    required this.selectedAnswers,
    required this.currentIndex,
  });

  final List<QuestionModel> questions;
  final Map<int, int> selectedAnswers;
  final int currentIndex;

  QuestionModel get currentQuestion => questions[currentIndex];
  bool get isFirstQuestion => currentIndex == 0;
  bool get isLastQuestion => currentIndex == questions.length - 1;
  int? get selectedOptionIndex => selectedAnswers[currentIndex];
  double get progress => (currentIndex + 1) / questions.length;

  QuestionnaireState copyWith({
    List<QuestionModel>? questions,
    Map<int, int>? selectedAnswers,
    int? currentIndex,
  }) {
    return QuestionnaireState(
      questions: questions ?? this.questions,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class QuestionnaireController extends StateNotifier<QuestionnaireState> {
  QuestionnaireController()
      : super(
          QuestionnaireState(
            questions: _questions,
            selectedAnswers: const {},
            currentIndex: 0,
          ),
        );

  static final List<QuestionModel> _questions = [
    QuestionModel(
      id: 'sleep_pattern',
      question: 'How would you describe your sleep?',
      options: const [
        QuestionOption(
          label: 'Interrupted, less than 6 hours',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Usually 6 to 8 hours',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'More than 8 hours and sound sleep',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'sleep_duration',
      question: 'How long does your sleep usually feel overall?',
      options: const [
        QuestionOption(
          label: 'Less',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Medium',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'More',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'excitement',
      question: 'When you get excited, what is your natural pattern?',
      options: const [
        QuestionOption(
          label: 'Quick excitement, but it cools down quickly',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Quick excitement, but slow cooling',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Excitement is rare',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'working_style',
      question: 'How do you usually work?',
      options: const [
        QuestionOption(
          label: 'Quick',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Medium pace',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Slow',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'other_movements',
      question: 'How would you describe your other body movements or habits?',
      options: const [
        QuestionOption(
          label: 'Fast and unnecessary',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Moderate',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Slow and steady',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'strength',
      question: 'How is your strength usually?',
      options: const [
        QuestionOption(
          label: 'Less, I fatigue easily',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Moderate',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Good',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'problem_handling',
      question: 'How do you usually handle problems?',
      options: const [
        QuestionOption(
          label: 'I tend to worry',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'I become irritable or angry',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'I stay calm and stable',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'control_on_desires',
      question: 'How much control do you usually have over your desires?',
      options: const [
        QuestionOption(
          label: 'Poor control',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Moderate control',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Good control',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'concentration',
      question: 'How is your concentration usually?',
      options: const [
        QuestionOption(
          label: 'Poor',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Good when I am interested',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Excellent',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'grasping',
      question: 'How quickly do you grasp or understand things?',
      options: const [
        QuestionOption(
          label: 'Quick, but poor',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Quick and good',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Slow',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'storage',
      question: 'How well do you store or retain information?',
      options: const [
        QuestionOption(
          label: 'Poor',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Average',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Good',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'memory',
      question: 'How would you describe your memory?',
      options: const [
        QuestionOption(
          label: 'Less',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Average',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Good',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
  ];

  void selectOption(int optionIndex) {
    final updated = Map<int, int>.from(state.selectedAnswers)
      ..[state.currentIndex] = optionIndex;
    state = state.copyWith(selectedAnswers: updated);
  }

  void nextQuestion() {
    if (state.selectedOptionIndex == null || state.isLastQuestion) {
      return;
    }

    state = state.copyWith(currentIndex: state.currentIndex + 1);
  }

  void previousQuestion() {
    if (state.isFirstQuestion) {
      return;
    }

    state = state.copyWith(currentIndex: state.currentIndex - 1);
  }

  void reset() {
    state = QuestionnaireState(
      questions: _questions,
      selectedAnswers: const {},
      currentIndex: 0,
    );
  }

  PrakritiAssessmentResult calculateResult() {
    var vataScore = 0;
    var pittaScore = 0;
    var kaphaScore = 0;

    for (var index = 0; index < state.questions.length; index++) {
      final selectedIndex = state.selectedAnswers[index];
      if (selectedIndex == null) {
        continue;
      }

      final option = state.questions[index].options[selectedIndex];
      vataScore += option.scores[Dosha.vata] ?? 0;
      pittaScore += option.scores[Dosha.pitta] ?? 0;
      kaphaScore += option.scores[Dosha.kapha] ?? 0;
    }

    final resultMap = {
      Dosha.vata: vataScore,
      Dosha.pitta: pittaScore,
      Dosha.kapha: kaphaScore,
    };

    final dominant = resultMap.entries.reduce(
      (current, next) => current.value >= next.value ? current : next,
    );

    return PrakritiAssessmentResult(
      vataScore: vataScore,
      pittaScore: pittaScore,
      kaphaScore: kaphaScore,
      finalPrakriti: dominant.key.label,
      createdAt: DateTime.now(),
    );
  }
}
