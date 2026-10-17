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
  final VoidCallback? onCoffeeBreak;
  final VoidCallback? onHistory;
  final VoidCallback onPauseOrStop;
  final VoidCallback onOpenSettings;
  final VoidCallback? onTapGauge;

  const ActiveFocusVisual({
    super.key,
    required this.elapsedSeconds,
    required this.targetMinutes,
    this.focusScore = 88,
    this.distractionCount = 0,
    this.onCoffeeBreak,
    this.onHistory,
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
        const SizedBox(height: AppSpacing.md),
        // Subtitle & Title header
        Text(
          l10n.deepWork,
          style: AppTypography.titleLarge.copyWith(
            letterSpacing: 1.0,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.deepWorkSession,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 48),

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
                  strokeWidth: 12.0,
                  strokeCap: StrokeCap.round,
                  backgroundColor: const Color(0xFF26262A),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
              Text(
                timeStr,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 46,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Dual Metric Cards: [Focus Score: 88] [Distractions: 0]
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMetricCard(
              title: l10n.focusScore,
              value: '$focusScore',
            ),
            const SizedBox(width: AppSpacing.md),
            _buildMetricCard(
              title: l10n.distractions,
              value: '$distractionCount',
            ),
          ],
        ),

        const SizedBox(height: 48),

        // 3-Button Control Bar: [Inbox / History] [Pause] [Settings]
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSecondaryButton(
              icon: Icons.all_inbox_outlined,
              tooltip: 'Session Logs',
              onPressed: onHistory ?? onCoffeeBreak ?? () {},
            ),
            const SizedBox(width: 32),
            _buildPauseButton(
              tooltip: 'Pause / Stop',
              onPressed: onPauseOrStop,
            ),
            const SizedBox(width: 32),
            _buildSecondaryButton(
              icon: Icons.settings_outlined,
              tooltip: 'Settings',
              onPressed: onOpenSettings,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseButton({
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.pause_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        child: Icon(
          icon,
          color: AppColors.textSecondary,
          size: 22,
        ),
      ),
    );
  }
}
