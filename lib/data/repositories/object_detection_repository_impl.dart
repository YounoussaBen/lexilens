import 'package:camera/camera.dart';
import '../../domain/entities/detection_result.dart';
import '../../domain/repositories/object_detection_repository.dart';
import '../datasources/yolo_detection_datasource.dart';

class ObjectDetectionRepositoryImpl implements ObjectDetectionRepository {
  final YoloDetectionDataSource dataSource;

  ObjectDetectionRepositoryImpl(this.dataSource);

  @override
  bool get isModelLoaded => dataSource.isModelLoaded;

  @override
  Future<void> loadModel() async {
    await dataSource.loadModel();
  }

  @override
  Future<List<DetectionResult>> detectObjects(CameraImage image) async {
    return await dataSource.detectObjects(image);
  }

  @override
  Future<void> dispose() async {
    dataSource.dispose();
  }
}