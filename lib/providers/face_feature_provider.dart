import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/question_model.dart';

final faceFeatureProvider =
    StateNotifierProvider<FaceFeatureController, FaceFeatureState>((ref) {
      return FaceFeatureController();
    });

class FaceFeatureState {
  const FaceFeatureState({
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

  FaceFeatureState copyWith({
    List<QuestionModel>? questions,
    Map<int, int>? selectedAnswers,
    int? currentIndex,
  }) {
    return FaceFeatureState(
      questions: questions ?? this.questions,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class FaceFeatureController extends StateNotifier<FaceFeatureState> {
  FaceFeatureController()
    : super(
        FaceFeatureState(
          questions: _questions,
          selectedAnswers: const {},
          currentIndex: 0,
        ),
      );

  static final List<QuestionModel> _questions = [
    QuestionModel(
      id: 'eyes_colour',
      question: 'What best describes the colour of your eyes?',
      options: const [
        QuestionOption(label: 'Blackish', scores: {Dosha.vata: 3}),
        QuestionOption(
          label: 'Reddish or brownish tint',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Milky white with reddish edges',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'lips_texture',
      question: 'How would you describe the texture of your lips?',
      options: const [
        QuestionOption(
          label: 'Cracked and shapeless',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Smooth, soft, and thin',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Smooth, glossy, and well-proportioned',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'lips_thickness',
      question: 'How thick are your lips naturally?',
      options: const [
        QuestionOption(label: 'Thin', scores: {Dosha.vata: 3}),
        QuestionOption(
          label: 'Medium thickness',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(label: 'Broad or large', scores: {Dosha.kapha: 3}),
      ],
    ),
    QuestionModel(
      id: 'lips_colour',
      question: 'What is the natural colour of your lips?',
      options: const [
        QuestionOption(
          label: 'Blackish or dark',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(label: 'Reddish', scores: {Dosha.pitta: 3}),
        QuestionOption(label: 'Pinkish', scores: {Dosha.kapha: 3}),
      ],
    ),
    QuestionModel(
      id: 'face_colour',
      question: 'What is your natural face complexion?',
      options: const [
        QuestionOption(
          label: 'Blackish or dark toned',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Reddish toned',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Pinkish toned',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'face_texture',
      question: 'How does your facial skin generally feel?',
      options: const [
        QuestionOption(label: 'Cracky and rough', scores: {Dosha.vata: 3}),
        QuestionOption(
          label: 'Soft and oily, prone to pimples or freckles',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Smooth and glossy',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'skin_colour',
      question: 'What best describes your overall skin colour?',
      options: const [
        QuestionOption(
          label: 'Blackish tinge',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Yellowish tinge',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Fair or light tinge',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'hair_colour',
      question: 'What is the natural colour of your hair?',
      options: const [
        QuestionOption(
          label: 'Black (dry or dull looking)',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Gray or brownish',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Black and naturally shiny',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'hair_texture',
      question: 'How would you describe the texture of your hair?',
      options: const [
        QuestionOption(
          label: 'Rough and dry',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Soft and delicate',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Soft and shiny',
          scores: {Dosha.kapha: 3},
        ),
      ],
    ),
    QuestionModel(
      id: 'forehead_size',
      question:
          'What is the size of your forehead?\n(Place 4 fingers horizontally across your forehead to measure)',
      options: const [
        QuestionOption(
          label: 'Broad, wider than 4 fingers',
          scores: {Dosha.vata: 3},
        ),
        QuestionOption(
          label: 'Medium, exactly 4 fingers wide',
          scores: {Dosha.pitta: 3},
        ),
        QuestionOption(
          label: 'Narrow, less than 4 fingers wide',
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
    state = FaceFeatureState(
      questions: _questions,
      selectedAnswers: const {},
      currentIndex: 0,
    );
  }
}
