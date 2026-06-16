class AppConstants {
  AppConstants._();

  static const String appName = 'Bad Habits Punisher';
  static const String appVersion = '1.0.0';

  static const int detectionFrameInterval = 3;
  static const double defaultConfidenceThreshold = 0.6;

  static const int slouchingCooldownSeconds = 120;
  static const int sleepingCooldownSeconds = 30;
  static const int smokingCooldownSeconds = 5;
  static const int nailBitingCooldownSeconds = 5;
  static const int doomScrollingCooldownSeconds = 60;

  static const int freeHabitLimit = 2;
  static const int freeHistoryDays = 7;
}
