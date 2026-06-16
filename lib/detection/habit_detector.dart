import 'habit_detection_result.dart';

abstract class HabitDetector {
  String get habitId;
  double sensitivityThreshold = 0.6;

  HabitDetectionResult process({
    required List<double>? poseLandmarks,
    required List<double>? faceLandmarks,
    required List<double>? handLandmarks,
    required double imageWidth,
    required double imageHeight,
  });

  void reset();
}
