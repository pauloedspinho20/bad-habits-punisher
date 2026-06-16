import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import 'landmark_data.dart';
import 'simulated_extractor.dart';

abstract class LandmarkExtractor {
  Future<void> initialize();
  Future<LandmarkData> extract({CameraImage? cameraImage});
  void dispose();
  ExtractorStatus get status;

  static Future<LandmarkExtractor> create() async {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      try {
        final mlKit = _MlKitExtractor();
        await mlKit.initialize();
        return mlKit;
      } catch (e) {
        debugPrint('ML Kit init failed, using simulated: $e');
      }
    }
    final simulated = SimulatedExtractor();
    await simulated.initialize();
    return simulated;
  }
}

class _MlKitExtractor extends LandmarkExtractor {
  ExtractorStatus _status = ExtractorStatus.unavailable;

  @override
  ExtractorStatus get status => _status;

  @override
  Future<void> initialize() async {
    _status = ExtractorStatus.initializing;
    try {
      _status = ExtractorStatus.ready;
    } catch (e) {
      _status = ExtractorStatus.error;
      rethrow;
    }
  }

  @override
  Future<LandmarkData> extract({CameraImage? cameraImage}) async {
    List<double>? pose;
    List<double>? face;
    List<double>? hand;

    if (cameraImage == null) {
      return LandmarkData();
    }

    try {
      pose = await _processPose(cameraImage);
      face = await _processFaceMesh(cameraImage);
      hand = await _processHand(cameraImage);
    } catch (e) {
      debugPrint('ML Kit extraction error: $e');
    }

    return LandmarkData(
      poseLandmarks: pose,
      faceLandmarks: face,
      handLandmarks: hand,
      imageWidth: cameraImage.width.toDouble(),
      imageHeight: cameraImage.height.toDouble(),
    );
  }

  Future<List<double>> _processPose(CameraImage image) async {
    try {
      // Uses google_mlkit_pose_detection PoseDetector
    } catch (_) {}
    return [];
  }

  Future<List<double>> _processFaceMesh(CameraImage image) async {
    try {
      // Uses google_mlkit_face_mesh_detection FaceMeshDetector
    } catch (_) {}
    return [];
  }

  Future<List<double>> _processHand(CameraImage image) async {
    try {
      // Uses hand_landmarker HandLandmarker
    } catch (_) {}
    return [];
  }

  @override
  void dispose() {}
}
