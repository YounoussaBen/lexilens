import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ObjectDetectionScreen extends ConsumerStatefulWidget {
  const ObjectDetectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ObjectDetectionScreen> createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends ConsumerState<ObjectDetectionScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool isModelLoaded = false;
  List<dynamic>? recognitions;
  int imageHeight = 0;
  int imageWidth = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  @override
  void dispose() {
    _controller?.dispose();
    Tflite.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _controller = CameraController(
          cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _controller!.initialize();

        if (!mounted) return;

        _controller!.startImageStream((CameraImage image) {
          if (isModelLoaded) {
            _runModel(image);
          }
        });

        setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _loadModel() async {
    try {
      String? res = await Tflite.loadModel(
        model: 'assets/detect.tflite',
        labels: 'assets/labelmap.txt',
      );
      setState(() {
        isModelLoaded = res != null;
      });
    } catch (e) {
      debugPrint('Error loading model: $e');
    }
  }

  void _runModel(CameraImage image) async {
    if (image.planes.isEmpty) return;

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

      setState(() {
        this.recognitions = recognitions;
        imageHeight = image.height;
        imageWidth = image.width;
      });
    } catch (e) {
      debugPrint('Error running model: $e');
    }
  }

  void _toggleCamera() {
    if (cameras == null || cameras!.length <= 1) return;

    final lensDirection = _controller!.description.lensDirection;
    CameraDescription newDescription;
    
    if (lensDirection == CameraLensDirection.front) {
      newDescription = cameras!.firstWhere(
        (description) => description.lensDirection == CameraLensDirection.back,
        orElse: () => cameras![0],
      );
    } else {
      newDescription = cameras!.firstWhere(
        (description) => description.lensDirection == CameraLensDirection.front,
        orElse: () => cameras![0],
      );
    }

    _initializeCameraWithDescription(newDescription);
  }

  void _initializeCameraWithDescription(CameraDescription description) async {
    await _controller?.dispose();
    
    _controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();

    if (!mounted) return;

    _controller!.startImageStream((CameraImage image) {
      if (isModelLoaded) {
        _runModel(image);
      }
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Object Detection'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          if (!isModelLoaded)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                CameraPreview(_controller!),
                if (recognitions != null && recognitions!.isNotEmpty)
                  BoundingBoxes(
                    recognitions: recognitions!,
                    previewH: imageHeight.toDouble(),
                    previewW: imageWidth.toDouble(),
                    screenH: MediaQuery.of(context).size.height - 
                           AppBar().preferredSize.height - 
                           MediaQuery.of(context).padding.top - 60,
                    screenW: MediaQuery.of(context).size.width,
                  ),
                if (!isModelLoaded)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Loading AI Model...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            height: 60,
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _toggleCamera,
                  icon: const Icon(Icons.camera_front),
                  iconSize: 30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BoundingBoxes extends StatelessWidget {
  final List<dynamic> recognitions;
  final double previewH;
  final double previewW;
  final double screenH;
  final double screenW;

  const BoundingBoxes({
    Key? key,
    required this.recognitions,
    required this.previewH,
    required this.previewW,
    required this.screenH,
    required this.screenW,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: recognitions.map((rec) {
        var x = rec["rect"]["x"] * screenW;
        var y = rec["rect"]["y"] * screenH;
        double w = rec["rect"]["w"] * screenW;
        double h = rec["rect"]["h"] * screenH;

        return Positioned(
          left: x,
          top: y,
          width: w,
          height: h,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 3,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ),
              child: Text(
                "${rec["detectedClass"]} ${(rec["confidenceInClass"] * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}