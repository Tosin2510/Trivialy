import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trivialy/features/quiz/services/quiz_history_service.dart';

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;
  final int? currentProgress;
  final int? targetProgress;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    this.currentProgress,
    this.targetProgress,
  });
}

class AchievementsScreen extends StatefulWidget{
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
final QuizHistoryService _service = QuizHistoryService();
bool _isLoading = true;
List<Achievement> _achievements = [];

@override
void initState() {
  super.initState();
  _load();
}

int _currentDayStreak(List<QuizAttempt> attempts) {
  final Set<DateTime> playedDays = attempts
    .where((a) => a.completedAt != null)
    .map((a) {
      final val = a.completedAt!.toLocal();
      return DateTime(val.year, val.month, val.day);
    }).toSet();
  if (playedDays.isEmpty) return 0;

  final DateTime today = DateTime.now();
  final DateTime todayOnly = DateTime(today.year, today.month, today.day);

  final DateTime yesterday = todayOnly.subtract(const Duration(days: 1));
  if (!playedDays.contains(todayOnly) && !playedDays.contains(yesterday)) {
    return 0;
  }

  int streak = 0;
  DateTime cursor = playedDays.contains(todayOnly) ? todayOnly : yesterday;
  while (playedDays.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

Future<void> _load() async {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  List<QuizAttempt> attempts = [];
  if (uid != null) {
    attempts = await _service.getHistory(uid);
  }
  final int dayStreak = _currentDayStreak(attempts);
  final int totalPlayed = attempts.length;
  final int bestPercentage = attempts.isEmpty ? 0 : attempts.map((a) => a.scorePercentage).reduce((u,v) => u > v ? u : v);
  final bool hasPerfectScore = attempts.any((a) => a.scorePercentage == 100);
  final List<QuizAttempt> regularQuizzes = attempts.where((u) => !u.isWeeklyChallenge).toList();
  final int regularCounter = regularQuizzes.length;
  final Set<String> differentCategories = regularQuizzes.map((a) => a.category).toSet();
  final bool hasPerfectRegularScore = regularQuizzes.any((a) => a.scorePercentage == 100);

  final List<Achievement> achievements = [
    Achievement(
      title: 'First Steps', 
      description: 'Complete your first weekly challenge', 
      icon: Icons.flag_rounded, 
      unlocked: totalPlayed >= 1,
      currentProgress: totalPlayed,
      targetProgress: 1
    ),
    Achievement(
      title: 'Sharp Mind', 
      description: 'Score 70% or higher on a challenge', 
      icon: Icons.psychology_rounded, 
      unlocked: bestPercentage >= 70,
    ),
    Achievement(
      title: 'Perfect Score', 
      description: 'Get 100% on a weekly challenge', 
      icon: Icons.stars_rounded, 
      unlocked: hasPerfectScore,
    ),
    Achievement(
      title: 'Regular Player', 
      description: 'Complete 7 weekly challenges', 
      icon: Icons.event_repeat_rounded, 
      unlocked: totalPlayed >= 7,
      currentProgress: totalPlayed,
      targetProgress: 7
    ),
    Achievement(
      title: 'Veteran', 
      description: 'Complete 20 weekly challenges', 
      icon: Icons.military_tech_rounded, 
      unlocked: totalPlayed >= 20,
      currentProgress: totalPlayed,
      targetProgress: 20
    ),
     Achievement(
      title: 'Practice Makes Perfect', 
      description: 'Complete 5 regular quizzes', 
      icon: Icons.fitness_center_rounded, 
      unlocked: regularCounter >= 5,
      currentProgress: regularCounter,
      targetProgress: 5
    ),
     Achievement(
      title: 'Category Explorer', 
      description: 'Play quizzes in 3 different categories', 
      icon: Icons.explore_rounded, 
      unlocked: differentCategories.length >= 3,
    ),
     Achievement(
      title: 'Flawless Round', 
      description: 'Score 100% on a regular quiz', 
      icon: Icons.workspace_premium_rounded, 
      unlocked: hasPerfectRegularScore,
    ),
    Achievement(
      title: 'Raging',
      description: 'Reach a 14-day streak',
      icon: Icons.local_fire_department_rounded,
      unlocked: dayStreak >= 14,
      currentProgress: dayStreak,
      targetProgress: 14,
    ),
    Achievement(
      title: 'Inferno',
      description: 'Reach a 30-day streak',
      icon: Icons.local_fire_department_rounded,
      unlocked: dayStreak >= 30,
      currentProgress: dayStreak,
      targetProgress: 30,
    ),
  ];

  if (mounted) {
    setState(() {
      _achievements = achievements;
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final int unlockedCount = _achievements.where((v) => v.unlocked).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: _isLoading 
          ? const Center(
            child: CircularProgressIndicator(color: Color(0xFF2563EB),),
          )
          : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all((screenWidth * 0.05).clamp(16.0, 24.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context), 
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A),)
                    ),
                    const Text(
                      'Achievements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 4,),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '$unlockedCount of ${_achievements.length} unlocked',
                    style: const TextStyle(
                      color: Color(0xFF64748B), fontSize: 13
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    mainAxisExtent: 190
                  ),
                  itemCount: _achievements.length,
                  itemBuilder: (context, index) => _buildBadge(_achievements[index]),
                )
              ],
            ),
          )
      ),
    );
  } 
Widget _buildBadge(Achievement achievement) {
  final Color color = achievement.unlocked ? const Color(0xFFB45309) : const Color(0xFF94A3B8);
  final bool hasProgress = achievement.currentProgress != null && achievement.targetProgress != null;
  final double progressFraction = hasProgress 
    ? (achievement.currentProgress! / achievement.targetProgress!).clamp(0.0, 1.0)
    : 0;

  return Container(
    padding:  const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: achievement.unlocked ? const Color(0xFFFEF3C7) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: achievement.unlocked ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
      )
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            achievement.unlocked ? achievement.icon : Icons.lock_outline_rounded,
            color: color,
            size: 22,
          ),
        ),
        const SizedBox(height: 12,),
        Text(
          achievement.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: achievement.unlocked ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 4,),
        Text(
          achievement.description,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B), height: 1.3
          ),
        ),
        if (!achievement.unlocked && hasProgress)...[
          const SizedBox(height: 10,),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressFraction,
              minHeight: 6,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB45309)),
            ),
          ),
          const SizedBox(height: 4,),
          Text(
            '${achievement.currentProgress}/${achievement.targetProgress}',
            style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
          )
        ]
      ],
    ),
  );
}
}