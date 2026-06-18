import 'detection_utils.dart';
import 'habit_detection_result.dart';
import 'habit_detector.dart';

class SlouchingDetector extends HabitDetector {
  @override
  String get habitId => 'slouching';

  @override
  double sensitivityThreshold = 0.55;

  final SmoothingBuffer _headForwardSmoother = SmoothingBuffer(15);
  final SmoothingBuffer _shoulderDropSmoother = SmoothingBuffer(10);
  final HysteresisCounter _hysteresis = HysteresisCounter(threshold: 5, decay: 2);

  @override
  HabitDetectionResult process({
    required List<double>? poseLandmarks,
    required List<double>? faceLandmarks,
    required List<double>? handLandmarks,
    required double imageWidth,
    required double imageHeight,
  }) {
    if (poseLandmarks == null || poseLandmarks.length < 33 * 3) {
      return HabitDetectionResult(habitId: habitId, confidence: 0, detected: false);
    }

    final nose = _lm(poseLandmarks, 0);
    final leftShoulder = _lm(poseLandmarks, 11);
    final rightShoulder = _lm(poseLandmarks, 12);
    final leftEar = _lm(poseLandmarks, 7);
    final rightEar = _lm(poseLandmarks, 8);
    final midEye = _lm(poseLandmarks, 1);

    if (nose == null || leftShoulder == null || rightShoulder == null ||
        leftEar == null || rightEar == null) {
      return HabitDetectionResult(habitId: habitId, confidence: 0, detected: false);
    }

    final midShoulderY = (leftShoulder.$2 + rightShoulder.$2) / 2;
    final midShoulderX = (leftShoulder.$1 + rightShoulder.$1) / 2;
    final midEarX = (leftEar.$1 + rightEar.$1) / 2;
    final midEarY = (leftEar.$2 + rightEar.$2) / 2;

    final forwardHead = midEarX - midShoulderX;
    final headHeight = midShoulderY - midEarY;

    final forwardHeadScore = headHeight > 0
        ? (forwardHead / (headHeight * 0.4)).clamp(0.0, 1.0)
        : 0.0;

    final shoulderDrop = (leftShoulder.$2 - rightShoulder.$2).abs();
    final shoulderDropScore = (shoulderDrop / 0.08).clamp(0.0, 1.0);

    final headTilt = (midEye?.$2 ?? midEarY) - midShoulderY;
    final headTiltScore = headTilt > 0
        ? (headTilt / 0.25).clamp(0.0, 1.0)
        : 0.0;

    _headForwardSmoother.add(forwardHeadScore);
    _shoulderDropSmoother.add(shoulderDropScore);

    final smoothedHead = _headForwardSmoother.average;
    final smoothedShoulder = _shoulderDropSmoother.average;

    const headWeight = 0.55;
    const shoulderWeight = 0.25;
    const tiltWeight = 0.20;

    final confidence = smoothedHead * headWeight +
        smoothedShoulder * shoulderWeight +
        headTiltScore * tiltWeight;

    final detected = _hysteresis.update(confidence >= sensitivityThreshold);

    return HabitDetectionResult(
      habitId: habitId,
      confidence: confidence,
      detected: detected,
      signals: {
        'forward_head_score': smoothedHead,
        'shoulder_score': smoothedShoulder,
        'head_tilt_score': headTiltScore,
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
    _headForwardSmoother.clear();
    _shoulderDropSmoother.clear();
    _hysteresis.reset();
  }
}
