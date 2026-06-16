import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../detection/detection_engine.dart';
import '../detection/habit_detection_result.dart';
import '../ml/landmark_data.dart';
import '../ml/landmark_extractor.dart';
import '../providers/camera_provider.dart';
import '../providers/detection_provider.dart';
import '../widgets/camera_overlay.dart';
import '../widgets/detection_indicator.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  StreamSubscription? _detectionSub;
  Timer? _frameTimer;
  bool _isDetecting = false;
  LandmarkExtractor? _extractor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await ref.read(cameraProvider.future);
    if (cameras.isEmpty) return;

    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.bgra8888,
    );

    try {
      await _controller!.initialize();
      _extractor = await LandmarkExtractor.create();
      ref.read(isCameraInitializedProvider.notifier).state = true;
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  void _startDetection() {
    final engine = ref.read(detectionEngineProvider);
    engine.start();
    ref.read(detectionStateProvider.notifier).state = DetectionEngineState.running;
    _isDetecting = true;

    _detectionSub = engine.onEventsDetected.listen((events) {
      final recorder = ref.read(eventRecorderProvider);
      for (final event in events) {
        recorder.recordEvent(event);
        _showHabitAlert(event);
      }
    });

    _frameTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!_isDetecting || _controller == null || !_controller!.value.isInitialized) return;
      _processFrame();
    });
  }

  Future<void> _processFrame() async {
    if (_controller == null || _extractor == null) return;

    final engine = ref.read(detectionEngineProvider);

    LandmarkData data;
    try {
      data = await _extractor!.extract();
    } catch (e) {
      debugPrint('Extraction error: $e');
      return;
    }

    final results = engine.processFrame(
      poseLandmarks: data.poseLandmarks,
      faceLandmarks: data.faceLandmarks,
      handLandmarks: data.handLandmarks,
      imageWidth: data.imageWidth,
      imageHeight: data.imageHeight,
    );

    ref.read(detectionResultsProvider.notifier).state = results;
  }

  void _showHabitAlert(DetectedEvent event) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('\u26A0\uFE0F ${_habitName(event.habitId)} detected!'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  String _habitName(String id) {
    switch (id) {
      case 'slouching': return 'Slouching';
      case 'sleeping': return 'Sleeping';
      case 'smoking': return 'Smoking';
      case 'nail_biting': return 'Nail Biting';
      case 'doom_scrolling': return 'Doom Scrolling';
      default: return id;
    }
  }

  void _stopDetection() {
    _isDetecting = false;
    _frameTimer?.cancel();
    _detectionSub?.cancel();
    ref.read(detectionEngineProvider).stop();
    ref.read(detectionStateProvider.notifier).state = DetectionEngineState.idle;
    ref.read(detectionResultsProvider.notifier).state = [];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopDetection();
    _extractor?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller?.resumePreview();
    } else if (state == AppLifecycleState.paused) {
      _controller?.pausePreview();
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialized = ref.watch(isCameraInitializedProvider);
    final results = ref.watch(detectionResultsProvider);
    final engineState = ref.watch(detectionStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _stopDetection();
            context.pop();
          },
        ),
        actions: [
          if (engineState == DetectionEngineState.running)
            TextButton.icon(
              onPressed: _stopDetection,
              icon: const Icon(Icons.stop),
              label: const Text('Stop'),
            )
          else
            TextButton.icon(
              onPressed: _startDetection,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
            ),
        ],
      ),
      body: initialized && _controller != null
          ? Stack(
              children: [
                CameraPreview(_controller!),
                CameraOverlay(results: results),
                Positioned(
                  top: 16,
                  right: 16,
                  child: DetectionIndicator(
                    isRunning: engineState == DetectionEngineState.running,
                    results: results,
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class CameraPreview extends StatelessWidget {
  final CameraController controller;
  const CameraPreview(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: controller.buildPreview(),
    );
  }
}
