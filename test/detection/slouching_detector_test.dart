import 'package:flutter_test/flutter_test.dart';
import 'package:bad_habits_punisher/detection/slouching_detector.dart';

void main() {
  group('SlouchingDetector', () {
    late SlouchingDetector detector;

    setUp(() {
      detector = SlouchingDetector();
    });

    test('returns not detected when no pose landmarks', () {
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
        poseLandmarks: [0.1, 0.2, 0.3],
        faceLandmarks: null,
        handLandmarks: null,
        imageWidth: 640,
        imageHeight: 480,
      );

      expect(result.detected, false);
    });

    test('has correct habit id', () {
      expect(detector.habitId, 'slouching');
    });
  });
}
