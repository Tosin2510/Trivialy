import 'package:html_character_entities/html_character_entities.dart';

// A model for the questions from the trivia api.
class Question{
  final String category;
  final String difficulty;
  final String questionText;
  final String correctAnswer;
  final List<String> allOptions;
  Question({
    required this.category,
    required this.difficulty,
    required this.questionText,
    required this.correctAnswer,
    required this.allOptions
  });
  factory Question.fromJson(Map<String, dynamic> json) {
    // I am switching to trivia api.
    final String rawQuestionText = json['question'] is Map
       ?(json['question']['text'] ?? '')
       : (json['question']?.toString() ?? '');
    final String decodeQuestionText = HtmlCharacterEntities.decode(rawQuestionText);
    final String decodeCorrectAnswer = HtmlCharacterEntities.decode(
      json['correctAnswer'] ?.toString() ?? '',);

    List<String> choices = (json['incorrectAnswers'] as List? ?? [])
       .map((answer) => HtmlCharacterEntities.decode(answer.toString())).toList();
    choices.add(decodeCorrectAnswer);
    choices.shuffle();

    return Question(
      category: json['category']?.toString() ?? 'General',
      difficulty: json['difficulty']?.toString() ?? 'medium',
      questionText: decodeQuestionText,
      correctAnswer: decodeCorrectAnswer,
      allOptions: choices,
    );
  }
}