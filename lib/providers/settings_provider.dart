import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../database/database.dart';

final settingsProvider = Provider<SettingsManager>((ref) {
  final db = ref.watch(databaseProvider);
  return SettingsManager(db);
});

final enabledHabitsProvider = FutureProvider<List<Habit>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getEnabledHabits();
});

final allHabitsProvider = FutureProvider<List<Habit>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getHabits();
});

final enabledHabitsCountProvider = FutureProvider<int>((ref) async {
  final habits = await ref.watch(enabledHabitsProvider.future);
  return habits.length;
});

final isPremiumProvider = StateProvider<bool>((ref) => false);

class SettingsManager {
  final AppDatabase _db;

  SettingsManager(this._db);

  Future<String?> get(String key) => _db.getSetting(key);
  Future<void> set(String key, String value) => _db.setSetting(key, value);

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final val = await _db.getSetting(key);
    if (val == null) return defaultValue;
    return val == 'true';
  }

  Future<void> setBool(String key, bool value) =>
      _db.setSetting(key, value.toString());

  Future<int> getInt(String key, {int defaultValue = 0}) async {
    final val = await _db.getSetting(key);
    if (val == null) return defaultValue;
    return int.tryParse(val) ?? defaultValue;
  }

  Future<void> setInt(String key, int value) =>
      _db.setSetting(key, value.toString());

  Future<double> getDouble(String key, {double defaultValue = 0.0}) async {
    final val = await _db.getSetting(key);
    if (val == null) return defaultValue;
    return double.tryParse(val) ?? defaultValue;
  }

  Future<void> setDouble(String key, double value) =>
      _db.setSetting(key, value.toString());
}
