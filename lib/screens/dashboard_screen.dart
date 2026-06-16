import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/habit_config.dart';
import '../database/database.dart';
import '../providers/settings_provider.dart';
import '../widgets/streak_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allHabits = ref.watch(allHabitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: allHabits.when(
        data: (habits) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Today\'s Progress',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...habits.map((habit) => _HabitSummaryCard(
              habitId: habit.id,
              habitName: habit.name,
            )),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _HabitSummaryCard extends ConsumerWidget {
  final String habitId;
  final String habitName;

  const _HabitSummaryCard({
    required this.habitId,
    required this.habitName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(databaseProvider);
    final today = _todayStr();
    final config = HabitConfig.fromId(habitId);

    return FutureBuilder(
      future: db.getDailySummaries(habitId: habitId, days: 1),
      builder: (context, snapshot) {
        final summaries = snapshot.data ?? [];
        final summary = summaries.isNotEmpty && summaries.first.date == today
            ? summaries.first
            : null;
        final count = summary?.count ?? 0;
        final duration = summary?.totalDurationMs ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                config?.icon ?? Icons.help_outline,
                color: theme.colorScheme.primary,
              ),
            ),
            title: Text(habitName),
            subtitle: Text('$count detections today \u00B7 ${_formatDuration(duration)}'),
            trailing: StreakWidget(habitId: habitId),
          ),
        );
      },
    );
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int ms) {
    final seconds = ms ~/ 1000;
    final minutes = seconds ~/ 60;
    if (minutes > 0) return '${minutes}m ${seconds % 60}s';
    return '${seconds}s';
  }
}
