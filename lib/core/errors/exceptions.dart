class ModelLoadException implements Exception {
  final String message;
  ModelLoadException(this.message);
  
  @override
  String toString() => 'ModelLoadException: $message';
}

class DetectionException implements Exception {
  final String message;
  DetectionException(this.message);
  
  @override
  String toString() => 'DetectionException: $message';
}

class CameraException implements Exception {
  final String message;
  CameraException(this.message);
  
  @override
  String toString() => 'CameraException: $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}

class FirebaseException implements Exception {
  final String message;
  const FirebaseException(this.message);
  
  @override
  String toString() => 'FirebaseException: $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}