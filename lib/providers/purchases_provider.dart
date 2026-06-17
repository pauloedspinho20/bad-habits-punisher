import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../services/revenuecat_service.dart';

final isPremiumProvider = StateProvider<bool>((ref) {
  ref.onDispose(() {});
  return false;
});

final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  return RevenueCatService.getOfferings();
});

final purchaseInProgressProvider = StateProvider<bool>((ref) => false);

final purchasePackageProvider = FutureProvider.family<bool, Package>((ref, package) async {
  ref.read(purchaseInProgressProvider.notifier).state = true;
  try {
    final isActive = await RevenueCatService.purchasePackage(package);
    if (isActive) {
      ref.read(isPremiumProvider.notifier).state = true;
    }
    return isActive;
  } catch (e) {
    return false;
  } finally {
    ref.read(purchaseInProgressProvider.notifier).state = false;
  }
});

final restorePurchasesProvider = FutureProvider<bool>((ref) async {
  ref.read(purchaseInProgressProvider.notifier).state = true;
  try {
    final isActive = await RevenueCatService.restorePurchases();
    if (isActive) {
      ref.read(isPremiumProvider.notifier).state = true;
    }
    return isActive;
  } catch (e) {
    return false;
  } finally {
    ref.read(purchaseInProgressProvider.notifier).state = false;
  }
});

StreamSubscription<bool>? _premiumSub;

Future<void> initializePurchases(WidgetRef ref) async {
  await RevenueCatService.initialize();
  final isActive = await RevenueCatService.isPremium();
  ref.read(isPremiumProvider.notifier).state = isActive;

  _premiumSub?.cancel();
  _premiumSub = RevenueCatService.premiumStatusStream.listen((isActive) {
    ref.read(isPremiumProvider.notifier).state = isActive;
  });
}

void disposePurchases() {
  _premiumSub?.cancel();
  _premiumSub = null;
  RevenueCatService.dispose();
}
