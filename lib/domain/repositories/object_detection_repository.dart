import 'package:camera/camera.dart';
import '../entities/detection_result.dart';

abstract class ObjectDetectionRepository {
  Future<void> loadModel();
  Future<List<DetectionResult>> detectObjects(CameraImage image);
  Future<void> dispose();
  bool get isModelLoaded;
}