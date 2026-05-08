import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

class ScoreEntry {
  final String quizType;
  final int score;
  final int total;
  final DateTime playedAt;

  ScoreEntry({
    required this.quizType,
    required this.score,
    required this.total,
    required this.playedAt,
  });

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
    quizType: json['quiz_type'] as String,
    score: json['score'] as int,
    total: json['total'] as int,
    playedAt: DateTime.parse(json['played_at'] as String),
  );
}

class BestScore {
  final String quizType;
  final int bestScore;
  final int total;
  final DateTime updatedAt;

  BestScore({
    required this.quizType,
    required this.bestScore,
    required this.total,
    required this.updatedAt,
  });

  factory BestScore.fromJson(Map<String, dynamic> json) => BestScore(
    quizType: json['quiz_type'] as String,
    bestScore: json['best_score'] as int,
    total: json['total'] as int,
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  String get percentage => '${((bestScore / total) * 100).round()}%';
}

class ScoreService {
  static final _client = Supabase.instance.client;

  static Future<void> saveScore({
    required String quizType, // 'flags' / 'states' / 'capitals'
    required int score,
    required int total,
  }) async {
    if (!AuthService.isLoggedIn) return;
    final userId = AuthService.currentUser!.id;

    await _client.from('score_history').insert({
      'user_id': userId,
      'quiz_type': quizType,
      'score': score,
      'total': total,
    });

    await _client
        .from('best_scores')
        .upsert(
          {
            'user_id': userId,
            'quiz_type': quizType,
            'best_score': score,
            'total': total,
            'updated_at': DateTime.now().toIso8601String(),
          },
          onConflict: 'user_id, quiz_type',
          ignoreDuplicates: false,
        );

    await _saveBestIfBetter(userId, quizType, score, total);
  }

  static Future<void> _saveBestIfBetter(
    String userId,
    String quizType,
    int score,
    int total,
  ) async {
    final existing = await _client
        .from('best_scores')
        .select()
        .eq('user_id', userId)
        .eq('quiz_type', quizType)
        .maybeSingle();

    if (existing == null || (existing['best_score'] as int) < score) {
      await _client.from('best_scores').upsert({
        'user_id': userId,
        'quiz_type': quizType,
        'best_score': score,
        'total': total,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, quiz_type');
    }
  }

  static Future<List<BestScore>> fetchBestScores() async {
    if (!AuthService.isLoggedIn) return [];

    final data = await _client
        .from('best_scores')
        .select()
        .eq('user_id', AuthService.currentUser!.id);

    return (data as List)
        .map((json) => BestScore.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static Future<List<ScoreEntry>> fetchHistory({String? quizType}) async {
    if (!AuthService.isLoggedIn) return [];

    var query = _client
        .from('score_history')
        .select()
        .eq('user_id', AuthService.currentUser!.id);

    final data = await (quizType != null
        ? query.eq('quiz_type', quizType).order('played_at', ascending: false)
        : query.order('played_at', ascending: false));

    return (data as List)
        .map((json) => ScoreEntry.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
