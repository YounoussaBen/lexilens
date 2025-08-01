import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:go_router/go_router.dart';
import '../providers/saved_words_provider.dart';
import '../widgets/detection/word_flashcard.dart';
import '../../domain/entities/saved_word.dart';
import '../../core/services/tts_service.dart';

class RealTimeObjectDetection extends ConsumerStatefulWidget {
  final List<CameraDescription> cameras;

  const RealTimeObjectDetection({
    super.key,
    required this.cameras,
  });

  @override
  ConsumerState<RealTimeObjectDetection> createState() =>
      _RealTimeObjectDetectionState();
}

class _RealTimeObjectDetectionState extends ConsumerState<RealTimeObjectDetection> {
  late CameraController _controller;
  bool isModelLoaded = false;
  bool isDetectionPaused = false;
  bool isShowingFlashcard = false;
  List<dynamic>? recognitions;
  int imageHeight = 0;
  int imageWidth = 0;
  String? lastDetectedWord;
  DateTime? lastDetectionTime;
  final TTSService _ttsService = TTSService();

  // Confidence threshold for showing flashcard
  static const double confidenceThreshold = 0.7;
  // Minimum time between detections (seconds)
  static const int detectionCooldown = 3;

  @override
  void initState() {
    super.initState();
    _ttsService.initialize();
    loadModel();
    initializeCamera(null);
  }

  @override
  void dispose() {
    _ttsService.dispose();
    _controller.dispose();
    Tflite.close();
    super.dispose();
  }

  Future<void> loadModel() async {
    String? res = await Tflite.loadModel(
      model: 'assets/detect.tflite',
      labels: 'assets/labelmap.txt',
    );
    setState(() {
      isModelLoaded = res != null;
    });
  }

  void toggleCamera() {
    final lensDirection = _controller.description.lensDirection;
    CameraDescription newDescription;
    if (lensDirection == CameraLensDirection.front) {
      newDescription = widget.cameras.firstWhere(
        (description) => description.lensDirection == CameraLensDirection.back,
      );
    } else {
      newDescription = widget.cameras.firstWhere(
        (description) => description.lensDirection == CameraLensDirection.front,
      );
    }

    initializeCamera(newDescription);
  }

  void initializeCamera(description) async {
    if (description == null) {
      _controller = CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );
    } else {
      _controller = CameraController(
        description,
        ResolutionPreset.high,
        enableAudio: false,
      );
    }

    await _controller.initialize();

