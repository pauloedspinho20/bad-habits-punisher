import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';

final historyFilterHabitProvider = StateProvider<String?>((ref) => null);

final historyFilterDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

final filteredHistoryEventsProvider = FutureProvider<List<DetectionEvent>>((ref) async {
  final db = ref.watch(databaseProvider);
  final habitId = ref.watch(historyFilterHabitProvider);
  final dateRange = ref.watch(historyFilterDateRangeProvider);

  DateTime? from;
  DateTime? to;

  if (dateRange != null) {
    from = dateRange.start;
    to = dateRange.end;
  }

  return db.getEvents(habitId: habitId, from: from, to: to);
});

final historyStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final events = await ref.watch(filteredHistoryEventsProvider.future);
  if (events.isEmpty) return {'total': 0};

  final byHabit = <String, int>{};
  int totalDuration = 0;
  double totalConfidence = 0;

  for (final e in events) {
    byHabit[e.habitId] = (byHabit[e.habitId] ?? 0) + 1;
    totalDuration += e.durationMs;
    totalConfidence += e.confidence;
  }

  final mostCommon = byHabit.entries.reduce((a, b) => a.value > b.value ? a : b);

  return {
    'total': events.length,
    'most_common_habit': mostCommon.key,
    'most_common_count': mostCommon.value,
    'total_duration_ms': totalDuration,
    'avg_confidence': events.isNotEmpty ? totalConfidence / events.length : 0.0,
    'habit_counts': byHabit,
  };
});
