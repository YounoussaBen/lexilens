import 'dart:typed_data';
import '../entities/detection_result.dart';

abstract class ObjectDetectionRepository {
  Future<void> loadModel();
  Future<List<DetectionResult>> detectObjects(Uint8List imageBytes);
  Future<void> dispose();
  bool get isModelLoaded;
}