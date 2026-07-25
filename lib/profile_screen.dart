import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trivialy/achievements_screen.dart';
import 'package:trivialy/edit_profile_screen.dart';
import 'package:trivialy/profile_service.dart';
import 'package:trivialy/quiz_history_service.dart';
import 'package:trivialy/stats_history_screen.dart';
import 'package:trivialy/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  UserProfile? _profile;
  bool _isLoading = true;
  final QuizHistoryService _historyService = QuizHistoryService();
  int _totalPoints = 0;
  int _totalQuizzes = 0;
  int _dayStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  DateTime? _joinedDate;
  Future<void> _loadProfile() async {
    final profile = await _profileService.loadProfile();
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    DateTime? joinedDate;
    if (uid != null) {
      joinedDate = await _profileService.getJoinedDate(uid);
      final attempts = await _historyService.getHistory(uid);
      _totalPoints = _historyService.totalPoints(attempts);
      _totalQuizzes = attempts.length;
      _dayStreak = _historyService.currentDayStreak(attempts);
    }
    if (mounted) {
      setState(() {
        _profile = profile;
        _joinedDate = joinedDate;
        _isLoading = false;
      });
    }
  }

  String get _joinedText {
    if (_joinedDate == null) return 'Joined recently';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'];
    return 'Joined ${months[_joinedDate!.month - 1]} ${_joinedDate!.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor:  Color(0xFFF1F5F9),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0XFF2563EB),
          ),
        ),
      );
    }

    final double screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all((screenWidth * 0.06).clamp(6.0, 24.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 36),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final bool? updated = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute
                          (builder: (context) => EditProfileScreen(profile: _profile),
                        )
                        );
                        if (updated == true) _loadProfile();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.settings_outlined,
                        color: Color(0xFF0F172A),
                        size: 20,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      _buildAvatar(),
                      const SizedBox(height: 16),
                      Text(
                        _profile?.name ?? 'User',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _joinedText,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 28,),
                // For the up to real stats once quiz-history tracking exists.
                Row(
                  children: [
                    _buildStatCard('$_totalPoints', 'TOTAL PTS'),
                    const SizedBox(width: 12),
                    _buildStatCard('$_totalQuizzes', 'QUIZZES'),
                    const SizedBox(width: 12),
                    _buildStatCard('$_dayStreak', 'DAY STREAK'),
                  ],),
                  const SizedBox(height: 28,),
                  _buildMenuRow(Icons.bar_chart_rounded, 'My Stats & History', () {
                    Navigator.push(
                      context, MaterialPageRoute(builder: (context) => const StatsHistoryScreen()),
                    );
                  }),
                  const SizedBox(height: 12,),
                  _buildMenuRow(Icons.emoji_events_outlined, 'Achievements', (){
                    Navigator.push(
                      context, MaterialPageRoute(builder: (context) => const AchievementsScreen()),
                    );
                  }),
              ],
            ),
          )
        ),
    );
  }
  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4)
            )
          ]
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A)
              )
            ),
            const SizedBox(height: 4,),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 0.3
              ),
            )
          ],)
      )
    );
  }

  Widget _buildMenuRow(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2563EB),
                size: 18,
              ),
            ),
            const SizedBox(width: 12,),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                )
              )
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8))
          ],
        ),
      ),
    );
  }
  Widget _buildAvatar() {
    const double size = 96;

    if (_profile != null && _profile!.hasCustomImage) {
      return CircleAvatar(
        radius: size/2,
        backgroundColor: const Color(0xFFE2E8F0),
        backgroundImage: FileImage(File(_profile!.imagePath!)),
        onBackgroundImageError: (_, _) {},
      );
    }

    return CircleAvatar(
      radius: size/2,
      backgroundColor: const Color(0xFF2563EB),
      child: Text(
        _profile?.initials ?? '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w800,
        ),
      )
    );
  }
}