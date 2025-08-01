import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/saved_word.dart';
import '../../domain/repositories/saved_words_repository.dart';
import '../models/saved_word_model.dart';

class SavedWordsRepositoryImpl implements SavedWordsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<SavedWordModel> get _collection {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('saved_words')
        .withConverter<SavedWordModel>(
          fromFirestore: SavedWordModel.fromFirestore,
          toFirestore: (SavedWordModel word, _) => word.toFirestore(),
        );
  }

  @override
  Stream<List<SavedWord>> getSavedWords() {
    return _collection
        .orderBy('detectedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data().toEntity())
            .toList());
  }

  @override
  Future<void> saveWord(SavedWord word) async {
    final model = SavedWordModel.fromEntity(word);
    await _collection.doc(word.id).set(model);
  }

  @override
  Future<void> updateWord(SavedWord word) async {
    final model = SavedWordModel.fromEntity(word);
    await _collection.doc(word.id).update(model.toFirestore());
  }

  @override
  Future<void> deleteWord(String wordId) async {
    await _collection.doc(wordId).delete();
  }

  @override
  Future<SavedWord?> getWordById(String wordId) async {
    final doc = await _collection.doc(wordId).get();
    if (doc.exists) {
      return doc.data()?.toEntity();
    }
    return null;
  }

  @override
  Future<bool> isWordSaved(String word) async {
    final query = await _collection
        .where('word', isEqualTo: word.toLowerCase())
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  @override
  Future<void> incrementPracticeCount(String wordId) async {
    await _collection.doc(wordId).update({
      'practiceCount': FieldValue.increment(1),
      'lastPracticed': Timestamp.now(),
    });
  }

  @override
  Future<void> toggleFavorite(String wordId) async {
    final doc = await _collection.doc(wordId).get();
    if (doc.exists) {
      final currentValue = doc.data()?.isFavorite ?? false;
      await _collection.doc(wordId).update({
        'isFavorite': !currentValue,
      });
    }
  }

  @override
  Future<List<SavedWord>> searchWords(String query) async {
    if (query.isEmpty) return [];
    
    final snapshot = await _collection
        .where('word', isGreaterThanOrEqualTo: query.toLowerCase())
        .where('word', isLessThan: '${query.toLowerCase()}z')
        .get();
    
    return snapshot.docs
        .map((doc) => doc.data().toEntity())
        .toList();
  }

  @override
  Future<List<SavedWord>> getWordsByTag(String tag) async {
    final snapshot = await _collection
        .where('tags', arrayContains: tag)
        .orderBy('detectedAt', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => doc.data().toEntity())
        .toList();
  }

  @override
  Future<List<SavedWord>> getRecentWords({int limit = 10}) async {
    final snapshot = await _collection
        .orderBy('detectedAt', descending: true)
        .limit(limit)
        .get();
    
    return snapshot.docs
        .map((doc) => doc.data().toEntity())
        .toList();
  }

  @override
  Future<List<SavedWord>> getFavoriteWords() async {
    final snapshot = await _collection
        .where('isFavorite', isEqualTo: true)
        .orderBy('detectedAt', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => doc.data().toEntity())
        .toList();
  }
}