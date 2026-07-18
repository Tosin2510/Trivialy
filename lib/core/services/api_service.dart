import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trivialy/features/quiz/models/question_model.dart';

class ApiService{
  static const String _baseUrl = 'https://the-trivia-api.com/v2/questions';

  // This basically fetches multiple choice questions from the database.
  Future<List<Question>> fetchQuestions({
    required int amount,
    List<String> categories = const[],
    String? difficulty,
  }) async {
    // This is the part where I set up the query parameters.
    final Map<String, String> queryParameters = {
      'limit': amount.toString(),
    };
    if (categories.isNotEmpty) {
      queryParameters['categories'] = categories.join(',');
    }
    if (difficulty != null && difficulty.toLowerCase() != 'any') {
      queryParameters['difficulties'] = difficulty.toLowerCase();
    }
    final Uri url = Uri.parse(_baseUrl).replace(queryParameters: queryParameters);
    debugPrint('Fetching: $url');

    try {
      final response = await http.get(url);
      if(response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body);
        return results.map((json) => Question.fromJson(json)).toList();
      } else if (response.statusCode == 429) {
        throw Exception('Too many requests - please wait a moment and try again');
      } else {
        throw Exception('Server error: Failed to fetch trivia data');
      }
    } on http.ClientException {
      throw Exception('Network error: Please verify your internet connection.');
    }
  }
}