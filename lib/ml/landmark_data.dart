import 'package:flutter/foundation.dart';

@immutable
class LandmarkData {
  final List<double>? poseLandmarks;
  final List<double>? faceLandmarks;
  final List<double>? handLandmarks;
  final double imageWidth;
  final double imageHeight;

  const LandmarkData({
    this.poseLandmarks,
    this.faceLandmarks,
    this.handLandmarks,
    this.imageWidth = 640,
    this.imageHeight = 480,
  });
}

enum ExtractorStatus {
  unavailable,
  initializing,
  ready,
  error,
}
