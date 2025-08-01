import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../realtime_detection_screen.dart';

/// Discovery screen that wraps the camera detection functionality
/// This integrates the existing YOLO object detection with the new navigation structure
class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Discovery',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      Text(
                        'Learn by exploring',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: () => _showHelpDialog(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Camera detection area
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: const CameraDetectionContent(),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Discovery Tips & Guide',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // How it works section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How Discovery Works',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('1. Point your camera at any object'),
                  const SizedBox(height: 6),
                  const Text(
                    '2. AI detects and identifies objects in real-time',
                  ),
                  const SizedBox(height: 6),
                  const Text('3. Tap detected objects to learn their names'),
                  const SizedBox(height: 6),
                  const Text('4. Words are saved to your vocabulary'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tips section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.tips_and_updates,
                          color: Theme.of(context).colorScheme.primary,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Detection Tips',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[900],
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSimpleTipRow(
                    context,
                    Icons.wb_sunny_outlined,
                    'Use good lighting for better accuracy',
                    Colors.orange[600]!,
                  ),
                  const SizedBox(height: 8),
                  _buildSimpleTipRow(
                    context,
                    Icons.center_focus_strong_outlined,
                    'Hold camera steady',
                    Colors.blue[600]!,
                  ),
                  const SizedBox(height: 8),
                  _buildSimpleTipRow(
                    context,
                    Icons.zoom_out_map,
                    'Keep objects clearly in frame',
                    Colors.green[600]!,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it!'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleTipRow(
    BuildContext context,
    IconData icon,
    String text,
    Color iconColor,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}

/// Wrapper for the existing camera detection screen content
/// This allows us to reuse the existing YOLO detection logic within the new navigation structure
class CameraDetectionContent extends StatefulWidget {
  const CameraDetectionContent({super.key});

  @override
  State<CameraDetectionContent> createState() => _CameraDetectionContentState();
}

class _CameraDetectionContentState extends State<CameraDetectionContent> {
  bool showCamera = false;
  List<CameraDescription>? cameras;
  bool isLoading = false;

  Future<void> _initializeCameras() async {
    setState(() {
      isLoading = true;
    });
    try {
      cameras = await availableCameras();
    } catch (e) {
      debugPrint('Error initializing cameras: $e');
      cameras = null;
    }
    setState(() {
      isLoading = false;
    });
  }

  void _onStartDetection() async {
    await _initializeCameras();
    setState(() {
      showCamera = true;
    });
  }

  void _onCloseCamera() {
    setState(() {
      showCamera = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showCamera) {
      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (cameras == null || cameras!.isEmpty) {
        return Center(child: Text('No cameras available'));
      }
      return Stack(
        children: [
          RealTimeObjectDetection(cameras: cameras!, onClose: _onCloseCamera),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              onPressed: _onCloseCamera,
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
              ),
            ),
          ),
        ],
      );
    }
    // Show intro UI
    return _CameraDetectionView(onStartDetection: _onStartDetection);
  }
}

/// Camera detection view with navigation to full-screen detection
class _CameraDetectionView extends StatelessWidget {
  final VoidCallback? onStartDetection;
  const _CameraDetectionView({this.onStartDetection});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.center_focus_strong_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'AI Object Detection',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Point your camera at objects to discover vocabulary',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onStartDetection,
              icon: const Icon(Icons.center_focus_strong_outlined),
              label: const Text('Start Detection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
