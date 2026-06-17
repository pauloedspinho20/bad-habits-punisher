import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'punishment_config.dart';

class PunishmentExecutor {
  final BuildContext? _context;
  AudioPlayer? _player;

  PunishmentExecutor(this._context);

  Future<void> execute(PunishmentOptions options) async {
    final tasks = <Future<void>>[];

    if (options.vibration) {
      tasks.add(_vibrate(options.intensity));
    }
    if (options.sound) {
      tasks.add(_playSound(options.intensity));
    }
    if (options.flash) {
      _flash();
    }

    await Future.wait(tasks);
  }

  Future<void> _vibrate(double intensity) async {
    try {
      if (intensity >= 0.7) {
        HapticFeedback.heavyImpact();
      } else if (intensity >= 0.4) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    } catch (_) {
    }
  }

  Future<void> _playSound(double intensity) async {
    try {
      _player?.dispose();
      _player = AudioPlayer();
      await _player!.setVolume(intensity.clamp(0.0, 1.0));
      await _player!.play(AssetSource('sounds/alarm.wav'));
    } catch (_) {
    }
  }

  void _flash() {
    final ctx = _context;
    if (ctx == null) return;
    ScaffoldMessenger.maybeOf(ctx)?.showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Bad habit detected!'),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
