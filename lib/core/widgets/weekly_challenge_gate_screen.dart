import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trivialy/features/quiz/models/question_model.dart';
import 'package:trivialy/features/quiz/presentation/quiz_screen.dart';
import 'package:trivialy/features/quiz/services/weekly_challenge_service.dart';

// This is basically a screen that checks if a user has completed the weekly challenge earlier and if they have not, it fetch the questions.
class WeeklyChallengeGateScreen extends StatefulWidget{
  const WeeklyChallengeGateScreen({super.key});

  @override
  State<WeeklyChallengeGateScreen> createState() => _WeeklyChallengeGateScreenState();
}

class _WeeklyChallengeGateScreenState extends State<WeeklyChallengeGateScreen> {
  final WeeklyChallengeService _service = WeeklyChallengeService();
  bool _isLoading = true;
  bool _alreadyCompleted = false;
  List<Question> _questions = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

// Loads questions for weekly challenge and also check if the user is signed in.
  Future<void> _load() async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "You need to be signed in to participate in the weekly challenge";
      });
      return;
    }

    try {
      // Checks if the user has done the challenge at all for that week.
      final bool completed = await _service.hasCompletedThisWeekChallenge(uid);
      if (completed) {
        setState(() {
          _isLoading = false;
          _alreadyCompleted = true;
        });
        return;
      }
      // This part fetches the questions for the weekly challenge.
      final List<Question> questions = await _service.getWeeklyQuestions();
      debugPrint('Gate screen: received ${questions.length} questions from service');
      setState(() {
      _questions = questions;
      _isLoading = false;
      });
    } catch (e) {
      debugPrint('Gate screen: Caught exception $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load weekly challenge. Please try it again.';
      });
    }
  }
  
  // This part actually builds the screen for if the user has completed the challenge, if not, it takes them to the quiz screen.
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFFF1F5F9),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
      );
    }

// If they have alReady completed, it shows them a message telling them.
    if(_alreadyCompleted) {
      return _buildMessageScreen(
        icon: Icons.check_circle_rounded,
        iconColor: const Color(0xFF16A34A),
        title: "You've already completed this week challenge",
        message: 'Come back next week for a new set of challenge questions.',
        showCountdown: true,
      );
    }

// If an error occurs trying to fetch the questions, it shows them a message.
    if (_errorMessage != null) {
      return _buildMessageScreen(
        icon: Icons.error_outline_rounded,
        iconColor: const Color(0xFFDC2626),
        title: 'Something went wrong',
        message: _errorMessage!,
      );
    }

// If no issues, it leads the user to quiz scree.
    return QuizScreen(
      categoryTitle: 'Weekly Challenge', 
      amount: _questions.length,
      difficulty: 'hard',
      categoryIds: const [],
      timeLimit: const Duration(minutes: 5),
      preLoadedQuestions: _questions,
      isWeeklyChallenge: true,
    );
  }


// This is the part that builds the screen if the user has done the challenge earlier for that week.
  Widget _buildMessageScreen({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    bool showCountdown = false,
  }) {
    // This part calculate the number of days left until the next challenge.
    final int daysUntilReset = _daysUntilNextChallenge();
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 48, color: iconColor,),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500
                    )
                  ),
                  // This is the part that shows the days left to the next challenge on the screen.
                  if (showCountdown) ...[
                    const SizedBox(height: 20,),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        daysUntilReset == 1
                           ? 'Resets tomorrow'
                           : 'Resets in $daysUntilReset days',
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        )
                      ),
                    )
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      // This part, onpressing it, it takes the user back to the home screen...
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ), 
                      child: const Text('Back to Home',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ),
    );
  }
  int _daysUntilNextChallenge() {
    final DateTime nowUtc = DateTime.now().toUtc();
    final int daysUntil = (DateTime.monday - nowUtc.weekday + 7) % 7;
    return daysUntil == 0 ? 7 : daysUntil;
  }
}
