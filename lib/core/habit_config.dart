import 'package:flutter/material.dart';

class HabitConfig {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Duration cooldown;
  final double defaultSensitivity;
  final bool isPremium;

  const HabitConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.cooldown,
    this.defaultSensitivity = 0.6,
    this.isPremium = false,
  });

  static const List<HabitConfig> all = [
    HabitConfig(
      id: 'slouching',
      name: 'Slouching',
      description: 'Detects poor posture — forward head, rounded shoulders',
      icon: Icons.accessibility_new,
      cooldown: Duration(seconds: 120),
      defaultSensitivity: 0.55,
    ),
    HabitConfig(
      id: 'sleeping',
      name: 'Sleeping',
      description: 'Detects when you fall asleep — closed eyes, head nod',
      icon: Icons.nightlight_round,
      cooldown: Duration(seconds: 30),
      defaultSensitivity: 0.6,
    ),
    HabitConfig(
      id: 'smoking',
      name: 'Smoking',
      description: 'Detects hand-to-mouth smoking gestures',
      icon: Icons.smoking_rooms,
      cooldown: Duration(seconds: 5),
      defaultSensitivity: 0.65,
      isPremium: true,
    ),
    HabitConfig(
      id: 'nail_biting',
      name: 'Nail Biting',
      description: 'Detects fingers near mouth in biting gesture',
      icon: Icons.pan_tool,
      cooldown: Duration(seconds: 5),
      defaultSensitivity: 0.6,
      isPremium: true,
    ),
    HabitConfig(
      id: 'doom_scrolling',
      name: 'Doom Scrolling',
      description: 'Detects excessive screen time and close face proximity',
      icon: Icons.phone_android,
      cooldown: Duration(seconds: 60),
      defaultSensitivity: 0.5,
      isPremium: true,
    ),
    HabitConfig(
      id: 'face_touching',
      name: 'Face Touching',
      description: 'Detects when you touch your face — common germ-spreading habit',
      icon: Icons.face,
      cooldown: Duration(seconds: 10),
      defaultSensitivity: 0.55,
      isPremium: true,
    ),
    HabitConfig(
      id: 'eye_rubbing',
      name: 'Eye Rubbing',
      description: 'Detects when you rub your eyes — can cause irritation and damage',
      icon: Icons.remove_red_eye,
      cooldown: Duration(seconds: 15),
      defaultSensitivity: 0.6,
      isPremium: true,
    ),
  ];

  static HabitConfig? fromId(String id) {
    try {
      return all.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }
}
