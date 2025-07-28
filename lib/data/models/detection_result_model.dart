import 'dart:ui';
import '../../domain/entities/detection_result.dart';

class DetectionResultModel extends DetectionResult {
  const DetectionResultModel({
    required super.label,
    required super.confidence,
    required super.boundingBox,
    required super.classId,
  });

  factory DetectionResultModel.fromRawDetection({
    required String label,
    required double confidence,
    required double x,
    required double y,
    required double width,
    required double height,
    required int classId,
  }) {
    return DetectionResultModel(
      label: label,
      confidence: confidence,
      boundingBox: Rect.fromLTWH(x, y, width, height),
      classId: classId,
    );
  }
}