import 'package:flutter/material.dart';

class AppTextTheme {
  AppTextTheme._();

  static const TextStyle display = TextStyle(
    fontFamily: 'Inter',
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 56 / 48,
    letterSpacing: -0.96,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: -0.32,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 28 / 18,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: 0.7,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
  );

  static const TextTheme textTheme = TextTheme(
    displayLarge: display,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}

class AppDimens {
  AppDimens._();

  static const double radiusSm = 4;
  static const double radiusDefault = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 9999;

  static const double spacingGutter = 24;
  static const double spacingMarginDesktop = 32;
  static const double spacingMarginMobile = 16;
  static const double spacingStackXs = 4;
  static const double spacingStackSm = 8;
  static const double spacingStackMd = 16;
  static const double spacingStackLg = 40;
  static const double containerMax = 1280;
}
