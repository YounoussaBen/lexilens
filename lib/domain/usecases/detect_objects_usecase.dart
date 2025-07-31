import 'package:camera/camera.dart';
import '../entities/detection_result.dart';
import '../repositories/object_detection_repository.dart';

class DetectObjectsUseCase {
  final ObjectDetectionRepository repository;

  DetectObjectsUseCase(this.repository);

  Future<List<DetectionResult>> call(CameraImage image) async {
    if (!repository.isModelLoaded) {
      await repository.loadModel();
    }
    return await repository.detectObjects(image);
  }
}