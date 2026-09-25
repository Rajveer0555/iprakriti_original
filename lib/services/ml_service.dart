// lib/services/ml_service.dart
//
// IPrakriti — ML Service (Flutter ↔ FastAPI bridge)
// ===================================================
// Sends the user's 35 questionnaire answers to the FastAPI prediction server
// and returns a PrakritiMLResult.
//
// During development:  points to localhost (your laptop running uvicorn)
// In production:       swap BASE_URL to your deployed Railway/Render URL

import 'dart:convert';
import 'package:http/http.dart' as http;

// ---------------------------------------------------------------------------
// CONFIG — change this one line when you deploy
// ---------------------------------------------------------------------------

// Android emulator uses 10.0.2.2 to reach the host machine's localhost.
// For a real device on the same Wi-Fi, use your laptop's local IP:
//   e.g. 'http://192.168.1.5:8000'
// For production after Railway/Render deploy:
//   e.g. 'https://iprakriti-ml.railway.app'
const String _baseUrl = 'http://10.0.2.2:8000';

// ---------------------------------------------------------------------------
// DATA MODELS
// ---------------------------------------------------------------------------

class DoshaScore {
  final String dosha;
  final double score;

  const DoshaScore({required this.dosha, required this.score});

  factory DoshaScore.fromJson(Map<String, dynamic> json) {
    return DoshaScore(
      dosha: json['dosha'] as String,
      score: (json['score'] as num).toDouble(),
    );
  }
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

  factory PrakritiMLResult.fromJson(Map<String, dynamic> json) {
    return PrakritiMLResult(
      predictedPrakriti: json['predicted_prakriti'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      allScores: (json['all_scores'] as List)
          .map((s) => DoshaScore.fromJson(s as Map<String, dynamic>))
          .toList(),
      isDummyModel: json['is_dummy_model'] as bool,
    );
  }

  /// Confidence as a readable percentage string, e.g. "87.3%"
  String get confidencePercent =>
      '${(confidence * 100).toStringAsFixed(1)}%';

  /// The #2 dosha (if any) with meaningful probability
  DoshaScore? get secondaryDosha {
    if (allScores.length < 2) return null;
    final second = allScores[1];
    return second.score >= 0.15 ? second : null;
  }
}

class MLServiceException implements Exception {
  final String message;
  const MLServiceException(this.message);

  @override
  String toString() => 'MLServiceException: $message';
}

// ---------------------------------------------------------------------------
// SERVICE
// ---------------------------------------------------------------------------

class MLService {
  MLService._();
  static final MLService instance = MLService._();

  final _client = http.Client();

  /// Sends [answers] (a list of exactly 35 integers, each 0/1/2) to the
  /// FastAPI server and returns the predicted Prakriti result.
  ///
  /// Throws [MLServiceException] on any network or server error.
  Future<PrakritiMLResult> predict(List<int> answers) async {
    if (answers.length != 35) {
      throw MLServiceException(
        'Expected 35 answers, got ${answers.length}.',
      );
    }

    for (int i = 0; i < answers.length; i++) {
      final a = answers[i];
      if (a < 0 || a > 2) {
        throw MLServiceException(
          'Answer at index $i is $a — must be 0, 1, or 2.',
        );
      }
    }

    // Build request body — keys must match PrakritiInput field names in schemas.py
    final questionKeys = [
      'Q1_Body_Frame', 'Q2_Body_Weight', 'Q3_Skin_Texture', 'Q4_Skin_Color',
      'Q5_Hair_Type', 'Q6_Hair_Color', 'Q7_Eye_Size', 'Q8_Eye_Color',
      'Q9_Teeth_Size', 'Q10_Appetite', 'Q11_Digestion', 'Q12_Bowel_Movement',
      'Q13_Sweat', 'Q14_Sleep_Pattern', 'Q15_Sleep_Duration', 'Q16_Dream_Type',
      'Q17_Memory', 'Q18_Speech', 'Q19_Mind_Nature', 'Q20_Stress_Response',
      'Q21_Emotional_Tendency', 'Q22_Decision_Making', 'Q23_Work_Style',
      'Q24_Financial_Tendency', 'Q25_Social_Preference',
      'Q26_Weather_Preference', 'Q27_Exercise_Capacity',
      'Q28_Disease_Tendency', 'Q29_Pulse_Nature', 'Q30_Voice_Quality',
      'Q31_Walk_Style', 'Q32_Hand_Nature', 'Q33_Nail_Type',
      'Q34_Tongue_Coating', 'Q35_Prakriti_Self_Assessment',
    ];

    final body = <String, int>{
      for (int i = 0; i < 35; i++) questionKeys[i]: answers[i],
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
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return PrakritiMLResult.fromJson(json);
      } else if (response.statusCode == 503) {
        throw const MLServiceException(
          'ML model is not loaded on the server yet. '
          'Run `python model/train.py --dummy` to create a model.',
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
        'Could not reach the ML server at $_baseUrl. '
        'Make sure uvicorn is running: `uvicorn api.main:app --reload`\n'
        'Error: $e',
      );
    }
  }

  /// Health check — returns true if the server is reachable and model is loaded.
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
