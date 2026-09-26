// lib/services/ml_service.dart
//
// IPrakriti — ML Service
// =======================
// Connects Flutter app to the FastAPI prediction server.
// Sends 25 facial/behavioral features and returns Prakriti prediction.
//
// During dev:  server runs on your laptop (localhost)
// Production:  swap _baseUrl to your Railway/Render deployed URL

import 'dart:convert';
import 'package:http/http.dart' as http;

// ---------------------------------------------------------------------------
// CONFIG — change this one line when you deploy to Railway
// ---------------------------------------------------------------------------
// Android emulator → use 10.0.2.2 to reach host machine localhost
// Real device on same Wi-Fi → use your laptop IP e.g. http://192.168.1.5:8000
// Production → e.g. https://iprakriti-ml.railway.app
const String _baseUrl = 'http://10.206.26.222:8000';

// ---------------------------------------------------------------------------
// DATA MODELS
// ---------------------------------------------------------------------------

class DoshaScore {
  final String dosha;
  final double score;

  const DoshaScore({required this.dosha, required this.score});

  factory DoshaScore.fromJson(Map<String, dynamic> json) => DoshaScore(
        dosha: json['dosha'] as String,
        score: (json['score'] as num).toDouble(),
      );

  String get scorePercent => '${(score * 100).toStringAsFixed(1)}%';
}

class PrakritiMLResult {
  final String predictedPrakriti;
  final double confidence;
  final List<DoshaScore> allScores;
  final bool isDummyModel;

  const PrakritiMLResult({
    required this.predictedPrakriti,
    required this.confidence,
    required this.allScores,
    required this.isDummyModel,
  });

  factory PrakritiMLResult.fromJson(Map<String, dynamic> json) =>
      PrakritiMLResult(
        predictedPrakriti: json['predicted_prakriti'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        allScores: (json['all_scores'] as List)
            .map((s) => DoshaScore.fromJson(s as Map<String, dynamic>))
            .toList(),
        isDummyModel: json['is_dummy_model'] as bool,
      );

  /// Confidence as readable percent e.g. "58.7%"
  String get confidencePercent =>
      '${(confidence * 100).toStringAsFixed(1)}%';

  /// Secondary dosha if it has meaningful probability (≥15%)
  DoshaScore? get secondaryDosha {
    if (allScores.length < 2) return null;
    final second = allScores[1];
    return second.score >= 0.15 ? second : null;
  }

  /// Color hex for the predicted prakriti (for UI theming)
  String get prakritiColor {
    switch (predictedPrakriti) {
      case 'Vata-Pitta':
        return '#E87B4A'; // warm orange
      case 'Pitta-Kapha':
        return '#4A8E6A'; // earthy green
      case 'Vata-Kapha':
        return '#6A7DBE'; // cool blue
      default:
        return '#7B6B5A'; // neutral
    }
  }
}

class MLServiceException implements Exception {
  final String message;
  final bool isServerDown;

  const MLServiceException(this.message, {this.isServerDown = false});

  @override
  String toString() => message;
}

// ---------------------------------------------------------------------------
// ANSWER ENCODING HELPERS
// ---------------------------------------------------------------------------
// Use these maps to convert your Google Form answer text → int (0/1/2)
// so you can call MLService.instance.predict() from your questionnaire screen.

class PrakritiAnswerEncoder {
  /// Eyes colour answer → int
  static int encodeEyesColour(String answer) {
    const map = {
      'Blackish': 0,
      'Reddish/Brown': 1,
      'Milky/WhitishEdges': 2,
    };
    return map[answer] ?? 1;
  }

  /// Lips texture → int
  static int encodeLipsTexture(String answer) {
    const map = {
      'Cracked / Shapeless': 0,
      'Smooth, Soft, Thin': 1,
      'Smooth, Glossy, Proportionate': 2,
      'Smooth, Glossy': 2,
    };
    return map[answer] ?? 1;
  }

  /// Lips thickness → int
  static int encodeLipsThickness(String answer) {
    const map = {'Thin': 0, 'Medium': 1, 'Broad / Large': 2};
    return map[answer] ?? 1;
  }

  /// Lips color → int
  static int encodeLipsColor(String answer) {
    const map = {'Blackish': 0, 'Reddish': 1, 'Pinkish': 2};
    return map[answer] ?? 1;
  }

  /// Face color → int
  static int encodeFaceColor(String answer) {
    const map = {'Blackish': 0, 'Reddish': 1, 'Pinkish': 2};
    return map[answer] ?? 1;
  }

