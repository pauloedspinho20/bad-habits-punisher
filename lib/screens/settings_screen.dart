import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../app.dart';
import '../core/constants.dart';
import '../core/habit_config.dart';
import '../database/database.dart';
import '../providers/purchases_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPremium = ref.watch(isPremiumProvider);
    final isDark = ref.watch(darkModeProvider);
    final enabledCount = ref.watch(enabledHabitsCountProvider);

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
            onChanged: (v) => _toggleDarkMode(ref, v),
          ),
          const Divider(height: 32),
          Text('Punishments', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.gavel),
              title: const Text('Configure Punishments'),
              subtitle: const Text('Vibration, sound, flash on detection'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/punishments'),
            ),
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
              subtitle: Text(
                isPremium
                    ? 'All habits unlocked'
                    : '${AppConstants.freeHabitLimit} habits enabled (${enabledCount.valueOrNull ?? 0} used) \u00B7 ${AppConstants.freeHistoryDays} day history',
              ),
              trailing: isPremium
                  ? null
                  : FilledButton.tonal(
                      onPressed: () => showUpgradeSheet(context),
                      child: const Text('Upgrade'),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleDarkMode(WidgetRef ref, bool value) async {
    final db = ref.read(databaseProvider);
    await db.setSetting('dark_mode', value.toString());
    ref.read(darkModeProvider.notifier).state = value;
  }
}

void showUpgradeSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => const _UpgradeSheetContent(),
  );
}

class _UpgradeSheetContent extends ConsumerWidget {
  const _UpgradeSheetContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offeringsAsync = ref.watch(offeringsProvider);
    final inProgress = ref.watch(purchaseInProgressProvider);

    return Padding(
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
          offeringsAsync.when(
            data: (offerings) {
              final offering = offerings?.current;
              final monthly = offering?.monthly;
              if (monthly == null) return const _FallbackPurchaseButton();
              return _PackageButton(package: monthly);
            },
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const _FallbackPurchaseButton(),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: inProgress
                ? null
                : () async {
                    await ref.read(restorePurchasesProvider.future);
                    if (context.mounted) Navigator.pop(context);
                  },
            child: const Text('Restore Purchases'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: inProgress ? null : () => Navigator.pop(context),
            child: const Text('Not now'),
          ),
        ],
      ),
    );
  }
}

class _FallbackPurchaseButton extends ConsumerWidget {
  const _FallbackPurchaseButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inProgress = ref.watch(purchaseInProgressProvider);

    return FilledButton(
      onPressed: inProgress
          ? null
          : () async {
              final offerings = await ref.read(offeringsProvider.future);
              final monthly = offerings?.current?.monthly;
              if (monthly != null) {
                await ref.read(purchasePackageProvider(monthly).future);
              }
              if (context.mounted) Navigator.pop(context);
            },
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      child: inProgress
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : const Text('Upgrade'),
    );
  }
}

class _PackageButton extends ConsumerWidget {
  final Package package;

  const _PackageButton({required this.package});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inProgress = ref.watch(purchaseInProgressProvider);
    final product = package.storeProduct;
    final priceString = product.priceString;
    final period = _formatPeriod(product.subscriptionPeriod);

    return FilledButton(
      onPressed: inProgress
          ? null
          : () async {
              await ref.read(purchasePackageProvider(package).future);
              if (context.mounted) Navigator.pop(context);
            },
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      child: inProgress
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : Text('$priceString / $period \u00B7 Start Free Trial'),
    );
  }

  String _formatPeriod(String? iso) {
    if (iso == null) return 'month';
    switch (iso) {
      case 'P1W': return 'week';
      case 'P1M': return 'month';
      case 'P3M': return '3 months';
      case 'P6M': return '6 months';
      case 'P1Y': return 'year';
      default: return iso.replaceAll('P', '').replaceAll('M', ' months').replaceAll('W', ' weeks').replaceAll('Y', ' years');
    }
  }
}

class _HabitSettingsTile extends ConsumerWidget {
  final HabitConfig habit;

  const _HabitSettingsTile({required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPremium = ref.watch(isPremiumProvider);
    final allHabitsAsync = ref.watch(allHabitsProvider);
    final enabledCountAsync = ref.watch(enabledHabitsCountProvider);

    final locked = habit.isPremium && !isPremium;
    final allHabits = allHabitsAsync.valueOrNull ?? [];
    Habit? dbHabit;
    try {
      dbHabit = allHabits.firstWhere((h) => h.id == habit.id);
    } catch (_) {}
    final enabled = dbHabit?.enabled ?? false;
    final enabledCount = enabledCountAsync.valueOrNull ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: locked
              ? theme.colorScheme.surfaceContainerHighest
              : enabled
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            locked ? Icons.lock : habit.icon,
            color: locked
                ? theme.colorScheme.outline
                : enabled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
          ),
        ),
        title: Text(habit.name),
        subtitle: Text(habit.description, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: locked
            ? Icon(Icons.lock, color: theme.colorScheme.outline)
            : Switch(
                value: enabled,
                onChanged: (v) => _toggleHabit(ref, habit, v, enabledCount),
              ),
      ),
    );
  }

  Future<void> _toggleHabit(WidgetRef ref, HabitConfig habit, bool newValue, int currentEnabledCount) async {
    final isPremium = ref.read(isPremiumProvider);

    if (newValue && !isPremium) {
      const freeLimit = AppConstants.freeHabitLimit;
      if (currentEnabledCount >= freeLimit) {
        _showLimitReached(ref.context);
        return;
      }
      if (habit.isPremium) {
        _showPremiumPrompt(ref.context);
        return;
      }
    }

    final db = ref.read(databaseProvider);
    await db.toggleHabit(habit.id);
    ref.invalidate(allHabitsProvider);
    ref.invalidate(enabledHabitsProvider);
    ref.invalidate(enabledHabitsCountProvider);
  }

  void _showLimitReached(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Free Limit Reached'),
        content: const Text(
          'You can track up to ${AppConstants.freeHabitLimit} habits on the free tier. '
          'Upgrade to premium to unlock all habits.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Not now')),
          FilledButton(onPressed: () { Navigator.pop(ctx); _showUpgradeSheet(context); }, child: const Text('Upgrade')),
        ],
      ),
    );
  }

  void _showPremiumPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Premium Habit'),
        content: Text('${habit.name} is a premium habit. Upgrade to unlock it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Not now')),
          FilledButton(onPressed: () { Navigator.pop(ctx); _showUpgradeSheet(context); }, child: const Text('Upgrade')),
        ],
      ),
    );
  }

  void _showUpgradeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _UpgradeSheetContent(),
    );
  }
}
