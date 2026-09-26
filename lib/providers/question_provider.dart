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
      id: 'appetite',
      question: 'How would you describe your appetite and hunger?',
      options: const [
        QuestionOption(
          label: 'Variable and irregular, hunger comes and goes unpredictably',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Strong and sharp, I get very hungry at regular mealtimes',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Slow and low, I can skip meals comfortably',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'meal_skipped',
      question: 'What happens if you skip a meal or change your eating routine?',
      options: const [
        QuestionOption(
          label: 'I feel constipated or gassy and bloated',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'I get headaches or feel nauseated',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Mild discomfort or nothing much changes',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'stool_consistency',
      question: 'How would you describe your stool consistency usually?',
      options: const [
        QuestionOption(label: 'Hard and dry', scores: {Dosha.vata: 3}),
        QuestionOption(
          label: 'Semisolid or sometimes loose',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Well-formed and regular',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'sleep_pattern',
      question: 'How would you describe your typical sleep pattern?',
      options: const [
        QuestionOption(
          label: 'Interrupted or disturbed, usually less than 6 hours',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Moderate and regular, about 6 to 8 hours',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Deep and sound, more than 8 hours',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'work_duration',
      question: 'How much work or activity can you sustain before feeling tired?',
      options: const [
        QuestionOption(
          label: 'Less, I tire quickly and need frequent breaks',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Medium, I work well for moderate stretches',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'More, I have naturally high stamina and endurance',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'excitement_response',
      question: 'How do you respond to exciting or new situations?',
      options: const [
        QuestionOption(
          label: 'I get excited quickly and cool down just as fast',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'I get excited quickly but take time to calm down',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'I rarely get excited, I stay naturally calm',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'working_style',
      question: 'How would you describe your general working style?',
      options: const [
        QuestionOption(
          label: 'Quick, I like to act fast and move on',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Medium, I work steadily with clear focus',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Slow, I take my time and am very thorough',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'body_movements',
      question: 'How would you describe your body movements and gestures?',
      options: const [
        QuestionOption(
          label: 'Fast and sometimes restless or unnecessary',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Moderate and purposeful',
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
      question: 'How would you describe your physical strength and endurance?',
      options: const [
        QuestionOption(
          label: 'Less strength, I fatigue easily',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Moderate strength and endurance',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Good strength, I have natural physical endurance',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'problem_handling',
      question: 'How do you usually respond when you face a problem or stress?',
      options: const [
        QuestionOption(
          label: 'I tend to worry and feel anxious',
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
      question: 'How well can you control your desires and impulses?',
      options: const [
        QuestionOption(
          label: 'Poor control, I often act on impulse',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Moderate control, I manage most of the time',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Good control, I am disciplined and steady',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'concentration',
      question: 'How would you rate your ability to concentrate?',
      options: const [
        QuestionOption(
          label: 'Poor, my mind wanders frequently',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Good when I am genuinely interested in the topic',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Excellent, I can focus deeply for long periods',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'grasping_power',
      question: 'How quickly do you grasp or learn new things?',
      options: const [
        QuestionOption(
          label: 'Quick to grasp but I tend to forget easily',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Quick to grasp and my retention is good',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Slow to grasp but once I learn it stays permanently',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'storage',
      question: 'How well do you retain information over time?',
      options: const [
        QuestionOption(
          label: 'Poor, I often forget what I recently learned',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Average, I remember most important things',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Good, I have strong and reliable long-term retention',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'memory',
      question: 'How would you describe your overall memory?',
      options: const [
        QuestionOption(
          label: 'Less or forgetful, I lose track of things easily',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Average, neither particularly strong nor weak',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Good, I remember people, events, and details well',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'body_frame',
      question: 'How would you describe your natural body frame?',
      options: const [
        QuestionOption(
          label: 'Thin and light, hard to gain weight',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Medium and muscular, moderate build',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Large or stocky, gain weight easily',
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
    if (state.selectedOptionIndex == null || state.isLastQuestion) return;
    state = state.copyWith(currentIndex: state.currentIndex + 1);
  }

  void previousQuestion() {
    if (state.isFirstQuestion) return;
    state = state.copyWith(currentIndex: state.currentIndex - 1);
  }

  void reset() {
    state = QuestionnaireState(
      questions: _questions,
      selectedAnswers: const {},
      currentIndex: 0,
    );
  }

  /// Rule-based fallback result.
  /// BUG FIX: Now returns a dual-dosha label (Vata-Pitta, Pitta-Kapha,
  /// Vata-Kapha) instead of a pure dosha label, so the fallback result
  /// matches the 3 classes the ML model was trained on.
  /// This is only used when the ML API is unreachable.
  PrakritiAssessmentResult calculateResult({
    required Map<int, int> faceFeatureAnswers,
  }) {
    final faceDistribution = _distributionFromFaceAnswers(faceFeatureAnswers);
    final quizDistribution = _distributionFromQuizAnswers();

    final weightedVata = (faceDistribution[Dosha.vata] ?? 0) * 0.4 +
        (quizDistribution[Dosha.vata] ?? 0) * 0.6;
    final weightedPitta = (faceDistribution[Dosha.pitta] ?? 0) * 0.4 +
        (quizDistribution[Dosha.pitta] ?? 0) * 0.6;
    final weightedKapha = (faceDistribution[Dosha.kapha] ?? 0) * 0.4 +
        (quizDistribution[Dosha.kapha] ?? 0) * 0.6;

    final vataScore = (weightedVata * 1000).round();
    final pittaScore = (weightedPitta * 1000).round();
    final kaphaScore = (weightedKapha * 1000).round();

    // Map scores to the 3 dual-dosha classes the ML model uses.
    // Pick the two highest scoring doshas and combine them.
    final scores = {
      Dosha.vata: vataScore,
      Dosha.pitta: pittaScore,
      Dosha.kapha: kaphaScore,
    };
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final first = sorted[0].key;
    final second = sorted[1].key;
    final fallbackPrakriti = _toDualDosha(first, second);

    return PrakritiAssessmentResult(
      vataScore: vataScore,
      pittaScore: pittaScore,
      kaphaScore: kaphaScore,
      finalPrakriti: fallbackPrakriti,
      createdAt: DateTime.now(),
    );
  }

  /// Converts the two dominant doshas to one of the 3 valid dual-dosha labels.
  String _toDualDosha(Dosha first, Dosha second) {
    final pair = {first, second};
    if (pair.containsAll([Dosha.vata, Dosha.pitta])) return 'Vata-Pitta';
    if (pair.containsAll([Dosha.pitta, Dosha.kapha])) return 'Pitta-Kapha';
    if (pair.containsAll([Dosha.vata, Dosha.kapha])) return 'Vata-Kapha';
    // Edge case: all three equal — default to Vata-Pitta
    return 'Vata-Pitta';
  }

  Map<Dosha, double> _distributionFromFaceAnswers(Map<int, int> faceAnswers) {
    if (faceAnswers.isEmpty) {
      return {Dosha.vata: 0, Dosha.pitta: 0, Dosha.kapha: 0};
    }

    var vata = 0;
    var pitta = 0;
    var kapha = 0;

    for (final optionIndex in faceAnswers.values) {
      switch (optionIndex) {
        case 0:
          vata += 1;
        case 1:
          pitta += 1;
        case 2:
          kapha += 1;
      }
    }

    final total = faceAnswers.length.toDouble();
    return {
      Dosha.vata: vata / total,
      Dosha.pitta: pitta / total,
      Dosha.kapha: kapha / total,
    };
  }

  Map<Dosha, double> _distributionFromQuizAnswers() {
    var vataScore = 0;
    var pittaScore = 0;
    var kaphaScore = 0;

    for (var index = 0; index < state.questions.length; index++) {
      final selectedIndex = state.selectedAnswers[index];
      if (selectedIndex == null) continue;

      final option = state.questions[index].options[selectedIndex];
      vataScore += option.scores[Dosha.vata] ?? 0;
      pittaScore += option.scores[Dosha.pitta] ?? 0;
      kaphaScore += option.scores[Dosha.kapha] ?? 0;
    }

    final total = (vataScore + pittaScore + kaphaScore).toDouble();
    if (total == 0) {
      return {Dosha.vata: 0, Dosha.pitta: 0, Dosha.kapha: 0};
    }

    return {
      Dosha.vata: vataScore / total,
      Dosha.pitta: pittaScore / total,
      Dosha.kapha: kaphaScore / total,
    };
  }
}