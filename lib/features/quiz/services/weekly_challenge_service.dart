import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trivialy/core/services/api_service.dart';
import 'package:trivialy/features/quiz/models/question_model.dart';

// Handles weekly challenge atempts for each users.
class WeeklyAttempt {
  final String weekId;
  final int score;
  final int scorePercentage;
  final DateTime? completedAt;

  WeeklyAttempt({
    required this.weekId,
    required this.score,
    required this.scorePercentage,
    this.completedAt
  });
}
class WeeklyChallengeService {
  // Uses firestore to store the weekly challenge questions for subsequent users.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ApiService _apiService = ApiService();

//
  String get currentWeekId {
    final DateTime now = DateTime.now().toUtc();
    final DateTime firstDayOfYear = DateTime.utc(now.year, 1, 1);
    final int dayOfYear = now.difference(firstDayOfYear).inDays + 1;
    final int weekNumber = ((dayOfYear - now.weekday + 10) / 7).floor();
    return '${now.year} - W$weekNumber';
  }

// Gets all the weekly challenge attempts by user.
  Future<List<WeeklyAttempt>> getAllAttempts(String uid) async {
    final snapshot = await _firestore
      .collection('users')
      .doc(uid)
      .collection('weekly_attempts')
      .orderBy('completedAt', descending: false)
      .get();

// Return a snapshot of the atempts.
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final Timestamp? timestamp = data['completedAt'] as Timestamp?;
      return WeeklyAttempt(
        weekId: doc.id, 
        score: (data['score'] as num?)?.toInt() ?? 0, 
        scorePercentage: (data['scorePercentage'] as num?)?.toInt() ?? 0,
        completedAt: timestamp?.toDate(),
      );
    }).toList();
  }

// Get the current week question from the api then save to firestore for other subsequent users.
  Future<List<Question>> getWeeklyQuestions() async {
    final String weekId = currentWeekId;
    debugPrint('Weekly challenge: checking week $weekId');
    final docRef = _firestore.collection('weekly_challenges').doc(weekId);
    final existing = await docRef.get();
    debugPrint('Weekly challenge: existing doc exists=${existing.exists}, data=${existing.data()}');
    if (existing.exists && existing.data() ? ['questions'] != null) {
      final List<dynamic> raw = existing.data()!['questions'];
      debugPrint('Weekly challenge: returning ${raw.length} cached questions');
      return raw.map((q) => Question.fromJson(Map<String, dynamic>.from(q))).toList();
    }
    // the questions for all players participating in the weekly challenge for that week is the question generated when the first player plays.
    debugPrint('Weekly challenge: fetching fresh questions from API');
    final List<Question> freshQuestions = await _apiService.fetchQuestions(
        amount: 20,
        difficulty: 'hard',
      ); 

// This basically just make sure the trivia api actually return exactly 20 questions.
      if (freshQuestions.length < 20) {
        throw Exception(
          'The trivia API returned an incomplete question set (${freshQuestions.length}/20). Try again'
        );
      }
      debugPrint('Weekly challenge: API returned ${freshQuestions.length} questions');
      // This recheck part is for when two or more players click this at once(the same time/almost same time.)
      // By this, i meant the weekly challenge question.
      final recheck = await docRef.get();
      if (recheck.exists && recheck.data()?['questions'] != null) {
        final List<dynamic> raw = recheck.data()!['questions'];
        return raw.map((q) => Question.fromJson(Map<String, dynamic>.from(q))).toList();
      }

      await docRef.set({
      'weekId': weekId,
      'createdAt': FieldValue.serverTimestamp(),
      'questions': freshQuestions.map((q) => {
            'category': q.category,
            'difficulty': q.difficulty,
            'question': {'text': q.questionText},
            'correctAnswer': q.correctAnswer,
            'incorrectAnswers': q.allOptions.where((o) => o != q.correctAnswer).toList(),
          }).toList(),
    });
    return freshQuestions;
  }

// If a user has finished the challenge for that week, it will return true.
  Future<bool> hasCompletedThisWeekChallenge(String uid) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('weekly_attempts')
        .doc(currentWeekId)
        .get();
      return doc.exists;
  }

// This part saves the result of the completed weekly challenge to firebase.
  Future<void> markCompleted (String uid, int score, int scorePercentage) async {
    await _firestore
      .collection('users')
      .doc(uid)
      .collection('weekly_attempts')
      .doc(currentWeekId)
      .set({
        'score': score,
        'scorePercentage': scorePercentage,
        'completedAt': FieldValue.serverTimestamp(),
      });

// Saves the weekly challenge result to the leaderboard and display it in the leaderboard screen.
      await _firestore
         .collection('weekly_leaderboard')
         .doc(currentWeekId)
         .collection('entries')
         .doc(uid)
         .set({
          'score': score,
          'scorePercentage': scorePercentage,
          'completedAt': FieldValue.serverTimestamp(),
         });
  }
}

