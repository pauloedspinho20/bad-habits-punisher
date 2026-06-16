import 'habit_detection_result.dart';
import 'habit_detector.dart';

class SmokingDetector extends HabitDetector {
  @override
  String get habitId => 'smoking';

  @override
  double sensitivityThreshold = 0.65;

  final _handNearMouthHistory = <double>[];
  static const int _smoothingWindow = 10;

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
      return HabitDetectionResult(
        habitId: habitId,
        confidence: 0,
        detected: false,
      );
    }

    final indexTip = _handLm(handLandmarks, 8);
    final thumbTip = _handLm(handLandmarks, 4);
    final mouthCenter = _faceLm(faceLandmarks, 13);
    final noseTip = _faceLm(faceLandmarks, 1);

    if (indexTip == null || thumbTip == null ||
        mouthCenter == null || noseTip == null) {
      return HabitDetectionResult(
        habitId: habitId,
        confidence: 0,
        detected: false,
      );
    }

    final handCenterX = (indexTip.$1 + thumbTip.$1) / 2;
    final handCenterY = (indexTip.$2 + thumbTip.$2) / 2;
    final mouthX = mouthCenter.$1;
    final mouthY = mouthCenter.$2;

    final dx = handCenterX - mouthX;
    final dy = handCenterY - mouthY;
    final distance = (dx * dx + dy * dy);

    final fingerSpread = _dist(indexTip, thumbTip);
    final mouthOpenScore = _detectMouthOpen(faceLandmarks);

    final nearMouthScore = distance < 0.02 ? 1.0 :
        distance < 0.05 ? 0.6 :
        distance < 0.1 ? 0.3 : 0.0;

    final spreadScore = (fingerSpread / 0.15).clamp(0.0, 1.0);
    final pinchScore = 1.0 - spreadScore;

    _handNearMouthHistory.add(nearMouthScore);
    if (_handNearMouthHistory.length > _smoothingWindow) {
      _handNearMouthHistory.removeAt(0);
    }

    final smoothedProximity = _handNearMouthHistory.reduce((a, b) => a + b) /
        _handNearMouthHistory.length;

    const proximityWeight = 0.5;
    const pinchWeight = 0.3;
    const mouthOpenWeight = 0.2;

    final confidence = smoothedProximity * proximityWeight +
        pinchScore * pinchWeight +
        mouthOpenScore * mouthOpenWeight;

    final detected = confidence >= sensitivityThreshold;

    return HabitDetectionResult(
      habitId: habitId,
      confidence: confidence,
      detected: detected,
      signals: {
        'hand_mouth_distance': distance,
        'pinch_score': pinchScore,
        'mouth_open': mouthOpenScore,
        'smoothed_proximity': smoothedProximity,
      },
    );
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
    _handNearMouthHistory.clear();
  }
}
