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

  static const _missingResultsTableMessage =
      'Supabase table "public.prakriti_results" is missing. Create the '
      'results table before saving or loading assessments.';
  static const _resultsRlsMessage =
      'Supabase row-level security is blocking access to '
      '"public.prakriti_results". Add SELECT, INSERT, and DELETE policies for the '
      'signed-in user.';

  final SupabaseClient _client;

  Future<void> saveResult({
    required String userId,
    required PrakritiAssessmentResult result,
  }) async {
    try {
      await _client.from('prakriti_results').insert({
        'user_id': userId,
        'vata': result.vataScore,
        'pitta': result.pittaScore,
        'kapha': result.kaphaScore,
        'final_prakriti': result.finalPrakriti,
        'created_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (error) {
      if (_isMissingResultsTable(error)) {
        throw Exception(_missingResultsTableMessage);
      }
      if (_isResultsTableRlsDenied(error)) {
        throw Exception(_resultsRlsMessage);
      }
      rethrow;
    }
  }

  Future<List<PrakritiHistoryEntry>> fetchResults(String userId) async {
    try {
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
    } on PostgrestException catch (error) {
      if (_isMissingResultsTable(error)) {
        return [];
      }
      if (_isResultsTableRlsDenied(error)) {
        throw Exception(_resultsRlsMessage);
      }
      rethrow;
    }
  }

  Future<void> deleteResult(String resultId) async {
    try {
      await _client.from('prakriti_results').delete().eq('id', resultId);
    } on PostgrestException catch (error) {
      if (_isMissingResultsTable(error)) {
        throw Exception(_missingResultsTableMessage);
      }
      if (_isResultsTableRlsDenied(error)) {
        throw Exception(_resultsRlsMessage);
      }
      rethrow;
    }
  }

  bool _isMissingResultsTable(PostgrestException error) {
    return error.code == 'PGRST205' &&
        (error.message.contains("table 'public.prakriti_results'") ||
            error.message.contains("table 'prakriti_results'"));
  }

  bool _isResultsTableRlsDenied(PostgrestException error) {
    return error.code == '42501' &&
        error.message.contains('row-level security policy') &&
        error.message.contains('"prakriti_results"');
  }
}
