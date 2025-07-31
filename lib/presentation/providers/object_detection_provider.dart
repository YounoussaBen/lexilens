import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/detection_result.dart';
import '../../domain/usecases/detect_objects_usecase.dart';
import '../../data/datasources/yolo_detection_datasource.dart';
import '../../data/repositories/object_detection_repository_impl.dart';

final yoloDataSourceProvider = Provider<YoloDetectionDataSource>((ref) {
  return YoloDetectionDataSourceImpl();
});

final objectDetectionRepositoryProvider = Provider<ObjectDetectionRepositoryImpl>((ref) {
  final dataSource = ref.watch(yoloDataSourceProvider);
  return ObjectDetectionRepositoryImpl(dataSource);
});

final detectObjectsUseCaseProvider = Provider<DetectObjectsUseCase>((ref) {
  final repository = ref.watch(objectDetectionRepositoryProvider);
  return DetectObjectsUseCase(repository);
});

class ObjectDetectionState {
  final bool isLoading;
  final List<DetectionResult> detections;
  final String? error;
  final bool isModelLoaded;

  const ObjectDetectionState({
    this.isLoading = false,
    this.detections = const [],
    this.error,
    this.isModelLoaded = false,
  });

  ObjectDetectionState copyWith({
    bool? isLoading,
    List<DetectionResult>? detections,
    String? error,
    bool? isModelLoaded,
  }) {
    return ObjectDetectionState(
      isLoading: isLoading ?? this.isLoading,
      detections: detections ?? this.detections,
      error: error,
      isModelLoaded: isModelLoaded ?? this.isModelLoaded,
    );
  }
}

class ObjectDetectionNotifier extends StateNotifier<ObjectDetectionState> {
  final DetectObjectsUseCase detectObjectsUseCase;
  final ObjectDetectionRepositoryImpl repository;

  ObjectDetectionNotifier(this.detectObjectsUseCase, this.repository)
      : super(const ObjectDetectionState());

  Future<void> initializeModel() async {
    if (state.isModelLoaded) return;

    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await repository.loadModel();
      state = state.copyWith(isLoading: false, isModelLoaded: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> detectObjects(CameraImage image) async {
    if (!state.isModelLoaded) {
      await initializeModel();
      if (!state.isModelLoaded) return;
    }

    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final detections = await detectObjectsUseCase(image);
      state = state.copyWith(isLoading: false, detections: detections);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearDetections() {
    state = state.copyWith(detections: []);
  }

  @override
  void dispose() {
    repository.dispose();
    super.dispose();
  }
}

final objectDetectionProvider = StateNotifierProvider<ObjectDetectionNotifier, ObjectDetectionState>((ref) {
  final useCase = ref.watch(detectObjectsUseCaseProvider);
  final repository = ref.watch(objectDetectionRepositoryProvider);
  return ObjectDetectionNotifier(useCase, repository);
});