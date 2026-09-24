import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';

/// Screen 2 (TIMER ACTIF): Sage Green circular gauge, 25:00 timer, Focus/Distraction cards,
/// and 3-button control bar: Coffee break [☕], Pause/Stop [⏸], Settings [⚙].
class ActiveFocusVisual extends StatelessWidget {
  final int elapsedSeconds;
  final int? targetMinutes;
  final int focusScore;
  final int distractionCount;
  final VoidCallback onCoffeeBreak;
  final VoidCallback onPauseOrStop;
  final VoidCallback onOpenSettings;
  final VoidCallback? onTapGauge;

  const ActiveFocusVisual({
    super.key,
    required this.elapsedSeconds,
    required this.targetMinutes,
    this.focusScore = 88,
    this.distractionCount = 0,
    required this.onCoffeeBreak,
    required this.onPauseOrStop,
    required this.onOpenSettings,
    this.onTapGauge,
  });

  String _formatTime(int elapsedSec, int? targetMin) {
    if (targetMin == null) {
      final m = elapsedSec ~/ 60;
      final s = elapsedSec % 60;
      return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    final totalTargetSec = targetMin * 60;
    final remainingSec = (totalTargetSec - elapsedSec).clamp(0, totalTargetSec);
    final m = remainingSec ~/ 60;
    final s = remainingSec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double _calculateProgress(int elapsedSec, int? targetMin) {
    if (targetMin == null || targetMin <= 0) {
      // Gentle infinite pulse simulation when in open mode
      return (elapsedSec % 60) / 60.0;
    }
    final totalTargetSec = targetMin * 60;
    return (elapsedSec / totalTargetSec).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = _calculateProgress(elapsedSeconds, targetMinutes);
    final timeStr = _formatTime(elapsedSeconds, targetMinutes);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Subtitle & Title header
        Text(
          l10n.deepWork,
          style: AppTypography.titleLarge.copyWith(
            letterSpacing: 2.0,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.deepWorkSession,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Circular Gauge with 25:00 Timer
        GestureDetector(
          onTap: onTapGauge,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4.0,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeStr,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 44,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.active,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Dual Metric Cards: [Focus Score: 88] [Distractions: 0]
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMetricCard(
              title: l10n.focusScore,
              value: '$focusScore',
              icon: Icons.speed_rounded,
              accentColor: AppColors.accent,
            ),
            const SizedBox(width: AppSpacing.md),
            _buildMetricCard(
              title: l10n.distractions,
              value: '$distractionCount',
              icon: Icons.shield_outlined,
              accentColor: AppColors.textSecondary,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        // 3-Button Control Bar: [☕] [⏸] [⚙]
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircleButton(
              icon: Icons.coffee_rounded,
              tooltip: 'Coffee Break',
              onPressed: onCoffeeBreak,
              color: AppColors.surface,
              iconColor: AppColors.accentAmber,
            ),
            const SizedBox(width: AppSpacing.lg),
            _buildCircleButton(
              icon: Icons.pause_rounded,
              tooltip: 'Pause / Complete',
              onPressed: onPauseOrStop,
              color: AppColors.accent,
              iconColor: AppColors.background,
              size: 60,
              iconSize: 32,
            ),
            const SizedBox(width: AppSpacing.lg),
            _buildCircleButton(
              icon: Icons.settings_outlined,
              tooltip: 'Settings',
              onPressed: onOpenSettings,
              color: AppColors.surface,
              iconColor: AppColors.textSecondary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: accentColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required Color color,
    required Color iconColor,
    double size = 48,
    double iconSize = 22,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: iconSize),
      ),
    );
  }
}
