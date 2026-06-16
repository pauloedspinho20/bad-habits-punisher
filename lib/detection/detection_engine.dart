import 'dart:async';

import '../core/habit_config.dart';
import 'habit_detection_result.dart';
import 'habit_detector.dart';

enum DetectionEngineState {
  idle,
  running,
  paused,
}

class DetectionEngine {
  final List<HabitDetector> detectors;

  final _resultController = StreamController<List<DetectedEvent>>.broadcast();
  Stream<List<DetectedEvent>> get onEventsDetected => _resultController.stream;

  DetectionEngineState _state = DetectionEngineState.idle;
  DetectionEngineState get state => _state;

  final Map<String, DateTime> _lastAlertTime = {};
  final Map<String, int> _consecutiveFrames = {};

  int _frameCount = 0;
  final int _frameSkip;

  DetectionEngine({
    required this.detectors,
    int frameSkip = 3,
  }) : _frameSkip = frameSkip;

  List<HabitDetectionResult> processFrame({
    required List<double>? poseLandmarks,
    required List<double>? faceLandmarks,
    required List<double>? handLandmarks,
    required double imageWidth,
    required double imageHeight,
  }) {
    if (_state != DetectionEngineState.running) return [];

    _frameCount++;
    if (_frameCount % _frameSkip != 0) return [];

    final results = <HabitDetectionResult>[];
    final events = <DetectedEvent>[];

    for (final detector in detectors) {
      final result = detector.process(
        poseLandmarks: poseLandmarks,
        faceLandmarks: faceLandmarks,
        handLandmarks: handLandmarks,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      );

      results.add(result);

      if (result.detected) {
        final habitConsecutive = _consecutiveFrames[detector.habitId] ?? 0;
        _consecutiveFrames[detector.habitId] = habitConsecutive + 1;

        if (_consecutiveFrames[detector.habitId]! >= 3) {
          final now = DateTime.now();
          final lastAlert = _lastAlertTime[detector.habitId];
          final config = HabitConfig.fromId(detector.habitId);
          final cooldown = config?.cooldown ?? const Duration(seconds: 30);

          if (lastAlert == null || now.difference(lastAlert) > cooldown) {
            _lastAlertTime[detector.habitId] = now;
            events.add(DetectedEvent(
              habitId: detector.habitId,
              timestamp: now,
              durationMs: _consecutiveFrames[detector.habitId]! * _frameSkip * 33,
              confidence: result.confidence,
            ));
          }
        }
      } else {
        _consecutiveFrames[detector.habitId] = 0;
      }
    }

    if (events.isNotEmpty) {
      _resultController.add(events);
    }

    return results;
  }

  void start() => _state = DetectionEngineState.running;
  void pause() => _state = DetectionEngineState.paused;
  void stop() {
    _state = DetectionEngineState.idle;
    _consecutiveFrames.clear();
    _lastAlertTime.clear();
    _frameCount = 0;
  }

  void reset() {
    for (final detector in detectors) {
      detector.reset();
    }
    _consecutiveFrames.clear();
    _lastAlertTime.clear();
    _frameCount = 0;
  }

  void dispose() {
    stop();
    _resultController.close();
  }
}
