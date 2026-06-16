import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../detection/detection_engine.dart';
import '../detection/habit_detection_result.dart';
import '../detection/habit_detector.dart';
import '../detection/sleeping_detector.dart';
import '../detection/slouching_detector.dart';
import '../detection/smoking_detector.dart';
import '../detection/nail_biting_detector.dart';
import '../detection/doom_scrolling_detector.dart';

final detectionEngineProvider = Provider<DetectionEngine>((ref) {
  final detectors = <HabitDetector>[
    SlouchingDetector(),
    SleepingDetector(),
    SmokingDetector(),
    NailBitingDetector(),
    DoomScrollingDetector(),
  ];

  final engine = DetectionEngine(detectors: detectors, frameSkip: 3);
  ref.onDispose(() => engine.dispose());
  return engine;
});

final detectionStateProvider = StateProvider<DetectionEngineState>((ref) {
  return DetectionEngineState.idle;
});

final detectionResultsProvider =
    StateProvider<List<HabitDetectionResult>>((ref) => []);

final eventRecorderProvider = Provider<EventRecorder>((ref) {
  final db = ref.watch(databaseProvider);
  return EventRecorder(db);
});

class EventRecorder {
  final AppDatabase _db;

  EventRecorder(this._db);

  Future<void> recordEvent(DetectedEvent event) async {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    await _db.insertEvent(
      DetectionEventsCompanion.insert(
        habitId: event.habitId,
        timestamp: event.timestamp,
        durationMs: event.durationMs,
        confidence: event.confidence,
      ),
    );

    final existing = await _db.getDailySummaries(
      habitId: event.habitId,
      days: 1,
    );

    final existingCount =
        existing.isNotEmpty && existing.first.date == dateStr
            ? existing.first.count
            : 0;
    final existingDuration =
        existing.isNotEmpty && existing.first.date == dateStr
            ? existing.first.totalDurationMs
            : 0;

    await _db.upsertDailySummary(
      date: dateStr,
      habitId: event.habitId,
      count: existingCount + 1,
      totalDurationMs: existingDuration + event.durationMs,
    );

    await _db.updateStreak(event.habitId, 1);
  }
}
