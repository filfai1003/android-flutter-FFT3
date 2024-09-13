import 'dart:ui';

import 'package:flutter/cupertino.dart';

class AppColors{
  static const Color primary = Color(0xFFFF6464);
  static const Color secondary = Color(0xFFFF9696);
  static const Color background1 = Color(0xFFFFFFFF);
  static const Color background2 = Color(0xFFECECEC);

  static const Color text1 = Color(0xFF000000);
  static const Color text2 = Color(0xFF323232);
  static const Color text3 = Color(0xFFFFFFFF);
}

class Constants{
  static const double paddingValue = 10;

  static const double borderRadiusValue1 = 25;
  static const double borderRadiusValue2 = 10;

  static const double fontSize1 = 25;
  static const double fontSize2 = 20;
  static const double fontSize3 = 15;

  static const double iconSize1 = 50;
  static const double iconSize2 = 25;
  static const double iconSize3 = 15;

  static const double padding1 = 24;
  static const double padding2 = 16;
  static const double padding3 = 8;
}

class TextStyles {
  static const TextStyle textStyle1 = TextStyle(
    fontSize: Constants.fontSize1,
    color: Color(0xFF000000),
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  static const TextStyle textStyle2 = TextStyle(
    fontSize: Constants.fontSize2,
    color: Color(0xFF323232),
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
  );

  static const TextStyle textStyle3 = TextStyle(
    fontSize: Constants.fontSize3,
    color: Color(0xFF323232),
    fontWeight: FontWeight.normal,
    letterSpacing: 0.8,
  );

  static const TextStyle textStyle11 = TextStyle(
    fontSize: Constants.fontSize1,
    color: Color(0xFFFFFFFF),
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  static const TextStyle textStyle12 = TextStyle(
    fontSize: Constants.fontSize2,
    color: Color(0xFFCDCDCD),
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
  );

  static const TextStyle textStyle13 = TextStyle(
    fontSize: Constants.fontSize3,
    color: Color(0xFFCDCDCD),
    fontWeight: FontWeight.normal,
    letterSpacing: 0.8,
  );
}