import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/habit_config.dart';
import '../database/database.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: FutureBuilder(
        future: db.getEvents(limit: 100),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!;
          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('No detection events yet', style: theme.textTheme.titleMedium),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final config = HabitConfig.fromId(event.habitId);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _eventColor(event.habitId).withValues(alpha: 0.2),
                  child: Icon(config?.icon ?? Icons.help_outline, color: _eventColor(event.habitId)),
                ),
                title: Text(config?.name ?? event.habitId),
                subtitle: Text(
                  '${DateFormat.yMMMd().add_jm().format(event.timestamp)} \u00B7 ${(event.confidence * 100).toStringAsFixed(0)}% confidence',
                ),
                trailing: Text(_formatDuration(event.durationMs)),
              );
            },
          );
        },
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
