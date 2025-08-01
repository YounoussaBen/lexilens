# ProGuard rules for TensorFlow Lite and ML models
# Add rules from missing_rules.txt if needed
-keep class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**
-keep class sq.flutter.tflite.** { *; }
-dontwarn sq.flutter.tflite.**
