import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/habit_config.dart';
import '../database/database.dart';
import '../providers/punishment_provider.dart';
import '../punishment/punishment_config.dart';

class PunishmentSettingsScreen extends ConsumerWidget {
  const PunishmentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final configsAsync = ref.watch(punishmentOptionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Punishments')),
      body: configsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (configs) {
          if (configs.isEmpty) {
            return const Center(child: Text('No habits configured'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Configure what happens when a bad habit is detected.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              ...HabitConfig.all.map((habit) {
                final config = configs.cast<PunishmentOptions?>().firstWhere(
                      (c) => c?.habitId == habit.id,
                      orElse: () => null,
                    );
                if (config == null) return const SizedBox.shrink();
                return _PunishmentCard(habit: habit, config: config);
              }),
            ],
          );
        },
      ),
    );
  }
}

class _PunishmentCard extends ConsumerStatefulWidget {
  final HabitConfig habit;
  final PunishmentOptions config;

  const _PunishmentCard({required this.habit, required this.config});

  @override
  ConsumerState<_PunishmentCard> createState() => _PunishmentCardState();
}

class _PunishmentCardState extends ConsumerState<_PunishmentCard> {
  late bool _vibration;
  late bool _sound;
  late bool _flash;
  late double _intensity;

  @override
  void initState() {
    super.initState();
    _vibration = widget.config.vibration;
    _sound = widget.config.sound;
    _flash = widget.config.flash;
    _intensity = widget.config.intensity;
  }

  Future<void> _save() async {
    final db = ref.read(databaseProvider);
    await db.updatePunishmentConfig(
      habitId: widget.habit.id,
      vibration: _vibration,
      sound: _sound,
      flash: _flash,
      intensity: _intensity,
    );
    ref.invalidate(punishmentOptionsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  child: Icon(widget.habit.icon, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Text(widget.habit.name, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            _ToggleRow(
              icon: Icons.vibration,
              label: 'Vibration',
              value: _vibration,
              onChanged: (v) => setState(() { _vibration = v; _save(); }),
            ),
            _ToggleRow(
              icon: Icons.volume_up,
              label: 'Sound',
              value: _sound,
              onChanged: (v) => setState(() { _sound = v; _save(); }),
            ),
            _ToggleRow(
              icon: Icons.flash_on,
              label: 'Flash',
              value: _flash,
              onChanged: (v) => setState(() { _flash = v; _save(); }),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.tune, size: 18, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text('Intensity', style: theme.textTheme.bodyMedium),
                const Spacer(),
                Text('${(_intensity * 100).round()}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
            Slider(
              value: _intensity,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: '${(_intensity * 100).round()}%',
              onChanged: (v) => setState(() => _intensity = v),
              onChangeEnd: (_) => _save(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
    );
  }
}