  /// Face texture → int
  static int encodeFaceTexture(String answer) {
    const map = {
      'Cracky / Rough': 0,
      'Soft, Oily, Pimples/Freckles': 1,
      'Smooth, Glossy': 2,
      'Smooth, Glossy, Proportionate': 2,
    };
    return map[answer] ?? 1;
  }

  /// Skin color → int
  static int encodeSkinColor(String answer) {
    const map = {
      'Blackish tinge': 0,
      'Yellowish tinge': 1,
      'Fair/Light tinge': 2,
      'Blackish': 0,
    };
    return map[answer] ?? 1;
  }

  /// Hair color → int
  static int encodeHairColor(String answer) {
    const map = {'Black': 0, 'Gray / Brown': 1, 'Black(Shiny)': 2};
    return map[answer] ?? 0;
  }

  /// Hair texture → int
  static int encodeHairTexture(String answer) {
    const map = {
      'Rough & Dry': 0,
      'Soft & Delicate': 1,
      'Soft & Shiny': 2,
    };
    return map[answer] ?? 1;
  }

  /// Forehead size → int
  static int encodeForeheadSize(String answer) {
    const map = {
      'Narrow(<4 fingers)': 0,
      'Medium (=4 fingers)': 1,
      'Broad (>4 fingers)': 2,
    };
    return map[answer] ?? 1;
  }

  /// Appetite → int
  static int encodeAppetite(String answer) {
    const map = {
      'Variable / Irregular (Vata)': 0,
      'Strong / Sharp appetite (Pitta)': 1,
      'Slow / Low appetite (Kapha)': 2,
    };
    return map[answer] ?? 1;
  }

  /// Meal skip response → int
  static int encodeMealSkipResponse(String answer) {
    const map = {
      'Constipation': 0,
      'Headache /vomitting': 1,
      'Mild discomfort or no change (Kapha)': 2,
    };
    return map[answer] ?? 2;
  }

  /// Stool consistency → int
  static int encodeStoolConsistency(String answer) {
    const map = {'Hard': 0, 'Semisolid': 1, 'Well formed': 2};
    return map[answer] ?? 1;
  }

  /// Sleep → int
  static int encodeSleep(String answer) {
    const map = {
      'Interrupted / <6 hrs': 0,
      '6–8 hrs': 1,
      '6-8 hrs': 1,
      'More than 8 hrs, sound sleep (Kapha)': 2,
    };
    return map[answer] ?? 1;
  }

  /// Work capacity → int
  static int encodeWorkCapacity(String answer) {
    const map = {'Less': 0, 'Medium': 1, 'More': 2};
    return map[answer] ?? 1;
  }

  /// Excitement response → int
  static int encodeExcitementResponse(String answer) {
    const map = {
      'Quick, cools quickly': 0,
      'Quick, slow to cool': 1,
      'Rare': 2,
    };
    return map[answer] ?? 1;
  }

  /// Working style → int
  static int encodeWorkingStyle(String answer) {
    const map = {'Quick': 0, 'Medium': 1, 'Slow': 2};
    return map[answer] ?? 1;
  }

  /// Body movements → int
  static int encodeBodyMovements(String answer) {
    const map = {
      'Fast, unnecessary': 0,
      'Moderate': 1,
      'Slow, steady': 2,
    };
    return map[answer] ?? 1;
  }

  /// Strength → int
  static int encodeStrength(String answer) {
    const map = {
      'Less, fatigues easily': 0,
      'Moderate': 1,
      'Good': 2,
    };
    return map[answer] ?? 1;
  }

  /// Problem handling → int
  static int encodeProblemHandling(String answer) {
    const map = {
      'Worrying': 0,
      'Irritable / Angry': 1,
      'Calm & Stable': 2,
    };
    return map[answer] ?? 1;
  }

  /// Control on desires → int
  static int encodeControlOnDesires(String answer) {
    const map = {'Poor': 0, 'Moderate': 1, 'Good': 2};
    return map[answer] ?? 1;
  }

  /// Concentration → int
  static int encodeConcentration(String answer) {
    const map = {'Poor': 0, 'Good on interest': 1, 'Excellent': 2};
    return map[answer] ?? 1;
  }

  /// Grasping power → int
  static int encodeGraspingPower(String answer) {
    const map = {
      'Slow to grasp': 0,
      'Quick but poor retention': 1,
      'Quick and good retention': 2,
    };
    return map[answer] ?? 1;
  }

