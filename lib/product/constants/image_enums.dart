// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

enum ImageEnums {
  logo,
  googleLogo,

  tr_flag,
  cs_flag,
  en_flag;

  static const _imagePath = 'assets/images/';

  /// this method convert enum to image
  /// note: add parameters when it's needed
  Image assetImage(
          {double? width, double? height, String imgExtension = ".png"}) =>
      Image.asset(
        '$_imagePath$name$imgExtension',
        width: width,
        height: height,
      );
}
