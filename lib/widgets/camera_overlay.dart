import 'package:flutter/material.dart';

import '../detection/habit_detection_result.dart';

class CameraOverlay extends StatelessWidget {
  final List<HabitDetectionResult> results;

  const CameraOverlay({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        children: [
          const Spacer(),
          if (results.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: results.map((r) => _HabitResultRow(result: r)).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _HabitResultRow extends StatelessWidget {
  final HabitDetectionResult result;

  const _HabitResultRow({required this.result});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            result.detected ? Icons.warning_amber : Icons.check_circle_outline,
            color: result.detected ? Colors.orange : Colors.green,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(_habitName(result.habitId), style: const TextStyle(color: Colors.white)),
          const Spacer(),
          Text(
            '${(result.confidence * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              color: result.detected ? Colors.orange : Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: LinearProgressIndicator(
              value: result.confidence,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation(
                result.detected ? Colors.orange : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _habitName(String id) {
    switch (id) {
      case 'slouching': return 'Slouching';
      case 'sleeping': return 'Sleeping';
      case 'smoking': return 'Smoking';
      case 'nail_biting': return 'Nail Biting';
      case 'doom_scrolling': return 'Doom Scrolling';
      default: return id;
    }
  }
}
