import 'package:cloud_firestore/cloud_firestore.dart';

class QuizAttempt {
  final String category;
  final String? difficulty;
  final int score;
  final int scorePercentage;
  final int questionCount;
  final bool isWeeklyChallenge;
  final DateTime? completedAt;

  QuizAttempt({
    required this.category,
    required this.difficulty,
    required this.score,
    required this.scorePercentage,
    required this.questionCount,
    required this.isWeeklyChallenge,
    this.completedAt,
  });
}

class QuizHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> recordAttempt({
    required String uid,
    required String category,
    String? difficulty,
    required int score,
    required int scorePercentage,
    required int questionCount,
    required bool isWeeklyChallenge
  }) async {
    await _firestore.collection('users').doc(uid).collection('quiz_history').add(
      {
        'category': category,
        'difficulty': difficulty,
        'score': score,
        'scorePercentage': scorePercentage,
        'questionCount': questionCount,
        'isWeeklyChallenge': isWeeklyChallenge,
        'completedAt': FieldValue.serverTimestamp(),
      }
    );
  }

  Future<List<QuizAttempt>> getHistory(String uid) async {
    final snapshot = await _firestore
      .collection('users')
      .doc(uid)
      .collection('quiz_history')
      .orderBy('completedAt', descending: false)
      .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final Timestamp? timestamp = data['completedAt'] as Timestamp?;
        return QuizAttempt(
          category: data['category'] as String? ?? 'General', 
          difficulty: data['difficulty'] as String?, 
          score: (data['score'] as num?)?.toInt() ?? 0, 
          scorePercentage: (data['scorePercentage'] as num?)?.toInt() ?? 0,
          questionCount: (data['questionCount'] as num?)?.toInt() ?? 0,
          isWeeklyChallenge: data['isWeeklyChallenge'] as bool? ?? false,
          completedAt: timestamp?.toDate(),
        );
      }).toList();
  }

  int totalPoints(List<QuizAttempt> attempts) {
    if (attempts.isEmpty) return 0;
    return attempts.fold<int>(0, (add, a) => add + a.score);
  }

  int bestScore(List<QuizAttempt> attempts) {
    if (attempts.isEmpty) return 0;
    return attempts.map((a) => a.score).reduce((a,b) => a > b ? a : b);
  }

  int currentDayStreak(List<QuizAttempt> attempts) {
    final Set<DateTime> playedDays = attempts
      .where((a) => a.completedAt != null)
      .map((a) {
        final val = a.completedAt!.toLocal();
        return DateTime(val.year, val.month, val.day);
      }).toSet();

    if (playedDays.isEmpty) return 0;

    final DateTime today = DateTime.now();
    final DateTime todayAlone = DateTime(today.year, today.month, today.day);
    final DateTime yesterday = todayAlone.subtract(const Duration(days: 1));

    if (!playedDays.contains(todayAlone) && !playedDays.contains(yesterday)) {
      return 0;
    }

    int streak = 0;
    DateTime streakCursor = playedDays.contains(todayAlone) ? todayAlone : yesterday;
    while (playedDays.contains(streakCursor)) {
      streak++;
      streakCursor = streakCursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Stream<List<QuizAttempt>> historyStream(String uid) {
    return _firestore
      .collection('users')
      .doc(uid)
      .collection('quiz_history')
      .orderBy('completedAt', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        final Timestamp? timestamp = data['completedAt'] as Timestamp?;
        return QuizAttempt(
          category: data['category'] as String? ?? 'General', 
          difficulty: data['difficulty'] as String?, 
          score: (data['score'] as num?)?.toInt() ?? 0, 
          scorePercentage: (data['scorePercentage'] as num?)?.toInt() ?? 0, 
          questionCount: (data['questionCount'] as num?)?.toInt() ?? 0, 
          isWeeklyChallenge: data['isWeeklyChallenge'] as bool? ?? false,
          completedAt: timestamp?.toDate(),
        );
      }).toList()
    );
  }
}