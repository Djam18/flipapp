import 'package:flutter/material.dart';

/// Official "Obsidian & Sage" color palette for Flip to Focus.
/// Tailored for OLED displays: pure black (#000000) and eye-resting contrast.
abstract class AppColors {
  // Background & Surfaces
  static const Color background = Color(0xFF000000); // True OLED Black
  static const Color surface = Color(0xFF121214); // Elevation 1 (Cards, dialogs)
  static const Color surfaceElevated = Color(0xFF1E1E22); // Elevation 2 (Inactive buttons)

  // Typography & Contrasts
  static const Color textPrimary = Color(0xFFF5F5F7); // Titanium White (non-glare)
  static const Color textSecondary = Color(0xFF8E8E93); // Subtitles, units
  static const Color textMuted = Color(0xFF48484A); // Placeholders, dividers

  // Focus Accents & Semantics
  static const Color accent = Color(0xFF8FA89B); // Sage Green
  static const Color accentGlow = Color(0x338FA89B); // Breathing pulse halo
  static const Color accentAmber = Color(0xFFE0A96D); // Warm Amber (Intentions)

  // Alerts & States
  static const Color danger = Color(0xFFE26D5C); // Terracotta Red (10s Grace alert)
  static const Color warning = Color(0xFFD97706); // Warning Amber (Emergency pause)
  static const Color border = Color(0xFF26262A); // Subtle borders
}
