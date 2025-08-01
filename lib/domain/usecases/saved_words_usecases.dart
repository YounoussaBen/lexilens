import '../entities/saved_word.dart';
import '../repositories/saved_words_repository.dart';

class SaveWordUseCase {
  final SavedWordsRepository repository;

  SaveWordUseCase(this.repository);

  Future<void> call(SavedWord word) async {
    await repository.saveWord(word);
  }
}

class GetSavedWordsUseCase {
  final SavedWordsRepository repository;

  GetSavedWordsUseCase(this.repository);

  Stream<List<SavedWord>> call() {
    return repository.getSavedWords();
  }
}

class DeleteSavedWordUseCase {
  final SavedWordsRepository repository;

  DeleteSavedWordUseCase(this.repository);

  Future<void> call(String wordId) async {
    await repository.deleteWord(wordId);
  }
}

class ToggleFavoriteWordUseCase {
  final SavedWordsRepository repository;

  ToggleFavoriteWordUseCase(this.repository);

  Future<void> call(String wordId) async {
    await repository.toggleFavorite(wordId);
  }
}

class IncrementPracticeCountUseCase {
  final SavedWordsRepository repository;

  IncrementPracticeCountUseCase(this.repository);

  Future<void> call(String wordId) async {
    await repository.incrementPracticeCount(wordId);
  }
}

class SearchSavedWordsUseCase {
  final SavedWordsRepository repository;

  SearchSavedWordsUseCase(this.repository);

  Future<List<SavedWord>> call(String query) async {
    return await repository.searchWords(query);
  }
}

class GetRecentWordsUseCase {
  final SavedWordsRepository repository;

  GetRecentWordsUseCase(this.repository);

  Future<List<SavedWord>> call({int limit = 10}) async {
    return await repository.getRecentWords(limit: limit);
  }
}

class GetFavoriteWordsUseCase {
  final SavedWordsRepository repository;

  GetFavoriteWordsUseCase(this.repository);

  Future<List<SavedWord>> call() async {
    return await repository.getFavoriteWords();
  }
}

class CheckIfWordSavedUseCase {
  final SavedWordsRepository repository;

  CheckIfWordSavedUseCase(this.repository);

  Future<bool> call(String word) async {
    return await repository.isWordSaved(word);
  }
}