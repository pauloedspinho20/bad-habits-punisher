import 'dart:math' as math;

import 'detection_utils.dart';
import 'habit_detection_result.dart';
import 'habit_detector.dart';

class SmokingDetector extends HabitDetector {
  @override
  String get habitId => 'smoking';

  @override
  double sensitivityThreshold = 0.65;

  final SmoothingBuffer _proximitySmoother = SmoothingBuffer(10);
  final HysteresisCounter _hysteresis = HysteresisCounter(threshold: 4, decay: 2);
  final TrajectoryTracker _trajectory = TrajectoryTracker();

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

    final indexTip = _handLm(handLandmarks, 8);
    final thumbTip = _handLm(handLandmarks, 4);
    final indexMcp = _handLm(handLandmarks, 5);
    final pinkyMcp = _handLm(handLandmarks, 17);
    final wrist = _handLm(handLandmarks, 0);
    final mouthCenter = _faceLm(faceLandmarks, 13);
    final noseTip = _faceLm(faceLandmarks, 1);

    if (indexTip == null || thumbTip == null ||
        mouthCenter == null || noseTip == null ||
        indexMcp == null || pinkyMcp == null || wrist == null) {
      return HabitDetectionResult(habitId: habitId, confidence: 0, detected: false);
    }

    final handCenterX = (indexTip.$1 + thumbTip.$1) / 2;
    final handCenterY = (indexTip.$2 + thumbTip.$2) / 2;
    final mouthX = mouthCenter.$1;
    final mouthY = mouthCenter.$2;

    _trajectory.add(handCenterX, handCenterY);

    final dx = handCenterX - mouthX;
    final dy = handCenterY - mouthY;
    final distance = dx * dx + dy * dy;

    final fingerSpread = _dist(indexTip, thumbTip);
    final mouthOpenScore = _detectMouthOpen(faceLandmarks);

    final nearMouthScore = distance < 0.015 ? 1.0 :
        distance < 0.04 ? 0.7 :
        distance < 0.08 ? 0.3 : 0.0;

    final spreadScore = (fingerSpread / 0.12).clamp(0.0, 1.0);
    final pinchScore = 1.0 - spreadScore;

    final handOrientation = _handOrientation(wrist, indexMcp, pinkyMcp);
    final orientationScore = handOrientation < 0.3 ? 0.0 : handOrientation;

    _proximitySmoother.add(nearMouthScore);
    final smoothedProximity = _proximitySmoother.average;

    const proximityWeight = 0.40;
    const pinchWeight = 0.20;
    const mouthOpenWeight = 0.15;
    const orientationWeight = 0.15;
    const trajectoryWeight = 0.10;

    final trajScore = _trajectory.isMovingToward ? 0.8 : 0.2;

    final confidence = smoothedProximity * proximityWeight +
        pinchScore * pinchWeight +
        mouthOpenScore * mouthOpenWeight +
        orientationScore * orientationWeight +
        trajScore * trajectoryWeight;

    final detected = _hysteresis.update(confidence >= sensitivityThreshold);

    return HabitDetectionResult(
      habitId: habitId,
      confidence: confidence,
      detected: detected,
      signals: {
        'hand_mouth_distance': distance,
        'pinch_score': pinchScore,
        'mouth_open': mouthOpenScore,
        'smoothed_proximity': smoothedProximity,
        'hand_orientation': orientationScore,
        'hysteresis': _hysteresis.normalized,
      },
    );
  }

  double _handOrientation(
    (double, double, double) wrist,
    (double, double, double) indexMcp,
    (double, double, double) pinkyMcp,
  ) {
    final handDx = indexMcp.$1 - wrist.$1;
    final handDy = indexMcp.$2 - wrist.$2;
    final handLength = math.sqrt(handDx * handDx + handDy * handDy);
    final handWidth = _dist(indexMcp, pinkyMcp);
    if (handLength == 0) return 0.0;
    final aspect = handWidth / handLength;
    return (1.0 - aspect / 0.5).clamp(0.0, 1.0);
  }

  double _detectMouthOpen(List<double> faceLandmarks) {
    final upperLip = _faceLm(faceLandmarks, 13);
    final lowerLip = _faceLm(faceLandmarks, 14);
    if (upperLip == null || lowerLip == null) return 0;

    final jawDrop = (lowerLip.$2 - upperLip.$2).abs();
    return (jawDrop / 0.05).clamp(0.0, 1.0);
  }

  double _dist((double, double, double) a, (double, double, double) b) {
    final dx = a.$1 - b.$1;
    final dy = a.$2 - b.$2;
    return dx * dx + dy * dy;
  }

  (double, double, double)? _handLm(List<double> landmarks, int index) {
    final i = index * 3;
    if (i + 2 >= landmarks.length) return null;
    return (landmarks[i], landmarks[i + 1], landmarks[i + 2]);
  }

  (double, double, double)? _faceLm(List<double> landmarks, int index) {
    final i = index * 3;
    if (i + 2 >= landmarks.length) return null;
    return (landmarks[i], landmarks[i + 1], landmarks[i + 2]);
  }

  @override
  void reset() {
    _proximitySmoother.clear();
    _hysteresis.reset();
    _trajectory.reset();
  }
}
