import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/database/app_database.dart';
import '../domain/settings_state.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});

class SettingsNotifier extends Notifier<SettingsState> {
  static const String _keyGracePeriod = 'ftf_grace_period_seconds';
  static const String _keyHaptics = 'ftf_haptics_enabled';
  static const String _keyAutoDnd = 'ftf_auto_dnd_enabled';
  static const String _keyScreenOff = 'ftf_screen_off_sim';
  static const String _keyOnboarding = 'ftf_has_seen_onboarding';
  static const String _keyLanguage = 'ftf_language_code';

  @override
  SettingsState build() {
    _loadPreferences();
    return const SettingsState();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      gracePeriodSeconds: prefs.getInt(_keyGracePeriod) ?? 10,
      hapticsEnabled: prefs.getBool(_keyHaptics) ?? true,
      autoDndEnabled: prefs.getBool(_keyAutoDnd) ?? true,
      screenOffSimulation: prefs.getBool(_keyScreenOff) ?? true,
      hasSeenOnboarding: prefs.getBool(_keyOnboarding) ?? false,
      languageCode: prefs.getString(_keyLanguage) ?? 'en',
    );
  }

  Future<void> setGracePeriodSeconds(int seconds) async {
    state = state.copyWith(gracePeriodSeconds: seconds);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyGracePeriod, seconds);
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    state = state.copyWith(hapticsEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHaptics, enabled);
  }

  Future<void> setAutoDndEnabled(bool enabled) async {
    state = state.copyWith(autoDndEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoDnd, enabled);
  }

  Future<void> setScreenOffSimulation(bool enabled) async {
    state = state.copyWith(screenOffSimulation: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyScreenOff, enabled);
  }

  Future<void> setLanguageCode(String code) async {
    state = state.copyWith(languageCode: code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, code);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(hasSeenOnboarding: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarding, true);
  }

  /// Wipes all historical focus sessions and daily summaries
  Future<void> resetAllData() async {
    final db = await AppDatabase.instance.database;
    await db.delete('focus_sessions');
    await db.delete('daily_summaries');
  }
}
