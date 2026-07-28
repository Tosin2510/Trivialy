import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trivialy/features/quiz/controllers/quiz_controller.dart';
import 'package:trivialy/features/quiz/models/question_model.dart';
import 'package:trivialy/features/quiz/presentation/game_over_screen.dart';
import 'package:trivialy/features/quiz/presentation/review_answer_screen.dart';
import 'package:trivialy/features/quiz/services/quiz_history_service.dart';
import 'package:trivialy/features/quiz/services/weekly_challenge_service.dart';

class QuizScreen extends StatefulWidget {
  final int amount;
  final List<String> categoryIds;
  final String? difficulty;
  final String categoryTitle;
  final Duration timeLimit;
  final List<Question>? preLoadedQuestions;
  final bool isWeeklyChallenge;
  

  const QuizScreen({
    super.key,
    this.amount = 10,
    this.categoryIds = const [],
    this.difficulty,
    required this.categoryTitle,
    required this.timeLimit,
    this.preLoadedQuestions,
    this.isWeeklyChallenge = false,
  });
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}
class _QuizScreenState extends State<QuizScreen> {
  final QuizController _controller = QuizController();
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _countdownTimer;
  late int _remainingSeconds;
  bool _timeExpired = false;
  static const List<String> _optionLabels = ['A', 'B', 'C', 'D'];

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.timeLimit.inSeconds;
    _loadQuiz();
  }
  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    if (widget.preLoadedQuestions != null) {
      _controller.loadPreloadedQuestions(widget.preLoadedQuestions!);
    } else{
    await _controller.loadQuiz(
      amount: widget.amount,
      categoryIds: widget.categoryIds,
      difficulty: widget.difficulty,
    );
  }
    _stopwatch..reset()..start();
    _remainingSeconds = widget.timeLimit.inSeconds;
    _timeExpired = false;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), _onTick);
    if (mounted) setState(() {});
}


  void _onTick(Timer timer) {
    if (_remainingSeconds <= 0) {
      timer.cancel();
      _stopwatch.stop();
      _timeExpired = true;
      setState(() => _controller.submitQuiz());
      
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        QuizHistoryService().recordAttempt(
          uid: uid,
          category: widget.categoryTitle,
          difficulty: widget.difficulty,
          score: _controller.score,
          scorePercentage: _controller.scorePercentage,
          questionCount: _controller.questions.length,
          isWeeklyChallenge: widget.isWeeklyChallenge,
        );
      }
      if (widget.isWeeklyChallenge) {
        if (uid != null) {
          WeeklyChallengeService().markCompleted(
            uid, 
            _controller.score, 
            _controller.scorePercentage
          );
        }
      }
    } else {
      setState(() => _remainingSeconds--);
    }
  }

  void _selectOption(String option) {
    setState(() {
      _controller.answerQuestion(option);
    });
  }
  void _goToPrevious() {
    setState(() => _controller.previousQuestion());
  }
  void _goToNext() {
    _stopwatch.stop();
    final bool isLast = _controller.currentQuestionIndex == _controller.questions.length - 1;
    if (isLast) {
      _countdownTimer?.cancel();
      _stopwatch.stop();
      setState(() => _controller.submitQuiz());

      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        QuizHistoryService().recordAttempt(
          uid: uid,
          category: widget.categoryTitle,
          difficulty: widget.difficulty,
          score: _controller.score,
          scorePercentage: _controller.scorePercentage,
          questionCount: _controller.questions.length,
          isWeeklyChallenge: widget.isWeeklyChallenge,
        );
      }
      if (widget.isWeeklyChallenge) {
        final String? uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          WeeklyChallengeService().markCompleted(
            uid,
            _controller.score, 
            _controller.scorePercentage,
          );
        }
      }
    } else {
      setState(() => _controller.nextQuestion());
    }
  }
  String get _formattedRemaining {
    final int minutes = _remainingSeconds ~/ 60;
    final int seconds = _remainingSeconds % 60;
    // I used string interpolation here to evaluate the expression inside text quotes.
    return '$minutes:${seconds.toString().padLeft(2, '0')}';  
  }
  int get _correctCount {
    int count = 0;
    for (int i= 0; i < _controller.questions.length; i++) {
    if (_controller.selectedAnswers[i] == _controller.questions[i].correctAnswer) {
      count++;
    }
    }
    return count;
  }
  int get _wrongCount => _controller.questions.length - _correctCount;

  @override
  Widget build(BuildContext context) {
    switch (_controller.state) {
      case QuizState.loading:
        return _buildLoading();
      case QuizState.error:
        return _buildError();
      case QuizState.gameOver:        
        return _buildGameOver();
      case QuizState.playing:
        return _buildQuiz(context);
    }
  }
  Widget _buildLoading() {
    return const Scaffold(
      backgroundColor: Color(0xFFF1F5F9),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF2563EB))
        )
    );
  }
  Widget _buildError() {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 56,
                  color: Color(0xFFDC2626),
                ),
                const SizedBox(height: 16),
                Text(
                  _controller.errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  )
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)
                      ),
                  ),
                  child: const Text('Try Again',
                     style: TextStyle(fontWeight: FontWeight.bold)
                  )
                )
              ],
              )
          )
        )
      ),
    );
  }
  Widget _buildQuiz(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final question = _controller.questions[_controller.currentQuestionIndex];
    final String? selected = _controller.selectedAnswers[_controller.currentQuestionIndex];
    final bool isFirst = _controller.currentQuestionIndex == 0;
    final bool isLast = _controller.currentQuestionIndex == _controller.questions.length - 1;
    final double progress = (_controller.currentQuestionIndex + 1)/ _controller.questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(progress, isLast, screenWidth),
            Expanded(child: 
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                (screenWidth * 0.06).clamp(16.0, 24.0),
                24,
                (screenWidth * 0.06).clamp(16.0, 24.0),
                16
                ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuestionCard(question, screenWidth),
                  const SizedBox(height: 20),
                  ..._buildOptions(question, selected, screenWidth),
                ],
              ),
            ),
          ),
          _buildNavigationBar(isFirst, isLast, screenWidth),
        ],
        )
        )
    );
  }
  Widget _buildHeader(double progress, bool isLast, double screenWidth) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        (screenWidth * 0.06).clamp(16.0, 24.0),
        12, 
        (screenWidth * 0.06).clamp(16.0, 24.0),
        0
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close,
                  color: Color(0xFF0F172A)),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  widget.categoryTitle,
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: (screenWidth * 0.042).clamp(14.0, 18.0),
                  )
                ),
                const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_controller.currentQuestionIndex + 1} of ${_controller.questions.length}',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  fontSize: (screenWidth * 0.036).clamp(12.0, 14.0),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _remainingSeconds <= 30 
                    ?const Color(0xFFFEE2E2)
                    : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined,
                    size: 16,
                    color: _remainingSeconds <= 30
                       ? const Color(0xFFDC2626)
                       : const Color(0xFFB45309)
                    ),
                    const SizedBox(width: 4,),
                    Text(
                      _formattedRemaining,
                      style: TextStyle(
                        color: _remainingSeconds <= 30
                          ? const Color(0xFFDC2626)
                          : const Color(0xFFB45309),
                        fontWeight: FontWeight.bold,
                        fontSize: (screenWidth * 0.033).clamp(12.0, 13.0),
                      )
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: 
                const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
            )
          )
        ],
      ),
    );
  }
  Widget _buildQuestionCard(Question question, double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all((screenWidth * 0.05).clamp(16.0, 24.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0,4),
          ),
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.category.toUpperCase(),
            style: TextStyle(
              fontSize: (screenWidth * 0.03).clamp(11.0, 13.0),
              fontWeight: FontWeight.bold,
              color: Color(0xFF2563EB),
              letterSpacing: 0.5,
            )
          ),
          const SizedBox(height: 8),
          Text(
            question.questionText,
            style: TextStyle(
              fontSize: (screenWidth * 0.05).clamp(17.0, 22.0),
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              height: 1.3,
            )
          )
        ],
      ),
    );
  }

  Widget _buildGameOver() {
    return GameOverScreen(
      scorePercentage: _controller.scorePercentage, 
      score: _controller.score, 
      correctCount: _correctCount, 
      wrongCount: _wrongCount, 
      timeDisplay: _formattedRemaining, 
      timeExpired: _timeExpired, 
      onPlayAgain: _loadQuiz, 
      isWeeklyChallenge: widget.isWeeklyChallenge,
      onReviewAnswers: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewAnswerScreen(
              questions: _controller.questions, 
              selectedAnswers: _controller.selectedAnswers
              )
            )
        );
      },
      onBackToHome: () {
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      );
  }

  List<Widget> _buildOptions(Question question, String? selected, double screenWidth) {
    final List<String> options = question.allOptions;
    final double avatarRadius = (screenWidth * 0.037).clamp(12.0, 16.0);
    final double optionPadding = (screenWidth * 0.04).clamp(14.0, 18.0);
    return List.generate(options.length, (index) {
      final String option = options[index];
      final bool isSelected = selected == option;
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: GestureDetector(
          onTap: () => _selectOption(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              horizontal: optionPadding,
              vertical: optionPadding
            ),
            decoration: BoxDecoration(
              color: isSelected
                ? const Color(0xFF2563EB).withValues(alpha: 0.08)
                : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: 
                  isSelected ? const Color(0xFF2563EB):
                  Colors.transparent,
                width: 1.5,
                ),
                boxShadow: isSelected ? [] : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0,4)
                  ),
                ],
            ),
            child: Row(
              children: [
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: isSelected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF2563EB).withValues(alpha: 0.1),
                    child: Text(
                      _optionLabels[index],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: (screenWidth * 0.033).clamp(12.0, 13.0),
                        color:
                          isSelected? Colors.white : const Color(0xFF2563EB)
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: (screenWidth * 0.038).clamp(14.0, 16.0),
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A)
                      )
                    )
                    )
              ],),
            ),
          ),
      );
    }
    );
  }
  Widget _buildNavigationBar(bool isFirst, bool isLast, double screenWidth) {
    final double buttonHeight = (screenWidth * 0.14).clamp(48.0, 56.0);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (screenWidth * 0.06).clamp(16.0, 24.0),
        vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28)
        )
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: buttonHeight,
              child: OutlinedButton(
                onPressed: isFirst ? null: _goToPrevious,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F172A),
                  disabledForegroundColor: const Color(0xFFCBD5E1),
                  side: BorderSide(
                    color: isFirst 
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFFCBD5E1)
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)
                      )
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, size: 18),
                    SizedBox(width: 8),
                    Text('Previous',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    )
                    )
                  ],
                  ),
              )
            )
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: _goToNext, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          isLast ? 'Submit Quiz'
                          : 'Next Question',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(isLast ? Icons.check_rounded
                         : Icons.arrow_forward,
                         size: 18
                      )
                    ],
                    )
                  )
              )
              )
        ],
      ),
    );
  }
}