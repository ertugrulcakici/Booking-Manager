import 'package:bookingmanager/core/services/navigation/navigation_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SettingsNotifier extends ChangeNotifier {
  String _language =
      EasyLocalization.of(NavigationService.context)!.locale.languageCode;
  String get languageCode => _language;
  void setLanguage(String value, BuildContext context) {
    _language = value;
    EasyLocalization.of(context)!.setLocale(Locale(value));
    notifyListeners();
  }
}
