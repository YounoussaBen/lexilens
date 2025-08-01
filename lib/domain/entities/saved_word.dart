class SavedWord {
  final String id;
  final String word;
  final String definition;
  final DateTime detectedAt;
  final double confidence;
  final int practiceCount;
  final DateTime? lastPracticed;
  final bool isFavorite;
  final List<String> tags;

  const SavedWord({
    required this.id,
    required this.word,
    required this.definition,
    required this.detectedAt,
    required this.confidence,
    this.practiceCount = 0,
    this.lastPracticed,
    this.isFavorite = false,
    this.tags = const [],
  });

  SavedWord copyWith({
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
    return SavedWord(
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

  @override
  String toString() {
    return 'SavedWord(id: $id, word: $word, confidence: ${confidence.toStringAsFixed(2)}, detectedAt: $detectedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavedWord &&
        other.id == id &&
        other.word == word &&
        other.definition == definition &&
        other.detectedAt == detectedAt &&
        other.confidence == confidence &&
        other.practiceCount == practiceCount &&
        other.lastPracticed == lastPracticed &&
        other.isFavorite == isFavorite;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        word.hashCode ^
        definition.hashCode ^
        detectedAt.hashCode ^
        confidence.hashCode ^
        practiceCount.hashCode ^
        lastPracticed.hashCode ^
        isFavorite.hashCode;
  }
}