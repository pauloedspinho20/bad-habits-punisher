import 'dart:ui';

import 'habit_detection_result.dart';
import 'habit_detector.dart';

class SlouchingDetector extends HabitDetector {
  @override
  String get habitId => 'slouching';

  @override
  double sensitivityThreshold = 0.55;

  final _headForwardAngles = <double>[];
  static const int _smoothingWindow = 15;

  @override
  HabitDetectionResult process({
    required List<double>? poseLandmarks,
    required List<double>? faceLandmarks,
    required List<double>? handLandmarks,
    required double imageWidth,
    required double imageHeight,
  }) {
    if (poseLandmarks == null || poseLandmarks.length < 33 * 3) {
      return HabitDetectionResult(
        habitId: habitId,
        confidence: 0,
        detected: false,
      );
    }

    final nose = _lm(poseLandmarks, 0);
    final leftShoulder = _lm(poseLandmarks, 11);
    final rightShoulder = _lm(poseLandmarks, 12);
    final leftEar = _lm(poseLandmarks, 7);
    final rightEar = _lm(poseLandmarks, 8);

    if (nose == null || leftShoulder == null || rightShoulder == null) {
      return HabitDetectionResult(
        habitId: habitId,
        confidence: 0,
        detected: false,
      );
    }

    final midShoulder = Offset(
      (leftShoulder.$1 + rightShoulder.$1) / 2,
      (leftShoulder.$2 + rightShoulder.$2) / 2,
    );

    final headForward = nose.$2 < midShoulder.dy
        ? 0.0
        : (nose.$2 - midShoulder.dy).clamp(0.0, 1.0);

    final earY = ((leftEar?.$2 ?? nose.$2) + (rightEar?.$2 ?? nose.$2)) / 2;
    final headTilt = earY - midShoulder.dy;

    final shoulderDrop = (leftShoulder.$2 - rightShoulder.$2).abs();

    _headForwardAngles.add(headForward);
    if (_headForwardAngles.length > _smoothingWindow) {
      _headForwardAngles.removeAt(0);
    }

    final smoothedHeadForward = _headForwardAngles.isEmpty
        ? 0.0
        : _headForwardAngles.reduce((a, b) => a + b) /
            _headForwardAngles.length;

    final headForwardScore = (smoothedHeadForward / 0.3).clamp(0.0, 1.0);
    final shoulderScore = (shoulderDrop / 0.1).clamp(0.0, 1.0);

    const headWeight = 0.7;
    const shoulderWeight = 0.3;

    final confidence = headForwardScore * headWeight + shoulderScore * shoulderWeight;
    final detected = confidence >= sensitivityThreshold;

    return HabitDetectionResult(
      habitId: habitId,
      confidence: confidence,
      detected: detected,
      signals: {
        'head_forward': smoothedHeadForward,
        'head_forward_score': headForwardScore,
        'shoulder_score': shoulderScore,
        'head_tilt': headTilt,
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
    _headForwardAngles.clear();
  }
}
