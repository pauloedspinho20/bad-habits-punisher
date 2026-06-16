import 'package:flutter_test/flutter_test.dart';
import 'package:bad_habits_punisher/detection/smoking_detector.dart';

void main() {
  group('SmokingDetector', () {
    late SmokingDetector detector;

    setUp(() {
      detector = SmokingDetector();
    });

    test('returns not detected when no hand or face landmarks', () {
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
        faceLandmarks: [0.1, 0.2],
        handLandmarks: [0.1, 0.2],
        imageWidth: 640,
        imageHeight: 480,
      );
      expect(result.detected, false);
    });

    test('has correct habit id', () {
      expect(detector.habitId, 'smoking');
    });
  });
}
