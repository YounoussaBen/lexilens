import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  
  late final String _apiKey;
  
  GeminiService() {
    _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }
  }
  
  /// Generate chat response from Gemini
  Future<String> generateChatResponse(String userMessage, {List<String>? conversationHistory}) async {
    try {
      final prompt = _buildChatPrompt(userMessage, conversationHistory);
      return await _callGeminiAPI(prompt);
    } catch (e) {
      throw Exception('Failed to generate chat response: $e');
    }
  }
  
  /// Generate word of the day with definition, pronunciation, and examples
  Future<WordOfTheDay> generateWordOfTheDay() async {
    try {
      const prompt = '''
Generate a word of the day for English vocabulary learning. Provide the response in JSON format with the following structure:
{
  "word": "example",
  "pronunciation": "/ɪɡˈzæmpəl/",
  "partOfSpeech": "noun",
  "definition": "A thing characteristic of its kind or illustrating a general rule.",
  "example": "This painting is a perfect example of the artist's work.",
  "etymology": "From Latin exemplum, meaning 'sample' or 'pattern'.",
  "difficulty": "intermediate"
}

Choose an interesting, useful word that would be valuable for English learners. Make sure the pronunciation is in IPA format and the example sentence clearly demonstrates the word's usage.
      ''';
      
      final response = await _callGeminiAPI(prompt);
      return WordOfTheDay.fromJson(jsonDecode(_extractJsonFromResponse(response)));
    } catch (e) {
      throw Exception('Failed to generate word of the day: $e');
    }
  }
  
  /// Generate vocabulary quiz based on provided words
  Future<List<QuizQuestion>> generateVocabularyQuiz(List<String> words) async {
    try {
      final prompt = '''
Create a vocabulary quiz with 5 multiple choice questions based on these words: ${words.join(', ')}.
Provide the response in JSON format as an array of questions:
[
  {
    "question": "What does the word 'example' mean?",
    "options": ["A sample or illustration", "A type of food", "A musical instrument", "A color"],
    "correctAnswer": 0,
    "explanation": "Example means a sample or illustration of something."
  }
]

Make the questions engaging and educational, with clear explanations.
      ''';
      
      final response = await _callGeminiAPI(prompt);
      final List<dynamic> questionsJson = jsonDecode(_extractJsonFromResponse(response));
      return questionsJson.map((q) => QuizQuestion.fromJson(q)).toList();
    } catch (e) {
      throw Exception('Failed to generate vocabulary quiz: $e');
    }
  }
  
  /// Build chat prompt with context
  String _buildChatPrompt(String userMessage, List<String>? conversationHistory) {
    final context = '''
You are LexiLens AI, a friendly vocabulary tutor for English learners. Your role is to:
- Help users learn new vocabulary words
- Explain word meanings, usage, and pronunciation
- Provide examples and practice exercises
- Answer questions about English grammar and vocabulary
- Be encouraging and educational

Keep responses conversational, helpful, and focused on vocabulary learning.
    ''';
    
    String prompt = context;
    
    if (conversationHistory != null && conversationHistory.isNotEmpty) {
      prompt += '\n\nConversation history:\n${conversationHistory.join('\n')}\n\n';
    }
    
    prompt += 'User: $userMessage\nLexiLens AI:';
    
    return prompt;
  }
  
  /// Call Gemini API with the given prompt
  Future<String> _callGeminiAPI(String prompt) async {
    final uri = Uri.parse('$_baseUrl?key=$_apiKey');
    
    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 1024,
      }
    };
    
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );
    
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final candidates = responseData['candidates'] as List?;
      
      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content'];
        final parts = content['parts'] as List?;
        
        if (parts != null && parts.isNotEmpty) {
          return parts[0]['text'] ?? 'No response generated';
        }
      }
      
      throw Exception('Unexpected response format from Gemini API');
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception('Gemini API error: ${errorData['error']['message']}');
    }
  }
  
  /// Extract JSON from response text (in case AI adds extra text)
  String _extractJsonFromResponse(String response) {
    // Find the first { and last } to extract JSON
    final startIndex = response.indexOf('{');
    final endIndex = response.lastIndexOf('}');
    
    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return response.substring(startIndex, endIndex + 1);
    }
    
    // If no JSON brackets found, return the whole response
    return response;
  }
}

/// Word of the Day model
class WordOfTheDay {
  final String word;
  final String pronunciation;
  final String partOfSpeech;
  final String definition;
  final String example;
  final String etymology;
  final String difficulty;
  final DateTime generatedAt;
  
  WordOfTheDay({
    required this.word,
    required this.pronunciation,
    required this.partOfSpeech,
    required this.definition,
    required this.example,
    required this.etymology,
    required this.difficulty,
    required this.generatedAt,
  });
  
  factory WordOfTheDay.fromJson(Map<String, dynamic> json) {
    return WordOfTheDay(
      word: json['word'] ?? '',
      pronunciation: json['pronunciation'] ?? '',
      partOfSpeech: json['partOfSpeech'] ?? '',
      definition: json['definition'] ?? '',
      example: json['example'] ?? '',
      etymology: json['etymology'] ?? '',
      difficulty: json['difficulty'] ?? '',
      generatedAt: DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'pronunciation': pronunciation,
      'partOfSpeech': partOfSpeech,
      'definition': definition,
      'example': example,
      'etymology': etymology,
      'difficulty': difficulty,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}

/// Quiz Question model
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  
  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
  
  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? 0,
      explanation: json['explanation'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }
}