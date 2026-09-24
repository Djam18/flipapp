/// Immutable state model representing user ergonomic and system preferences.
class SettingsState {
  final int gracePeriodSeconds;
  final bool hapticsEnabled;
  final bool autoDndEnabled;
  final bool screenOffSimulation;
  final bool hasSeenOnboarding;
  final String languageCode; // 'en' | 'fr'

  const SettingsState({
    this.gracePeriodSeconds = 10,
    this.hapticsEnabled = true,
    this.autoDndEnabled = true,
    this.screenOffSimulation = true,
    this.hasSeenOnboarding = false,
    this.languageCode = 'en',
  });

  SettingsState copyWith({
    int? gracePeriodSeconds,
    bool? hapticsEnabled,
    bool? autoDndEnabled,
    bool? screenOffSimulation,
    bool? hasSeenOnboarding,
    String? languageCode,
  }) {
    return SettingsState(
      gracePeriodSeconds: gracePeriodSeconds ?? this.gracePeriodSeconds,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      autoDndEnabled: autoDndEnabled ?? this.autoDndEnabled,
      screenOffSimulation: screenOffSimulation ?? this.screenOffSimulation,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}
