import '../entities/saved_word.dart';

abstract class SavedWordsRepository {
  Stream<List<SavedWord>> getSavedWords();
  
  Future<void> saveWord(SavedWord word);
  
  Future<void> updateWord(SavedWord word);
  
  Future<void> deleteWord(String wordId);
  
  Future<SavedWord?> getWordById(String wordId);
  
  Future<bool> isWordSaved(String word);
  
  Future<void> incrementPracticeCount(String wordId);
  
  Future<void> toggleFavorite(String wordId);
  
  Future<List<SavedWord>> searchWords(String query);
  
  Future<List<SavedWord>> getWordsByTag(String tag);
  
  Future<List<SavedWord>> getRecentWords({int limit = 10});
  
  Future<List<SavedWord>> getFavoriteWords();
}