import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/object_detection_provider.dart';
import '../widgets/detection_overlay.dart';

class CameraDetectionScreen extends HookConsumerWidget {
  const CameraDetectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraController = useState<CameraController?>(null);
    final isInitialized = useState(false);
    final detectionState = ref.watch(objectDetectionProvider);

    useEffect(() {
      _initializeCamera(cameraController, isInitialized);
      ref.read(objectDetectionProvider.notifier).initializeModel();
      
      return () {
        cameraController.value?.dispose();
      };
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LexiLens - Object Detection'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: isInitialized.value && cameraController.value != null
                  ? Stack(
                      children: [
                        CameraPreview(cameraController.value!),
                        if (detectionState.detections.isNotEmpty)
                          DetectionOverlay(
                            detections: detectionState.detections,
                            imageSize: Size(
                              MediaQuery.of(context).size.width,
                              MediaQuery.of(context).size.width * 
                                  cameraController.value!.value.aspectRatio,
                            ),
                          ),
                      ],
                    )
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Column(
                children: [
                  if (detectionState.isLoading)
                    const CircularProgressIndicator()
                  else if (detectionState.error != null)
                    Text(
                      'Error: ${detectionState.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    )
                  else ...[
                    Text(
                      'Detected Objects: ${detectionState.detections.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: detectionState.detections.length,
                        itemBuilder: (context, index) {
                          final detection = detectionState.detections[index];
                          return ListTile(
                            dense: true,
                            title: Text(detection.label),
                            trailing: Text(
                              '${(detection.confidence * 100).toInt()}%',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: isInitialized.value && !detectionState.isLoading
                            ? () => _captureAndDetect(cameraController.value!, ref)
                            : null,
                        child: const Text('Detect Objects'),
                      ),
                      ElevatedButton(
                        onPressed: detectionState.detections.isNotEmpty
                            ? () => ref.read(objectDetectionProvider.notifier).clearDetections()
                            : null,
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeCamera(
    ValueNotifier<CameraController?> controllerNotifier,
    ValueNotifier<bool> isInitializedNotifier,
  ) async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();
      controllerNotifier.value = controller;
      isInitializedNotifier.value = true;
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _captureAndDetect(CameraController controller, WidgetRef ref) async {
    try {
      final image = await controller.takePicture();
      final bytes = await image.readAsBytes();
      await ref.read(objectDetectionProvider.notifier).detectObjects(bytes);
    } catch (e) {
      debugPrint('Capture and detect error: $e');
    }
  }
}