    if (!mounted) {
      return;
    }
    _controller.startImageStream((CameraImage image) {
      if (isModelLoaded && !isDetectionPaused && !isShowingFlashcard) {
        runModel(image);
      }
    });
    setState(() {});
  }

  void runModel(CameraImage image) async {
    if (image.planes.isEmpty) return;

    var detections = await Tflite.detectObjectOnFrame(
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
      recognitions = detections;
      imageHeight = image.height;
      imageWidth = image.width;
    });

    // Check for high-confidence detections to trigger flashcard
    _checkForWordDetection(detections);
  }

  void _checkForWordDetection(List<dynamic>? detections) {
    if (detections == null || detections.isEmpty) return;

    // Find the highest confidence detection
    var bestDetection = detections.reduce((a, b) => 
        a['confidenceInClass'] > b['confidenceInClass'] ? a : b);

    double confidence = bestDetection['confidenceInClass'];
    String detectedClass = bestDetection['detectedClass'];

    // Check if this meets our criteria for showing flashcard
    if (confidence >= confidenceThreshold && 
        _shouldShowFlashcard(detectedClass)) {
      _pauseDetectionAndShowFlashcard(detectedClass, confidence);
    }
  }

  bool _shouldShowFlashcard(String word) {
    // Don't show flashcard for the same word too frequently
    if (lastDetectedWord == word && lastDetectionTime != null) {
      final timeSince = DateTime.now().difference(lastDetectionTime!);
      if (timeSince.inSeconds < detectionCooldown) {
        return false;
      }
    }
    return true;
  }

  void _pauseDetectionAndShowFlashcard(String word, double confidence) {
    setState(() {
      isDetectionPaused = true;
      isShowingFlashcard = true;
      lastDetectedWord = word;
      lastDetectionTime = DateTime.now();
    });

    // Generate a simple definition
    String definition = _generateDefinition(word);

    // Show flashcard overlay
    _showWordFlashcard(word, definition, confidence);
  }

  String _generateDefinition(String word) {
    // Simple mapping for common objects
    Map<String, String> definitions = {
      'person': 'A human being',
      'bicycle': 'A two-wheeled vehicle powered by pedaling',
      'car': 'A four-wheeled motor vehicle',
      'motorcycle': 'A two-wheeled motor vehicle',
      'airplane': 'A powered flying vehicle with fixed wings',
      'bus': 'A large motor vehicle for carrying passengers',
      'train': 'A series of connected railway cars',
      'truck': 'A large motor vehicle for transporting goods',
      'boat': 'A watercraft used for traveling on water',
      'traffic light': 'A signal device to control vehicle and pedestrian traffic',
      'fire hydrant': 'A connection point for firefighters to access water',
      'stop sign': 'A traffic sign requiring vehicles to come to a complete stop',
      'parking meter': 'A device for collecting payment for parking',
      'bench': 'A long seat for multiple people',
      'bird': 'A flying animal with feathers and wings',
      'cat': 'A small carnivorous mammal, often kept as a pet',
      'dog': 'A domesticated carnivorous mammal, often kept as a pet',
      'horse': 'A large four-legged animal used for riding and work',
      'sheep': 'A woolly farm animal',
      'cow': 'A large farm animal that produces milk',
      'elephant': 'A large mammal with a trunk',
      'bear': 'A large carnivorous mammal',
      'zebra': 'A horse-like animal with black and white stripes',
      'giraffe': 'A tall African mammal with a long neck',
      'backpack': 'A bag carried on the back',
      'umbrella': 'A collapsible canopy used for protection from rain',
      'handbag': 'A bag for carrying personal items',
      'tie': 'A strip of cloth worn around the neck',
      'suitcase': 'A rectangular case for carrying clothes while traveling',
      'frisbee': 'A disc-shaped toy thrown and caught',
      'skis': 'Long runners worn on feet for gliding over snow',
      'snowboard': 'A board for sliding down snow-covered slopes',
      'sports ball': 'A round object used in various sports',
      'kite': 'A lightweight object flown in the wind',
      'baseball bat': 'A smooth wooden or metal club used in baseball',
      'baseball glove': 'A leather glove worn to catch baseballs',
      'skateboard': 'A board with wheels used for riding',
      'surfboard': 'A board used for riding waves',
      'tennis racket': 'A racket used to hit tennis balls',
      'bottle': 'A container for liquids',
      'wine glass': 'A stemmed glass for drinking wine',
      'cup': 'A small container for drinking',
      'fork': 'A utensil with prongs for eating',
      'knife': 'A cutting tool with a sharp blade',
      'spoon': 'A utensil with a bowl for eating liquids',
      'bowl': 'A round container for food',
      'banana': 'A yellow curved fruit',
      'apple': 'A round red or green fruit',
      'sandwich': 'Food between two pieces of bread',
      'orange': 'A round citrus fruit',
      'broccoli': 'A green vegetable with a tree-like shape',
      'carrot': 'An orange root vegetable',
      'hot dog': 'A grilled sausage in a bun',
      'pizza': 'A flatbread with toppings',
      'donut': 'A sweet fried ring-shaped pastry',
      'cake': 'A sweet baked dessert',
      'chair': 'A seat for one person',
      'couch': 'A comfortable seat for multiple people',
      'potted plant': 'A plant growing in a container',
      'bed': 'A piece of furniture for sleeping',
      'dining table': 'A table for eating meals',
      'toilet': 'A bathroom fixture for waste disposal',
      'tv': 'A device for receiving television broadcasts',
      'laptop': 'A portable computer',
      'mouse': 'A computer pointing device',
      'remote': 'A device for controlling electronics from a distance',
      'keyboard': 'A device for typing on a computer',
      'cell phone': 'A portable telephone',
      'microwave': 'An appliance for heating food',
      'oven': 'An appliance for baking and cooking',
      'toaster': 'An appliance for toasting bread',
      'sink': 'A basin for washing',
      'refrigerator': 'An appliance for keeping food cold',
      'book': 'A written or printed work bound in pages',
      'clock': 'A device for telling time',
      'vase': 'A container for flowers',
      'scissors': 'A cutting tool with two blades',
      'teddy bear': 'A stuffed toy bear',
      'hair drier': 'A device for drying hair',
      'toothbrush': 'A brush for cleaning teeth',
    };

    return definitions[word] ?? 'A common object or living thing';
  }

  void _showWordFlashcard(String word, String definition, double confidence) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WordFlashcard(
        word: word,
        definition: definition,
        confidence: confidence,
        onSave: () => _saveWord(word, definition, confidence),
        onClose: _resumeDetection,
        onNavigateToMyWords: () => _navigateToMyWords(),
        isAlreadySaved: false,
      ),
    );
  }

  Future<void> _saveWord(String word, String definition, double confidence) async {
    final savedWord = SavedWord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      word: word.toLowerCase(),
      definition: definition,
      detectedAt: DateTime.now(),
      confidence: confidence,
      practiceCount: 0,
      isFavorite: false,
      tags: [],
    );

    try {
      await ref.read(saveWordUseCaseProvider)(savedWord);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Word "$word" saved successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save word: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _resumeDetection() {
    setState(() {
      isDetectionPaused = false;
      isShowingFlashcard = false;
    });
  }

  void _navigateToMyWords() {
    if (mounted) {
      context.go('/review');
    }
  }


  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          Positioned.fill(
            child: CameraPreview(_controller),
          ),
          
          // Detection overlays
          if (recognitions != null && !isShowingFlashcard)
            BoundingBoxes(
              recognitions: recognitions!,
              previewH: imageHeight.toDouble(),
              previewW: imageWidth.toDouble(),
              screenH: MediaQuery.of(context).size.height,
              screenW: MediaQuery.of(context).size.width,
            ),

          // Bottom camera toggle only
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: IconButton(
                  onPressed: toggleCamera,
                  icon: const Icon(
                    Icons.flip_camera_ios,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
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
    super.key,
    required this.recognitions,
    required this.previewH,
    required this.previewW,
    required this.screenH,
    required this.screenW,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: recognitions.map((rec) {
        var x = rec["rect"]["x"] * screenW;
        var y = rec["rect"]["y"] * screenH;
        double w = rec["rect"]["w"] * screenW;
        double h = rec["rect"]["h"] * screenH;
        double confidence = rec["confidenceInClass"];

        return Positioned(
          left: x,
          top: y,
          width: w,
          height: h,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: confidence >= 0.7 ? Colors.green : Colors.red, 
                width: 2,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              color: Colors.black54,
              child: Text(
                "${rec["detectedClass"]} ${(confidence * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                  color: confidence >= 0.7 ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
