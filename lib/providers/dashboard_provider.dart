import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';

final weeklySummariesProvider = FutureProvider.family<List<DailySummary>, String>((ref, habitId) async {
  final db = ref.watch(databaseProvider);
  return db.getDailySummaries(habitId: habitId, days: 7);
});

final todayStrProvider = Provider<String>((ref) {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
});

final todaySummaryProvider = FutureProvider.family<int, String>((ref, habitId) async {
  final db = ref.watch(databaseProvider);
  final today = ref.watch(todayStrProvider);
  final summaries = await db.getDailySummaries(habitId: habitId, days: 1);
  final match = summaries.isNotEmpty && summaries.first.date == today ? summaries.first : null;
  return match?.count ?? 0;
});

final totalTodayProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final habits = await db.getEnabledHabits();
  final today = ref.watch(todayStrProvider);
  int total = 0;
  for (final habit in habits) {
    final summaries = await db.getDailySummaries(habitId: habit.id, days: 1);
    final match = summaries.isNotEmpty && summaries.first.date == today ? summaries.first : null;
    total += match?.count ?? 0;
  }
  return total;
});

final allStreaksProvider = FutureProvider<Map<String, Streak?>>((ref) async {
  final db = ref.watch(databaseProvider);
  final habits = await db.getHabits();
  final map = <String, Streak?>{};
  for (final habit in habits) {
    map[habit.id] = await db.getStreak(habit.id);
  }
  return map;
});
