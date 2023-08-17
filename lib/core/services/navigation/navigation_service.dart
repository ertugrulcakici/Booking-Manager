import 'package:flutter/material.dart';

abstract class NavigationService {
  static BuildContext get context => navigatorKey.currentContext!;

  static Future<void> _waitForBuildEnd() async {
    await WidgetsBinding.instance.endOfFrame;
  }

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<T?> toPage<T>(Widget page, {Object? arguments}) async {
    await _waitForBuildEnd();
    return await navigatorKey.currentState!.push<T?>(
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  static Future toPageReplacement(Widget page, {Object? arguments}) async {
    await _waitForBuildEnd();
    return await navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  static Future toPageAndRemoveUntil(Widget page, {Object? arguments}) async {
    await _waitForBuildEnd();
    return await navigatorKey.currentState!.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => page,
      ),
      (route) => false,
    );
  }

  // back if can
  static void back({Object? data}) {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop(data);
    }
  }

  // back to root
  static void backToRoot() {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }
  }
}
