class AppConstants {
  static const String appName = 'LexiLens';
  static const String yoloModelPath = 'assets/yolov8n.tflite';
  static const String labelsPath = 'assets/labels.txt';
  
  static const int inputImageHeight = 640;
  static const int inputImageWidth = 640;
  static const int numChannels = 3;
  static const double confidenceThreshold = 0.5;
  static const double iouThreshold = 0.4;
  static const int maxDetections = 100;
}