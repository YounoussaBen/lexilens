import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/tts_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? error;
  final bool isStreaming;
  final String? streamingText;
  final String?
  displayText; // Text to display in UI (if different from actual text)
  final String? fullText; // Store the complete text when streaming

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.error,
    this.isStreaming = false,
    this.streamingText,
    this.displayText,
    this.fullText,
  });

  ChatMessage copyWith({
    String? text,
    bool? isUser,
    DateTime? timestamp,
    String? error,
    bool? isStreaming,
    String? streamingText,
    String? displayText,
    String? fullText,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      error: error ?? this.error,
      isStreaming: isStreaming ?? this.isStreaming,
      streamingText: streamingText ?? this.streamingText,
      displayText: displayText ?? this.displayText,
      fullText: fullText ?? this.fullText,
    );
  }
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({this.messages = const [], this.isLoading = false, this.error});

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

  void addUserMessage(String text, {String? displayText}) {
    final message = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      displayText: displayText, // This will be shown in UI if provided
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
      text:
          "Hello! I'm your AI vocabulary tutor. I can help you:\n\n"
          "• Practice vocabulary from your discoveries\n"
          "• Explain word meanings and usage\n"
          "• Create custom learning exercises\n"
          "• Answer questions about English\n\n"
          "How can I help you today?",
      isUser: false,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(messages: [...state.messages, welcomeMessage]);
  }

  Future<void> _generateAIResponse(String userMessage) async {
    try {
      // Create conversation history for context
      final conversationHistory = state.messages
          .map((msg) => '${msg.isUser ? "User" : "Assistant"}: ${msg.text}')
          .toList();

      // Add a placeholder message for streaming
      final streamingMessage = ChatMessage(
        text: "",
        displayText: "",
        fullText: "",
        isUser: false,
        timestamp: DateTime.now(),
        isStreaming: true,
      );

      final messages = [...state.messages, streamingMessage];
      state = state.copyWith(messages: messages);

      // Get AI response
      final aiResponse = await _geminiService.generateChatResponse(
        userMessage,
        conversationHistory: conversationHistory,
      );

      // Stream the response
      await _streamResponse(aiResponse, messages.length - 1);
    } catch (e) {
      // Handle errors
      final messages = List<ChatMessage>.from(state.messages);

      // Remove streaming message if it exists
      if (messages.isNotEmpty && messages.last.isStreaming) {
        messages.removeLast();
      }

      final errorMessage = ChatMessage(
        text:
            "I'm sorry, I encountered an error while processing your message. Please try again.",
        isUser: false,
        timestamp: DateTime.now(),
        error: e.toString(),
      );

      state = state.copyWith(
        messages: [...messages, errorMessage],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _streamResponse(String fullResponse, int messageIndex) async {
    const charactersPerUpdate = 2;
    const updateIntervalMs = 50;

    final messages = List<ChatMessage>.from(state.messages);
    final messageToUpdate = messages[messageIndex];

    for (int i = 0; i <= fullResponse.length; i += charactersPerUpdate) {
      if (i > fullResponse.length) i = fullResponse.length;

      final currentText = fullResponse.substring(0, i);

      messages[messageIndex] = messageToUpdate.copyWith(
        text: fullResponse, // Keep full text for saving
        displayText: currentText, // Show partial text for UI
        fullText: fullResponse,
        isStreaming: i < fullResponse.length,
      );

      state = state.copyWith(messages: List.from(messages));

      if (i < fullResponse.length) {
        await Future.delayed(const Duration(milliseconds: updateIntervalMs));
      }
    }

    // Final update to ensure streaming is complete
    messages[messageIndex] = messageToUpdate.copyWith(
      text: fullResponse,
      displayText: fullResponse,
      fullText: fullResponse,
      isStreaming: false,
    );

    state = state.copyWith(messages: List.from(messages), isLoading: false);
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
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(),
);
