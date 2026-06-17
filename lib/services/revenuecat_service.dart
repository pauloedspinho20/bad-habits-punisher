import 'dart:async';

import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static const String apiKey = String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: 'test_xBqPcqcWrdOdSogSHyKtWFeUgCW',
  );

  static const String premiumEntitlementId = 'premium';

  static final _premiumController = StreamController<bool>.broadcast();

  static Stream<bool> get premiumStatusStream => _premiumController.stream;

  static Future<void> initialize() async {
    await Purchases.configure(PurchasesConfiguration(apiKey));
    Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdate);
  }

  static void _onCustomerInfoUpdate(CustomerInfo customerInfo) {
    final isActive = customerInfo.entitlements.all[premiumEntitlementId]?.isActive ?? false;
    _premiumController.add(isActive);
  }

  static Future<bool> isPremium() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[premiumEntitlementId]?.isActive ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (_) {
      return null;
    }
  }

  static Future<bool> purchasePackage(Package package) async {
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      return result.customerInfo.entitlements.all[premiumEntitlementId]?.isActive ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all[premiumEntitlementId]?.isActive ?? false;
    } catch (_) {
      return false;
    }
  }

  static void dispose() {
    _premiumController.close();
  }
}
