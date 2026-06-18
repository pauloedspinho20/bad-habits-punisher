import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'hand_landmarker_stub.dart'
    if (dart.library.io) 'hand_landmarker_real.dart';

import 'landmark_data.dart';
import 'simulated_extractor.dart';

abstract class LandmarkExtractor {
  Future<void> initialize();
  Future<LandmarkData> extract({CameraImage? cameraImage, CameraDescription? camera});
  void dispose();
  ExtractorStatus get status;
  String? get errorMessage;

  static Future<LandmarkExtractor> create() async {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      final mlKit = MlKitExtractor();
      await mlKit.initialize();
      return mlKit;
    }
    final simulated = SimulatedExtractor();
    await simulated.initialize();
    return simulated;
  }
}

class MlKitExtractor extends LandmarkExtractor {
  ExtractorStatus _status = ExtractorStatus.initializing;
  String? _errorMessage;

  PoseDetector? _poseDetector;
  FaceMeshDetector? _faceMeshDetector;
  HandLandmarkerPlugin? _handLandmarker;

  @override
  ExtractorStatus get status => _status;
  @override
  String? get errorMessage => _errorMessage;

  @override
  Future<void> initialize() async {
    _status = ExtractorStatus.initializing;
    int successes = 0;

    try {
      _poseDetector = PoseDetector(
        options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
      );
      successes++;
    } catch (e) {
      debugPrint('PoseDetector init failed: $e');
    }

    try {
      _faceMeshDetector = FaceMeshDetector(
        option: FaceMeshDetectorOptions.faceMesh,
      );
      successes++;
    } catch (e) {
      debugPrint('FaceMeshDetector init failed: $e');
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        _handLandmarker = HandLandmarkerPlugin.create(numHands: 1);
        successes++;
      } catch (e) {
        debugPrint('HandLandmarker init failed: $e');
      }
    }

    if (successes > 0) {
      _status = ExtractorStatus.ready;
    } else {
      _status = ExtractorStatus.error;
      _errorMessage = 'ML Kit native libraries unavailable. '
          'Ensure device supports Google ML Kit and native build is correct.';
    }
  }

  @override
  Future<LandmarkData> extract({CameraImage? cameraImage, CameraDescription? camera}) async {
    if (cameraImage == null || camera == null) {
      return LandmarkData();
    }

    List<double>? pose;
    List<double>? face;
    List<double>? hand;

    final inputImage = _buildInputImage(cameraImage, camera);

    if (inputImage == null) {
      return LandmarkData(
        imageWidth: cameraImage.width.toDouble(),
        imageHeight: cameraImage.height.toDouble(),
      );
    }

    try {
      final results = await Future.wait([
        _processPose(inputImage),
        _processFaceMesh(inputImage),
        _processHand(cameraImage, camera),
      ]);
      pose = results[0];
      face = results[1];
      hand = results[2];
    } catch (e) {
      debugPrint('ML Kit processing error: $e');
    }

    return LandmarkData(
      poseLandmarks: pose,
      faceLandmarks: face,
      handLandmarks: hand,
      imageWidth: cameraImage.width.toDouble(),
      imageHeight: cameraImage.height.toDouble(),
    );
  }

  InputImage? _buildInputImage(CameraImage image, CameraDescription camera) {
    try {
      final sensorOrientation = camera.sensorOrientation;
      InputImageRotation? rotation;
      try {
        rotation = InputImageRotation.values.firstWhere(
          (r) => r.rawValue == sensorOrientation,
        );
      } catch (_) {
        rotation = InputImageRotation.rotation0deg;
      }

      InputImageFormat format;
      switch (image.format.group) {
        case ImageFormatGroup.yuv420:
          format = InputImageFormat.yuv_420_888;
          break;
        case ImageFormatGroup.bgra8888:
          format = InputImageFormat.bgra8888;
          break;
        case ImageFormatGroup.nv21:
          format = InputImageFormat.nv21;
          break;
        default:
          format = defaultTargetPlatform == TargetPlatform.android
              ? InputImageFormat.yuv_420_888
              : InputImageFormat.bgra8888;
      }

      if (defaultTargetPlatform == TargetPlatform.android) {
        final WriteBuffer allBytes = WriteBuffer();
        for (final plane in image.planes) {
          allBytes.putUint8List(plane.bytes);
        }
        final bytes = allBytes.done().buffer.asUint8List();

        return InputImage.fromBytes(
          bytes: bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: format,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );
      } else {
        return InputImage.fromBytes(
          bytes: image.planes[0].bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: format,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );
      }
    } catch (e) {
      debugPrint('InputImage build error: $e');
      return null;
    }
  }

  Future<List<double>> _processPose(InputImage inputImage) async {
    if (_poseDetector == null) return [];
    try {
      final poses = await _poseDetector!.processImage(inputImage);
      if (poses.isNotEmpty) return _flattenPose(poses.first);
    } on MissingPluginException catch (e) {
      debugPrint('Pose native plugin missing: $e');
      _poseDetector = null;
    } catch (e) {
      debugPrint('Pose processing error: $e');
    }
    return [];
  }

  Future<List<double>> _processFaceMesh(InputImage inputImage) async {
    if (_faceMeshDetector == null) return [];
    try {
      final meshes = await _faceMeshDetector!.processImage(inputImage);
      if (meshes.isNotEmpty) return _flattenFaceMesh(meshes.first);
    } on MissingPluginException catch (e) {
      debugPrint('FaceMesh native plugin missing: $e');
      _faceMeshDetector = null;
    } catch (e) {
      debugPrint('FaceMesh processing error: $e');
    }
    return [];
  }

  Future<List<double>> _processHand(CameraImage image, CameraDescription camera) async {
    if (_handLandmarker == null) return [];
    if (defaultTargetPlatform != TargetPlatform.android) return [];
    try {
      final hands = _handLandmarker!.detect(image, camera.sensorOrientation);
      if (hands.isNotEmpty) return _flattenHand(hands.first);
    } catch (e) {
      debugPrint('Hand processing error: $e');
    }
    return [];
  }

  static List<double> _flattenPose(Pose pose) {
    final landmarks = <double>[];
    for (final type in PoseLandmarkType.values) {
      final l = pose.landmarks[type];
      if (l != null) {
        landmarks.addAll([l.x, l.y, l.z]);
      } else {
        landmarks.addAll([0.0, 0.0, 0.0]);
      }
    }
    return landmarks;
  }

  static List<double> _flattenFaceMesh(FaceMesh mesh) {
    final points = List<double>.filled(478 * 3, 0.0);
    for (final p in mesh.points) {
      final i = p.index * 3;
      if (i + 2 < points.length) {
        points[i] = p.x;
        points[i + 1] = p.y;
        points[i + 2] = p.z;
      }
    }
    return points;
  }

  static List<double> _flattenHand(Hand hand) {
    final landmarks = <double>[];
    for (final l in hand.landmarks) {
      landmarks.addAll([l.x, l.y, l.z]);
    }
    return landmarks;
  }

  @override
  void dispose() {
    _poseDetector?.close();
    _faceMeshDetector?.close();
  }
}
