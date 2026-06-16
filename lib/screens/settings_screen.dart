import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app.dart';
import '../core/constants.dart';
import '../core/habit_config.dart';
import '../database/database.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPremium = ref.watch(isPremiumProvider);
    final isDark = ref.watch(darkModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Habits', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...HabitConfig.all.map((habit) => _HabitSettingsTile(habit: habit)),
          const Divider(height: 32),
          Text('Preferences', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle dark theme'),
            value: isDark,
            onChanged: (v) => ref.read(darkModeProvider.notifier).state = v,
          ),
          const Divider(height: 32),
          Text('Subscription', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(
                isPremium ? Icons.workspace_premium : Icons.lock_outline,
                color: isPremium ? Colors.amber : null,
              ),
              title: Text(isPremium ? 'Premium Active' : 'Free Tier'),
              subtitle: Text(isPremium
                  ? 'All habits unlocked'
                  : '${AppConstants.freeHabitLimit} habits \u00B7 ${AppConstants.freeHistoryDays} day history'),
              trailing: isPremium
                  ? null
                  : FilledButton.tonal(
                      onPressed: () => _showUpgradeSheet(context),
                      child: const Text('Upgrade'),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpgradeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text('Go Premium', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Unlock all habits, unlimited history, detailed analytics, and more.'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: const Text('\$4.99/month \u00B7 Start Free Trial'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Not now'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitSettingsTile extends ConsumerWidget {
  final HabitConfig habit;

  const _HabitSettingsTile({required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPremium = ref.watch(isPremiumProvider);
    final locked = habit.isPremium && !isPremium;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: locked
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.primaryContainer,
          child: Icon(
            locked ? Icons.lock : habit.icon,
            color: locked
                ? theme.colorScheme.outline
                : theme.colorScheme.primary,
          ),
        ),
        title: Text(habit.name),
        subtitle: Text(habit.description, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: locked
            ? Icon(Icons.lock, color: theme.colorScheme.outline)
            : Switch(
                value: false,
                onChanged: (v) {
                  ref.read(databaseProvider).toggleHabit(habit.id);
                },
              ),
      ),
    );
  }
}
