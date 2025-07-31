import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple object detection screen for basic functionality
/// This will be a minimal implementation until we get full detection working
class SimpleDetectionScreen extends ConsumerStatefulWidget {
  const SimpleDetectionScreen({super.key});

  @override
  ConsumerState<SimpleDetectionScreen> createState() => _SimpleDetectionScreenState();
}

class _SimpleDetectionScreenState extends ConsumerState<SimpleDetectionScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
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

        setState(() {
          isInitialized = true;
        });

        // Start image stream for basic functionality
        _controller!.startImageStream((CameraImage image) {
          // Basic detection will be implemented here
          _processFrame(image);
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  void _processFrame(CameraImage image) {
    // Placeholder for detection processing
    // This would integrate with our detection service
    // For now, just log the frame info
    // debugPrint('Processing frame: ${image.width}x${image.height}');
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

    setState(() {
      isInitialized = true;
    });

    _controller!.startImageStream((CameraImage image) {
      _processFrame(image);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing Camera...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Object Detection'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: _toggleCamera,
            icon: const Icon(Icons.camera_front),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                const Icon(Icons.camera_alt, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Camera Active - AI Detection Ready',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          // Camera preview
          Expanded(
            child: Stack(
              children: [
                CameraPreview(_controller!),
                // Overlay for future detection boxes
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: CustomPaint(
                    painter: DetectionOverlayPainter(),
                  ),
                ),
                // Instructions overlay
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Point camera at objects to detect them\nAI object detection coming soon!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for detection overlays
class DetectionOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Placeholder for drawing detection boxes
    // This will be implemented when we have actual detections
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}