import 'package:flutter/material.dart';

class GameOverScreen extends StatelessWidget{
  final int scorePercentage;
  final int score;
  final int correctCount;
  final int wrongCount;
  final String timeDisplay;
  final bool timeExpired;
  final VoidCallback onPlayAgain;
  final VoidCallback onReviewAnswers;
  final VoidCallback onBackToHome;
  final bool isWeeklyChallenge;

  const GameOverScreen({
    super.key,
    required this.scorePercentage,
    required this.score,
    required this.correctCount,
    required this.wrongCount,
    required this.timeDisplay,
    required this.timeExpired,
    required this.onPlayAgain,
    required this.onReviewAnswers,
    required this.onBackToHome,
    this.isWeeklyChallenge = false
  });
  @override
  // Handles the build for when the game is over.
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF0F172A)),
                        onPressed: onBackToHome, 
                      ),  
                    const Text(
                      'Quiz Complete',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A)
                      )
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 24),
                _buildScoreRing(),
                const SizedBox(height: 24),
                Text(
                  scorePercentage >= 50
                    ? 'Nice work, User, keep it up!'
                    : 'Keep going User, you can do better!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A)
                  )
                ),
                if (timeExpired) ...[
                  const SizedBox(height: 4,),
                  const Text(
                    'Time ran out before you finished',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64648B),
                      fontWeight: FontWeight.w500,
                    )
                  )
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    // Handles the building of the statistic card.
                    _buildStatCard('$correctCount', 'CORRECT', const Color(0xFF16A34A)),
                    const SizedBox(width: 12,),
                    _buildStatCard('$wrongCount', 'WRONG', const Color(0xFFDC2626)),
                    const SizedBox(width: 12,),
                    _buildStatCard(timeDisplay, 'TIME LEFT', const Color(0xFf2563EB))
                  ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF92600c),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events_rounded,
                        color: Colors.white,
                        size: 22
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '+$score pts earned',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const Text(
                              'Added to Gold League total',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12
                              ),
                            ),
                          ],
                          ),
                      ],),
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: onReviewAnswers,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2563EB),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              )
                            ),
                            child: const Text(
                              'Review Answers',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold
                              )
                            )
                            )
                        )
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          // Handles the play again button and back to home, in the case of weekly challengews.
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isWeeklyChallenge? onBackToHome : onPlayAgain, 
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0
                              ),
                              child: Text(
                                isWeeklyChallenge ? 'Back to Home' : 'Play Aagain',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold
                                )
                              )
                              )
                          )
                          )
                    ],)
                ],
              )
          )
        )
    );
  }
  // This widget for the score ring, shows the user score percentage.
  Widget _buildScoreRing() {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: CircularProgressIndicator(
              value: scorePercentage/100,
              strokeWidth: 14,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$scorePercentage%',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                )
              ),
              const Text(
                'SCORE',
                style:TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5
                ),
              ),
            ],
          ),
        ],
      )
      );
  }
// This handles the user statistics card.
Widget _buildStatCard(String value, String label, Color accentColor){
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.3,
            )
          )
        ],
      ),
    ),
    );
}
}