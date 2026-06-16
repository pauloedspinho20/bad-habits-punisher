import 'package:flutter/material.dart';

import '../detection/habit_detection_result.dart';

class DetectionIndicator extends StatelessWidget {
  final bool isRunning;
  final List<HabitDetectionResult> results;

  const DetectionIndicator({
    super.key,
    required this.isRunning,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    final anyDetected = results.any((r) => r.detected);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isRunning
            ? (anyDetected ? Colors.orange.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.6))
            : Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRunning
                  ? (anyDetected ? Colors.red : Colors.green)
                  : Colors.grey,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isRunning ? (anyDetected ? 'Detecting' : 'Monitoring') : 'Paused',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
