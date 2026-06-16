import 'dart:math';

import 'package:camera/camera.dart';

import 'landmark_data.dart';
import 'landmark_extractor.dart';

class SimulatedExtractor extends LandmarkExtractor {
  ExtractorStatus _status = ExtractorStatus.unavailable;

  @override
  ExtractorStatus get status => _status;

  int _frame = 0;

  @override
  Future<void> initialize() async {
    _status = ExtractorStatus.ready;
  }

  @override
  Future<LandmarkData> extract({CameraImage? cameraImage}) async {
    _frame++;
    return LandmarkData(
      poseLandmarks: _generatePoseLandmarks(),
      faceLandmarks: _generateFaceLandmarks(),
      handLandmarks: _generateHandLandmarks(),
      imageWidth: cameraImage?.width.toDouble() ?? 640,
      imageHeight: cameraImage?.height.toDouble() ?? 480,
    );
  }

  List<double> _generatePoseLandmarks() {
    final landmarks = <double>[];
    final slouchAmount = (sin(_frame * 0.02) * 0.5 + 0.5) * 0.2;

    for (var i = 0; i < 33; i++) {
      final v = sin(_frame * 0.05 + i * 0.5) * 0.02;
      final noseForward = i == 0 ? slouchAmount : 0.0;
      final shoulderDrop = (i == 11 || i == 12) ? sin(_frame * 0.03) * 0.03 : 0.0;

      landmarks.addAll([
        0.5 + v,
        0.3 + v + noseForward + shoulderDrop,
        v * 0.5,
      ]);
    }
    return landmarks;
  }

  List<double> _generateFaceLandmarks() {
    final landmarks = <double>[];
    final eyeClosure = (sin(_frame * 0.015) * 0.5 + 0.5) * 0.35;

    for (var i = 0; i < 478; i++) {
      final isEye = (i >= 33 && i <= 133) || (i >= 362 && i <= 399);
      final v = sin(_frame * 0.03 + i * 0.1) * 0.01;
      final eyeNarrow = isEye ? -eyeClosure * 0.05 : 0.0;

      landmarks.addAll([
        0.5 + v,
        0.4 + v + eyeNarrow,
        v,
      ]);
    }
    return landmarks;
  }

  List<double> _generateHandLandmarks() {
    final nearMouth = (sin(_frame * 0.04) * 0.5 + 0.5) * 0.4 + 0.1;
    final landmarks = <double>[];
    for (var i = 0; i < 21; i++) {
      final angle = i * 0.5;
      landmarks.addAll([
        0.5 + cos(angle) * nearMouth,
        0.4 + sin(angle) * nearMouth * 0.8,
        sin(i * 0.3) * 0.05,
      ]);
    }
    return landmarks;
  }

  @override
  void dispose() {}
}
