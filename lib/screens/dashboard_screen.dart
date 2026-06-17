import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/habit_config.dart';
import '../database/database.dart';
import '../providers/dashboard_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/streak_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allHabits = ref.watch(allHabitsProvider);
    final totalToday = ref.watch(totalTodayProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: allHabits.when(
        data: (habits) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SummaryHeader(totalToday: totalToday),
            const SizedBox(height: 20),
            Text('Today\'s Progress',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...habits.map((habit) => _HabitDashboardCard(habitId: habit.id, habitName: habit.name)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _SummaryHeader extends ConsumerWidget {
  final AsyncValue<int> totalToday;

  const _SummaryHeader({required this.totalToday});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allStreaks = ref.watch(allStreaksProvider);
    final count = totalToday.valueOrNull ?? 0;

    int bestStreak = 0;
    String bestHabit = '';
    final streaks = allStreaks.valueOrNull ?? {};
    for (final entry in streaks.entries) {
      final s = entry.value;
      if (s != null && s.longestLength > bestStreak) {
        bestStreak = s.longestLength;
        bestHabit = entry.key;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Detections Today',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text('$count',
                      style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                ],
              ),
            ),
            if (bestStreak > 0)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Best Streak',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('$bestStreak days',
                        style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.green)),
                    if (bestHabit.isNotEmpty)
                      Text(HabitConfig.fromId(bestHabit)?.name ?? bestHabit,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HabitDashboardCard extends ConsumerWidget {
  final String habitId;
  final String habitName;

  const _HabitDashboardCard({required this.habitId, required this.habitName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = HabitConfig.fromId(habitId);
    final todayCount = ref.watch(todaySummaryProvider(habitId));
    final weekly = ref.watch(weeklySummariesProvider(habitId));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(config?.icon ?? Icons.help_outline,
                      color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(habitName, style: theme.textTheme.titleMedium)),
                StreakWidget(habitId: habitId),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Today: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
                Text('${todayCount.valueOrNull ?? 0} detections',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: weekly.when(
                data: (data) => _WeeklyChart(data: data),
                loading: () => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<DailySummary> data;

  const _WeeklyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    final bars = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dateStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final match = data.where((d) => d.date == dateStr);
      return match.isNotEmpty ? match.first.count.toDouble() : 0.0;
    });

    final maxY = bars.reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxY < 1 ? 1.0 : maxY;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: effectiveMax * 1.2,
        minY: 0,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                final idx = value.toInt();
                if (idx < 0 || idx >= 7) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(days[idx],
                      style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                );
              },
              reservedSize: 16,
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (i) => BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: bars[i],
              color: bars[i] > 0 ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
              width: 10,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        )),
      ),
    );
  }
}
