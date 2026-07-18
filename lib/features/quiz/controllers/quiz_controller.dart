import 'package:trivialy/core/services/api_service.dart';
import 'package:trivialy/features/quiz/models/question_model.dart';

enum QuizState {loading, playing, error, gameOver}

class QuizController {
  final ApiService _apiService = ApiService();

  List<Question> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  QuizState state = QuizState.loading;
  String errorMessage = '';
  // this part keeps track of the player's selected answer.
  final Map<int, String> selectedAnswers = {};
  // This map keeps track of correctly answered questions that has already been rewarded points.
  final Set<int> _correctlyAnsweredIndices = {};

  // This part basically fetches questions from the API.
  Future<void> loadQuiz({
    int amount = 10,
    List<String> categoryIds = const [],
    String? difficulty
    }) async {
      state = QuizState.loading;
      try {
        questions = await _apiService.fetchQuestions(
          amount: amount,
          categories: categoryIds,
          difficulty: difficulty,
        );
        
        if (questions.isEmpty) {
          state = QuizState.error;
          errorMessage = 'No questions found. Try changing filters!';
        } else {
          currentQuestionIndex = 0;
          score = 0;
          selectedAnswers.clear();
          _correctlyAnsweredIndices.clear();
          state = QuizState.playing;
        }
      } catch (e) {
        state = QuizState.error;
        errorMessage = e.toString().replaceAll('Exception:', '');
      }
    }
    bool answerQuestion(String selectedAnswer) {
      final currentQuestion = questions[currentQuestionIndex];
      bool isCorrect = currentQuestion.correctAnswer == selectedAnswer;
      selectedAnswers[currentQuestionIndex] = selectedAnswer;

      if (isCorrect) {
        // Points should only be awarded if they have not already been awarded for a particular question.
        if (!_correctlyAnsweredIndices.contains(currentQuestionIndex)) {
          score += 10;
          _correctlyAnsweredIndices.add(currentQuestionIndex);
        }
      } else {
        if (_correctlyAnsweredIndices.contains(currentQuestionIndex)) {
          score -= 10;
          _correctlyAnsweredIndices.remove(currentQuestionIndex);
        }
      }
      return isCorrect;
    }
    void nextQuestion() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      }
    }
    void previousQuestion() {
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
      }
    }
    void submitQuiz() {
      state = QuizState.gameOver;
    }

    int get scorePercentage {
      if (questions.isEmpty) return 0;

      int maxPossibleScore = questions.length * 10;
      double percentage = (score/ maxPossibleScore) * 100;

      return percentage.round();
    }

    void loadPreloadedQuestions(List<Question> preloadedQuestions) {
      questions = preloadedQuestions;
      currentQuestionIndex = 0;
      score = 0;
      selectedAnswers.clear();
      _correctlyAnsweredIndices.clear();
      state = questions.isEmpty ? QuizState.error : QuizState.playing;
      if (questions.isEmpty) {
        errorMessage = 'No questions found. Try changing filters.';
      }
    }
}