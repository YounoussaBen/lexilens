import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/saved_word.dart';

class SavedWordModel extends SavedWord {
  const SavedWordModel({
    required super.id,
    required super.word,
    required super.definition,
    required super.detectedAt,
    required super.confidence,
    super.practiceCount,
    super.lastPracticed,
    super.isFavorite,
    super.tags,
  });

  factory SavedWordModel.fromEntity(SavedWord word) {
    return SavedWordModel(
      id: word.id,
      word: word.word,
      definition: word.definition,
      detectedAt: word.detectedAt,
      confidence: word.confidence,
      practiceCount: word.practiceCount,
      lastPracticed: word.lastPracticed,
      isFavorite: word.isFavorite,
      tags: word.tags,
    );
  }

  factory SavedWordModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception('Document data is null');
    }

    return SavedWordModel(
      id: snapshot.id,
      word: data['word'] ?? '',
      definition: data['definition'] ?? '',
      detectedAt: (data['detectedAt'] as Timestamp).toDate(),
      confidence: (data['confidence'] ?? 0.0).toDouble(),
      practiceCount: data['practiceCount'] ?? 0,
      lastPracticed: data['lastPracticed'] != null
          ? (data['lastPracticed'] as Timestamp).toDate()
          : null,
      isFavorite: data['isFavorite'] ?? false,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'word': word,
      'definition': definition,
      'detectedAt': Timestamp.fromDate(detectedAt),
      'confidence': confidence,
      'practiceCount': practiceCount,
      'lastPracticed': lastPracticed != null
          ? Timestamp.fromDate(lastPracticed!)
          : null,
      'isFavorite': isFavorite,
      'tags': tags,
    };
  }

  SavedWord toEntity() {
    return SavedWord(
      id: id,
      word: word,
      definition: definition,
      detectedAt: detectedAt,
      confidence: confidence,
      practiceCount: practiceCount,
      lastPracticed: lastPracticed,
      isFavorite: isFavorite,
      tags: tags,
    );
  }

  @override
  SavedWordModel copyWith({
    String? id,
    String? word,
    String? definition,
    DateTime? detectedAt,
    double? confidence,
    int? practiceCount,
    DateTime? lastPracticed,
    bool? isFavorite,
    List<String>? tags,
  }) {
    return SavedWordModel(
      id: id ?? this.id,
      word: word ?? this.word,
      definition: definition ?? this.definition,
      detectedAt: detectedAt ?? this.detectedAt,
      confidence: confidence ?? this.confidence,
      practiceCount: practiceCount ?? this.practiceCount,
      lastPracticed: lastPracticed ?? this.lastPracticed,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
    );
  }
}