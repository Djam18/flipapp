import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../focus_session/data/focus_session_repository.dart';
import '../domain/analytics_data.dart';

final analyticsProvider =
    AsyncNotifierProvider<AnalyticsNotifier, AnalyticsData>(() {
  return AnalyticsNotifier();
});

class AnalyticsNotifier extends AsyncNotifier<AnalyticsData> {
  FocusSessionRepository get _repository =>
      ref.read(focusSessionRepositoryProvider);

  @override
  Future<AnalyticsData> build() async {
    return _fetchAnalytics();
  }

  Future<AnalyticsData> _fetchAnalytics() async {
    final aggregateStats = await _repository.getAggregateStats();
    final summaries = await _repository.getDailySummaries(days: 30);
    final recentSessions = await _repository.getRecentSessions(limit: 50);

    final totalSeconds = (aggregateStats['totalSeconds'] as int?) ?? 0;
    final totalHours = (totalSeconds / 3600).floor();
    final streak = (aggregateStats['streak'] as int?) ?? 0;
    final totalCompleted = (aggregateStats['totalCompleted'] as int?) ?? 0;

    // Create 7-day weekly heatmap (from 6 days ago up to today)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<HeatmapDay> heatmap = [];

    final Map<String, int> dailySecondsMap = {
      for (final s in summaries)
        s['date_key'] as String:
            (s['total_deep_work_seconds'] as int?) ?? 0,
    };

    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    for (int i = 6; i >= 0; i--) {
      final dayDate = today.subtract(Duration(days: i));
      final dateKey = _formatDateKey(dayDate);
      final seconds = dailySecondsMap[dateKey] ?? 0;
      final minutes = (seconds / 60).round();

      int intensity = 0;
      if (minutes >= 120) {
        intensity = 4;
      } else if (minutes >= 60) {
        intensity = 3;
      } else if (minutes >= 30) {
        intensity = 2;
      } else if (minutes > 0) {
        intensity = 1;
      }

      heatmap.add(
        HeatmapDay(
          date: dayDate,
          dayLabel: dayLabels[dayDate.weekday - 1],
          totalMinutes: minutes,
          intensityLevel: intensity,
          isToday: i == 0,
        ),
      );
    }

    final todayKey = _formatDateKey(today);
    final todaySeconds = dailySecondsMap[todayKey] ?? 0;
    final todayMinutes = (todaySeconds / 60).round();

    return AnalyticsData(
      todayFocusMinutes: todayMinutes,
      totalDeepWorkHours: totalHours,
      currentStreakDays: streak,
      totalSessionsCompleted: totalCompleted,
      weeklyHeatmap: heatmap,
      recentSessions: recentSessions,
    );
  }

  /// Refreshes the analytics data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchAnalytics());
  }

  static String _formatDateKey(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
