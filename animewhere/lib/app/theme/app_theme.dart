import 'package:flutter/material.dart';

import 'app_text_theme.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFFADC6FF);
  static const Color onPrimary = Color(0xFF002E69);
  static const Color primaryContainer = Color(0xFF4C8EFF);
  static const Color onPrimaryContainer = Color(0xFF00285D);
  static const Color inversePrimary = Color(0xFF005AC2);

  static const Color secondary = Color(0xFFC6C6C7);
  static const Color onSecondary = Color(0xFF2F3131);
  static const Color secondaryContainer = Color(0xFF454747);
  static const Color onSecondaryContainer = Color(0xFFB4B5B5);

  static const Color tertiary = Color(0xFFD5BAFF);
  static const Color onTertiary = Color(0xFF42008A);
  static const Color tertiaryContainer = Color(0xFFA974FF);
  static const Color onTertiaryContainer = Color(0xFF3A0079);

  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  static const Color surface = Color(0xFF131313);
  static const Color surfaceDim = Color(0xFF131313);
  static const Color surfaceBright = Color(0xFF262626);
  static const Color surfaceContainerLowest = Color(0xFF0E0E0E);
  static const Color surfaceContainerLow = Color(0xFF1C1B1B);
  static const Color surfaceContainer = Color(0xFF201F1F);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighest = Color(0xFF353534);

  static const Color onSurface = Color(0xFFE5E2E1);
  static const Color onSurfaceVariant = Color(0xFFC2C6D6);
  static const Color inverseSurface = Color(0xFFE5E2E1);
  static const Color inverseOnSurface = Color(0xFF313030);
  static const Color outline = Color(0xFF8C909F);
  static const Color outlineVariant = Color(0xFF414754);
  static const Color surfaceTint = Color(0xFFADC6FF);

  static const Color background = Color(0xFF131313);
  static const Color onBackground = Color(0xFFE5E2E1);
  static const Color surfaceVariant = Color(0xFF353534);
  static const Color surfaceDeep = Color(0xFF161616);
  static const Color glassTint = Color(0x0DFFFFFF);

  static const ColorScheme colorScheme = ColorScheme.dark(
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    inversePrimary: inversePrimary,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    tertiary: tertiary,
    onTertiary: onTertiary,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onTertiaryContainer,
    error: error,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,
    surface: surface,
    surfaceDim: surfaceDim,
    surfaceBright: surfaceBright,
    surfaceContainerLowest: surfaceContainerLowest,
    surfaceContainerLow: surfaceContainerLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceContainerHigh,
    surfaceContainerHighest: surfaceContainerHighest,
    onSurface: onSurface,
    onSurfaceVariant: onSurfaceVariant,
    inverseSurface: inverseSurface,
    onInverseSurface: inverseOnSurface,
    outline: outline,
    outlineVariant: outlineVariant,
    surfaceTint: surfaceTint,
  );

  static ThemeData get themeData => ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    fontFamily: 'Inter',
    textTheme: AppTextTheme.textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceDeep,
      foregroundColor: onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: surfaceDeep,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppDimens.radiusLg)),
      ),
    ),
    dividerTheme: const DividerThemeData(color: outlineVariant),
  );
}
