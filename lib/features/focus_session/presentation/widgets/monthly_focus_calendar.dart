import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';

/// Screen 3 (RÉCAP & CALENDRIER): Embedded monthly calendar highlighting deep work sessions.
class MonthlyFocusCalendar extends StatefulWidget {
  final Set<int> activeDayNumbers;

  const MonthlyFocusCalendar({
    super.key,
    this.activeDayNumbers = const {3, 7, 12, 14, 18, 21, 24},
  });

  @override
  State<MonthlyFocusCalendar> createState() => _MonthlyFocusCalendarState();
}

class _MonthlyFocusCalendarState extends State<MonthlyFocusCalendar> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final calendarTitle = AppLocalizations.of(context)?.calendar ?? 'Calendar';
    final monthTitle = DateFormat('MMMM yyyy').format(_displayedMonth);

    // Number of days in current displayed month
    final daysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    // Weekday of 1st day (Sunday = 7 in DateTime.weekday, we map to Sunday = 0 for S M T W T F S)
    final firstWeekday = _displayedMonth.weekday % 7;

    const weekdayHeaders = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Calendar title and month navigation < November 2026 >
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                calendarTitle,
                style: AppTypography.caption.copyWith(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: _previousMonth,
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.chevron_left_rounded, size: 20, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    monthTitle,
                    style: AppTypography.bodyRegular.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: _nextMonth,
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: AppSpacing.sm),

          // Weekday letters row: S M T W T F S
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdayHeaders.map((day) {
              return SizedBox(
                width: 28,
                child: Center(
                  child: Text(
                    day,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Days Grid (6 rows of 7 days)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 35, // 5 weeks standard compact grid
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - firstWeekday + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final isCompleted = widget.activeDayNumbers.contains(dayNumber);

              return Center(
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppColors.accent.withValues(alpha: 0.25)
                        : Colors.transparent,
                    border: isCompleted
                        ? Border.all(color: AppColors.accent, width: 1.5)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$dayNumber\u200B',
                      style: TextStyle(
                        color: isCompleted ? AppColors.accent : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: isCompleted ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
