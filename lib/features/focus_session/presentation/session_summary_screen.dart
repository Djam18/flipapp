import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../analytics/presentation/analytics_controller.dart';
import 'focus_session_controller.dart';
import 'widgets/monthly_focus_calendar.dart';
import '../../../l10n/app_localizations.dart';

/// Screen displayed after a focus session completes or is gracefully finished.
/// Provides deep work metrics, reflection notes, and crystal growth progression.
class SessionSummaryScreen extends ConsumerStatefulWidget {
  final int durationMinutes;
  final String? intentionTag;
  final bool isCompleted;

  const SessionSummaryScreen({
    super.key,
    required this.durationMinutes,
    this.intentionTag,
    required this.isCompleted,
  });

  @override
  ConsumerState<SessionSummaryScreen> createState() => _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends ConsumerState<SessionSummaryScreen> {
  final _reflectionController = TextEditingController();
  bool _copied = false;

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  void _shareSummary() {
    final tag = widget.intentionTag ?? 'deep work';
    final text = 'Forged ${widget.durationMinutes} min of pure focus on $tag. #FlipToFocus';
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Summary copied to clipboard'),
        backgroundColor: AppColors.surfaceElevated,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summaryTitle = l10n?.summary ?? 'Summary';
    final sessionCompleteTitle = l10n?.sessionComplete ?? 'Session Complete';
    final breaksText = l10n?.breaks ?? 'breaks';
    final analytics = ref.watch(analyticsProvider).asData?.value;
    final currentStreak = analytics?.currentStreakDays ?? 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Bar: "Summary" + Info Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    summaryTitle,
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline, color: AppColors.textSecondary),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: AppColors.surfaceElevated,
                          title: Text(summaryTitle, style: const TextStyle(color: AppColors.textPrimary)),
                          content: const Text(
                            'Session completed. Your focus minutes are forged locally and tracked on your calendar.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK', style: TextStyle(color: AppColors.accent)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Subheader: "Session Complete" / "SESSION FORGED"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 5),
                    decoration: BoxDecoration(
                      color: widget.isCompleted
                          ? AppColors.accent.withValues(alpha: 0.15)
                          : AppColors.accentAmber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                      border: Border.all(
                        color: widget.isCompleted ? AppColors.accent : AppColors.accentAmber,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.isCompleted ? 'SESSION FORGED' : 'PARTIAL FOCUS SAVED',
                      style: AppTypography.caption.copyWith(
                        color: widget.isCompleted ? AppColors.accent : AppColors.accentAmber,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    sessionCompleteTitle,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Central Circular Badge: 50m / Duration
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(
                    color: widget.isCompleted ? AppColors.accent : AppColors.accentAmber,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isCompleted ? AppColors.accent : AppColors.accentAmber)
                          .withValues(alpha: 0.25),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${widget.durationMinutes}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'm',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xs),
              Text(
                'MINUTES DEEP WORK',
                style: AppTypography.caption.copyWith(
                  letterSpacing: 2,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Dual Cards: [50m Focus] [2 breaks]
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSummaryPill(
                    title: '${widget.durationMinutes}m Focus',
                    icon: Icons.timer_outlined,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _buildSummaryPill(
                    title: '2 $breaksText',
                    icon: Icons.coffee_rounded,
                    color: AppColors.accentAmber,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Metrics Card: Intention, Streak, Shield
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricColumn('INTENTION', widget.intentionTag ?? '#code'),
                    Container(height: 30, width: 1, color: AppColors.border),
                    _buildMetricColumn('STREAK', '$currentStreak DAYS'),
                    Container(height: 30, width: 1, color: AppColors.border),
                    _buildMetricColumn('DISTRACTIONS', '0 (SHIELDED)'),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Embedded Monthly Calendar
              const MonthlyFocusCalendar(),

              const SizedBox(height: AppSpacing.md),

              // Reflection Field
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'REFLECTION & OUTPUT',
                  style: AppTypography.caption.copyWith(
                    letterSpacing: 1.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _reflectionController,
                style: AppTypography.bodyRegular.copyWith(color: AppColors.textPrimary),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'What key milestone or concept did you ship?',
                  hintStyle: AppTypography.bodyRegular.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    borderSide: const BorderSide(color: AppColors.accent),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Action buttons
              Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      ),
                    ),
                    onPressed: _shareSummary,
                    icon: Icon(_copied ? Icons.check : Icons.share_outlined, size: 18),
                    label: Text(_copied ? 'Copied' : 'Share'),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                        ),
                      ),
                      onPressed: () {
                        ref.read(focusSessionProvider.notifier).resetToIdle();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'RETURN TO COCKPIT',
                        style: AppTypography.button.copyWith(color: AppColors.background),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryPill({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTypography.button.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.bodyRegular.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
