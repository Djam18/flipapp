import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../focus_session/domain/focus_session_record.dart';
import 'analytics_controller.dart';
import '../../../l10n/app_localizations.dart';

/// Screen displaying the complete chronological ledger of focus sessions.
/// Allows filtering by status (Completed, Interrupted) and intention tags.
class SessionHistoryScreen extends ConsumerStatefulWidget {
  const SessionHistoryScreen({super.key});

  @override
  ConsumerState<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends ConsumerState<SessionHistoryScreen> {
  // Internal filter keys — never displayed directly, labels come from l10n
  static const _kAll = 'ALL';
  static const _kCompleted = 'COMPLETED';
  static const _kInterrupted = 'INTERRUPTED';

  String _selectedFilter = _kAll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final analyticsAsync = ref.watch(analyticsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          l10n.sessionHistory,
          style: AppTypography.titleMedium.copyWith(
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: analyticsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (err, _) => Center(
          child: Text(l10n.errorLoadingLedger, style: AppTypography.caption),
        ),
        data: (data) {
          final allSessions = data.recentSessions;
          final filteredSessions = _filterSessions(allSessions);

          return Column(
            children: [
              _buildFilterBar(l10n),
              Expanded(
                child: filteredSessions.isEmpty
                    ? _buildEmptyState(l10n)
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: filteredSessions.length,
                        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final session = filteredSessions[index];
                          return _buildSessionCard(session, l10n);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(AppLocalizations l10n) {
    final filters = [
      (_kAll, l10n.filterAll),
      (_kCompleted, l10n.filterCompleted),
      (_kInterrupted, l10n.filterInterrupted),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: filters.map((entry) {
          final (key, label) = entry;
          final isSelected = _selectedFilter == key;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(
                label,
                style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
              ),
              selected: isSelected,
              selectedColor: AppColors.accent.withValues(alpha: 0.2),
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: isSelected ? AppColors.accent : AppColors.border,
                width: 1,
              ),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
              ),
              onSelected: (val) {
                if (val) setState(() => _selectedFilter = key);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  List<FocusSessionRecord> _filterSessions(List<FocusSessionRecord> sessions) {
    if (_selectedFilter == _kCompleted) {
      return sessions.where((s) => s.isCompleted).toList();
    } else if (_selectedFilter == _kInterrupted) {
      return sessions.where((s) => !s.isCompleted).toList();
    }
    return sessions;
  }

  Widget _buildSessionCard(FocusSessionRecord session, AppLocalizations l10n) {
    final minutes = (session.actualDurationSeconds / 60).round();
    final target = session.targetDurationMinutes ?? minutes;
    final dateStr = DateFormat('MMM d, y • HH:mm').format(session.startedAt);
    final isDone = session.isCompleted;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.accent.withValues(alpha: 0.15)
                  : AppColors.accentAmber.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDone ? Icons.check_circle_outline_rounded : Icons.timelapse_rounded,
              color: isDone ? AppColors.accent : AppColors.accentAmber,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      session.intentionTag ?? l10n.deepWork,
                      style: AppTypography.bodyRegular.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '$minutes / $target min',
                      style: AppTypography.bodyRegular.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDone ? AppColors.accent : AppColors.accentAmber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateStr,
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      isDone ? l10n.filterCompleted : l10n.filterInterrupted,
                      style: AppTypography.caption.copyWith(
                        color: isDone ? AppColors.accent : AppColors.accentAmber,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    final lines = l10n.noSessionsYet.split('\n');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          Text(
            lines.first,
            style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            lines.length > 1 ? lines.last : '',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
