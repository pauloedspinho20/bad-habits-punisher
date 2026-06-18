import 'detection_utils.dart';
import 'habit_detection_result.dart';
import 'habit_detector.dart';

class SleepingDetector extends HabitDetector {
  @override
  String get habitId => 'sleeping';

  final SmoothingBuffer _earSmoother = SmoothingBuffer(10);
  final SmoothingBuffer _headNodSmoother = SmoothingBuffer(8);
  final SmoothingBuffer _mouthAspectSmoother = SmoothingBuffer(5);
  final HysteresisCounter _hysteresis = HysteresisCounter(threshold: 15, decay: 3);

  @override
  HabitDetectionResult process({
    required List<double>? poseLandmarks,
    required List<double>? faceLandmarks,
    required List<double>? handLandmarks,
    required double imageWidth,
    required double imageHeight,
  }) {
    if (faceLandmarks == null || faceLandmarks.length < 478 * 3) {
      return HabitDetectionResult(habitId: habitId, confidence: 0, detected: false);
    }

    final leftEyeTop = _lm(faceLandmarks, 159);
    final leftEyeBottom = _lm(faceLandmarks, 145);
    final leftEyeLeft = _lm(faceLandmarks, 33);
    final leftEyeRight = _lm(faceLandmarks, 133);

    final rightEyeTop = _lm(faceLandmarks, 386);
    final rightEyeBottom = _lm(faceLandmarks, 374);
    final rightEyeLeft = _lm(faceLandmarks, 362);
    final rightEyeRight = _lm(faceLandmarks, 263);

    if (leftEyeTop == null || leftEyeBottom == null ||
        leftEyeLeft == null || leftEyeRight == null ||
        rightEyeTop == null || rightEyeBottom == null ||
        rightEyeLeft == null || rightEyeRight == null) {
      return HabitDetectionResult(habitId: habitId, confidence: 0, detected: false);
    }

    final leftEAR = _eyeAspectRatio(leftEyeTop, leftEyeBottom, leftEyeLeft, leftEyeRight);
    final rightEAR = _eyeAspectRatio(rightEyeTop, rightEyeBottom, rightEyeLeft, rightEyeRight);

    final minEAR = leftEAR < rightEAR ? leftEAR : rightEAR;

    _earSmoother.add(minEAR);
    final smoothedEAR = _earSmoother.average;

    final eyesClosedScore = smoothedEAR < 0.18
        ? 1.0
        : smoothedEAR < 0.25
            ? (0.25 - smoothedEAR) / 0.07
            : 0.0;

    final headNodScore = _detectHeadNod(poseLandmarks);
    _headNodSmoother.add(headNodScore);
    final smoothedNod = _headNodSmoother.average;

    final yawnScore = _detectYawn(faceLandmarks);

    const eyesWeight = 0.55;
    const nodWeight = 0.25;
    const yawnWeight = 0.20;

    final confidence = eyesClosedScore * eyesWeight +
        smoothedNod * nodWeight +
        yawnScore * yawnWeight;

    final detected = _hysteresis.update(confidence >= sensitivityThreshold);

    return HabitDetectionResult(
      habitId: habitId,
      confidence: confidence,
      detected: detected,
      signals: {
        'ear': smoothedEAR,
        'eyes_closed_score': eyesClosedScore,
        'head_nod': smoothedNod,
        'yawn': yawnScore,
        'hysteresis': _hysteresis.normalized,
      },
    );
  }

  double _eyeAspectRatio(
    (double, double, double) top,
    (double, double, double) bottom,
    (double, double, double) left,
    (double, double, double) right,
  ) {
    final vDist = _dist(top, bottom);
    final hDist = _dist(left, right);
    if (hDist == 0) return 1;
    return vDist / hDist;
  }

  double _detectYawn(List<double> faceLandmarks) {
    final upperLip = _lm(faceLandmarks, 13);
    final lowerLip = _lm(faceLandmarks, 14);
    final leftMouth = _lm(faceLandmarks, 61);
    final rightMouth = _lm(faceLandmarks, 291);

    if (upperLip == null || lowerLip == null || leftMouth == null || rightMouth == null) return 0;

    final mouthOpen = _dist(upperLip, lowerLip);
    final mouthWidth = _dist(leftMouth, rightMouth);
    if (mouthWidth == 0) return 0;

    final aspect = mouthOpen / mouthWidth;
    _mouthAspectSmoother.add(aspect);
    final smoothed = _mouthAspectSmoother.average;

    if (smoothed < 0.08) return 0.0;
    if (smoothed < 0.15) return (smoothed - 0.08) / 0.07 * 0.5;
    if (smoothed < 0.30) return 0.5 + (smoothed - 0.15) / 0.15 * 0.5;
    return 1.0;
  }

  double _dist((double, double, double) a, (double, double, double) b) {
    final dx = a.$1 - b.$1;
    final dy = a.$2 - b.$2;
    return dx * dx + dy * dy;
  }

  double _detectHeadNod(List<double>? poseLandmarks) {
    if (poseLandmarks == null || poseLandmarks.length < 5 * 3) return 0;
    final nose = _lm(poseLandmarks, 0);
    final leftEye = _lm(poseLandmarks, 2);
    final rightEye = _lm(poseLandmarks, 5);
    if (nose == null || leftEye == null || rightEye == null) return 0;

    final eyeY = (leftEye.$2 + rightEye.$2) / 2;
    final headPitch = nose.$2 - eyeY;

    return (headPitch / 0.12).abs().clamp(0.0, 1.0);
  }

  (double, double, double)? _lm(List<double> landmarks, int index) {
    final i = index * 3;
    if (i + 2 >= landmarks.length) return null;
    return (landmarks[i], landmarks[i + 1], landmarks[i + 2]);
  }

  @override
  void reset() {
    _earSmoother.clear();
    _headNodSmoother.clear();
    _mouthAspectSmoother.clear();
    _hysteresis.reset();
  }
}
