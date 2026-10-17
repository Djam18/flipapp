import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/platform/native_sensor_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../analytics/presentation/analytics_controller.dart';
import 'about_screen.dart';
import 'interactive_flip_test_screen.dart';
import 'settings_controller.dart';
import '../../../l10n/app_localizations.dart';

/// Settings & Ergonomics preferences screen.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final sensorService = ref.read(nativeSensorServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.settingsTitle,
          style: AppTypography.caption.copyWith(
            color: AppColors.textPrimary,
            letterSpacing: 2.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Grace Period
            _buildSectionHeader(l10n.gracePeriodDuration),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.pickupTolerance,
                        style: AppTypography.bodyRegular.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${settings.gracePeriodSeconds} ${l10n.seconds}',
                        style: GoogleFonts.jetBrainsMono(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.gracePeriodSubtitle,
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.accent,
                      inactiveTrackColor: AppColors.surfaceElevated,
                      thumbColor: AppColors.textPrimary,
                      overlayColor: AppColors.accent.withValues(alpha: 0.2),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: settings.gracePeriodSeconds.toDouble(),
                      min: 5,
                      max: 30,
                      divisions: 5,
                      onChanged: (val) => notifier.setGracePeriodSeconds(val.round()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Language Selection
            _buildSectionHeader(l10n.language.toUpperCase()),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              child: Material(
                color: AppColors.surface,
                child: ListTile(
                  leading: const Icon(Icons.language_rounded, color: AppColors.accent, size: 22),
                  title: Text(
                    l10n.language,
                    style: AppTypography.bodyRegular.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    settings.languageCode == 'fr' ? 'Français' : 'English',
                    style: AppTypography.caption.copyWith(color: AppColors.accent),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
                  onTap: () => _showLanguageDialog(context, ref, settings.languageCode),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Section 2: Sensor & Hardware Controls
            _buildSectionHeader(l10n.hardwareShield),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              child: Material(
                color: AppColors.surface,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(
                        l10n.autoDnd,
                        style: AppTypography.bodyRegular.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        l10n.autoDndSubtitle,
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      ),
                      value: settings.autoDndEnabled,
                      activeThumbColor: AppColors.accent,
                      onChanged: (val) => notifier.setAutoDndEnabled(val),
                    ),
                    const Divider(color: AppColors.border, height: 1),
                    SwitchListTile(
                      title: Text(
                        l10n.hapticPulses,
                        style: AppTypography.bodyRegular.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        l10n.hapticSubtitle,
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      ),
                      value: settings.hapticsEnabled,
                      activeThumbColor: AppColors.accent,
                      onChanged: (val) => notifier.setHapticsEnabled(val),
                    ),
                    const Divider(color: AppColors.border, height: 1),
                    SwitchListTile(
                      title: Text(
                        l10n.oledBlackout,
                        style: AppTypography.bodyRegular.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        l10n.oledSubtitle,
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      ),
                      value: settings.screenOffSimulation,
                      activeThumbColor: AppColors.accent,
                      onChanged: (val) => notifier.setScreenOffSimulation(val),
                    ),
                    const Divider(color: AppColors.border, height: 1),
                    ListTile(
                      leading: const Icon(Icons.flip_to_back_rounded, color: AppColors.accent, size: 22),
                      title: Text(
                        l10n.hardwareCalibration,
                        style: AppTypography.bodyRegular.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        l10n.hardwareCalibrationSubtitle,
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const InteractiveFlipTestScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Section 3: Android DND System Permissions
            _buildSectionHeader(l10n.systemPermissions),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.do_not_disturb_on_rounded, color: AppColors.accent, size: 24),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.dndAccessPolicy,
                          style: AppTypography.bodyRegular.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          l10n.dndSubtitle,
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 8),
                    ),
                    onPressed: () => sensorService.requestDndPermission(),
                    child: Text(l10n.manage, style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Section 4: Data & Reset
            _buildSectionHeader(l10n.dataPrivacy),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              child: Material(
                color: AppColors.surface,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        l10n.manifestoAbout,
                        style: AppTypography.bodyRegular.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        l10n.manifestoSubtitle,
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AboutScreen()),
                        );
                      },
                    ),
                    const Divider(color: AppColors.border, height: 1),
                    ListTile(
                      title: Text(
                        l10n.wipeData,
                        style: AppTypography.bodyRegular.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        l10n.wipeDataSubtitle,
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      ),
                      trailing: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                      onTap: () => _showWipeConfirmation(context, ref),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.xs),
      child: Text(
        title,
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _showWipeConfirmation(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          l10n.wipeDialogTitle,
          style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          l10n.wipeDialogBody,
          style: AppTypography.bodyRegular.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            child: Text(l10n.cancel, style: const TextStyle(color: AppColors.textSecondary)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.textPrimary,
            ),
            child: Text(l10n.wipeEverything),
            onPressed: () async {
              await ref.read(settingsProvider.notifier).resetAllData();
              ref.invalidate(analyticsProvider);
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.dataErased),
                    backgroundColor: AppColors.surfaceElevated,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, String currentCode) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          l10n.languageSubtitle,
          style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
        ),
        children: [
          SimpleDialogOption(
            onPressed: () {
              ref.read(settingsProvider.notifier).setLanguageCode('en');
              Navigator.of(ctx).pop();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'English',
                  style: TextStyle(
                    color: currentCode == 'en' ? AppColors.accent : AppColors.textPrimary,
                    fontWeight: currentCode == 'en' ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
                if (currentCode == 'en')
                  const Icon(Icons.check, color: AppColors.accent, size: 20),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(settingsProvider.notifier).setLanguageCode('fr');
              Navigator.of(ctx).pop();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Français',
                  style: TextStyle(
                    color: currentCode == 'fr' ? AppColors.accent : AppColors.textPrimary,
                    fontWeight: currentCode == 'fr' ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
                if (currentCode == 'fr')
                  const Icon(Icons.check, color: AppColors.accent, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
