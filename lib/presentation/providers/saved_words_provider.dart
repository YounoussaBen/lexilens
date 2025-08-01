import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/saved_words_repository_impl.dart';
import '../../domain/entities/saved_word.dart';
import '../../domain/repositories/saved_words_repository.dart';
import '../../domain/usecases/saved_words_usecases.dart';

final savedWordsRepositoryProvider = Provider<SavedWordsRepository>((ref) {
  return SavedWordsRepositoryImpl();
});

final saveWordUseCaseProvider = Provider<SaveWordUseCase>((ref) {
  return SaveWordUseCase(ref.watch(savedWordsRepositoryProvider));
});

final getSavedWordsUseCaseProvider = Provider<GetSavedWordsUseCase>((ref) {
  return GetSavedWordsUseCase(ref.watch(savedWordsRepositoryProvider));
});

final deleteSavedWordUseCaseProvider = Provider<DeleteSavedWordUseCase>((ref) {
  return DeleteSavedWordUseCase(ref.watch(savedWordsRepositoryProvider));
});

final toggleFavoriteWordUseCaseProvider = Provider<ToggleFavoriteWordUseCase>((ref) {
  return ToggleFavoriteWordUseCase(ref.watch(savedWordsRepositoryProvider));
});

final incrementPracticeCountUseCaseProvider = Provider<IncrementPracticeCountUseCase>((ref) {
  return IncrementPracticeCountUseCase(ref.watch(savedWordsRepositoryProvider));
});

final searchSavedWordsUseCaseProvider = Provider<SearchSavedWordsUseCase>((ref) {
  return SearchSavedWordsUseCase(ref.watch(savedWordsRepositoryProvider));
});

final getRecentWordsUseCaseProvider = Provider<GetRecentWordsUseCase>((ref) {
  return GetRecentWordsUseCase(ref.watch(savedWordsRepositoryProvider));
});

final getFavoriteWordsUseCaseProvider = Provider<GetFavoriteWordsUseCase>((ref) {
  return GetFavoriteWordsUseCase(ref.watch(savedWordsRepositoryProvider));
});

final checkIfWordSavedUseCaseProvider = Provider<CheckIfWordSavedUseCase>((ref) {
  return CheckIfWordSavedUseCase(ref.watch(savedWordsRepositoryProvider));
});

final savedWordsProvider = StreamProvider<List<SavedWord>>((ref) {
  final useCase = ref.watch(getSavedWordsUseCaseProvider);
  return useCase();
});

final recentWordsProvider = FutureProvider<List<SavedWord>>((ref) {
  final useCase = ref.watch(getRecentWordsUseCaseProvider);
  return useCase(limit: 10);
});

final favoriteWordsProvider = FutureProvider<List<SavedWord>>((ref) {
  final useCase = ref.watch(getFavoriteWordsUseCaseProvider);
  return useCase();
});

final searchResultsProvider = StateNotifierProvider<SearchResultsNotifier, AsyncValue<List<SavedWord>>>((ref) {
  return SearchResultsNotifier(ref.watch(searchSavedWordsUseCaseProvider));
});

class SearchResultsNotifier extends StateNotifier<AsyncValue<List<SavedWord>>> {
  final SearchSavedWordsUseCase _searchUseCase;

  SearchResultsNotifier(this._searchUseCase) : super(const AsyncValue.data([]));

  Future<void> searchWords(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final results = await _searchUseCase(query);
      state = AsyncValue.data(results);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearSearch() {
    state = const AsyncValue.data([]);
  }
}