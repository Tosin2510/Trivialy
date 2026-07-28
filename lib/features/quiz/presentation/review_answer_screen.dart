import 'package:flutter/material.dart';
import 'package:trivialy/features/quiz/models/question_model.dart';

// This screen allows users to check the answer they picked and the correct answer for the questions.
class ReviewAnswerScreen extends StatelessWidget {
  final List<Question> questions;
  final Map<int, String> selectedAnswers;

  const ReviewAnswerScreen({
    super.key,
    required this.questions,
    required this.selectedAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB
              ((screenWidth * 0.06).clamp(16.0, 24.0), 
              12, 
              (screenWidth * 0.06).clamp(16.0, 24.0),
              0               
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF0F172A)
                  ),
                  onPressed: () => Navigator.pop(context),                   
                  ),
                  const Text(
                    'Review Answers',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )
                  ),
                  const SizedBox(width: 48),
            ],
            ),
              ),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(
                    (screenWidth * 0.06).clamp(16.0, 24.0),
                  ),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    return _buildQuestionReviewCard(index, screenWidth);
                  }
                  )
              )
          ],
        ))
    );
  }
  Widget _buildQuestionReviewCard(int index, double screenWidth) {
    final Question question = questions[index];
    final String? userAnswer = selectedAnswers[index];
    final bool wasAnswered = userAnswer != null;
    final bool wasCorrect = userAnswer == question.correctAnswer;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      padding: EdgeInsets.all(
        (screenWidth * 0.05).clamp(
          16.0, 20.0)
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Text(
                  'Q${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB)
                  )
                )
              ),
              const Spacer(),
              Icon(
                !wasAnswered
                  ? Icons.remove_circle_outline_rounded
                  : wasCorrect
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: !wasAnswered
                    ? const Color(0xFF94A3B8)
                    : wasCorrect
                       ? const Color(0xFF16A34A)
                       : const Color(0xFFDC2626),
                size: 20,
              )
            ],
          ),
          const SizedBox(height: 10,),
          Text(
            question.questionText,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              height: 1.3
            )
          ),
          const SizedBox(height: 14,),
          if (wasAnswered) ...[
            _buildAnswerRow(
              label: 'Your answer',
              answer: userAnswer,
              color: wasCorrect ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
            ),
            const SizedBox(height: 8),
          ] else ...[
            _buildAnswerRow(
              label: 'Your answer',
              answer: 'Not answered',
              color: const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 8),
          ],
          if (!wasCorrect)
            _buildAnswerRow(
              label: 'Correct answer',
              answer: question.correctAnswer,
              color: const Color(0xFF16A34A),
            )
        ],
      ),
    );
  }
  Widget _buildAnswerRow({
    required String label,
    required String answer,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.03)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Expanded(
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            )
          )
        ],
      ),
    );
  }
}