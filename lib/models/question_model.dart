enum Dosha { vata, pitta, kapha }

extension DoshaLabel on Dosha {
  String get label {
    switch (this) {
      case Dosha.vata:
        return 'Vata';
      case Dosha.pitta:
        return 'Pitta';
      case Dosha.kapha:
        return 'Kapha';
    }
  }
}

class QuestionOption {
  const QuestionOption({
    required this.label,
    required this.scores,
  });

  final String label;
  final Map<Dosha, int> scores;
}

class QuestionModel {
  const QuestionModel({
    required this.id,
    required this.question,
    required this.options,
  });

  final String id;
  final String question;
  final List<QuestionOption> options;
}

class PrakritiAssessmentResult {
  const PrakritiAssessmentResult({
    required this.vataScore,
    required this.pittaScore,
    required this.kaphaScore,
    required this.finalPrakriti,
    this.createdAt,
  });

  final int vataScore;
  final int pittaScore;
  final int kaphaScore;
  final String finalPrakriti;
  final DateTime? createdAt;

  int get totalScore => vataScore + pittaScore + kaphaScore;

  double get vataPercent => _toPercent(vataScore);
  double get pittaPercent => _toPercent(pittaScore);
  double get kaphaPercent => _toPercent(kaphaScore);

  double _toPercent(int score) {
    if (totalScore == 0) {
      return 0;
    }
    return (score / totalScore) * 100;
  }
}
