import 'dart:async';

import 'package:bookingmanager/core/services/navigation/navigation_service.dart';
import 'package:bookingmanager/product/widgets/animated_info_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../services/localization/locale_keys.g.dart';

/// This class is used to show popups.
/// Within instances of this class, you can call the methods for showing popups.
/// You can use this class as a singleton.
/// Via static methods, you can reconfigure the instance.
class PopupHelper {
  PopupHelper._();

  static BuildContext get _context =>
      NavigationService.navigatorKey.currentContext!;

  static Future<void> showSnackBar({
    required String message,
    bool error = false,
    Duration duration = const Duration(seconds: 3),
  }) async {
    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: error
            ? Colors.red
            : Theme.of(_context).snackBarTheme.backgroundColor,
      ),
    );
  }

  static Future<void> showAnimatedInfoDialog({
    required String title,
    required bool isSuccessful,
  }) async {
    await showDialog(
      context: _context,
      barrierDismissible: false,
      builder: (context) =>
          AnimatedInfoDialog(title: title, isSuccessful: isSuccessful),
    );
  }

  static Future<T?> showOkCancelDialog<T extends dynamic>({
    required String title,
    required String content,
    required Function() onOk,
    Function()? onCancel,
    String? onOkText,
    String? onCancelText,
  }) async {
    return showDialog<T>(
      context: _context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              NavigationService.back();
              onCancel?.call();
            },
            child: Text(onCancelText ?? LocaleKeys.general_cancel.tr()),
          ),
          TextButton(
            onPressed: () {
              NavigationService.back();
              onOk();
            },
            child: Text(onOkText ?? LocaleKeys.general_ok.tr()),
          ),
        ],
      ),
    );
  }

  static bool _isShowingLoadingPopup = false;

  static void _showLoading() {
    if (_isShowingLoadingPopup) return;
    _isShowingLoadingPopup = true;
    showDialog(
      context: _context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  static void _hideLoading() {
    if (!_isShowingLoadingPopup) return;
    _isShowingLoadingPopup = false;
    NavigationService.back();
  }

  /// in a list it should be like () async => await {function}()
  static Future<T> showLoadingWhile<T extends dynamic>(
      Future<T> Function() function) async {
    try {
      _showLoading();
      return await function();
    } catch (e) {
      rethrow;
    } finally {
      _hideLoading();
    }
  }
}
