import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'database/database.dart';
import 'providers/purchases_provider.dart';
import 'providers/punishment_provider.dart';
import 'screens/camera_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/punishment_settings_screen.dart';
import 'screens/settings_screen.dart';

final darkModeProvider = StateProvider<bool>((ref) => false);

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/camera',
        name: 'camera',
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/punishments',
        name: 'punishments',
        builder: (context, state) => const PunishmentSettingsScreen(),
      ),
    ],
  );
});

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    _loadPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(navigatorContextProvider.notifier).state = context;
    });
  }

  Future<void> _loadPreferences() async {
    if (!mounted) return;
    await initializePurchases(ref);
    final db = ref.read(databaseProvider);
    final darkModeVal = await db.getSetting('dark_mode');
    if (darkModeVal == 'true' && mounted) {
      ref.read(darkModeProvider.notifier).state = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(darkModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
