import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/habit_config.dart';
import '../database/database.dart';
import '../providers/settings_provider.dart';

class HabitCard extends ConsumerWidget {
  final HabitConfig habit;

  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPremium = ref.watch(isPremiumProvider);
    final locked = habit.isPremium && !isPremium;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: locked ? theme.colorScheme.surfaceContainerLow : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: locked
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.primaryContainer,
          child: Icon(
            locked ? Icons.lock_outline : habit.icon,
            color: locked
                ? theme.colorScheme.outline
                : theme.colorScheme.primary,
          ),
        ),
        title: Row(
          children: [
            Text(habit.name),
            if (locked) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'PREMIUM',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.amber.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(habit.description, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
        onTap: locked
            ? null
            : () {
                ref.read(databaseProvider).toggleHabit(habit.id);
              },
      ),
    );
  }
}
