import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'gemini_service.dart';

class WordOfTheDayService {
  static const String _collection = 'word_of_the_day';
  static const String _userCollection = 'users';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GeminiService _geminiService = GeminiService();
  
  /// Get word of the day for the current user
  Future<WordOfTheDay?> getWordOfTheDay(String userId) async {
    try {
      // Get today's date as string (YYYY-MM-DD)
      final today = _getTodayString();
      
      // Check if user has today's word
      final userWordDoc = await _firestore
          .collection(_userCollection)
          .doc(userId)
          .collection(_collection)
          .doc(today)
          .get();
      
      if (userWordDoc.exists) {
        // Return existing word for today
        return WordOfTheDay.fromJson(userWordDoc.data()!);
      }
      
      // Check if global word exists for today
      final globalWordDoc = await _firestore
          .collection(_collection)
          .doc(today)
          .get();
      
      WordOfTheDay wordOfTheDay;
      
      if (globalWordDoc.exists) {
        // Use existing global word
        wordOfTheDay = WordOfTheDay.fromJson(globalWordDoc.data()!);
      } else {
        // Generate new word for today
        wordOfTheDay = await _geminiService.generateWordOfTheDay();
        
        // Save to global collection
        await _firestore
            .collection(_collection)
            .doc(today)
            .set(wordOfTheDay.toJson());
      }
      
      // Save to user's personal collection
      await _firestore
          .collection(_userCollection)
          .doc(userId)
          .collection(_collection)
          .doc(today)
          .set(wordOfTheDay.toJson());
      
      return wordOfTheDay;
      
    } catch (e) {
      // Error getting word of the day: $e
      return null;
    }
  }
  
  /// Get word history for user
  Future<List<WordOfTheDay>> getWordHistory(String userId, {int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_userCollection)
          .doc(userId)
          .collection(_collection)
          .orderBy('generatedAt', descending: true)
          .limit(limit)
          .get();
      
      return querySnapshot.docs
          .map((doc) => WordOfTheDay.fromJson(doc.data()))
          .toList();
          
    } catch (e) {
      // Error getting word history: $e
      return [];
    }
  }
  
  /// Mark word as learned/saved
  Future<void> markWordAsLearned(String userId, String word) async {
    try {
      await _firestore
          .collection(_userCollection)
          .doc(userId)
          .collection('learned_words')
          .doc(word.toLowerCase())
          .set({
        'word': word,
        'learnedAt': FieldValue.serverTimestamp(),
        'source': 'word_of_the_day',
      });
    } catch (e) {
      // Error marking word as learned: $e
    }
  }
  
  /// Check if word refresh is needed (for debugging/testing)
  bool shouldRefreshWord(WordOfTheDay? currentWord) {
    if (currentWord == null) return true;
    
    final today = DateTime.now();
    final wordDate = currentWord.generatedAt;
    
    // Check if word is from today
    return wordDate.year != today.year ||
           wordDate.month != today.month ||
           wordDate.day != today.day;
  }
  
  /// Force refresh word of the day (for testing)
  Future<WordOfTheDay?> forceRefreshWord(String userId) async {
    try {
      final today = _getTodayString();
      
      // Delete existing user word for today
      await _firestore
          .collection(_userCollection)
          .doc(userId)
          .collection(_collection)
          .doc(today)
          .delete();
      
      // Generate new word
      return await getWordOfTheDay(userId);
      
    } catch (e) {
      // Error force refreshing word: $e
      return null;
    }
  }
  
  /// Clean up old words (keep only last 30 days)
  Future<void> cleanupOldWords(String userId) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      final oldWordsQuery = await _firestore
          .collection(_userCollection)
          .doc(userId)
          .collection(_collection)
          .where('generatedAt', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();
      
      final batch = _firestore.batch();
      for (final doc in oldWordsQuery.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      
    } catch (e) {
      // Error cleaning up old words: $e
    }
  }
  
  /// Get today's date as string (YYYY-MM-DD)
  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
  
  /// Get statistics for user's word learning
  Future<Map<String, int>> getWordStats(String userId) async {
    try {
      final historySnapshot = await _firestore
          .collection(_userCollection)
          .doc(userId)
          .collection(_collection)
          .get();
      
      final learnedSnapshot = await _firestore
          .collection(_userCollection)
          .doc(userId)
          .collection('learned_words')
          .where('source', isEqualTo: 'word_of_the_day')
          .get();
      
      return {
        'totalWords': historySnapshot.docs.length,
        'learnedWords': learnedSnapshot.docs.length,
        'streak': await _calculateStreak(userId),
      };
      
    } catch (e) {
      // Error getting word stats: $e
      return {'totalWords': 0, 'learnedWords': 0, 'streak': 0};
    }
  }
  
  /// Calculate learning streak
  Future<int> _calculateStreak(String userId) async {
    try {
      final now = DateTime.now();
      int streak = 0;
      
      for (int i = 0; i < 365; i++) { // Check up to a year
        final checkDate = now.subtract(Duration(days: i));
        final dateString = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
        
        final docSnapshot = await _firestore
            .collection(_userCollection)
            .doc(userId)
            .collection(_collection)
            .doc(dateString)
            .get();
        
        if (docSnapshot.exists) {
          streak++;
        } else {
          break; // Streak broken
        }
      }
      
      return streak;
      
    } catch (e) {
      // Error calculating streak: $e
      return 0;
    }
  }
}

/// Provider for Word of the Day service
final wordOfTheDayServiceProvider = Provider<WordOfTheDayService>((ref) {
  return WordOfTheDayService();
});

/// Provider for current word of the day
final currentWordOfTheDayProvider = FutureProvider.family<WordOfTheDay?, String>((ref, userId) async {
  final service = ref.watch(wordOfTheDayServiceProvider);
  return await service.getWordOfTheDay(userId);
});

/// Provider for word history
final wordHistoryProvider = FutureProvider.family<List<WordOfTheDay>, String>((ref, userId) async {
  final service = ref.watch(wordOfTheDayServiceProvider);
  return await service.getWordHistory(userId);
});

/// Provider for word stats
final wordStatsProvider = FutureProvider.family<Map<String, int>, String>((ref, userId) async {
  final service = ref.watch(wordOfTheDayServiceProvider);
  return await service.getWordStats(userId);
});