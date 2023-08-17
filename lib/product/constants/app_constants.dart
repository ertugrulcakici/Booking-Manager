import 'package:bookingmanager/product/constants/image_enums.dart';
import 'package:flutter/widgets.dart';

final class AppConstants {
  AppConstants._();
  static const pathLocale = "assets/lang";
  static const List<Locale> supportedLocales = [
    Locale("en"),
    Locale("tr"),
    Locale("cs")
  ];
  static const Map<String, String> languageCodes = {
    "en": "English",
    "tr": "Türkçe",
    "cs": "Čeština"
  };
  static const Map<String, ImageEnums> languageImages = {
    "en": ImageEnums.en_flag,
    "tr": ImageEnums.tr_flag,
    "cs": ImageEnums.cs_flag
  };

  static const Locale fallBackLocale = Locale("en");
}
