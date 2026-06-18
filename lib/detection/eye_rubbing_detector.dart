import 'detection_utils.dart';
import 'habit_detection_result.dart';
import 'habit_detector.dart';

class EyeRubbingDetector extends HabitDetector {
  @override
  String get habitId => 'eye_rubbing';

  final SmoothingBuffer _proximitySmoother = SmoothingBuffer(6);
  final HysteresisCounter _hysteresis = HysteresisCounter(threshold: 3, decay: 2);

  static const _fingerTips = [4, 8, 12, 16, 20];
  static const _fingerPips = [3, 6, 10, 14, 18];

  static const _leftEyePoints = [33, 133, 159, 145, 246, 7];
  static const _rightEyePoints = [362, 263, 386, 374, 466, 257];

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
    double curlScore = 0;
    int fingerCount = 0;

    for (var f = 0; f < _fingerTips.length; f++) {
      final tip = _lm(handLandmarks, _fingerTips[f]);
      final pip = _lm(handLandmarks, _fingerPips[f]);
      if (tip == null || pip == null) continue;

      final fingerDx = tip.$1 - pip.$1;
      final fingerDy = tip.$2 - pip.$2;
      final fingerLen = fingerDx * fingerDx + fingerDy * fingerDy;
      if (fingerLen > 0) {
        const typicalLen = 0.03;
        curlScore += (fingerLen / (typicalLen * typicalLen)).clamp(0.0, 1.0);
        fingerCount++;
      }

      for (final eyeIdx in _leftEyePoints) {
        final eyePt = _lm(faceLandmarks, eyeIdx);
        if (eyePt == null) continue;
        final dx = tip.$1 - eyePt.$1;
        final dy = tip.$2 - eyePt.$2;
        final d = dx * dx + dy * dy;
        if (d < minDistance) minDistance = d;
      }

      for (final eyeIdx in _rightEyePoints) {
        final eyePt = _lm(faceLandmarks, eyeIdx);
        if (eyePt == null) continue;
        final dx = tip.$1 - eyePt.$1;
        final dy = tip.$2 - eyePt.$2;
        final d = dx * dx + dy * dy;
        if (d < minDistance) minDistance = d;
      }
    }

    final avgCurl = fingerCount > 0 ? curlScore / fingerCount : 0.0;

    final proximityScore = minDistance < 0.01 ? 1.0 :
        minDistance < 0.025 ? 0.7 :
        minDistance < 0.05 ? 0.3 : 0.0;

    _proximitySmoother.add(proximityScore);
    final smoothedProximity = _proximitySmoother.average;

    const proximityWeight = 0.6;
    const curlWeight = 0.4;

    final confidence = smoothedProximity * proximityWeight +
        avgCurl * curlWeight;

    final detected = _hysteresis.update(confidence >= sensitivityThreshold);

    return HabitDetectionResult(
      habitId: habitId,
      confidence: confidence,
      detected: detected,
      signals: {
        'min_distance': minDistance,
        'finger_curl': avgCurl,
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
