import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Flip to Focus'**
  String get appTitle;

  /// No description provided for @flipScreen.
  ///
  /// In en, this message translates to:
  /// **'FLIP SCREEN'**
  String get flipScreen;

  /// No description provided for @faceDownToFocus.
  ///
  /// In en, this message translates to:
  /// **'FACE DOWN TO FOCUS'**
  String get faceDownToFocus;

  /// No description provided for @deepFocus.
  ///
  /// In en, this message translates to:
  /// **'DEEP FOCUS'**
  String get deepFocus;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get active;

  /// No description provided for @stabilizing.
  ///
  /// In en, this message translates to:
  /// **'STABILIZING...'**
  String get stabilizing;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get today;

  /// No description provided for @deepWork.
  ///
  /// In en, this message translates to:
  /// **'Deep Work'**
  String get deepWork;

  /// No description provided for @deepWorkSession.
  ///
  /// In en, this message translates to:
  /// **'Deep Work Session'**
  String get deepWorkSession;

  /// No description provided for @flipPhoneFor.
  ///
  /// In en, this message translates to:
  /// **'Flip phone for'**
  String get flipPhoneFor;

  /// No description provided for @intentionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Set intention (e.g., Code)'**
  String get intentionPlaceholder;

  /// No description provided for @intentionDefault.
  ///
  /// In en, this message translates to:
  /// **'#code'**
  String get intentionDefault;

  /// No description provided for @graceAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'DO NOT BREAK YOUR STRIDE'**
  String get graceAlertTitle;

  /// No description provided for @gracePeriodInstruction.
  ///
  /// In en, this message translates to:
  /// **'Place screen face-down on desk\nto rescue the session'**
  String get gracePeriodInstruction;

  /// No description provided for @emergencyPause.
  ///
  /// In en, this message translates to:
  /// **'Emergency Pause (2 minutes)'**
  String get emergencyPause;

  /// No description provided for @abandonSession.
  ///
  /// In en, this message translates to:
  /// **'Abandon session'**
  String get abandonSession;

  /// No description provided for @sessionCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'SESSION COMPLETE!'**
  String get sessionCompleteTitle;

  /// No description provided for @minutesOfDeepWork.
  ///
  /// In en, this message translates to:
  /// **'minutes of Deep Work'**
  String get minutesOfDeepWork;

  /// No description provided for @openDebrief.
  ///
  /// In en, this message translates to:
  /// **'Open Debrief & Reflection'**
  String get openDebrief;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @sessionRecorded.
  ///
  /// In en, this message translates to:
  /// **'Session Recorded'**
  String get sessionRecorded;

  /// No description provided for @focusPreserved.
  ///
  /// In en, this message translates to:
  /// **'min of focus preserved'**
  String get focusPreserved;

  /// No description provided for @encouragement.
  ///
  /// In en, this message translates to:
  /// **'Every minute of uninterrupted focus counts.'**
  String get encouragement;

  /// No description provided for @viewSummary.
  ///
  /// In en, this message translates to:
  /// **'View Summary & Notes'**
  String get viewSummary;

  /// No description provided for @coffeeBreakMessage.
  ///
  /// In en, this message translates to:
  /// **'Deep Work — 5 min break'**
  String get coffeeBreakMessage;

  /// No description provided for @sessionForged.
  ///
  /// In en, this message translates to:
  /// **'SESSION FORGED'**
  String get sessionForged;

  /// No description provided for @partialFocusSaved.
  ///
  /// In en, this message translates to:
  /// **'PARTIAL FOCUS SAVED'**
  String get partialFocusSaved;

  /// No description provided for @minutesDeepWork.
  ///
  /// In en, this message translates to:
  /// **'MINUTES DEEP WORK'**
  String get minutesDeepWork;

  /// No description provided for @reflectionOutput.
  ///
  /// In en, this message translates to:
  /// **'REFLECTION & OUTPUT'**
  String get reflectionOutput;

  /// No description provided for @reflectionHint.
  ///
  /// In en, this message translates to:
  /// **'What key milestone or concept did you ship?'**
  String get reflectionHint;

  /// No description provided for @intention.
  ///
  /// In en, this message translates to:
  /// **'INTENTION'**
  String get intention;

  /// No description provided for @shielded.
  ///
  /// In en, this message translates to:
  /// **'SHIELDED'**
  String get shielded;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'DAYS'**
  String get days;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @summaryCopied.
  ///
  /// In en, this message translates to:
  /// **'Summary copied to clipboard'**
  String get summaryCopied;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get onboardingSkip;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'THE PHYSICAL GESTURE'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Body.
  ///
  /// In en, this message translates to:
  /// **'Turn your phone completely face-down on your desk. Deep work begins with a physical commitment, not a virtual tap.'**
  String get onboardingSlide1Body;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'HARDWARE PRECISION'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Body.
  ///
  /// In en, this message translates to:
  /// **'Gravity and proximity sensors guard your focus. If you pick up your phone, a 10-second grace countdown gives you time to put it back.'**
  String get onboardingSlide2Body;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'DISTRACTION SHIELD'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Body.
  ///
  /// In en, this message translates to:
  /// **'Grant Android Do Not Disturb permission so the app can automatically mute incoming calls and alerts while your phone is face down.'**
  String get onboardingSlide3Body;

  /// No description provided for @onboardingGrantDnd.
  ///
  /// In en, this message translates to:
  /// **'Grant DND Permission'**
  String get onboardingGrantDnd;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get onboardingNext;

  /// No description provided for @onboardingEnterCockpit.
  ///
  /// In en, this message translates to:
  /// **'ENTER COCKPIT'**
  String get onboardingEnterCockpit;

  /// No description provided for @sessionHistory.
  ///
  /// In en, this message translates to:
  /// **'SESSION HISTORY'**
  String get sessionHistory;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get filterAll;

  /// No description provided for @filterCompleted.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get filterCompleted;

  /// No description provided for @filterInterrupted.
  ///
  /// In en, this message translates to:
  /// **'INTERRUPTED'**
  String get filterInterrupted;

  /// No description provided for @errorLoadingLedger.
  ///
  /// In en, this message translates to:
  /// **'Error loading session ledger'**
  String get errorLoadingLedger;

  /// No description provided for @noSessionsYet.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet.\nFlip your phone to start your first deep work block.'**
  String get noSessionsYet;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'VIEW ALL'**
  String get viewAll;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'PERFORMANCE'**
  String get performance;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS & ERGONOMICS'**
  String get settingsTitle;

  /// No description provided for @gracePeriodDuration.
  ///
  /// In en, this message translates to:
  /// **'GRACE PERIOD DURATION'**
  String get gracePeriodDuration;

  /// No description provided for @gracePeriodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Time allowed to pick up your phone to check emergency info before the deep work session is marked interrupted.'**
  String get gracePeriodSubtitle;

  /// No description provided for @pickupTolerance.
  ///
  /// In en, this message translates to:
  /// **'Pickup Tolerance'**
  String get pickupTolerance;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'SECONDS'**
  String get seconds;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select interface language'**
  String get languageSubtitle;

  /// No description provided for @hardwareShield.
  ///
  /// In en, this message translates to:
  /// **'HARDWARE & DISTRACTION SHIELD'**
  String get hardwareShield;

  /// No description provided for @autoDnd.
  ///
  /// In en, this message translates to:
  /// **'Auto Do Not Disturb (DND)'**
  String get autoDnd;

  /// No description provided for @autoDndSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mute notifications and calls while phone is flipped down'**
  String get autoDndSubtitle;

  /// No description provided for @hapticPulses.
  ///
  /// In en, this message translates to:
  /// **'Haptic Pulses'**
  String get hapticPulses;

  /// No description provided for @hapticSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Gentle vibrations on flip confirmation, grace alert, and session success'**
  String get hapticSubtitle;

  /// No description provided for @oledBlackout.
  ///
  /// In en, this message translates to:
  /// **'OLED True Blackout'**
  String get oledBlackout;

  /// No description provided for @oledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate display pixels completely to preserve battery'**
  String get oledSubtitle;

  /// No description provided for @hardwareCalibration.
  ///
  /// In en, this message translates to:
  /// **'Hardware Calibration & Practice'**
  String get hardwareCalibration;

  /// No description provided for @hardwareCalibrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Test flip detection, proximity sensor, and haptics in real-time'**
  String get hardwareCalibrationSubtitle;

  /// No description provided for @systemPermissions.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM PERMISSIONS'**
  String get systemPermissions;

  /// No description provided for @dndAccessPolicy.
  ///
  /// In en, this message translates to:
  /// **'DND Access Policy'**
  String get dndAccessPolicy;

  /// No description provided for @dndSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open Android settings to grant or check permission'**
  String get dndSubtitle;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @dataPrivacy.
  ///
  /// In en, this message translates to:
  /// **'DATA PRIVACY & STORAGE'**
  String get dataPrivacy;

  /// No description provided for @manifestoAbout.
  ///
  /// In en, this message translates to:
  /// **'Manifesto & About'**
  String get manifestoAbout;

  /// No description provided for @manifestoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deep Work principles, open source licenses, and privacy pledge'**
  String get manifestoSubtitle;

  /// No description provided for @wipeData.
  ///
  /// In en, this message translates to:
  /// **'Wipe All Historical Data'**
  String get wipeData;

  /// No description provided for @wipeDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Irreversibly delete all sessions, heatmap records, and streaks'**
  String get wipeDataSubtitle;

  /// No description provided for @wipeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data?'**
  String get wipeDialogTitle;

  /// No description provided for @wipeDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All deep work session history and daily streak metrics will be erased from your device.'**
  String get wipeDialogBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @wipeEverything.
  ///
  /// In en, this message translates to:
  /// **'Wipe Everything'**
  String get wipeEverything;

  /// No description provided for @dataErased.
  ///
  /// In en, this message translates to:
  /// **'All local session data has been erased.'**
  String get dataErased;

  /// No description provided for @simulateFlipDown.
  ///
  /// In en, this message translates to:
  /// **'Simulate Flip Down'**
  String get simulateFlipDown;

  /// No description provided for @simulateFlipUp.
  ///
  /// In en, this message translates to:
  /// **'Simulate Flip Up'**
  String get simulateFlipUp;

  /// No description provided for @restingFaceDown.
  ///
  /// In en, this message translates to:
  /// **'RESTING FACE DOWN'**
  String get restingFaceDown;

  /// No description provided for @sessionLogs.
  ///
  /// In en, this message translates to:
  /// **'SESSION LOGS'**
  String get sessionLogs;

  /// No description provided for @deepWorkRhythm.
  ///
  /// In en, this message translates to:
  /// **'DEEP WORK RHYTHM'**
  String get deepWorkRhythm;

  /// No description provided for @past7Days.
  ///
  /// In en, this message translates to:
  /// **'PAST 7 DAYS'**
  String get past7Days;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'STREAK'**
  String get streak;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get total;

  /// No description provided for @disciplineMilestones.
  ///
  /// In en, this message translates to:
  /// **'DISCIPLINE MILESTONES'**
  String get disciplineMilestones;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @sessionComplete.
  ///
  /// In en, this message translates to:
  /// **'Session Complete'**
  String get sessionComplete;

  /// No description provided for @focusScore.
  ///
  /// In en, this message translates to:
  /// **'Focus Score'**
  String get focusScore;

  /// No description provided for @distractions.
  ///
  /// In en, this message translates to:
  /// **'Distractions'**
  String get distractions;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @breaks.
  ///
  /// In en, this message translates to:
  /// **'breaks'**
  String get breaks;

  /// No description provided for @returnToCockpit.
  ///
  /// In en, this message translates to:
  /// **'RETURN TO COCKPIT'**
  String get returnToCockpit;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @viewAllSoftwareLicenses.
  ///
  /// In en, this message translates to:
  /// **'View All Software Licenses'**
  String get viewAllSoftwareLicenses;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
