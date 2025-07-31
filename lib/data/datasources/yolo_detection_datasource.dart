import 'package:camera/camera.dart';
import 'package:tflite_v2/tflite_v2.dart';
import '../../core/errors/exceptions.dart';
import '../models/detection_result_model.dart';

abstract class YoloDetectionDataSource {
  bool get isModelLoaded;
  Future<void> loadModel();
  Future<List<DetectionResultModel>> detectObjects(CameraImage image);
  void dispose();
}

class YoloDetectionDataSourceImpl implements YoloDetectionDataSource {
  bool _isModelLoaded = false;

  @override
  bool get isModelLoaded => _isModelLoaded;

  @override
  Future<void> loadModel() async {
    try {
      String? res = await Tflite.loadModel(
        model: 'assets/detect.tflite',
        labels: 'assets/labelmap.txt',
      );
      _isModelLoaded = res != null;
    } catch (e) {
      throw ModelLoadException('Failed to load YOLO model: $e');
    }
  }

  @override
  Future<List<DetectionResultModel>> detectObjects(CameraImage image) async {
    if (!_isModelLoaded) {
      throw DetectionException('Model not loaded');
    }

    if (image.planes.isEmpty) {
      return [];
    }

    try {
      var recognitions = await Tflite.detectObjectOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        model: 'SSDMobileNet',
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        numResultsPerClass: 1,
        threshold: 0.4,
      );

      if (recognitions == null) return [];

      return _parseRecognitions(recognitions);
    } catch (e) {
      throw DetectionException('Detection failed: $e');
    }
  }

  List<DetectionResultModel> _parseRecognitions(List<dynamic> recognitions) {
    final results = <DetectionResultModel>[];

    for (final recognition in recognitions) {
      final detectedClass = recognition["detectedClass"] as String?;
      final confidence = (recognition["confidenceInClass"] as num?)?.toDouble();
      final rect = recognition["rect"] as Map<String, dynamic>?;

      if (detectedClass == null || confidence == null || rect == null) {
        continue;
      }

      final x = (rect["x"] as num?)?.toDouble() ?? 0.0;
      final y = (rect["y"] as num?)?.toDouble() ?? 0.0;
      final width = (rect["w"] as num?)?.toDouble() ?? 0.0;
      final height = (rect["h"] as num?)?.toDouble() ?? 0.0;

      final result = DetectionResultModel.fromRawDetection(
        label: detectedClass,
        confidence: confidence,
        x: x,
        y: y,
        width: width,
        height: height,
        classId: 0, // Not provided by tflite_v2
      );

      results.add(result);
    }

    return results;
  }

  @override
  void dispose() {
    Tflite.close();
    _isModelLoaded = false;
  }
}