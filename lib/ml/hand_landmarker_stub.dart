import 'package:camera/camera.dart';

class Landmark {
  final double x;
  final double y;
  final double z;

  const Landmark({this.x = 0, this.y = 0, this.z = 0});
}

class Hand {
  final List<Landmark> landmarks;
  const Hand({this.landmarks = const []});
}

class HandLandmarkerPlugin {
  HandLandmarkerPlugin._();

  static HandLandmarkerPlugin create({int numHands = 1}) => HandLandmarkerPlugin._();

  List<Hand> detect(CameraImage image, int sensorOrientation) => [];

  void dispose() {}
}
