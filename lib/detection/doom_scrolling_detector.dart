import 'dart:math';

import 'detection_utils.dart';
import 'habit_detection_result.dart';
import 'habit_detector.dart';

class DoomScrollingDetector extends HabitDetector {
  @override
  String get habitId => 'doom_scrolling';

  DoomScrollingDetector() {
    sensitivityThreshold = 0.5;
  }

  final SmoothingBuffer _proximitySmoother = SmoothingBuffer(20);
  final SmoothingBuffer _stillnessSmoother = SmoothingBuffer(10);
  final HysteresisCounter _hysteresis = HysteresisCounter(threshold: 8, decay: 3);

  @override
  HabitDetectionResult process({
    required List<double>? poseLandmarks,
    required List<double>? faceLandmarks,
    required List<double>? handLandmarks,
    required double imageWidth,
    required double imageHeight,
  }) {
    final faceAvailable = faceLandmarks != null && faceLandmarks.length >= 478 * 3;
    final poseAvailable = poseLandmarks != null && poseLandmarks.length >= 33 * 3;
    final handAvailable = handLandmarks != null && handLandmarks.length >= 21 * 3;

    if (!faceAvailable) {
      return HabitDetectionResult(habitId: habitId, confidence: 0, detected: false);
    }

    final faceProximity = _measureFaceProximity(faceLandmarks, imageWidth, imageHeight);
    final gazeDown = _measureGazeDirection(faceLandmarks);
    final headStill = _measureHeadStillness(poseAvailable ? poseLandmarks : null);
    final phoneGrip = handAvailable ? _measurePhoneGrip(handLandmarks) : 0.0;

    _proximitySmoother.add(faceProximity);
    _stillnessSmoother.add(headStill);

    final smoothedProximity = _proximitySmoother.average;
    final smoothedStillness = _stillnessSmoother.average;

    const proximityWeight = 0.35;
    const gazeWeight = 0.20;
    const stillnessWeight = 0.20;
    const gripWeight = 0.15;
    const sustainedWeight = 0.10;

    final confidence = smoothedProximity * proximityWeight +
        gazeDown * gazeWeight +
        smoothedStillness * stillnessWeight +
        phoneGrip * gripWeight +
        _hysteresis.normalized * sustainedWeight;

    final detected = _hysteresis.update(confidence >= sensitivityThreshold);

    return HabitDetectionResult(
      habitId: habitId,
      confidence: confidence,
      detected: detected,
      signals: {
        'face_proximity': smoothedProximity,
        'gaze_down': gazeDown,
        'head_still': smoothedStillness,
        'phone_grip': phoneGrip,
        'hysteresis': _hysteresis.normalized,
      },
    );
  }

  double _measureFaceProximity(List<double> faceLandmarks, double imgW, double imgH) {
    final leftCheek = _lm(faceLandmarks, 234);
    final rightCheek = _lm(faceLandmarks, 454);
    final noseTip = _lm(faceLandmarks, 1);

    if (leftCheek == null || rightCheek == null || noseTip == null) return 0;

    final faceWidth = (rightCheek.$1 - leftCheek.$1).abs();
    final noseZ = noseTip.$3.abs();

    final relativeWidth = faceWidth / imgW;

    final widthScore = (relativeWidth / 0.4).clamp(0.0, 1.0);
    final depthScore = noseZ < 0.02 ? 1.0 : noseZ < 0.05 ? 0.5 : 0.0;

    return max(widthScore, depthScore);
  }

  double _measureGazeDirection(List<double> faceLandmarks) {
    final noseTip = _lm(faceLandmarks, 1);
    final leftEye = _lm(faceLandmarks, 159);
    final rightEye = _lm(faceLandmarks, 386);
    final chin = _lm(faceLandmarks, 152);
    final forehead = _lm(faceLandmarks, 10);

    if (noseTip == null || leftEye == null ||
        rightEye == null || chin == null || forehead == null) {
      return 0;
    }

    final eyeY = (leftEye.$2 + rightEye.$2) / 2;
    final faceHeight = (forehead.$2 - chin.$2).abs();

    if (faceHeight == 0) return 0;

    final noseBelowEyes = (noseTip.$2 - eyeY) / faceHeight;
    return (noseBelowEyes / 0.15).clamp(0.0, 1.0);
  }

  double? _lastNoseX;
  double? _lastNoseY;

  double _measureHeadStillness(List<double>? poseLandmarks) {
    if (poseLandmarks == null || poseLandmarks.length < 5 * 3) return 0.5;

    final nose = _lm(poseLandmarks, 0);
    final leftEar = _lm(poseLandmarks, 7);
    final rightEar = _lm(poseLandmarks, 8);
    if (nose == null || leftEar == null || rightEar == null) return 0.5;

    _lastNoseX ??= nose.$1;
    _lastNoseY ??= nose.$2;

    final dx = (nose.$1 - _lastNoseX!).abs();
    final dy = (nose.$2 - _lastNoseY!).abs();

    _lastNoseX = nose.$1;
    _lastNoseY = nose.$2;

    final movement = dx + dy;
    return movement < 0.005 ? 0.8 :
        movement < 0.01 ? 0.5 : 0.1;
  }

  double _measurePhoneGrip(List<double> handLandmarks) {
    if (handLandmarks.length < 21 * 3) return 0;

    final wrist = _lm(handLandmarks, 0);
    final indexMcp = _lm(handLandmarks, 5);
    final pinkyMcp = _lm(handLandmarks, 17);

    if (wrist == null || indexMcp == null || pinkyMcp == null) return 0;

    final handWidth = _dist2(indexMcp, pinkyMcp);
    final handOpenness = handWidth > 0.04 ? 0.0 : handWidth > 0.02 ? 0.5 : 1.0;

    return handOpenness;
  }

  (double, double, double)? _lm(List<double> landmarks, int index) {
    final i = index * 3;
    if (i + 2 >= landmarks.length) return null;
    return (landmarks[i], landmarks[i + 1], landmarks[i + 2]);
  }

  double _dist2((double, double, double) a, (double, double, double) b) {
    final dx = a.$1 - b.$1;
    final dy = a.$2 - b.$2;
    return dx * dx + dy * dy;
  }

  @override
  void reset() {
    _proximitySmoother.clear();
    _stillnessSmoother.clear();
    _hysteresis.reset();
    _lastNoseX = null;
    _lastNoseY = null;
  }
}
