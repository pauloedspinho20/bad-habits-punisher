import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/habit_config.dart';
import '../database/database.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habitFilter = ref.watch(historyFilterHabitProvider);
    final dateRange = ref.watch(historyFilterDateRangeProvider);
    final eventsAsync = ref.watch(filteredHistoryEventsProvider);
    final statsAsync = ref.watch(historyStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Column(
        children: [
          _FilterBar(habitFilter: habitFilter, dateRange: dateRange),
          Expanded(
            child: eventsAsync.when(
              data: (events) => events.isEmpty
                  ? _EmptyState(theme: theme)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        _StatsCard(statsAsync: statsAsync),
                        const SizedBox(height: 16),
                        _DailyBarChart(events: events),
                        const SizedBox(height: 16),
                        Text('Detection Events',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...events.map((e) => _EventTile(event: e)),
                      ],
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  final String? habitFilter;
  final DateTimeRange? dateRange;

  const _FilterBar({required this.habitFilter, required this.dateRange});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allHabits = HabitConfig.all;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String?>(
              value: habitFilter,
              decoration: const InputDecoration(
                labelText: 'Habit',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All habits')),
                ...allHabits.map((h) => DropdownMenuItem(
                      value: h.id,
                      child: Row(
                        children: [
                          Icon(h.icon, size: 16),
                          const SizedBox(width: 6),
                          Text(h.name),
                        ],
                      ),
                    )),
              ],
              onChanged: (v) => ref.read(historyFilterHabitProvider.notifier).state = v,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.date_range,
              color: dateRange != null ? theme.colorScheme.primary : null,
            ),
            onPressed: () => _pickDateRange(context, ref),
            tooltip: 'Filter by date',
          ),
          if (dateRange != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => ref.read(historyFilterDateRangeProvider.notifier).state = null,
              tooltip: 'Clear date filter',
            ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () => _exportCsv(context, ref),
            tooltip: 'Export as CSV',
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateRange(BuildContext context, WidgetRef ref) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: ref.read(historyFilterDateRangeProvider),
    );
    if (picked != null) {
      ref.read(historyFilterDateRangeProvider.notifier).state = picked;
    }
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final events = await ref.read(filteredHistoryEventsProvider.future);
    if (events.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No events to export')),
        );
      }
      return;
    }

    final buffer = StringBuffer('Date,Time,Habit,Confidence,Duration (s)\n');
    for (final e in events) {
      final config = HabitConfig.fromId(e.habitId);
      final dt = DateFormat('yyyy-MM-dd,HH:mm:ss').format(e.timestamp);
      buffer.writeln('$dt,${config?.name ?? e.habitId},${(e.confidence * 100).toStringAsFixed(1)}%,${(e.durationMs / 1000).toStringAsFixed(1)}');
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV copied to clipboard')),
      );
    }
  }
}

class _EmptyState extends StatelessWidget {
  final ThemeData theme;

  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text('No detection events yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Start tracking a habit to see history',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _StatsCard extends ConsumerWidget {
  final AsyncValue<Map<String, dynamic>> statsAsync;

  const _StatsCard({required this.statsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = statsAsync.valueOrNull;
    if (stats == null || stats['total'] == 0) return const SizedBox.shrink();

    final totalEvents = stats['total'] as int;
    final totalDuration = stats['total_duration_ms'] as int;
    final avgConf = (stats['avg_confidence'] as double) * 100;
    final mostCommonHabit = HabitConfig.fromId(stats['most_common_habit'] as String)?.name ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatItem(label: 'Events', value: '$totalEvents', icon: Icons.warning),
                _StatItem(label: 'Duration', value: _formatDuration(totalDuration), icon: Icons.timer),
                _StatItem(label: 'Avg Conf.', value: '${avgConf.toStringAsFixed(0)}%', icon: Icons.speed),
              ],
            ),
            if (mostCommonHabit.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Most detected: $mostCommonHabit (${stats['most_common_count']}x)',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(int ms) {
    final totalSec = ms ~/ 1000;
    if (totalSec < 60) return '${totalSec}s';
    final min = totalSec ~/ 60;
    final sec = totalSec % 60;
    return '${min}m ${sec}s';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _DailyBarChart extends StatelessWidget {
  final List<DetectionEvent> events;

  const _DailyBarChart({required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final grouped = <String, int>{};
    for (final e in events) {
      final day = DateFormat('MM/dd').format(e.timestamp);
      grouped[day] = (grouped[day] ?? 0) + 1;
    }

    final sortedDays = grouped.keys.toList()
      ..sort((a, b) {
        final am = DateFormat('MM/dd').parse(a);
        final bm = DateFormat('MM/dd').parse(b);
        return am.compareTo(bm);
      });

    if (sortedDays.length > 14) {
      sortedDays.removeRange(0, sortedDays.length - 14);
    }

    final maxCount = grouped.values.reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxCount < 3 ? 3.0 : maxCount.toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 12),
              child: Text('Daily Detections',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 120,
              child: BarChart(
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
                          final idx = value.toInt();
                          if (idx < 0 || idx >= sortedDays.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(sortedDays[idx],
                                style: TextStyle(fontSize: 9, color: theme.colorScheme.onSurfaceVariant)),
                          );
                        },
                        reservedSize: 18,
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(sortedDays.length, (i) {
                    final count = grouped[sortedDays[i]]?.toDouble() ?? 0;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: count,
                          color: count > 0 ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                          width: 12,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final DetectionEvent event;

  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = HabitConfig.fromId(event.habitId);

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: _eventColor(event.habitId).withValues(alpha: 0.2),
          child: Icon(config?.icon ?? Icons.help_outline, size: 18, color: _eventColor(event.habitId)),
        ),
        title: Text(config?.name ?? event.habitId, style: const TextStyle(fontSize: 14)),
        subtitle: Text(
          DateFormat.yMMMd().add_jm().format(event.timestamp),
          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${(event.confidence * 100).toStringAsFixed(0)}%',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _eventColor(event.habitId))),
            Text(_formatDuration(event.durationMs),
                style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Color _eventColor(String id) {
    switch (id) {
      case 'slouching': return Colors.orange;
      case 'sleeping': return Colors.indigo;
      case 'smoking': return Colors.red;
      case 'nail_biting': return Colors.purple;
      case 'doom_scrolling': return Colors.teal;
      case 'face_touching': return Colors.pink;
      case 'eye_rubbing': return Colors.brown;
      default: return Colors.grey;
    }
  }

  String _formatDuration(int ms) {
    final seconds = ms ~/ 1000;
    final minutes = seconds ~/ 60;
    if (minutes > 0) return '${minutes}m ${seconds % 60}s';
    return '${seconds}s';
  }
}
