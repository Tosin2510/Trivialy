import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trivialy/header_badge.dart';
import 'package:trivialy/header_badge_icon.dart';
import 'package:trivialy/quiz_history_service.dart';
class DashBoardHeader extends StatefulWidget{
  const DashBoardHeader({super.key});

  @override
  State<DashBoardHeader> createState() => _DashBoardHeaderState();
}

class _DashBoardHeaderState extends State<DashBoardHeader> {
  
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    double dynamicPadding = (screenWidth * 0.04).clamp(16.0,24.0);
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<List<QuizAttempt>>(
      stream: uid != null ? QuizHistoryService().historyStream(uid) : null, 
      builder: (context, snapshot) {
        final attempts = snapshot.data ?? [];
        final int streak = QuizHistoryService().currentDayStreak(attempts);
        final int totalPoints = QuizHistoryService().totalPoints(attempts);
        
        return Padding(
        padding: EdgeInsets.all(dynamicPadding),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/icon/app_icon_small.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Trivialy',
              style: TextStyle(
                fontSize: (screenWidth * 0.060).clamp(22.0, 24.0),
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            HeaderBadge(
              icon: '🔥',
              value: '$streak'
            ),
            HeaderBadgeIcon(
              icon: Icons.monetization_on_rounded,
              iconColor: Colors.amber.shade700,
              value: '$totalPoints',
            ),
          ]
        )
      );
    }
  );
  }
}