import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/tts_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? error;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.error,
  });

  ChatMessage copyWith({
    String? text,
    bool? isUser,
    DateTime? timestamp,
    String? error,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      error: error ?? this.error,
    );
  }
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(ChatState());

  final GeminiService _geminiService = GeminiService();
  final TTSService _ttsService = TTSService();

  void addUserMessage(String text) {
    final message = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    // Add welcome message if this is the first interaction
    if (state.messages.isEmpty) {
      _addWelcomeMessage();
    }

    state = state.copyWith(
      messages: [...state.messages, message],
      isLoading: true,
      error: null,
    );

    _generateAIResponse(text);
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      text: "Hello! I'm your AI vocabulary tutor. I can help you:\n\n"
          "• Practice vocabulary from your discoveries\n"
          "• Explain word meanings and usage\n"
          "• Create custom learning exercises\n"
          "• Answer questions about English\n\n"
          "How can I help you today?",
      isUser: false,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, welcomeMessage],
    );
  }

  Future<void> _generateAIResponse(String userMessage) async {
    try {
      // Create conversation history for context
      final conversationHistory = state.messages
          .map((msg) => '${msg.isUser ? "User" : "Assistant"}: ${msg.text}')
          .toList();

      final response = await _geminiService.generateChatResponse(
        userMessage,
        conversationHistory: conversationHistory,
      );

      final aiMessage = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
    } catch (e) {
      final errorMessage = ChatMessage(
        text: "I'm sorry, I encountered an error while processing your message. Please try again.",
        isUser: false,
        timestamp: DateTime.now(),
        error: e.toString(),
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearChat() {
    state = ChatState();
  }

  Future<void> speakMessage(String text, {bool slowly = false}) async {
    try {
      if (slowly) {
        await _ttsService.speakSlowly(text);
      } else {
        await _ttsService.speak(text);
      }
    } catch (e) {
      // Handle TTS errors silently
    }
  }

  Future<void> generateVocabularyQuiz(List<String> words) async {
    try {
      state = state.copyWith(isLoading: true);

      final questions = await _geminiService.generateVocabularyQuiz(words);
      
      final quizMessage = ChatMessage(
        text: _formatQuizMessage(questions),
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, quizMessage],
        isLoading: false,
      );
    } catch (e) {
      final errorMessage = ChatMessage(
        text: "I couldn't generate a quiz right now. Please try again later.",
        isUser: false,
        timestamp: DateTime.now(),
        error: e.toString(),
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  String _formatQuizMessage(List<QuizQuestion> questions) {
    if (questions.isEmpty) {
      return "I couldn't create a quiz with the given words. Please try with different words.";
    }

    String quizText = "🎯 **Vocabulary Quiz**\n\n";
    
    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      quizText += "**Question ${i + 1}:** ${question.question}\n\n";
      
      for (int j = 0; j < question.options.length; j++) {
        final letter = String.fromCharCode(65 + j); // A, B, C, D
        quizText += "$letter) ${question.options[j]}\n";
      }
      
      quizText += "\n";
    }
    
    quizText += "Reply with your answers (e.g., 'A, B, C, A, B') and I'll check them for you!";
    
    return quizText;
  }

  void sendQuickMessage(String message) {
    addUserMessage(message);
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});