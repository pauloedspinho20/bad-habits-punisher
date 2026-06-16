# Bad Habits Punisher

A cross-platform Flutter app that uses device camera + ML to detect and track bad habits in real time: slouching, sleeping, smoking, nail biting, and doom scrolling.

**Platforms:** macOS, iOS, Android, Windows, Linux, Web (WIP)

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.44+ / Dart 3.12+ |
| State | Riverpod |
| Navigation | GoRouter |
| Camera | `camera` plugin |
| ML (mobile) | Google ML Kit (pose, face mesh) + `hand_landmarker` |
| ML (desktop) | Simulated extractor (for development) |
| Database | Drift (SQLite) — offline-first |
| Ads | AdMob (planned) |
| Payments | RevenueCat (planned) |
| CI/CD | Codemagic / GitHub Actions |

## Prerequisites

- **Flutter SDK** 3.44+ ([install guide](https://docs.flutter.dev/get-started/install))
- **Platform SDKs:**
  - macOS: Xcode 16+
  - iOS: Xcode 16+ (CocoaPods)
  - Android: Android Studio, Android SDK 34+
  - Web: Chrome (partial — SQLite not supported in browser yet)
- **Optional:** Android/iOS device for real ML Kit landmark extraction

## Quick Start

```bash
# 1. Clone and enter the project
cd bad_habits_punisher

# 2. Install dependencies
flutter pub get

# 3. Run build_runner (generates Drift + Freezed code)
dart run build_runner build --delete-conflicting-outputs

# 4. Run on your platform
flutter run -d macos     # macOS desktop
flutter run -d ios       # iOS (requires connected device/simulator)
flutter run -d android   # Android (requires emulator or device)
flutter run -d chrome    # Web (database stubbed — dev only)
```

> **Note on Web:** SQLite (`dart:ffi`) is not available in browsers. A `drift_web` backend is needed for full web support. The macOS desktop build is currently the most complete runtime target.

## Available Scripts

| Command | Purpose |
|---|---|
| `flutter pub get` | Install dependencies |
| `dart run build_runner build` | Generate code (Drift, Freezed) |
| `dart analyze lib/` | Static analysis |
| `flutter test` | Run all tests |
| `flutter run -d macos` | Run macOS desktop (hot-reload) |
| `flutter run --release` | Run release mode (no hot-reload) |

## Building for Release

```bash
# macOS (App Store + DMG distribution)
flutter build macos
# Output: build/macos/Build/Products/Release/bad_habits_punisher.app

# iOS (App Store)
flutter build ios --release --no-codesign
# Output: build/ios/iphoneos/Runner.app

# Android (Google Play)
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab

# Web (PWA / hosting)
flutter build web
# Output: build/web/

# Windows
flutter build windows

# Linux
flutter build linux
```

### macOS Deployment

```bash
# 1. Build release
flutter build macos

# 2. Codesign & notarize
codesign --strong --deep --force build/macos/Build/Products/Release/bad_habits_punisher.app
ditto -c -k --sequesterRsrc --keepParent \
  build/macos/Build/Products/Release/bad_habits_punisher.app \
  build/macos/Build/Products/Release/bad_habits_punisher.zip

# 3. Submit to App Store via Xcode
open build/macos/Build/Products/Release/bad_habits_punisher.app
# Product → Archive → Distribute App
```

## Architecture

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # Riverpod + GoRouter + dark mode
├── core/                        # Theme, constants, responsive, habit config
├── database/                    # Drift SQLite schema + DAOs
├── detection/                   # All 5 habit detectors + engine
│   ├── habit_detector.dart      # Abstract interface
│   ├── detection_engine.dart    # Frame processor + event stream
│   ├── slouching_detector.dart  # Pose landmarks → head forward score
│   ├── sleeping_detector.dart   # Face mesh → EAR + head nod
│   ├── smoking_detector.dart    # Hand-to-mouth + pinch + mouth open
│   ├── nail_biting_detector.dart# Finger proximity + curl + mouth open
│   └── doom_scrolling_detector.dart # Face proximity + gaze + stillness
├── ml/                          # ML abstraction layer
│   ├── landmark_extractor.dart  # Abstract + factory + ML Kit stub
│   └── simulated_extractor.dart # Development-only simulated data
├── providers/                   # Riverpod state providers
├── screens/                     # Home, Camera, Dashboard, History, Settings
└── widgets/                     # HabitCard, CameraOverlay, DetectionIndicator, Streak
```

### Detection Pipeline

```
Camera frame (100ms)
  → LandmarkExtractor (ML Kit or simulated)
    → LandmarkData (pose, face, hand landmark lists)
      → DetectionEngine.processFrame()
        → Each HabitDetector.process() (temporal smoothing + scoring)
          → If sustained > threshold → DetectedEvent
            → EventRecorder → SQLite (events + daily summaries + streaks)
              → SnackBar alert in camera UI
```

### All 5 Detectors

| Habit | Input | Method |
|---|---|---|
| Slouching | 33 pose landmarks | Head forward offset + shoulder asymmetry |
| Sleeping | 478 face landmarks | Eye Aspect Ratio (EAR) + head nod |
| Smoking | Hand + face landmarks | Hand-to-mouth proximity + finger pinch + mouth opening |
| Nail Biting | Hand + face landmarks | Fingertip-to-mouth distance + finger curl |
| Doom Scrolling | Face + hand landmarks | Face proximity + downward gaze + head stillness + phone grip |

### Database Schema (SQLite)

| Table | Key Fields |
|---|---|
| `habits` | id, name, icon_path, enabled, sensitivity, sort_order |
| `detection_events` | id, habit_id, timestamp, duration_ms, confidence |
| `daily_summaries` | date, habit_id, count, total_duration_ms |
| `streaks` | id, habit_id, start_date, current_length, longest_length |
| `app_settings` | key, value |

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/detection/slouching_detector_test.dart
```

Tests cover: all 5 detectors (null/insufficient input), detection engine (state machine, frame processing, event emission), and data models.

## Monetization Model

| Tier | Price | Features |
|---|---|---|
| Free | $0 | 2 habits, 7-day history, banner + interstitial ads |
| Premium | $4.99/mo or $39.99/yr | All 5 habits, unlimited history, streaks, no ads |
| Lifetime | $79.99 | Same as Premium, one-time |

## 5 Bad Habits Detected

1. **Slouching** — poor posture detection (forward head, rounded shoulders)
2. **Sleeping** — eye closure detection (EAR) + head nod
3. **Smoking** — hand-to-mouth gesture + object proximity
4. **Nail Biting** — fingertip-to-mouth with curl detection
5. **Doom Scrolling** — face proximity + downward gaze + head stillness

## Planned Features

- [ ] Real ML Kit landmark extraction (iOS/Android)
- [ ] RevenueCat in-app purchases (premium unlock)
- [ ] AdMob (rewarded video, interstitial, banner)
- [ ] Push notifications (habit alerts, streak reminders)
- [ ] Web deployment (drift_web backend)
- [ ] Apple Watch / Wear OS companion
- [ ] Multi-device sync via Supabase
- [ ] PDF export (weekly/monthly reports)
- [ ] Custom habit creation

## License

Private — all rights reserved.
