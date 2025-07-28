import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FirestoreDataSource {
  Future<void> createUser(String uid, Map<String, dynamic> userData);
  Future<Map<String, dynamic>?> getUser(String uid);
  Future<void> updateUser(String uid, Map<String, dynamic> userData);
  
  Future<void> addVocabularyWord(String uid, Map<String, dynamic> wordData);
  Future<List<Map<String, dynamic>>> getUserVocabulary(String uid);
  Future<void> updateVocabularyWord(String uid, String wordId, Map<String, dynamic> updates);
  
  Future<void> logSession(String uid, Map<String, dynamic> sessionData);
  Future<List<Map<String, dynamic>>> getUserSessions(String uid, {int limit = 10});
  
  Future<void> addChatMessage(String uid, Map<String, dynamic> messageData);
  Future<List<Map<String, dynamic>>> getChatHistory(String uid, {int limit = 50});
}

class FirestoreDataSourceImpl implements FirestoreDataSource {
  final FirebaseFirestore _firestore;

  FirestoreDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createUser(String uid, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(uid).set({
      ...userData,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  @override
  Future<void> updateUser(String uid, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(uid).update({
      ...userData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> addVocabularyWord(String uid, Map<String, dynamic> wordData) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('vocabulary')
        .add({
      ...wordData,
      'createdAt': FieldValue.serverTimestamp(),
      'lastReviewed': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getUserVocabulary(String uid) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('vocabulary')
        .orderBy('lastReviewed', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }

  @override
  Future<void> updateVocabularyWord(String uid, String wordId, Map<String, dynamic> updates) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('vocabulary')
        .doc(wordId)
        .update({
      ...updates,
      'lastReviewed': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> logSession(String uid, Map<String, dynamic> sessionData) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .add({
      ...sessionData,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getUserSessions(String uid, {int limit = 10}) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }

  @override
  Future<void> addChatMessage(String uid, Map<String, dynamic> messageData) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('messages')
        .add({
      ...messageData,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getChatHistory(String uid, {int limit = 50}) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }
}