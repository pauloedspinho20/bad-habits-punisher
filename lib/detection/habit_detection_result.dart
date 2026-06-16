import 'package:flutter/foundation.dart';

enum DetectionStatus {
  monitoring,
  detecting,
  alerting,
  cooldown,
}

@immutable
class HabitDetectionResult {
  final String habitId;
  final double confidence;
  final bool detected;
  final Map<String, double> signals;

  const HabitDetectionResult({
    required this.habitId,
    required this.confidence,
    required this.detected,
    this.signals = const {},
  });
}

class DetectedEvent {
  final String habitId;
  final DateTime timestamp;
  final int durationMs;
  final double confidence;

  const DetectedEvent({
    required this.habitId,
    required this.timestamp,
    required this.durationMs,
    required this.confidence,
  });
}
