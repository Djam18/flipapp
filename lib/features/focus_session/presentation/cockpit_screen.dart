import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../analytics/presentation/analytics_controller.dart';
import '../../analytics/presentation/analytics_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../domain/focus_session_state.dart';
import 'focus_session_controller.dart';

/// Primary "Cockpit" screen for Flip to Focus.
class CockpitScreen extends ConsumerWidget {
  const CockpitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(focusSessionProvider);
    final controller = ref.read(focusSessionProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Cockpit UI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  _buildHeader(context, ref),
                  const Spacer(),
                  _buildCenterTarget(context, sessionState, controller),
                  const Spacer(),
                  _buildDurationSelector(sessionState, controller),
                  const SizedBox(height: AppSpacing.lg),
                  _buildIntentionSelector(context, sessionState, controller),
                  const SizedBox(height: AppSpacing.md),
                  _buildSimulationControls(controller, sessionState),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),

            // 10-Second Grace Alert Overlay (if phone picked up early)
            if (sessionState.status == SessionStatus.gracePeriod)
              _buildGracePeriodOverlay(context, sessionState, controller),

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
    final analyticsAsync = ref.watch(analyticsProvider);
    final todayMinutes = analyticsAsync.asData?.value.todayFocusMinutes ?? 0;
    final todayText = todayMinutes >= 60
        ? '${todayMinutes ~/ 60}h ${todayMinutes % 60}m Deep Work'
        : '${todayMinutes}m Deep Work';

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
            Text('TODAY', style: AppTypography.label),
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

  /// Core Visual Target: Pulsing ring prompting the user to flip phone face-down
  Widget _buildCenterTarget(
    BuildContext context,
    FocusSessionState state,
    FocusSessionNotifier controller,
  ) {
    final isFocusing = state.status == SessionStatus.focusing;
    final isArming = state.status == SessionStatus.arming;

    String primaryText = 'FLIP SCREEN';
    String secondaryText = 'FACE DOWN TO FOCUS';
    Color ringColor = AppColors.border;

    if (isArming) {
      primaryText = 'STABILIZING...';
      secondaryText = '3 SECONDS';
      ringColor = AppColors.accentAmber;
    } else if (isFocusing) {
      primaryText = 'DEEP FOCUS';
      secondaryText = 'ACTIVE';
      ringColor = AppColors.accent;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ringColor, width: 3),
            boxShadow: isFocusing
                ? const [
                    BoxShadow(
                      color: AppColors.accentGlow,
                      blurRadius: 30,
                      spreadRadius: 8,
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.stay_current_portrait_rounded,
                size: 38,
                color: isFocusing ? AppColors.accent : AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                primaryText,
                style: AppTypography.button.copyWith(
                  letterSpacing: 1.5,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                secondaryText,
                style: AppTypography.label.copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
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

    return Row(
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
    );
  }

  /// Quick task intention input chip
  Widget _buildIntentionSelector(
    BuildContext context,
    FocusSessionState state,
    FocusSessionNotifier controller,
  ) {
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
          Text(
            state.intentionTag ?? 'Set intention (e.g., Code)',
            style: AppTypography.bodyRegular.copyWith(fontSize: 13),
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
          TextButton.icon(
            icon: const Icon(Icons.phone_android, size: 16, color: AppColors.accent),
            label: const Text('Simulate: Flip Down', style: TextStyle(color: AppColors.accent, fontSize: 12)),
            onPressed: () => controller.onFlipDown(),
          ),
          TextButton.icon(
            icon: const Icon(Icons.pan_tool, size: 16, color: AppColors.danger),
            label: const Text('Simulate: Lift Up', style: TextStyle(color: AppColors.danger, fontSize: 12)),
            onPressed: () => controller.onFlipUp(),
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
    return Container(
      color: AppColors.background.withValues(alpha: 0.95),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 64, color: AppColors.danger),
          const SizedBox(height: AppSpacing.md),
          Text(
            'DO NOT BREAK YOUR STRIDE',
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
            'Place screen face-down on desk\nto rescue the session',
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
            child: const Text('Emergency Pause (2 minutes)'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => controller.abandonSession(),
            child: Text(
              'Abandon session',
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
    return Container(
      color: AppColors.background.withValues(alpha: 0.98),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 72, color: AppColors.accent),
          const SizedBox(height: AppSpacing.md),
          Text('SESSION COMPLETE!', style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${(state.elapsedSeconds / 60).round()} minutes of Deep Work',
            style: AppTypography.timerSub,
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.background,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
            ),
            onPressed: () => controller.resetToIdle(),
            child: Text('Continue (OK)', style: AppTypography.button.copyWith(color: AppColors.background)),
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
    return Container(
      color: AppColors.background.withValues(alpha: 0.98),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_rounded, size: 56, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          Text('Session Recorded', style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${(state.elapsedSeconds / 60).round()} min of focus preserved',
            style: AppTypography.timerSub.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Every minute of uninterrupted focus counts.',
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
            onPressed: () => controller.resetToIdle(),
            child: const Text('Back to Cockpit'),
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
