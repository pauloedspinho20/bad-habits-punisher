import 'package:flutter_test/flutter_test.dart';
import 'package:bad_habits_punisher/detection/habit_detection_result.dart';

void main() {
  group('HabitDetectionResult', () {
    test('creates a detected result', () {
      final result = HabitDetectionResult(
        habitId: 'test',
        confidence: 0.85,
        detected: true,
        signals: {'signal_a': 0.9},
      );

      expect(result.habitId, 'test');
      expect(result.confidence, 0.85);
      expect(result.detected, true);
      expect(result.signals, {'signal_a': 0.9});
    });

    test('creates a non-detected result with default signals', () {
      final result = HabitDetectionResult(
        habitId: 'test',
        confidence: 0.0,
        detected: false,
      );

      expect(result.detected, false);
      expect(result.signals, isEmpty);
    });
  });

  group('DetectedEvent', () {
    test('creates with required fields', () {
      final now = DateTime.now();
      final event = DetectedEvent(
        habitId: 'test',
        timestamp: now,
        durationMs: 1000,
        confidence: 0.9,
      );

      expect(event.habitId, 'test');
      expect(event.timestamp, now);
      expect(event.durationMs, 1000);
      expect(event.confidence, 0.9);
    });
  });
}
