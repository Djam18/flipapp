// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Flip to Focus';

  @override
  String get flipScreen => 'RETOURNEZ L\'ÉCRAN';

  @override
  String get faceDownToFocus => 'FACE CONTRE TABLE POUR VOUS CONCENTRER';

  @override
  String get deepFocus => 'CONCENTRATION PROFONDE';

  @override
  String get active => 'ACTIF';

  @override
  String get stabilizing => 'STABILISATION...';

  @override
  String get today => 'AUJOURD\'HUI';

  @override
  String get deepWork => 'Deep Work';

  @override
  String get deepWorkSession => 'Session de Deep Work';

  @override
  String get flipPhoneFor => 'Retournez le téléphone pour le';

  @override
  String get intentionPlaceholder => 'Définir une intention (ex. : Code)';

  @override
  String get intentionDefault => '#code';

  @override
  String get graceAlertTitle => 'NE BRISEZ PAS VOTRE ÉLAN';

  @override
  String get gracePeriodInstruction =>
      'Posez l\'écran face contre table\npour sauver la session';

  @override
  String get emergencyPause => 'Pause d\'urgence (2 minutes)';

  @override
  String get abandonSession => 'Abandonner la session';

  @override
  String get sessionCompleteTitle => 'SESSION ACCOMPLIE !';

  @override
  String get minutesOfDeepWork => 'minutes de Deep Work';

  @override
  String get openDebrief => 'Ouvrir le Bilan & Réflexion';

  @override
  String get dismiss => 'Ignorer';

  @override
  String get sessionRecorded => 'Session Enregistrée';

  @override
  String get focusPreserved => 'min de focus préservées';

  @override
  String get encouragement => 'Chaque minute de focus ininterrompu compte.';

  @override
  String get viewSummary => 'Voir le Bilan & Notes';

  @override
  String get coffeeBreakMessage => 'Deep Work — pause 5 min';

  @override
  String get sessionForged => 'SESSION ACCOMPLIE';

  @override
  String get partialFocusSaved => 'FOCUS PARTIEL SAUVEGARDÉ';

  @override
  String get minutesDeepWork => 'MINUTES DE DEEP WORK';

  @override
  String get reflectionOutput => 'RÉFLEXION & RÉSULTATS';

  @override
  String get reflectionHint => 'Quel jalon ou concept clé avez-vous accompli ?';

  @override
  String get intention => 'INTENTION';

  @override
  String get shielded => 'PROTÉGÉ';

  @override
  String get days => 'JOURS';

  @override
  String get copied => 'Copié';

  @override
  String get summaryCopied => 'Résumé copié dans le presse-papier';

  @override
  String get onboardingSkip => 'IGNORER';

  @override
  String get onboardingSlide1Title => 'LE GESTE PHYSIQUE';

  @override
  String get onboardingSlide1Body =>
      'Posez votre téléphone complètement face contre table. Le travail profond commence par un engagement physique, pas une pression virtuelle.';

  @override
  String get onboardingSlide2Title => 'PRÉCISION MATÉRIELLE';

  @override
  String get onboardingSlide2Body =>
      'Les capteurs de gravité et de proximité protègent votre focus. Si vous soulevez le téléphone, un compte à rebours de 10 secondes vous laisse le temps de le reposer.';

  @override
  String get onboardingSlide3Title => 'BOUCLIER ANTI-DISTRACTIONS';

  @override
  String get onboardingSlide3Body =>
      'Accordez la permission Ne Pas Déranger d\'Android pour que l\'app coupe automatiquement les appels et alertes quand votre téléphone est retourné.';

  @override
  String get onboardingGrantDnd => 'Accorder la permission DND';

  @override
  String get onboardingNext => 'SUIVANT';

  @override
  String get onboardingEnterCockpit => 'ACCÉDER AU COCKPIT';

  @override
  String get sessionHistory => 'HISTORIQUE DES SESSIONS';

  @override
  String get filterAll => 'TOUT';

  @override
  String get filterCompleted => 'ACCOMPLIES';

  @override
  String get filterInterrupted => 'INTERROMPUES';

  @override
  String get errorLoadingLedger => 'Erreur lors du chargement de l\'historique';

  @override
  String get noSessionsYet =>
      'Aucune session pour l\'instant.\nRetournez votre téléphone pour commencer votre premier bloc de travail profond.';

  @override
  String get viewAll => 'TOUT VOIR';

  @override
  String get performance => 'PERFORMANCES';

  @override
  String get settingsTitle => 'RÉGLAGES & ERGONOMIE';

  @override
  String get gracePeriodDuration => 'DÉLAI DE GRÂCE';

  @override
  String get gracePeriodSubtitle =>
      'Temps accordé pour soulever le téléphone avant que la session soit marquée interrompue.';

  @override
  String get pickupTolerance => 'Tolérance de reprise';

  @override
  String get seconds => 'SECONDES';

  @override
  String get language => 'Langue';

  @override
  String get languageSubtitle => 'Choisir la langue de l\'application';

  @override
  String get hardwareShield => 'BOUCLIER MATÉRIEL & DISTRACTIONS';

  @override
  String get autoDnd => 'Ne Pas Déranger Automatique (DND)';

  @override
  String get autoDndSubtitle =>
      'Couper les notifications et appels quand le téléphone est retourné';

  @override
  String get hapticPulses => 'Impulsions Haptiques';

  @override
  String get hapticSubtitle =>
      'Vibrations légères à la confirmation du flip, alerte de grâce et succès de session';

  @override
  String get oledBlackout => 'Noir Absolu OLED';

  @override
  String get oledSubtitle =>
      'Désactiver complètement les pixels de l\'écran pour préserver la batterie';

  @override
  String get hardwareCalibration => 'Calibrage Matériel & Entraînement';

  @override
  String get hardwareCalibrationSubtitle =>
      'Testez la détection du flip, le capteur de proximité et les haptiques en temps réel';

  @override
  String get systemPermissions => 'AUTORISATIONS SYSTÈME';

  @override
  String get dndAccessPolicy => 'Accès au mode Ne Pas Déranger';

  @override
  String get dndSubtitle =>
      'Ouvrir les paramètres Android pour accorder ou vérifier la permission';

  @override
  String get manage => 'Gérer';

  @override
  String get dataPrivacy => 'CONFIDENTIALITÉ & DONNÉES';

  @override
  String get manifestoAbout => 'Manifeste & À propos';

  @override
  String get manifestoSubtitle =>
      'Principes du Deep Work, licences open source et engagement de confidentialité';

  @override
  String get wipeData => 'Effacer toutes les données';

  @override
  String get wipeDataSubtitle =>
      'Supprimer définitivement toutes les sessions, la heatmap et les séries';

  @override
  String get wipeDialogTitle => 'Supprimer toutes les données ?';

  @override
  String get wipeDialogBody =>
      'Cette action est irréversible. Tout l\'historique des sessions de Deep Work et les métriques de série quotidienne seront effacés de votre appareil.';

  @override
  String get cancel => 'Annuler';

  @override
  String get wipeEverything => 'Tout effacer';

  @override
  String get dataErased => 'Toutes les données locales ont été effacées.';

  @override
  String get simulateFlipDown => 'Simuler Flip Bas';

  @override
  String get simulateFlipUp => 'Simuler Flip Haut';

  @override
  String get restingFaceDown => 'TÉLÉPHONE FACE CONTRE TABLE';

  @override
  String get sessionLogs => 'JOURNAL DE SESSIONS';

  @override
  String get deepWorkRhythm => 'RYTHME DE FOCUS';

  @override
  String get past7Days => '7 DERNIERS JOURS';

  @override
  String get streak => 'SÉRIE';

  @override
  String get total => 'TOTAL';

  @override
  String get disciplineMilestones => 'PALIERS DE DISCIPLINE';

  @override
  String get summary => 'Récapitulatif';

  @override
  String get sessionComplete => 'Session Terminée';

  @override
  String get focusScore => 'Score de Focus';

  @override
  String get distractions => 'Distractions';

  @override
  String get calendar => 'Calendrier';

  @override
  String get breaks => 'pauses';

  @override
  String get returnToCockpit => 'RETOUR AU COCKPIT';

  @override
  String get share => 'Partager';

  @override
  String get viewAllSoftwareLicenses => 'Voir toutes les licences logicielles';
}
