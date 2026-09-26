enum Dosha { vata, pitta, kapha }

extension DoshaLabel on Dosha {
  String get label {
    switch (this) {
      case Dosha.vata: return 'Vata';
      case Dosha.pitta: return 'Pitta';
      case Dosha.kapha: return 'Kapha';
    }
  }
}

class QuestionOption {
  const QuestionOption({required this.label, required this.scores});
  final String label;
  final Map<Dosha, int> scores;
}

class QuestionModel {
  const QuestionModel({required this.id, required this.question, required this.options});
  final String id;
  final String question;
  final List<QuestionOption> options;
}

class DoshaMLScore {
  const DoshaMLScore({required this.dosha, required this.score});
  final String dosha;
  final double score;
  String get scorePercent => '${(score * 100).toStringAsFixed(1)}%';
}

class PrakritiAssessmentResult {
  const PrakritiAssessmentResult({
    required this.vataScore,
    required this.pittaScore,
    required this.kaphaScore,
    required this.finalPrakriti,
    this.mlConfidence,
    this.mlAllScores,
    this.createdAt,
  });

  final int vataScore;
  final int pittaScore;
  final int kaphaScore;
  final String finalPrakriti;
  final double? mlConfidence;
  final List<DoshaMLScore>? mlAllScores;
  final DateTime? createdAt;

  int get totalScore => vataScore + pittaScore + kaphaScore;
  double get vataPercent => totalScore == 0 ? 0 : (vataScore / totalScore) * 100;
  double get pittaPercent => totalScore == 0 ? 0 : (pittaScore / totalScore) * 100;
  double get kaphaPercent => totalScore == 0 ? 0 : (kaphaScore / totalScore) * 100;
  bool get isMLBacked => mlConfidence != null;
  String? get mlConfidencePercent => mlConfidence != null
      ? '${(mlConfidence! * 100).toStringAsFixed(1)}%'
      : null;
}