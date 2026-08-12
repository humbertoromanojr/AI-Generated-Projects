import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      primaryContainer: AppColors.accent,
      onPrimaryContainer: AppColors.onAccent,
      secondary: AppColors.accent,
      onSecondary: AppColors.onAccent,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppTypography.fontFamily,
      splashFactory: InkSparkle.splashFactory,
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: AppTypography.headlineXl,
        displayMedium: AppTypography.headlineLg,
        headlineLarge: AppTypography.headlineLgMobile,
        headlineMedium: AppTypography.headlineLgMobile,
        headlineSmall: AppTypography.titleMd,
        titleLarge: AppTypography.headlineLgMobile,
        titleMedium: AppTypography.titleMd,
        titleSmall: AppTypography.titleMd.copyWith(fontSize: 16),
        bodyLarge: AppTypography.bodyMd,
        bodyMedium: AppTypography.bodyMd,
        bodySmall: AppTypography.bodySm,
        labelLarge: AppTypography.titleMd,
        labelMedium: AppTypography.labelCaps,
        labelSmall: AppTypography.labelCaps,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: AppTypography.bodyMd,
        behavior: SnackBarBehavior.floating,
      ),
      dividerColor: AppColors.outline,
    );
  }
}
