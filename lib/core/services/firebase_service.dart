import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';
import '../errors/exceptions.dart' as app_exceptions;

/// Service for Firebase initialization and configuration
class FirebaseService {
  static bool _isInitialized = false;

  /// Initialize Firebase with proper error handling
  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
      
      if (kDebugMode) {
        print('Firebase initialized successfully');
      }
    } on FirebaseException catch (e) {
      throw app_exceptions.FirebaseException('Failed to initialize Firebase: ${e.message}');
    } catch (e) {
      throw app_exceptions.FirebaseException('Unexpected error during Firebase initialization: $e');
    }
  }

  /// Check if Firebase is initialized
  static bool get isInitialized => _isInitialized;

  /// Get Firebase app instance
  static FirebaseApp get app {
    if (!_isInitialized) {
      throw const app_exceptions.FirebaseException('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
    return Firebase.app();
  }

  /// Configure Firebase for testing
  static Future<void> configureForTesting() async {
    if (kDebugMode) {
      // Configure Firebase settings for testing
      // This can include emulator settings, test configurations, etc.
      print('Firebase configured for testing environment');
    }
  }

  /// Reset Firebase state (useful for testing)
  static void reset() {
    _isInitialized = false;
  }
}