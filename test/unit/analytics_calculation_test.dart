import 'package:flutter_test/flutter_test.dart';
import 'package:flip_to_focus/features/analytics/domain/analytics_data.dart';
import 'package:flip_to_focus/features/analytics/domain/milestones_data.dart';

void main() {
  group('Analytics & Milestone Calculation Tests', () {
    test('Zero sessions unlocked zero badges', () {
      final data = AnalyticsData.empty();
      final badges = evaluateMilestones(data);

      expect(badges.length, equals(6));
      expect(badges.every((b) => !b.isUnlocked), isTrue);
    });

    test('1 completed session unlocks First Dive badge', () {
      const data = AnalyticsData(
        todayFocusMinutes: 25,
        totalDeepWorkHours: 0,
        currentStreakDays: 1,
        totalSessionsCompleted: 1,
        weeklyHeatmap: [],
        recentSessions: [],
      );

      final badges = evaluateMilestones(data);
      final firstDive = badges.firstWhere((b) => b.id == 'first_dive');
      expect(firstDive.isUnlocked, isTrue);

      final monk = badges.firstWhere((b) => b.id == 'monk_25h');
      expect(monk.isUnlocked, isFalse);
    });

    test('3-day streak unlocks Consistency badge', () {
      const data = AnalyticsData(
        todayFocusMinutes: 60,
        totalDeepWorkHours: 3,
        currentStreakDays: 3,
        totalSessionsCompleted: 5,
        weeklyHeatmap: [],
        recentSessions: [],
      );

      final badges = evaluateMilestones(data);
      final streak3 = badges.firstWhere((b) => b.id == 'streak_3');
      expect(streak3.isUnlocked, isTrue);

      final streak7 = badges.firstWhere((b) => b.id == 'streak_7');
      expect(streak7.isUnlocked, isFalse);
    });

    test('25 hours unlocks Monk Depth badge', () {
      const data = AnalyticsData(
        todayFocusMinutes: 120,
        totalDeepWorkHours: 25,
        currentStreakDays: 7,
        totalSessionsCompleted: 30,
        weeklyHeatmap: [],
        recentSessions: [],
      );

      final badges = evaluateMilestones(data);
      final monk = badges.firstWhere((b) => b.id == 'monk_25h');
      expect(monk.isUnlocked, isTrue);

      final streak7 = badges.firstWhere((b) => b.id == 'streak_7');
      expect(streak7.isUnlocked, isTrue);
    });
  });
}
