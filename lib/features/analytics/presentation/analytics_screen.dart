import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../focus_session/domain/focus_session_record.dart';
import '../domain/analytics_data.dart';
import '../domain/milestones_data.dart';
import 'analytics_controller.dart';
import 'session_history_screen.dart';
import '../../../l10n/app_localizations.dart';

/// Analytics & Deep Work History Screen.
/// Displays high-level stats, 7-day rhythm heatmap, and chronological session history.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final analyticsAsync = ref.watch(analyticsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.performance,
          style: AppTypography.caption.copyWith(
            color: AppColors.textPrimary,
            letterSpacing: 2.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 20),
            onPressed: () => ref.read(analyticsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: analyticsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (error, _) => Center(
          child: Text(
            'Failed to load analytics: $error',
            style: AppTypography.bodyRegular.copyWith(color: AppColors.danger),
          ),
        ),
        data: (data) => _buildContent(context, data),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AnalyticsData data) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricsOverview(context, data),
          const SizedBox(height: AppSpacing.xl),
          _buildHeatmapSection(context, data),
          const SizedBox(height: AppSpacing.xl),
          _buildMilestonesSection(context, data),
          const SizedBox(height: AppSpacing.xl),
          _buildSessionHistorySection(context, data),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  /// 3 summary cards: Today's Focus, Streak, Total Deep Work
  Widget _buildMetricsOverview(BuildContext context, AnalyticsData data) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            label: l10n.today,
            value: '${data.todayFocusMinutes}',
            unit: 'MIN',
            icon: Icons.timer_outlined,
            accentColor: AppColors.accent,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildMetricCard(
            label: l10n.streak,
            value: '${data.currentStreakDays}',
            unit: 'DAYS',
            icon: Icons.local_fire_department_rounded,
            accentColor: AppColors.accentAmber,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildMetricCard(
            label: l10n.total,
            value: '${data.totalDeepWorkHours}',
            unit: 'HRS',
            icon: Icons.military_tech_outlined,
            accentColor: AppColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(icon, size: 16, color: accentColor),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTypography.timerDisplay.copyWith(
                  fontSize: 26,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 7-day deep work rhythm heatmap
  Widget _buildHeatmapSection(BuildContext context, AnalyticsData data) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.deepWorkRhythm,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textPrimary,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                l10n.past7Days,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: data.weeklyHeatmap.map((day) => _buildHeatmapCell(day)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapCell(HeatmapDay day) {
    Color cellColor;
    switch (day.intensityLevel) {
      case 4:
        cellColor = const Color(0xFFA8C4B4);
        break;
      case 3:
        cellColor = AppColors.accent;
        break;
      case 2:
        cellColor = const Color(0xFF497C65);
        break;
      case 1:
        cellColor = const Color(0xFF264736);
        break;
      default:
        cellColor = const Color(0xFF161618);
    }

    return Column(
      children: [
        Text(
          day.dayLabel,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            color: day.isToday ? AppColors.accent : AppColors.textSecondary,
            fontWeight: day.isToday ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: cellColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            border: Border.all(
              color: day.isToday ? AppColors.accent : AppColors.border,
              width: day.isToday ? 1.5 : 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            day.totalMinutes > 0 ? '${day.totalMinutes}m' : '',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              color: day.intensityLevel >= 3 ? AppColors.background : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Discipline Milestones and Badges shelf
  Widget _buildMilestonesSection(BuildContext context, AnalyticsData data) {
    final l10n = AppLocalizations.of(context)!;
    final badges = evaluateMilestones(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.disciplineMilestones,
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${badges.where((b) => b.isUnlocked).length}/${badges.length} UNLOCKED',
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.accent,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: badges.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final badge = badges[index];
              return Container(
                width: 140,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(
                    color: badge.isUnlocked ? AppColors.accent : AppColors.border,
                    width: badge.isUnlocked ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          badge.icon,
                          size: 22,
                          color: badge.isUnlocked ? AppColors.accent : AppColors.textMuted,
                        ),
                        if (badge.isUnlocked)
                          const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.accent)
                        else
                          const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.textMuted),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          badge.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyRegular.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: badge.isUnlocked ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          badge.progressText,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: badge.isUnlocked ? AppColors.accent : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Session history list
  Widget _buildSessionHistorySection(BuildContext context, AnalyticsData data) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.sessionLogs,
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (data.recentSessions.isNotEmpty)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SessionHistoryScreen()),
                  );
                },
                child: Text(
                  'VIEW ALL',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (data.recentSessions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.phone_android_rounded,
                  size: 36,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No sessions recorded yet',
                  style: AppTypography.bodyRegular.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Place your phone face down on your desk to enter your first deep work session.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyRegular.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.recentSessions.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              return _buildSessionTile(data.recentSessions[index]);
            },
          ),
      ],
    );
  }

  Widget _buildSessionTile(FocusSessionRecord session) {
    final isCompleted = session.isCompleted;
    final timeStr = DateFormat('MMM d, HH:mm').format(session.startedAt);
    final minutes = session.actualDurationSeconds ~/ 60;
    final seconds = session.actualDurationSeconds % 60;
    final durationStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isCompleted ? AppColors.accent : AppColors.danger).withValues(alpha: 0.15),
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : Icons.close_rounded,
              size: 16,
              color: isCompleted ? AppColors.accent : AppColors.danger,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.intentionTag ?? (isCompleted ? 'Deep Work Focus' : 'Interrupted Focus'),
                  style: AppTypography.bodyRegular.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  timeStr,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                durationStr,
                style: GoogleFonts.jetBrainsMono(
                  color: isCompleted ? AppColors.accent : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                isCompleted ? 'COMPLETED' : 'ABORTED',
                style: AppTypography.caption.copyWith(
                  color: isCompleted ? AppColors.accent : AppColors.danger,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
