import 'dart:ui';

class DetectionResult {
  final String label;
  final double confidence;
  final Rect boundingBox;
  final int classId;

  const DetectionResult({
    required this.label,
    required this.confidence,
    required this.boundingBox,
    required this.classId,
  });

  @override
  String toString() {
    return 'DetectionResult(label: $label, confidence: ${confidence.toStringAsFixed(2)}, boundingBox: $boundingBox)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DetectionResult &&
        other.label == label &&
        other.confidence == confidence &&
        other.boundingBox == boundingBox &&
        other.classId == classId;
  }

  @override
  int get hashCode {
    return label.hashCode ^
        confidence.hashCode ^
        boundingBox.hashCode ^
        classId.hashCode;
  }
}