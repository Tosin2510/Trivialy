import 'package:flutter/material.dart';
import 'package:trivialy/core/widgets/weekly_challenge_gate_screen.dart';

// This basically displays the weekly challenge banner which basically allows users to play the weekly challenge and be ranked in the leaderboard
class WeeklyChallengeBanner extends StatelessWidget{
  const WeeklyChallengeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    double dynamicMargin = (screenWidth * 0.04).clamp(16.0, 24.0);
    double dynamicPadding = (screenWidth * 0.05).clamp(16.0, 24.0);
    double titleSize = (screenWidth * 0.045).clamp(16.0, 19.0);
    double bodySize = (screenWidth * 0.033).clamp(12.0,14.0);
    double buttonTextSize = (screenWidth * 0.035).clamp(13.0, 15.0);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: dynamicMargin, vertical: 8.0),
      padding: EdgeInsets.all(dynamicPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6),
        borderRadius: BorderRadius.circular(24)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Challenge',
            style: TextStyle(
              color: Colors.white,
              fontSize: titleSize,
              fontWeight: FontWeight.bold
            )
          ),
          const SizedBox(height: 6),
          Text(
            'Test your limits with our curated set of 20 high-difficult questions and get ranked in our leaderboard.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: bodySize,
              height: 1.4
            ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context, MaterialPageRoute(builder: (context) => WeeklyChallengeGateScreen())
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E3A8A),
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: (screenWidth * 0.06).clamp(20.0, 28.0),
                  vertical: (screenWidth * 0.03).clamp(10.0, 14.0)
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)
                    )
              ),
              child: Text(
                'Play Now',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: buttonTextSize
                )
              )
              )
        ],)
    );
  }
}