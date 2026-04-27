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
      id: 'digestion',
      question: 'How is your digestion usually?',
      options: const [
        QuestionOption(
          label: 'Very strong, can eat anything',
          scores: {Dosha.pitta: 3, Dosha.vata: 1},
        ),
        QuestionOption(
          label: 'Sharp and quick, gets hungry often',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Slow but steady',
          scores: {Dosha.kapha: 3},
        ),
        QuestionOption(
          label: 'Irregular and sensitive',
          scores: {Dosha.vata: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'energy',
      question: 'Which energy pattern feels most like you?',
      options: const [
        QuestionOption(
          label: 'Bursts of energy, then I need rest',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Strong, focused, and competitive',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Calm, stable, and consistent',
          scores: {Dosha.kapha: 3},
        ),
        QuestionOption(
          label: 'It changes a lot depending on stress',
          scores: {Dosha.vata: 2, Dosha.pitta: 1},
        ),
      ],
    ),
    QuestionModel(
      id: 'climate',
      question: 'Which climate affects you the most?',
      options: const [
        QuestionOption(
          label: 'Cold, windy weather throws me off balance',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Heat makes me irritable or drained',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Damp and cold makes me feel heavy',
          scores: {Dosha.kapha: 3},
        ),
        QuestionOption(
          label: 'I adapt well to most climates',
          scores: {Dosha.kapha: 1, Dosha.pitta: 1, Dosha.vata: 1},
        ),
      ],
    ),
    QuestionModel(
      id: 'mind',
      question: 'How would you describe your mind in daily life?',
      options: const [
        QuestionOption(
          label: 'Creative, fast, and full of ideas',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Driven, sharp, and decisive',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Patient, grounded, and thoughtful',
          scores: {Dosha.kapha: 3},
        ),
        QuestionOption(
          label: 'Focused but can become overwhelmed quickly',
          scores: {Dosha.vata: 1, Dosha.pitta: 2},
        ),
      ],
    ),
    QuestionModel(
      id: 'sleep',
      question: 'What does your sleep usually feel like?',
      options: const [
        QuestionOption(
          label: 'Light sleep and easy to wake up',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Moderate sleep, but I wake if overheated',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Deep, long, and hard to interrupt',
          scores: {Dosha.kapha: 3},
        ),
        QuestionOption(
          label: 'Unpredictable depending on stress or routine',
          scores: {Dosha.vata: 2, Dosha.kapha: 1},
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
