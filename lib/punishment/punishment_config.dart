enum PunishmentType { vibration, sound, flash }

class PunishmentOptions {
  final String habitId;
  final bool vibration;
  final bool sound;
  final bool flash;
  final double intensity;

  const PunishmentOptions({
    required this.habitId,
    this.vibration = false,
    this.sound = false,
    this.flash = true,
    this.intensity = 0.5,
  });

  PunishmentOptions copyWith({
    bool? vibration,
    bool? sound,
    bool? flash,
    double? intensity,
  }) {
    return PunishmentOptions(
      habitId: habitId,
      vibration: vibration ?? this.vibration,
      sound: sound ?? this.sound,
      flash: flash ?? this.flash,
      intensity: intensity ?? this.intensity,
    );
  }

  List<PunishmentType> get enabledTypes {
    final types = <PunishmentType>[];
    if (vibration) types.add(PunishmentType.vibration);
    if (sound) types.add(PunishmentType.sound);
    if (flash) types.add(PunishmentType.flash);
    return types;
  }
}
