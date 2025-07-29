import 'package:flutter/material.dart';
import '../../domain/entities/detection_result.dart';

class DetectionOverlay extends StatelessWidget {
  final List<DetectionResult> detections;
  final Size imageSize;

  const DetectionOverlay({
    super.key,
    required this.detections,
    required this.imageSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: detections.map((detection) {
        return Positioned(
          left: detection.boundingBox.left,
          top: detection.boundingBox.top,
          child: Container(
            width: detection.boundingBox.width,
            height: detection.boundingBox.height,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red,
                width: 2.0,
              ),
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                ),
                child: Text(
                  '${detection.label} ${(detection.confidence * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}