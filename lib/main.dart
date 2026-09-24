import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/focus_session/presentation/cockpit_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/settings/presentation/settings_controller.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce system UI overlay to OLED True Black
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    // ProviderScope is the mandatory root container for Riverpod state
    const ProviderScope(
      child: FlipToFocusApp(),
    ),
  );
}

class FlipToFocusApp extends ConsumerWidget {
  const FlipToFocusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Flip to Focus',
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: Locale(settings.languageCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: settings.hasSeenOnboarding
          ? const CockpitScreen()
          : const OnboardingScreen(),
    );
  }
}
