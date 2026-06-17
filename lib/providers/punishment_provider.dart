import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../punishment/punishment_config.dart';
import '../punishment/punishment_engine.dart';
import '../punishment/punishment_executor.dart';

final punishmentEngineProvider = Provider<PunishmentEngine>((ref) {
  final db = ref.watch(databaseProvider);
  final context = ref.watch(navigatorContextProvider);
  final executor = PunishmentExecutor(context);
  return PunishmentEngine(db, executor);
});

final punishmentOptionsProvider = FutureProvider<List<PunishmentOptions>>((ref) async {
  final db = ref.watch(databaseProvider);
  final rows = await db.getAllPunishmentConfigs();
  return rows.map((r) => PunishmentOptions(
    habitId: r.habitId,
    vibration: r.vibration,
    sound: r.sound,
    flash: r.flash,
    intensity: r.intensity,
  )).toList();
});

final navigatorContextProvider = StateProvider<BuildContext?>((ref) => null);
