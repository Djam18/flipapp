import '../../focus_session/domain/focus_session_record.dart';

/// Single day in the weekly deep work heatmap.
class HeatmapDay {
  final DateTime date;
  final String dayLabel; // 'M', 'T', 'W', 'T', 'F', 'S', 'S'
  final int totalMinutes;
  final int intensityLevel; // 0 (0m), 1 (1-25m), 2 (26-60m), 3 (61-120m), 4 (120m+)
  final bool isToday;

  const HeatmapDay({
    required this.date,
    required this.dayLabel,
    required this.totalMinutes,
    required this.intensityLevel,
    required this.isToday,
  });
}

/// Aggregated analytics state for the performance dashboard.
class AnalyticsData {
  final int todayFocusMinutes;
  final int totalDeepWorkHours;
  final int currentStreakDays;
  final int totalSessionsCompleted;
  final List<HeatmapDay> weeklyHeatmap;
  final List<FocusSessionRecord> recentSessions;

  const AnalyticsData({
    required this.todayFocusMinutes,
    required this.totalDeepWorkHours,
    required this.currentStreakDays,
    required this.totalSessionsCompleted,
    required this.weeklyHeatmap,
    required this.recentSessions,
  });

  factory AnalyticsData.empty() {
    return const AnalyticsData(
      todayFocusMinutes: 0,
      totalDeepWorkHours: 0,
      currentStreakDays: 0,
      totalSessionsCompleted: 0,
      weeklyHeatmap: [],
      recentSessions: [],
    );
  }
}
