import '../database/database.dart';
import '../detection/habit_detection_result.dart';
import 'punishment_config.dart';
import 'punishment_executor.dart';

class PunishmentEngine {
  final AppDatabase _db;
  final PunishmentExecutor _executor;
  final Map<String, DateTime> _lastPunishmentTime = {};
  static const _minInterval = Duration(seconds: 10);

  PunishmentEngine(this._db, this._executor);

  Future<void> processEvents(List<DetectedEvent> events) async {
    for (final event in events) {
      final now = DateTime.now();
      final last = _lastPunishmentTime[event.habitId];
      if (last != null && now.difference(last) < _minInterval) continue;

      final row = await _db.getPunishmentConfig(event.habitId);
      if (row == null) continue;

      final options = PunishmentOptions(
        habitId: row.habitId,
        vibration: row.vibration,
        sound: row.sound,
        flash: row.flash,
        intensity: row.intensity,
      );

      if (options.enabledTypes.isEmpty) continue;

      _lastPunishmentTime[event.habitId] = now;
      await _executor.execute(options);
    }
  }
}
