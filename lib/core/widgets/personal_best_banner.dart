import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trivialy/features/quiz/services/quiz_history_service.dart';

// This widget displays the user's personal best score.
class PersonalBestBanner extends StatelessWidget{
  const PersonalBestBanner({super.key});

  @override
  // The build part.
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    double dynamicMargin = (screenWidth * 0.04).clamp(16.0,24.0);
    double dynamicPadding = (screenWidth * 0.06).clamp(20.0, 28.0);
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

// Uses a stream builder so that changes can be taken note of and the widget can be updated...
    return StreamBuilder<List<QuizAttempt>>(
      stream: uid != null ? QuizHistoryService().historyStream(uid) : null, 
      // Uses a snapshot to get stream data.
      builder: (context, snapshot) {
        final attempts = snapshot.data ?? [];
        final int bestScore = QuizHistoryService().bestScore(attempts);

        return Container(
        margin: EdgeInsets.symmetric(horizontal: dynamicMargin, vertical: 8.0),
        padding: EdgeInsets.all(dynamicPadding),
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PERSONAL BEST',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    fontSize: (screenWidth * 0.04).clamp(11.0, 13.0)
                  ),
                ),
              ]
            ),
            const SizedBox(height: 2),
            // Displays best score.
            Text(
              '$bestScore pts',
              style: TextStyle(
                color: Colors.white,
                fontSize: (screenWidth * 0.11).clamp(28.0, 40.0),
                fontWeight: FontWeight.bold
              )
            )
          ],)
      );
    }
  );
  }
}