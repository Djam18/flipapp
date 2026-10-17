import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../analytics/presentation/analytics_controller.dart';
import '../../analytics/presentation/analytics_screen.dart';
import '../../analytics/presentation/session_history_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../domain/focus_session_state.dart';
import 'blackout_screen.dart';
import 'focus_session_controller.dart';
import 'session_summary_screen.dart';
import 'widgets/active_focus_visual.dart';
import 'widgets/standby_veille_visual.dart';
import '../../../l10n/app_localizations.dart';

/// Primary "Cockpit" screen for Flip to Focus.
class CockpitScreen extends ConsumerStatefulWidget {
  const CockpitScreen({super.key});

  @override
  ConsumerState<CockpitScreen> createState() => _CockpitScreenState();
}

class _CockpitScreenState extends ConsumerState<CockpitScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(focusSessionProvider.notifier).syncLifecycle(state);
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(focusSessionProvider);
    final controller = ref.read(focusSessionProvider.notifier);

    final isSessionActive = sessionState.status == SessionStatus.focusing ||
        sessionState.status == SessionStatus.arming;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Cockpit UI
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  if (!isSessionActive) _buildHeader(context, ref),
                  const SizedBox(height: AppSpacing.md),
                  _buildCenterTarget(context, sessionState, controller),
                  const SizedBox(height: AppSpacing.md),
                  if (!isSessionActive) ...[
                    _buildDurationSelector(sessionState, controller),
                    const SizedBox(height: AppSpacing.md),
                    _buildIntentionSelector(context, sessionState, controller),
                    const SizedBox(height: AppSpacing.md),
                    _buildSimulationControls(controller, sessionState),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),

            // 10-Second Grace Alert Overlay (if phone picked up early)
            if (sessionState.status == SessionStatus.gracePeriod)
              _buildGracePeriodOverlay(context, sessionState, controller),

            // 2-Minute Emergency Pause Overlay (Screen 5)
            if (sessionState.status == SessionStatus.paused)
              _buildPausedOverlay(context, sessionState, controller),

            // Celebration Overlay (Target completed)
            if (sessionState.status == SessionStatus.completed)
              _buildCelebrationOverlay(context, sessionState, controller),

            // Gentle Interrupted Session Summary Overlay
            if (sessionState.status == SessionStatus.interrupted)
              _buildInterruptedOverlay(context, sessionState, controller),
          ],
        ),
      ),
    );
  }

  /// Header: Settings, Today's metrics, and Journal
  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final analyticsAsync = ref.watch(analyticsProvider);
    final todayMinutes = analyticsAsync.asData?.value.todayFocusMinutes ?? 0;
    final todayText = todayMinutes >= 60
        ? '${todayMinutes ~/ 60}h ${todayMinutes % 60}m ${l10n.deepWork}'
        : '${todayMinutes}m ${l10n.deepWork}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
        Column(
          children: [
            Text(l10n.today, style: AppTypography.label),
            const SizedBox(height: 2),
            Text(
              todayText,
              style: AppTypography.titleMedium.copyWith(color: AppColors.accent),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.bar_chart_outlined, color: AppColors.textSecondary),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
            );
          },
        ),
      ],
    );
  }

  /// Core Visual Target: Screen 1 (VEILLE) when idle, Screen 2 (TIMER ACTIF) when focusing
  Widget _buildCenterTarget(
    BuildContext context,
    FocusSessionState state,
    FocusSessionNotifier controller,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isFocusing = state.status == SessionStatus.focusing;
    final isArming = state.status == SessionStatus.arming;

    if (isFocusing || isArming) {
      return ActiveFocusVisual(
        elapsedSeconds: state.elapsedSeconds,
        targetMinutes: state.targetMinutes,
        focusScore: 88,
        distractionCount: 0,
        onTapGauge: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BlackoutScreen()),
          );
        },
        onHistory: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SessionHistoryScreen()),
          );
        },
        onCoffeeBreak: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.deepWork} - 5 min break'),
              backgroundColor: AppColors.surfaceElevated,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        onPauseOrStop: () {
          controller.onFlipUp();
        },
        onOpenSettings: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      );
    }

    // Screen 1: VEILLE (Standby)
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Veille Lock Icon & Titles
        const Icon(
          Icons.lock_outline,
          size: 24,
          color: AppColors.accent,
        ),
        const SizedBox(height: 6),
        Text(
          l10n.flipPhoneFor,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          l10n.deepWork,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Concentric waves with isometric smartphone
        StandbyVeilleVisual(
          onTap: () => controller.onFlipDown(),
        ),

        const SizedBox(height: AppSpacing.md),

        // Instructional interactive pill
        GestureDetector(
          onTap: () => controller.onFlipDown(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.flipScreen,
                  style: AppTypography.button.copyWith(
                    letterSpacing: 1.5,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.faceDownToFocus,
                  style: AppTypography.label.copyWith(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),
        Text(
          _formatTime(state.elapsedSeconds, state.targetMinutes),
          style: AppTypography.timerDisplay,
        ),
      ],
    );
  }

  /// Horizontal duration selector
  Widget _buildDurationSelector(
    FocusSessionState state,
    FocusSessionNotifier controller,
  ) {
    final durations = [
      (label: 'Open', minutes: null),
      (label: '25 min', minutes: 25),
      (label: '45 min', minutes: 45),
      (label: '90 min', minutes: 90),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: durations.map((item) {
          final isSelected = state.targetMinutes == item.minutes;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => controller.setTargetDuration(item.minutes),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.border,
                  ),
                ),
                child: Text(
                  item.label,
                  style: AppTypography.button.copyWith(
                    fontSize: 13,
                    color: isSelected ? AppColors.background : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Quick task intention input chip
  Widget _buildIntentionSelector(
    BuildContext context,
    FocusSessionState state,
    FocusSessionNotifier controller,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.edit_note_rounded, size: 18, color: AppColors.accentAmber),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              state.intentionTag ?? l10n.intentionPlaceholder,
              style: AppTypography.bodyRegular.copyWith(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Physical sensor simulation triggers (for testing on emulators and desks)
  Widget _buildSimulationControls(
    FocusSessionNotifier controller,
    FocusSessionState state,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: TextButton.icon(
              icon: const Icon(Icons.phone_android, size: 16, color: AppColors.accent),
              label: const Text('Flip Down', style: TextStyle(color: AppColors.accent, fontSize: 12), overflow: TextOverflow.ellipsis),
              onPressed: () => controller.onFlipDown(),
            ),
          ),
          Expanded(
            child: TextButton.icon(
              icon: const Icon(Icons.pan_tool, size: 16, color: AppColors.danger),
              label: const Text('Lift Up', style: TextStyle(color: AppColors.danger, fontSize: 12), overflow: TextOverflow.ellipsis),
              onPressed: () => controller.onFlipUp(),
            ),
          ),
        ],
      ),
    );
  }

  /// 10-Second Grace Alert Overlay
  Widget _buildGracePeriodOverlay(
    BuildContext context,
    FocusSessionState state,
    FocusSessionNotifier controller,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: AppColors.background.withValues(alpha: 0.95),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 64, color: AppColors.danger),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.graceAlertTitle,
            style: AppTypography.titleMedium.copyWith(color: AppColors.danger),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '0${state.remainingGraceSeconds}s',
            style: AppTypography.timerDisplay.copyWith(color: AppColors.danger),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.gracePeriodInstruction,
            style: AppTypography.bodyRegular,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceElevated,
              foregroundColor: AppColors.textPrimary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
            onPressed: () => controller.pauseEmergency(),
            child: Text(l10n.emergencyPause),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => controller.abandonSession(),
            child: Text(
              l10n.abandonSession,
              style: AppTypography.caption.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  /// 2-Minute Emergency Pause Overlay (Screen 5)
  Widget _buildPausedOverlay(
    BuildContext context,
    FocusSessionState state,
    FocusSessionNotifier controller,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final mins = state.remainingPauseSeconds ~/ 60;
    final secs = state.remainingPauseSeconds % 60;
    final pauseTimeStr =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return Container(
      color: AppColors.background.withValues(alpha: 0.96),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pause_circle_outline_rounded, size: 72, color: AppColors.accentAmber),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.emergencyPause,
            style: AppTypography.titleMedium.copyWith(color: AppColors.accentAmber),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            pauseTimeStr,
            style: AppTypography.timerDisplay.copyWith(color: AppColors.accentAmber),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.gracePeriodInstruction,
            style: AppTypography.bodyRegular,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentAmber,
              foregroundColor: AppColors.background,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
            ),
            onPressed: () => controller.onFlipDown(),
            child: const Text('Resume Session (Flip Down)', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => controller.abandonSession(),
            child: Text(
              l10n.abandonSession,
              style: AppTypography.caption.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  /// Celebration Overlay (Session successfully accomplished)
  Widget _buildCelebrationOverlay(
    BuildContext context,
    FocusSessionState state,
    FocusSessionNotifier controller,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: AppColors.background.withValues(alpha: 0.98),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 72, color: AppColors.accent),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.sessionCompleteTitle, style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${(state.elapsedSeconds / 60).round()} ${l10n.minutesOfDeepWork}',
            style: AppTypography.timerSub,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.background,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SessionSummaryScreen(
                    durationMinutes: (state.elapsedSeconds / 60).round(),
                    intentionTag: state.intentionTag,
                    isCompleted: true,
                  ),
                ),
              );
            },
            child: Text(l10n.openDebrief, style: AppTypography.button.copyWith(color: AppColors.background)),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => controller.resetToIdle(),
            child: Text(l10n.dismiss, style: const TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  /// Interrupted Session Summary Overlay (Gentle and encouraging)
  Widget _buildInterruptedOverlay(
    BuildContext context,
    FocusSessionState state,
    FocusSessionNotifier controller,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: AppColors.background.withValues(alpha: 0.98),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_rounded, size: 56, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.sessionRecorded, style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${(state.elapsedSeconds / 60).round()} ${l10n.focusPreserved}',
            style: AppTypography.timerSub.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.encouragement,
            style: AppTypography.bodyRegular,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceElevated,
              foregroundColor: AppColors.textPrimary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SessionSummaryScreen(
                    durationMinutes: (state.elapsedSeconds / 60).round(),
                    intentionTag: state.intentionTag,
                    isCompleted: false,
                  ),
                ),
              );
            },
            child: Text(l10n.viewSummary),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => controller.resetToIdle(),
            child: Text(l10n.dismiss, style: const TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  String _formatTime(int elapsedSeconds, int? targetMinutes) {
    if (targetMinutes != null) {
      final totalSeconds = targetMinutes * 60;
      final remaining = (totalSeconds - elapsedSeconds).clamp(0, totalSeconds);
      final m = remaining ~/ 60;
      final s = remaining % 60;
      return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    } else {
      final m = elapsedSeconds ~/ 60;
      final s = elapsedSeconds % 60;
      return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
  }
}
