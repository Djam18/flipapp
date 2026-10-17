// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flip to Focus';

  @override
  String get flipScreen => 'FLIP SCREEN';

  @override
  String get faceDownToFocus => 'FACE DOWN TO FOCUS';

  @override
  String get deepFocus => 'DEEP FOCUS';

  @override
  String get active => 'ACTIVE';

  @override
  String get stabilizing => 'STABILIZING...';

  @override
  String get today => 'TODAY';

  @override
  String get deepWork => 'Deep Work';

  @override
  String get deepWorkSession => 'Deep Work Session';

  @override
  String get flipPhoneFor => 'Flip phone for';

  @override
  String get intentionPlaceholder => 'Set intention (e.g., Code)';

  @override
  String get intentionDefault => '#code';

  @override
  String get graceAlertTitle => 'DO NOT BREAK YOUR STRIDE';

  @override
  String get gracePeriodInstruction =>
      'Place screen face-down on desk\nto rescue the session';

  @override
  String get emergencyPause => 'Emergency Pause (2 minutes)';

  @override
  String get abandonSession => 'Abandon session';

  @override
  String get sessionCompleteTitle => 'SESSION COMPLETE!';

  @override
  String get minutesOfDeepWork => 'minutes of Deep Work';

  @override
  String get openDebrief => 'Open Debrief & Reflection';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get sessionRecorded => 'Session Recorded';

  @override
  String get focusPreserved => 'min of focus preserved';

  @override
  String get encouragement => 'Every minute of uninterrupted focus counts.';

  @override
  String get viewSummary => 'View Summary & Notes';

  @override
  String get coffeeBreakMessage => 'Deep Work — 5 min break';

  @override
  String get sessionForged => 'SESSION FORGED';

  @override
  String get partialFocusSaved => 'PARTIAL FOCUS SAVED';

  @override
  String get minutesDeepWork => 'MINUTES DEEP WORK';

  @override
  String get reflectionOutput => 'REFLECTION & OUTPUT';

  @override
  String get reflectionHint => 'What key milestone or concept did you ship?';

  @override
  String get intention => 'INTENTION';

  @override
  String get shielded => 'SHIELDED';

  @override
  String get days => 'DAYS';

  @override
  String get copied => 'Copied';

  @override
  String get summaryCopied => 'Summary copied to clipboard';

  @override
  String get onboardingSkip => 'SKIP';

  @override
  String get onboardingSlide1Title => 'THE PHYSICAL GESTURE';

  @override
  String get onboardingSlide1Body =>
      'Turn your phone completely face-down on your desk. Deep work begins with a physical commitment, not a virtual tap.';

  @override
  String get onboardingSlide2Title => 'HARDWARE PRECISION';

  @override
  String get onboardingSlide2Body =>
      'Gravity and proximity sensors guard your focus. If you pick up your phone, a 10-second grace countdown gives you time to put it back.';

  @override
  String get onboardingSlide3Title => 'DISTRACTION SHIELD';

  @override
  String get onboardingSlide3Body =>
      'Grant Android Do Not Disturb permission so the app can automatically mute incoming calls and alerts while your phone is face down.';

  @override
  String get onboardingGrantDnd => 'Grant DND Permission';

  @override
  String get onboardingNext => 'NEXT';

  @override
  String get onboardingEnterCockpit => 'ENTER COCKPIT';

  @override
  String get sessionHistory => 'SESSION HISTORY';

  @override
  String get filterAll => 'ALL';

  @override
  String get filterCompleted => 'COMPLETED';

  @override
  String get filterInterrupted => 'INTERRUPTED';

  @override
  String get errorLoadingLedger => 'Error loading session ledger';

  @override
  String get noSessionsYet =>
      'No sessions yet.\nFlip your phone to start your first deep work block.';

  @override
  String get viewAll => 'VIEW ALL';

  @override
  String get performance => 'PERFORMANCE';

  @override
  String get settingsTitle => 'SETTINGS & ERGONOMICS';

  @override
  String get gracePeriodDuration => 'GRACE PERIOD DURATION';

  @override
  String get gracePeriodSubtitle =>
      'Time allowed to pick up your phone to check emergency info before the deep work session is marked interrupted.';

  @override
  String get pickupTolerance => 'Pickup Tolerance';

  @override
  String get seconds => 'SECONDS';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Select interface language';

  @override
  String get hardwareShield => 'HARDWARE & DISTRACTION SHIELD';

  @override
  String get autoDnd => 'Auto Do Not Disturb (DND)';

  @override
  String get autoDndSubtitle =>
      'Mute notifications and calls while phone is flipped down';

  @override
  String get hapticPulses => 'Haptic Pulses';

  @override
  String get hapticSubtitle =>
      'Gentle vibrations on flip confirmation, grace alert, and session success';

  @override
  String get oledBlackout => 'OLED True Blackout';

  @override
  String get oledSubtitle =>
      'Deactivate display pixels completely to preserve battery';

  @override
  String get hardwareCalibration => 'Hardware Calibration & Practice';

  @override
  String get hardwareCalibrationSubtitle =>
      'Test flip detection, proximity sensor, and haptics in real-time';

  @override
  String get systemPermissions => 'SYSTEM PERMISSIONS';

  @override
  String get dndAccessPolicy => 'DND Access Policy';

  @override
  String get dndSubtitle =>
      'Open Android settings to grant or check permission';

  @override
  String get manage => 'Manage';

  @override
  String get dataPrivacy => 'DATA PRIVACY & STORAGE';

  @override
  String get manifestoAbout => 'Manifesto & About';

  @override
  String get manifestoSubtitle =>
      'Deep Work principles, open source licenses, and privacy pledge';

  @override
  String get wipeData => 'Wipe All Historical Data';

  @override
  String get wipeDataSubtitle =>
      'Irreversibly delete all sessions, heatmap records, and streaks';

  @override
  String get wipeDialogTitle => 'Delete All Data?';

  @override
  String get wipeDialogBody =>
      'This action cannot be undone. All deep work session history and daily streak metrics will be erased from your device.';

  @override
  String get cancel => 'Cancel';

  @override
  String get wipeEverything => 'Wipe Everything';

  @override
  String get dataErased => 'All local session data has been erased.';

  @override
  String get simulateFlipDown => 'Simulate Flip Down';

  @override
  String get simulateFlipUp => 'Simulate Flip Up';

  @override
  String get restingFaceDown => 'RESTING FACE DOWN';

  @override
  String get sessionLogs => 'SESSION LOGS';

  @override
  String get deepWorkRhythm => 'DEEP WORK RHYTHM';

  @override
  String get past7Days => 'PAST 7 DAYS';

  @override
  String get streak => 'STREAK';

  @override
  String get total => 'TOTAL';

  @override
  String get disciplineMilestones => 'DISCIPLINE MILESTONES';

  @override
  String get summary => 'Summary';

  @override
  String get sessionComplete => 'Session Complete';

  @override
  String get focusScore => 'Focus Score';

  @override
  String get distractions => 'Distractions';

  @override
  String get calendar => 'Calendar';

  @override
  String get breaks => 'breaks';

  @override
  String get returnToCockpit => 'RETURN TO COCKPIT';

  @override
  String get share => 'Share';

  @override
  String get viewAllSoftwareLicenses => 'View All Software Licenses';
}
