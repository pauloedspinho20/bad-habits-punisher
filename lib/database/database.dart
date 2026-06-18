import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Habits,
    DetectionEvents,
    DailySummaries,
    Streaks,
    AppSettings,
    PunishmentConfigs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'bad_habits'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedHabits();
          await _seedPunishmentConfigs();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(punishmentConfigs);
            await _seedPunishmentConfigs();
          }
        },
      );

  Future<void> _seedHabits() async {
    for (final h in _seedData) {
      await into(habits).insert(HabitsCompanion(
        id: Value(h.id),
        name: Value(h.name),
        iconPath: Value(h.iconPath),
        enabled: Value(h.enabled),
        sensitivity: Value(h.sensitivity),
        sortOrder: Value(h.sortOrder),
      ));
    }
  }

  Future<void> _seedPunishmentConfigs() async {
    for (final id in _seedData.map((h) => h.id)) {
      await into(punishmentConfigs).insert(
        PunishmentConfigsCompanion(
          habitId: Value(id),
          flash: const Value(true),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }

  static final _seedData = [
    _HabitSeed('slouching', 'Slouching', 'posture', false, 0.55, 1),
    _HabitSeed('sleeping', 'Sleeping', 'sleep', false, 0.60, 2),
    _HabitSeed('smoking', 'Smoking', 'smoking', false, 0.65, 3),
    _HabitSeed('nail_biting', 'Nail Biting', 'nail_biting', false, 0.60, 4),
    _HabitSeed('doom_scrolling', 'Doom Scrolling', 'doom_scrolling', false, 0.50, 5),
    _HabitSeed('face_touching', 'Face Touching', 'face', false, 0.55, 6),
    _HabitSeed('eye_rubbing', 'Eye Rubbing', 'eye_rubbing', false, 0.60, 7),
  ];

  Future<List<Habit>> getHabits() => select(habits).get();

  Future<List<Habit>> getEnabledHabits() =>
      (select(habits)..where((h) => h.enabled.equals(true))).get();

  Future<void> toggleHabit(String id) async {
    final current = await (select(habits)..where((h) => h.id.equals(id)))
        .getSingle();
    await (update(habits)..where((h) => h.id.equals(id))).write(
      HabitsCompanion(enabled: Value(!current.enabled)),
    );
  }

  Future<void> updateSensitivity(String id, double value) async {
    await (update(habits)..where((h) => h.id.equals(id))).write(
      HabitsCompanion(sensitivity: Value(value)),
    );
  }

  Future<int> insertEvent(DetectionEventsCompanion event) =>
      into(detectionEvents).insert(event);

  Future<List<DetectionEvent>> getEvents({
    String? habitId,
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    var query = select(detectionEvents)
      ..orderBy([(d) => OrderingTerm(expression: d.timestamp, mode: OrderingMode.desc)]);
    if (habitId != null) query.where((d) => d.habitId.equals(habitId));
    if (from != null) query.where((d) => d.timestamp.isBiggerOrEqualValue(from));
    if (to != null) query.where((d) => d.timestamp.isSmallerOrEqualValue(to));
    if (limit != null) query.limit(limit);
    return query.get();
  }

  Future<void> upsertDailySummary({
    required String date,
    required String habitId,
    required int count,
    required int totalDurationMs,
  }) async {
    await into(dailySummaries).insert(
      DailySummariesCompanion(
        date: Value(date),
        habitId: Value(habitId),
        count: Value(count),
        totalDurationMs: Value(totalDurationMs),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<List<DailySummary>> getDailySummaries({
    String? habitId,
    int? days,
  }) async {
    var query = select(dailySummaries)
      ..orderBy([(d) => OrderingTerm(expression: d.date, mode: OrderingMode.desc)]);
    if (habitId != null) query.where((d) => d.habitId.equals(habitId));
    if (days != null) query.limit(days);
    return query.get();
  }

  Future<Streak?> getStreak(String habitId) async {
    final results = await (select(streaks)..where((s) => s.habitId.equals(habitId))).get();
    return results.isEmpty ? null : results.first;
  }

  Future<void> updateStreak(String habitId, int brokeToday) async {
    final existing = await getStreak(habitId);
    if (existing == null) {
      await into(streaks).insert(StreaksCompanion.insert(
        habitId: habitId,
        startDate: DateTime.now(),
        currentLength: brokeToday == 0 ? 1 : 0,
        longestLength: brokeToday == 0 ? 1 : 0,
      ));
    } else {
      final newCurrent = brokeToday == 0 ? existing.currentLength + 1 : 0;
      final newLongest = newCurrent > existing.longestLength
          ? newCurrent
          : existing.longestLength;
      await (update(streaks)..where((s) => s.id.equals(existing.id))).write(
        StreaksCompanion(
          currentLength: Value(newCurrent),
          longestLength: Value(newLongest),
          startDate: Value(brokeToday == 0 ? existing.startDate : DateTime.now()),
        ),
      );
    }
  }

  Future<String?> getSetting(String key) async {
    final results = await (select(appSettings)..where((s) => s.key.equals(key))).get();
    return results.isEmpty ? null : results.first.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(appSettings).insert(
      AppSettingsCompanion(key: Value(key), value: Value(value)),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<PunishmentConfig?> getPunishmentConfig(String habitId) async {
    final results = await (select(punishmentConfigs)
          ..where((p) => p.habitId.equals(habitId)))
        .get();
    return results.isEmpty ? null : results.first;
  }

  Future<List<PunishmentConfig>> getAllPunishmentConfigs() =>
      select(punishmentConfigs).get();

  Future<void> updatePunishmentConfig({
    required String habitId,
    bool? vibration,
    bool? sound,
    bool? flash,
    double? intensity,
  }) async {
    await (update(punishmentConfigs)
          ..where((p) => p.habitId.equals(habitId)))
        .write(PunishmentConfigsCompanion(
      vibration: vibration != null ? Value(vibration) : const Value.absent(),
      sound: sound != null ? Value(sound) : const Value.absent(),
      flash: flash != null ? Value(flash) : const Value.absent(),
      intensity: intensity != null ? Value(intensity) : const Value.absent(),
    ));
  }
}

class _HabitSeed {
  final String id;
  final String name;
  final String iconPath;
  final bool enabled;
  final double sensitivity;
  final int sortOrder;

  const _HabitSeed(this.id, this.name, this.iconPath, this.enabled, this.sensitivity, this.sortOrder);
}
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());
