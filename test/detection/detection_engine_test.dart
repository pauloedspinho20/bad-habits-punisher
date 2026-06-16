import 'package:flutter_test/flutter_test.dart';
import 'package:bad_habits_punisher/detection/detection_engine.dart';
import 'package:bad_habits_punisher/detection/habit_detector.dart';
import 'package:bad_habits_punisher/detection/habit_detection_result.dart';

class _MockDetector extends HabitDetector {
  final String id;
  final bool returnDetected;

  _MockDetector({required this.id, this.returnDetected = false});

  @override
  String get habitId => id;

  @override
  double sensitivityThreshold = 0.5;

  @override
  HabitDetectionResult process({
    required List<double>? poseLandmarks,
    required List<double>? faceLandmarks,
    required List<double>? handLandmarks,
    required double imageWidth,
    required double imageHeight,
  }) {
    return HabitDetectionResult(
      habitId: id,
      confidence: returnDetected ? 0.9 : 0.1,
      detected: returnDetected,
    );
  }

  @override
  void reset() {}
}

void main() {
  group('DetectionEngine', () {
    test('starts in idle state', () {
      final engine = DetectionEngine(detectors: []);
      expect(engine.state, DetectionEngineState.idle);
    });

    test('transitions to running on start', () {
      final engine = DetectionEngine(detectors: []);
      engine.start();
      expect(engine.state, DetectionEngineState.running);
    });

    test('transitions to paused on pause', () {
      final engine = DetectionEngine(detectors: []);
      engine.start();
      engine.pause();
      expect(engine.state, DetectionEngineState.paused);
    });

    test('returns empty results when idle', () {
      final engine = DetectionEngine(detectors: []);
      final results = engine.processFrame(
        poseLandmarks: null,
        faceLandmarks: null,
        handLandmarks: null,
        imageWidth: 640,
        imageHeight: 480,
      );
      expect(results, isEmpty);
    });

    test('returns results when running with detector', () {
      final detector = _MockDetector(id: 'test_habit');
      final engine = DetectionEngine(detectors: [detector], frameSkip: 1);
      engine.start();

      final results = engine.processFrame(
        poseLandmarks: null,
        faceLandmarks: null,
        handLandmarks: null,
        imageWidth: 640,
        imageHeight: 480,
      );
      expect(results, hasLength(1));
      expect(results.first.habitId, 'test_habit');
      expect(results.first.detected, false);
    });

    test('emits events on sustained detection', () async {
      final detector = _MockDetector(id: 'test_habit', returnDetected: true);
      final engine = DetectionEngine(detectors: [detector], frameSkip: 1);

      // Use expectLater to wait for stream event
      final futureEvent = engine.onEventsDetected.first;

      engine.start();

      // Process frames until detection triggers (3 consecutive)
      for (var i = 0; i < 10; i++) {
        engine.processFrame(
          poseLandmarks: null,
          faceLandmarks: null,
          handLandmarks: null,
          imageWidth: 640,
          imageHeight: 480,
        );
      }

      final events = await futureEvent;
      expect(events, isNotEmpty);
      expect(events.first.habitId, 'test_habit');

      engine.dispose();
    });

    test('stops engine via stop()', () {
      final detector = _MockDetector(id: 'test_habit');
      final engine = DetectionEngine(detectors: [detector]);
      engine.start();
      engine.stop();
      expect(engine.state, DetectionEngineState.idle);
    });

    test('resets detectors and counters on reset', () {
      final detector = _MockDetector(id: 'test_habit', returnDetected: true);
      final engine = DetectionEngine(detectors: [detector], frameSkip: 1);
      engine.start();

      for (var i = 0; i < 6; i++) {
        engine.processFrame(
          poseLandmarks: null,
          faceLandmarks: null,
          handLandmarks: null,
          imageWidth: 640,
          imageHeight: 480,
        );
      }

      engine.reset();
      expect(engine.state, DetectionEngineState.running);
    });
  });
}
