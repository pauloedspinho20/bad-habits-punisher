import 'detection_utils.dart';
import 'habit_detection_result.dart';
import 'habit_detector.dart';

class NailBitingDetector extends HabitDetector {
  @override
  String get habitId => 'nail_biting';

  final SmoothingBuffer _biteSmoother = SmoothingBuffer(8);
  final HysteresisCounter _hysteresis = HysteresisCounter(threshold: 5, decay: 2);
  final TrajectoryTracker _trajectory = TrajectoryTracker();

  static const _fingerTips = [4, 8, 12, 16, 20];
  static const _fingerMcps = [1, 5, 9, 13, 17];
  static const _fingerPips = [2, 6, 10, 14, 18];

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

    final upperLip = _lm(faceLandmarks, 13);
    final lowerLip = _lm(faceLandmarks, 14);

    if (upperLip == null || lowerLip == null) {
      return HabitDetectionResult(habitId: habitId, confidence: 0, detected: false);
    }

    final mouthX = (upperLip.$1 + lowerLip.$1) / 2;
    final mouthY = (upperLip.$2 + lowerLip.$2) / 2;

    _trajectory.add(mouthX, mouthY);

    double minDistance = double.infinity;
    double maxCurl = 0;
    int closestFinger = -1;

    for (var f = 0; f < _fingerTips.length; f++) {
      final tip = _lm(handLandmarks, _fingerTips[f]);
      final mcp = _lm(handLandmarks, _fingerMcps[f]);
      final pip = _lm(handLandmarks, _fingerPips[f]);

      if (tip == null || mcp == null || pip == null) continue;

      final dx = tip.$1 - mouthX;
      final dy = tip.$2 - mouthY;
      final d = dx * dx + dy * dy;
      if (d < minDistance) {
        minDistance = d;
        closestFinger = f;
      }

      final mcpToPip = _distSq(mcp, pip);
      final pipToTip = _distSq(pip, tip);
      if (mcpToPip > 0) {
        final curl = 1.0 - (pipToTip / mcpToPip).clamp(0.0, 1.0);
        if (curl > maxCurl) maxCurl = curl;
      }
    }

    final mouthOpenScore = _detectMouthOpen(faceLandmarks);

    final proximityScore = minDistance < 0.006 ? 1.0 :
        minDistance < 0.015 ? 0.8 :
        minDistance < 0.03 ? 0.5 :
        minDistance < 0.05 ? 0.2 : 0.0;

    _biteSmoother.add(proximityScore);
    final smoothedProximity = _biteSmoother.average;

    const proximityWeight = 0.45;
    const curlWeight = 0.25;
    const mouthOpenWeight = 0.20;
    const trajectoryWeight = 0.10;

    final trajScore = _trajectory.isMovingToward ? 0.7 : 0.1;

    final confidence = smoothedProximity * proximityWeight +
        maxCurl * curlWeight +
        mouthOpenScore * mouthOpenWeight +
        trajScore * trajectoryWeight;

    final detected = _hysteresis.update(confidence >= sensitivityThreshold);

    return HabitDetectionResult(
      habitId: habitId,
      confidence: confidence,
      detected: detected,
      signals: {
        'min_distance': minDistance,
        'max_curl': maxCurl,
        'mouth_open': mouthOpenScore,
        'closest_finger': closestFinger.toDouble(),
        'hysteresis': _hysteresis.normalized,
      },
    );
  }

  double _detectMouthOpen(List<double> faceLandmarks) {
    final upperLip = _lm(faceLandmarks, 13);
    final lowerLip = _lm(faceLandmarks, 14);
    if (upperLip == null || lowerLip == null) return 0;
    final jawDrop = (lowerLip.$2 - upperLip.$2).abs();
    return (jawDrop / 0.035).clamp(0.0, 1.0);
  }

  double _distSq((double, double, double) a, (double, double, double) b) {
    final dx = a.$1 - b.$1;
    final dy = a.$2 - b.$2;
    return dx * dx + dy * dy;
  }

  (double, double, double)? _lm(List<double> landmarks, int index) {
    final i = index * 3;
    if (i + 2 >= landmarks.length) return null;
    return (landmarks[i], landmarks[i + 1], landmarks[i + 2]);
  }

  @override
  void reset() {
    _biteSmoother.clear();
    _hysteresis.reset();
    _trajectory.reset();
  }
}