  /// Storage → int
  static int encodeStorage(String answer) {
    const map = {'Poor': 0, 'Average': 1, 'Good': 2};
    return map[answer] ?? 1;
  }

  /// Memory → int
  static int encodeMemory(String answer) {
    const map = {'Poor': 0, 'Average': 1, 'Good': 2};
    return map[answer] ?? 1;
  }

  /// Convert a full map of raw answers to the 25-integer list the API needs.
  /// [answers] keys must match your questionnaire's answer field names.
  static List<int> encodeAll(Map<String, String> answers) {
    return [
      encodeEyesColour(answers['Eyes_Colour'] ?? ''),
      encodeLipsTexture(answers['Lips_Texture'] ?? ''),
      encodeLipsThickness(answers['Lips_Thickness'] ?? ''),
      encodeLipsColor(answers['Lips_Color'] ?? ''),
      encodeFaceColor(answers['Face_Color'] ?? ''),
      encodeFaceTexture(answers['Face_Texture'] ?? ''),
      encodeSkinColor(answers['Skin_Color'] ?? ''),
      encodeHairColor(answers['Hair_Color'] ?? ''),
      encodeHairTexture(answers['Hair_Texture'] ?? ''),
      encodeForeheadSize(answers['Forehead_Size'] ?? ''),
      encodeAppetite(answers['Appetite'] ?? ''),
      encodeMealSkipResponse(answers['Meal_Skip_Response'] ?? ''),
      encodeStoolConsistency(answers['Stool_Consistency'] ?? ''),
      encodeSleep(answers['Sleep'] ?? ''),
      encodeWorkCapacity(answers['Work_Capacity'] ?? ''),
      encodeExcitementResponse(answers['Excitement_Response'] ?? ''),
      encodeWorkingStyle(answers['Working_Style'] ?? ''),
      encodeBodyMovements(answers['Body_Movements'] ?? ''),
      encodeStrength(answers['Strength'] ?? ''),
      encodeProblemHandling(answers['Problem_Handling'] ?? ''),
      encodeControlOnDesires(answers['Control_on_Desires'] ?? ''),
      encodeConcentration(answers['Concentration'] ?? ''),
      encodeGraspingPower(answers['Grasping_Power'] ?? ''),
      encodeStorage(answers['Storage'] ?? ''),
      encodeMemory(answers['Memory'] ?? ''),
    ];
  }
}

// ---------------------------------------------------------------------------
// ML SERVICE
// ---------------------------------------------------------------------------

class MLService {
  MLService._();
  static final MLService instance = MLService._();

  final _client = http.Client();

  /// Predict Prakriti from a list of exactly 25 integers (each 0, 1, or 2).
  /// Use [PrakritiAnswerEncoder.encodeAll()] to convert raw answers first.
  Future<PrakritiMLResult> predict(List<int> answers) async {
    if (answers.length != 25) {
      throw MLServiceException(
        'Expected 25 answers, got ${answers.length}.',
      );
    }

    // Build JSON body matching API field names exactly
    final featureKeys = [
      'Eyes_Colour', 'Lips_Texture', 'Lips_Thickness', 'Lips_Color',
      'Face_Color', 'Face_Texture', 'Skin_Color', 'Hair_Color',
      'Hair_Texture', 'Forehead_Size', 'Appetite', 'Meal_Skip_Response',
      'Stool_Consistency', 'Sleep', 'Work_Capacity', 'Excitement_Response',
      'Working_Style', 'Body_Movements', 'Strength', 'Problem_Handling',
      'Control_on_Desires', 'Concentration', 'Grasping_Power',
      'Storage', 'Memory',
    ];

    final body = <String, int>{
      for (int i = 0; i < 25; i++) featureKeys[i]: answers[i],
    };

    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/predict'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return PrakritiMLResult.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else if (response.statusCode == 503) {
        throw const MLServiceException(
          'ML server is not ready. Make sure the model is trained.',
          isServerDown: true,
        );
      } else {
        throw MLServiceException(
          'Server error ${response.statusCode}: ${response.body}',
        );
      }
    } on MLServiceException {
      rethrow;
    } catch (e) {
      throw MLServiceException(
        'Could not reach ML server. Make sure uvicorn is running.\nError: $e',
        isServerDown: true,
      );
    }
  }

  /// Quick health check — true if server is up and model is loaded.
  Future<bool> isServerHealthy() async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return json['model_loaded'] == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}