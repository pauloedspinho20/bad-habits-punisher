import 'package:flutter_test/flutter_test.dart';
import 'package:bad_habits_punisher/detection/doom_scrolling_detector.dart';

void main() {
  group('DoomScrollingDetector', () {
    late DoomScrollingDetector detector;

    setUp(() {
      detector = DoomScrollingDetector();
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

    test('has correct habit id', () {
      expect(detector.habitId, 'doom_scrolling');
    });
  });
}
