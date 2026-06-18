import 'detection_utils.dart';
import 'habit_detection_result.dart';
import 'habit_detector.dart';

class FaceTouchingDetector extends HabitDetector {
  @override
  String get habitId => 'face_touching';

  @override
  double sensitivityThreshold = 0.55;

  final SmoothingBuffer _proximitySmoother = SmoothingBuffer(8);
  final HysteresisCounter _hysteresis = HysteresisCounter(threshold: 4, decay: 2);

  static const _fingerTips = [4, 8, 12, 16, 20];

  static const _faceRegions = <int>[
    1, 2, 98, 327,
    234, 454,
    50, 280,
    168, 6,
    152, 10,
  ];

  @override
  HabitDetectionResult process({
    required List<double>? poseLandmarks,
    required List<double>? faceLandmarks,
    required List<double>? handLandmarks,
    required double imageWidth,
    required double imageHeight,
  }) {
    if (handLandmarks == null || handLandmarks.length < 21 * 3 ||
        faceLandmarks == null || faceLandmarks.length < 478 * 3) {
      return HabitDetectionResult(habitId: habitId, confidence: 0, detected: false);
    }

    double minDistance = double.infinity;
    int closestRegion = -1;
    int closestFinger = -1;

    for (var f = 0; f < _fingerTips.length; f++) {
      final tip = _lm(handLandmarks, _fingerTips[f]);
      if (tip == null) continue;

      for (final regionIdx in _faceRegions) {
        final facePt = _lm(faceLandmarks, regionIdx);
        if (facePt == null) continue;

        final dx = tip.$1 - facePt.$1;
        final dy = tip.$2 - facePt.$2;
        final d = dx * dx + dy * dy;

        if (d < minDistance) {
          minDistance = d;
          closestRegion = regionIdx;
          closestFinger = f;
        }
      }
    }

    final proximityScore = minDistance < 0.008 ? 1.0 :
        minDistance < 0.02 ? 0.8 :
        minDistance < 0.035 ? 0.5 :
        minDistance < 0.06 ? 0.2 : 0.0;

    _proximitySmoother.add(proximityScore);
    final confidence = _proximitySmoother.average;

    final detected = _hysteresis.update(confidence >= sensitivityThreshold);

    return HabitDetectionResult(
      habitId: habitId,
      confidence: confidence,
      detected: detected,
      signals: {
        'min_distance': minDistance,
        'closest_region': closestRegion.toDouble(),
        'closest_finger': closestFinger.toDouble(),
        'hysteresis': _hysteresis.normalized,
      },
    );
  }

  (double, double, double)? _lm(List<double> landmarks, int index) {
    final i = index * 3;
    if (i + 2 >= landmarks.length) return null;
    return (landmarks[i], landmarks[i + 1], landmarks[i + 2]);
  }

  @override
  void reset() {
    _proximitySmoother.clear();
    _hysteresis.reset();
  }
}
