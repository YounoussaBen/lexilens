import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'realtime_detection_screen.dart';

class DetectionWrapperScreen extends StatefulWidget {
  const DetectionWrapperScreen({Key? key}) : super(key: key);

  @override
  State<DetectionWrapperScreen> createState() => _DetectionWrapperScreenState();
}

class _DetectionWrapperScreenState extends State<DetectionWrapperScreen> {
  List<CameraDescription>? cameras;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeCameras();
  }

  Future<void> _initializeCameras() async {
    try {
      cameras = await availableCameras();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error initializing cameras: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (cameras == null || cameras!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Camera Error'),
        ),
        body: const Center(
          child: Text('No cameras available'),
        ),
      );
    }

    return RealTimeObjectDetection(cameras: cameras!);
  }
}