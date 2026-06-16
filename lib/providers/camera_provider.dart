import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cameraProvider = FutureProvider<List<CameraDescription>>((ref) async {
  return await availableCameras();
});

final selectedCameraProvider = StateProvider<CameraDescription?>((ref) => null);

final isCameraInitializedProvider = StateProvider<bool>((ref) => false);
