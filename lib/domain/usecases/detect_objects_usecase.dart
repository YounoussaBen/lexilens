import 'dart:typed_data';
import '../entities/detection_result.dart';
import '../repositories/object_detection_repository.dart';

class DetectObjectsUseCase {
  final ObjectDetectionRepository repository;

  DetectObjectsUseCase(this.repository);

  Future<List<DetectionResult>> call(Uint8List imageBytes) async {
    if (!repository.isModelLoaded) {
      await repository.loadModel();
    }
    return await repository.detectObjects(imageBytes);
  }
}