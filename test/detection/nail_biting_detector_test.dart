import 'package:flutter_test/flutter_test.dart';
import 'package:bad_habits_punisher/detection/nail_biting_detector.dart';

void main() {
  group('NailBitingDetector', () {
    late NailBitingDetector detector;

    setUp(() {
      detector = NailBitingDetector();
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
        faceLandmarks: [0.1],
        handLandmarks: [0.1],
        imageWidth: 640,
        imageHeight: 480,
      );
      expect(result.detected, false);
    });

    test('has correct habit id', () {
      expect(detector.habitId, 'nail_biting');
    });
  });
}
