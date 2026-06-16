import 'habit_detection_result.dart';
import 'habit_detector.dart';

class SleepingDetector extends HabitDetector {
  @override
  String get habitId => 'sleeping';

  @override
  double sensitivityThreshold = 0.6;

  final _eyeAspectRatios = <double>[];
  static const int _smoothingWindow = 10;

  int _closedFrames = 0;
  static const int _minClosedFrames = 15;

  @override
  HabitDetectionResult process({
    required List<double>? poseLandmarks,
    required List<double>? faceLandmarks,
    required List<double>? handLandmarks,
    required double imageWidth,
    required double imageHeight,
  }) {
    if (faceLandmarks == null || faceLandmarks.length < 478 * 3) {
      return HabitDetectionResult(
        habitId: habitId,
        confidence: 0,
        detected: false,
      );
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
      return HabitDetectionResult(
        habitId: habitId,
        confidence: 0,
        detected: false,
      );
    }

    final leftEAR = _eyeAspectRatio(leftEyeTop, leftEyeBottom, leftEyeLeft, leftEyeRight);
    final rightEAR = _eyeAspectRatio(rightEyeTop, rightEyeBottom, rightEyeLeft, rightEyeRight);
    final avgEAR = (leftEAR + rightEAR) / 2;

    _eyeAspectRatios.add(avgEAR);
    if (_eyeAspectRatios.length > _smoothingWindow) {
      _eyeAspectRatios.removeAt(0);
    }

    final smoothedEAR = _eyeAspectRatios.isEmpty
        ? 1.0
        : _eyeAspectRatios.reduce((a, b) => a + b) / _eyeAspectRatios.length;

    final isEyeClosed = smoothedEAR < 0.2;

    if (isEyeClosed) {
      _closedFrames++;
    } else {
      _closedFrames = 0;
    }

    final headNodScore = _detectHeadNod(poseLandmarks);

    final eyesClosedScore = (_closedFrames / _minClosedFrames).clamp(0, 1);
    const eyesWeight = 0.7;
    const nodWeight = 0.3;

    final confidence = eyesClosedScore * eyesWeight + headNodScore * nodWeight;
    final detected = confidence >= sensitivityThreshold && _closedFrames >= _minClosedFrames;

    return HabitDetectionResult(
      habitId: habitId,
      confidence: confidence,
      detected: detected,
      signals: {
        'ear': smoothedEAR,
        'closed_frames': _closedFrames.toDouble(),
        'head_nod': headNodScore,
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

  double _dist((double, double, double) a, (double, double, double) b) {
    final dx = a.$1 - b.$1;
    final dy = a.$2 - b.$2;
    return dx * dx + dy * dy;
  }

  double _detectHeadNod(List<double>? poseLandmarks) {
    if (poseLandmarks == null || poseLandmarks.length < 3 * 3) return 0;
    final nose = _lm(poseLandmarks, 0);
    final leftEye = _lm(poseLandmarks, 2);
    final rightEye = _lm(poseLandmarks, 5);
    if (nose == null || leftEye == null || rightEye == null) return 0;

    final eyeY = (leftEye.$2 + rightEye.$2) / 2;
    final headPitch = nose.$2 - eyeY;

    return (headPitch / 0.15).abs().clamp(0, 1);
  }

  (double, double, double)? _lm(List<double> landmarks, int index) {
    final i = index * 3;
    if (i + 2 >= landmarks.length) return null;
    return (landmarks[i], landmarks[i + 1], landmarks[i + 2]);
  }

  @override
  void reset() {
    _eyeAspectRatios.clear();
    _closedFrames = 0;
  }
}
