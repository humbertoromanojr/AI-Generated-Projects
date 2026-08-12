import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class AppColors {
  static const background = Color(0xFF0D0D0D);
  static const surface = Color(0xFF1A1A1A);
  static const surfaceElevated = Color(0xFF262626);
  static const surfaceContainer = Color(0xFF20201F);
  static const surfaceHigh = Color(0xFF2A2A2A);
  static const primary = Color(0xFFE5B143);
  static const onPrimary = Color(0xFF412D00);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA0A0A0);
  static const outlineVariant = Color(0xFF4F4636);
  static const onSurfaceVariant = Color(0xFFD3C5B0);
}

abstract class AppSpacing {
  static const marginMain = 20.0;
  static const gutter = 16.0;
  static const stackSm = 8.0;
  static const stackMd = 24.0;
  static const stackLg = 40.0;
  static const radiusSm = 8.0;
  static const radiusLg = 16.0;
}

abstract class AppTheme {
  static ThemeData get dark {
    final base = ThemeData(brightness: Brightness.dark);
    final textTheme = base.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );
    const scheme = ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.textSecondary,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceContainer,
      outline: AppColors.outlineVariant,
      error: Color(0xFFFFB4AB),
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: scheme,
      fontFamily: 'Inter',
      textTheme: textTheme.copyWith(
        headlineLarge: const TextStyle(
          fontSize: 28,
          height: 34 / 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        headlineMedium: const TextStyle(
          fontSize: 24,
          height: 30 / 24,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: const TextStyle(
          fontSize: 18,
          height: 24 / 18,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: const TextStyle(
          fontSize: 16,
          height: 24 / 16,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: const TextStyle(
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelSmall: const TextStyle(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 24),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
