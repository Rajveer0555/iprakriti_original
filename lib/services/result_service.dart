import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/question_model.dart';

class PrakritiHistoryEntry {
  const PrakritiHistoryEntry({
    required this.id,
    required this.finalPrakriti,
    required this.vataScore,
    required this.pittaScore,
    required this.kaphaScore,
    required this.createdAt,
  });

  final String id;
  final String finalPrakriti;
  final int vataScore;
  final int pittaScore;
  final int kaphaScore;
  final DateTime createdAt;
}

class ResultService {
  ResultService(this._client);

  final SupabaseClient _client;

  Future<void> saveResult({
    required String userId,
    required PrakritiAssessmentResult result,
  }) {
    return _client.from('prakriti_results').insert({
      'user_id': userId,
      'vata': result.vataScore,
      'pitta': result.pittaScore,
      'kapha': result.kaphaScore,
      'final_prakriti': result.finalPrakriti,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<PrakritiHistoryEntry>> fetchResults(String userId) async {
    final response = await _client
        .from('prakriti_results')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>).map((item) {
      final map = item as Map<String, dynamic>;
      return PrakritiHistoryEntry(
        id: map['id'].toString(),
        finalPrakriti: map['final_prakriti'] as String? ?? 'Unknown',
        vataScore: (map['vata'] as num?)?.toInt() ?? 0,
        pittaScore: (map['pitta'] as num?)?.toInt() ?? 0,
        kaphaScore: (map['kapha'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
            DateTime.now(),
      );
    }).toList();
  }
}
