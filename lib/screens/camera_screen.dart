import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../database/database.dart';
import '../detection/detection_engine.dart';
import '../detection/habit_detection_result.dart';
import '../ml/landmark_data.dart';
import '../ml/landmark_extractor.dart';
import '../providers/camera_provider.dart';
import '../providers/detection_provider.dart';
import '../providers/punishment_provider.dart';
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
  CameraDescription? _cameraDescription;
  StreamSubscription? _detectionSub;
  bool _isDetecting = false;
  bool _isProcessing = false;
  bool _isRetrying = false;
  bool _isInitializing = true;
  int _lastProcessTimestamp = 0;
  LandmarkExtractor? _extractor;
  String? _initError;
  Set<String> _enabledHabitIds = {};

  static const _processInterval = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await ref.read(cameraProvider.future);
      if (cameras.isEmpty) {
        _setInitError('No camera found on this device.');
        return;
      }

      _cameraDescription = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        _cameraDescription!,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (!mounted) return;
      _extractor = await LandmarkExtractor.create();
      if (!mounted) return;

      if (_extractor!.status == ExtractorStatus.error) {
        _setInitError(_extractor!.errorMessage ?? 'ML Kit initialization failed.');
        return;
      }

      ref.read(isCameraInitializedProvider.notifier).state = true;
      if (mounted) setState(() => _isInitializing = false);
    } on MissingPluginException {
      _setInitError(
        kIsWeb
            ? 'Camera not available on web. Use the mobile or desktop app for live detection.'
            : defaultTargetPlatform == TargetPlatform.macOS
                ? 'Camera not available on macOS. Detection uses simulated data for testing.'
                : 'Camera plugin not available. Ensure native build is configured correctly.',
      );
    } catch (e) {
      _setInitError('Camera initialization failed: $e');
    }
  }

  void _setInitError(String message) {
    _extractor?.dispose();
    _extractor = null;
    _controller?.dispose();
    _controller = null;
    if (!mounted) return;
    setState(() {
      _isInitializing = false;
      _isRetrying = false;
      _initError = message;
    });
  }

  Future<void> _retryInit() async {
    setState(() => _isRetrying = true);
    _initError = null;
    _extractor?.dispose();
    _extractor = null;
    _controller?.dispose();
    _controller = null;
    ref.read(isCameraInitializedProvider.notifier).state = false;
    await _initCamera();
  }

  void _startDetection() {
    final engine = ref.read(detectionEngineProvider);
    final db = ref.read(databaseProvider);

    db.getEnabledHabits().then((enabled) {
      _enabledHabitIds = enabled.map((h) => h.id).toSet();
    });

    engine.start();
    ref.read(detectionStateProvider.notifier).state = DetectionEngineState.running;
    _isDetecting = true;
    _lastProcessTimestamp = 0;

    _detectionSub = engine.onEventsDetected.listen((events) {
      final recorder = ref.read(eventRecorderProvider);
      final punisher = ref.read(punishmentEngineProvider);
      for (final event in events) {
        recorder.recordEvent(event);
        _showHabitAlert(event);
      }
      punisher.processEvents(events);
    });

    _controller!.startImageStream(_onImageStream);
  }

  void _onImageStream(CameraImage image) {
    if (!_isDetecting || _isProcessing) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastProcessTimestamp < _processInterval.inMilliseconds) return;

    _lastProcessTimestamp = now;
    _isProcessing = true;

    _processFrame(image);
  }

  Future<void> _processFrame(CameraImage image) async {
    try {
      if (_extractor == null) return;

      final engine = ref.read(detectionEngineProvider);

      final data = await _extractor!.extract(cameraImage: image, camera: _cameraDescription);

      final results = engine.processFrame(
        poseLandmarks: data.poseLandmarks,
        faceLandmarks: data.faceLandmarks,
        handLandmarks: data.handLandmarks,
        imageWidth: data.imageWidth,
        imageHeight: data.imageHeight,
        enabledHabitIds: _enabledHabitIds.isNotEmpty ? _enabledHabitIds : null,
      );

      ref.read(detectionResultsProvider.notifier).state = results;
    } catch (e) {
      debugPrint('Frame processing error: $e');
    } finally {
      _isProcessing = false;
    }
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
    if (_controller != null && _controller!.value.isStreamingImages) {
      _controller!.stopImageStream();
    }
    _detectionSub?.cancel();
    ref.read(detectionEngineProvider).stop();
    ref.read(detectionStateProvider.notifier).state = DetectionEngineState.idle;
    ref.read(detectionResultsProvider.notifier).state = [];
  }

  Widget _buildBody(bool initialized, List<HabitDetectionResult> results, DetectionEngineState engineState) {
    final theme = Theme.of(context);

    if (_isRetrying) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Reinitializing camera\u2026'),
          ],
        ),
      );
    }

    if (_initError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Detection Unavailable', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                _initError!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _retryInit,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!initialized || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        CameraPreview(_controller!),
        CameraOverlay(results: results),
        if (_extractor != null && _extractor!.status != ExtractorStatus.ready)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.orange.shade800.withValues(alpha: 0.9),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ML Kit not ready',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Positioned(
          top: 16,
          right: 16,
          child: DetectionIndicator(
            isRunning: engineState == DetectionEngineState.running,
            results: results,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isDetecting = false;
    _detectionSub?.cancel();
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
          if (_initError != null || _isRetrying || _isInitializing)
            TextButton.icon(
              onPressed: null,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Unavailable'),
            )
          else if (engineState == DetectionEngineState.running)
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
      body: _buildBody(initialized, results, engineState),
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
