import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Mathematical typography scale for Flip to Focus.
/// Uses JetBrains Mono for timers/measurements and Inter for general UI text.
abstract class AppTypography {
  // Timers & Industrial Precision (Monospace)
  static TextStyle timerDisplay = GoogleFonts.jetBrainsMono(
    fontSize: 56,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.5,
    color: AppColors.textPrimary,
  );

  static TextStyle timerSub = GoogleFonts.jetBrainsMono(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.5,
    color: AppColors.accent,
  );

  // Hierarchy & Navigation (Inter)
  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyRegular = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static TextStyle label = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: AppColors.textSecondary,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textMuted,
  );

  static TextStyle button = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}
