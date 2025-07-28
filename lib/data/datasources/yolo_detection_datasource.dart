import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/detection_result_model.dart';

abstract class YoloDetectionDataSource {
  bool get isModelLoaded;
  Future<void> loadModel();
  Future<List<DetectionResultModel>> detectObjects(Uint8List imageBytes);
  void dispose();
}

class YoloDetectionDataSourceImpl implements YoloDetectionDataSource {
  Interpreter? _interpreter;
  List<String>? _labels;
  bool _isModelLoaded = false;

  @override
  bool get isModelLoaded => _isModelLoaded;

  @override
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(AppConstants.yoloModelPath);
      await _loadLabels();
      _isModelLoaded = true;
    } catch (e) {
      throw ModelLoadException('Failed to load YOLO model: $e');
    }
  }

  Future<void> _loadLabels() async {
    try {
      final labelsText = await rootBundle.loadString(AppConstants.labelsPath);
      _labels = labelsText
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();
    } catch (e) {
      throw ModelLoadException('Failed to load labels: $e');
    }
  }

  @override
  Future<List<DetectionResultModel>> detectObjects(Uint8List imageBytes) async {
    if (!_isModelLoaded || _interpreter == null || _labels == null) {
      throw DetectionException('Model not loaded');
    }

    try {
      final preprocessedImage = _preprocessImage(imageBytes);

      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final output = List.generate(
        outputShape[1],
        (index) => List.filled(outputShape[2], 0.0),
      );

      _interpreter!.run([preprocessedImage], [output]);

      return _parseDetections(output);
    } catch (e) {
      throw DetectionException('Detection failed: $e');
    }
  }

  List<List<List<double>>> _preprocessImage(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw DetectionException('Failed to decode image');
    }

    final resized = img.copyResize(
      image,
      width: AppConstants.inputImageWidth,
      height: AppConstants.inputImageHeight,
    );

    final input = List.generate(
      AppConstants.inputImageHeight,
      (y) => List.generate(
        AppConstants.inputImageWidth,
        (x) => List.generate(AppConstants.numChannels, (c) {
          final pixel = resized.getPixel(x, y);
          switch (c) {
            case 0:
              return pixel.r / 255.0;
            case 1:
              return pixel.g / 255.0;
            case 2:
              return pixel.b / 255.0;
            default:
              return 0.0;
          }
        }),
      ),
    );

    return input;
  }

  List<DetectionResultModel> _parseDetections(List detections) {
    final results = <DetectionResultModel>[];

    if (detections.isEmpty) return results;

    final detectionsData = detections[0] as List;

    for (int i = 0; i < detectionsData.length; i++) {
      final detection = detectionsData[i] as List;

      if (detection.length < 6) continue;

      final x = detection[0] as double;
      final y = detection[1] as double;
      final width = detection[2] as double;
      final height = detection[3] as double;
      final confidence = detection[4] as double;
      final classId = (detection[5] as double).toInt();

      if (confidence < AppConstants.confidenceThreshold) continue;
      if (classId < 0 || classId >= _labels!.length) continue;

      final result = DetectionResultModel.fromRawDetection(
        label: _labels![classId],
        confidence: confidence,
        x: x,
        y: y,
        width: width,
        height: height,
        classId: classId,
      );

      results.add(result);
    }

    return _applyNonMaxSuppression(results);
  }

  List<DetectionResultModel> _applyNonMaxSuppression(
    List<DetectionResultModel> detections,
  ) {
    if (detections.length <= 1) return detections;

    detections.sort((a, b) => b.confidence.compareTo(a.confidence));

    final keep = <bool>[];
    for (int i = 0; i < detections.length; i++) {
      keep.add(true);
    }

    for (int i = 0; i < detections.length; i++) {
      if (!keep[i]) continue;

      for (int j = i + 1; j < detections.length; j++) {
        if (!keep[j]) continue;

        final iou = _calculateIoU(
          detections[i].boundingBox,
          detections[j].boundingBox,
        );
        if (iou > AppConstants.iouThreshold) {
          keep[j] = false;
        }
      }
    }

    final result = <DetectionResultModel>[];
    for (int i = 0; i < detections.length; i++) {
      if (keep[i]) {
        result.add(detections[i]);
      }
    }

    return result.take(AppConstants.maxDetections).toList();
  }

  double _calculateIoU(Rect boxA, Rect boxB) {
    final intersectionArea = _calculateIntersectionArea(boxA, boxB);
    final unionArea =
        boxA.width * boxA.height + boxB.width * boxB.height - intersectionArea;
    return unionArea > 0 ? intersectionArea / unionArea : 0.0;
  }

  double _calculateIntersectionArea(Rect boxA, Rect boxB) {
    final left = boxA.left > boxB.left ? boxA.left : boxB.left;
    final top = boxA.top > boxB.top ? boxA.top : boxB.top;
    final right = boxA.right < boxB.right ? boxA.right : boxB.right;
    final bottom = boxA.bottom < boxB.bottom ? boxA.bottom : boxB.bottom;

    if (left >= right || top >= bottom) return 0.0;
    return (right - left) * (bottom - top);
  }

  @override
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
    _isModelLoaded = false;
  }
}
