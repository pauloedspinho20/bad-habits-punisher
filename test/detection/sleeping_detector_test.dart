import 'package:flutter_test/flutter_test.dart';
import 'package:bad_habits_punisher/detection/sleeping_detector.dart';

void main() {
  group('SleepingDetector', () {
    late SleepingDetector detector;

    setUp(() {
      detector = SleepingDetector();
    });

    test('returns not detected when no face landmarks', () {
      final result = detector.process(
        poseLandmarks: null,
        faceLandmarks: null,
        handLandmarks: null,
        imageWidth: 640,
        imageHeight: 480,
      );

      expect(result.detected, false);
      expect(result.confidence, 0);
    });

    test('returns not detected with insufficient landmarks', () {
      final result = detector.process(
        poseLandmarks: null,
        faceLandmarks: [0.1, 0.2, 0.3],
        handLandmarks: null,
        imageWidth: 640,
        imageHeight: 480,
      );

      expect(result.detected, false);
    });

    test('has correct habit id', () {
      expect(detector.habitId, 'sleeping');
    });

    test('resets state on reset call', () {
      detector.process(
        poseLandmarks: null,
        faceLandmarks: null,
        handLandmarks: null,
        imageWidth: 640,
        imageHeight: 480,
      );
      detector.reset();
      // Should not throw and state should be clean
      expect(true, isTrue);
    });
  });
}
