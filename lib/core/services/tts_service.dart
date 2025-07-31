import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();
  
  late FlutterTts _flutterTts;
  bool _isInitialized = false;
  
  /// Initialize TTS service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _flutterTts = FlutterTts();
    
    // Configure TTS settings
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5); // Slower for learning
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    // Set completion handler
    _flutterTts.setCompletionHandler(() {
      // Can be used for UI updates when speech completes
    });
    
    // Set error handler
    _flutterTts.setErrorHandler((message) {
      print('TTS Error: $message');
    });
    
    _isInitialized = true;
  }
  
  /// Speak a word or phrase
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    // Stop any current speech
    await _flutterTts.stop();
    
    // Speak the text
    await _flutterTts.speak(text);
  }
  
  /// Speak a word slowly for pronunciation learning
  Future<void> speakSlowly(String text) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    // Set slower rate for pronunciation
    await _flutterTts.setSpeechRate(0.3);
    
    // Stop any current speech
    await _flutterTts.stop();
    
    // Speak the text slowly
    await _flutterTts.speak(text);
    
    // Restore normal rate after a delay
    Future.delayed(const Duration(seconds: 3), () async {
      await _flutterTts.setSpeechRate(0.5);
    });
  }
  
  /// Stop current speech
  Future<void> stop() async {
    if (!_isInitialized) return;
    await _flutterTts.stop();
  }
  
  /// Pause current speech
  Future<void> pause() async {
    if (!_isInitialized) return;
    await _flutterTts.pause();
  }
  
  /// Check if TTS is currently speaking
  Future<bool> isSpeaking() async {
    if (!_isInitialized) return false;
    // Note: FlutterTts doesn't have a direct isSpeaking method
    // This is a placeholder that checks if the language is available
    final available = await _flutterTts.isLanguageAvailable("en-US");
    return available ?? false;
  }
  
  /// Get available languages
  Future<List<String>> getLanguages() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    final languages = await _flutterTts.getLanguages;
    return List<String>.from(languages ?? []);
  }
  
  /// Set speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    await _flutterTts.setSpeechRate(rate.clamp(0.0, 1.0));
  }
  
  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
  }
  
  /// Set pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    await _flutterTts.setPitch(pitch.clamp(0.5, 2.0));
  }
  
  /// Clean up resources
  void dispose() {
    if (_isInitialized) {
      _flutterTts.stop();
    }
  }
}