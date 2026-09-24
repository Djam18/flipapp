import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Global Flutter theme configuration for Flip to Focus (Dark Mode OLED).
abstract class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.accent,
        secondary: AppColors.accentAmber,
        error: AppColors.danger,
        onSurface: AppColors.textPrimary,
        onPrimary: AppColors.background,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleMedium,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      dividerColor: AppColors.border,
    );
  }
}
