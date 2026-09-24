import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';

/// About & Philosophy screen explaining the Deep Work manifesto and local-first privacy.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          AppLocalizations.of(context)?.manifestoAbout.toUpperCase() ?? 'MANIFESTO & ABOUT',
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
            // App Branding & Version
            Center(
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent, width: 2),
                    ),
                    child: const Icon(
                      Icons.stay_current_portrait_rounded,
                      size: 36,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Flip to Focus',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Version 1.0.0 (Build 1)',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // The Manifesto
            _buildSection(
              title: 'THE 1% MANIFESTO',
              content:
                  'Modern productivity apps keep your screen on, turning focus into a spectator sport. '
                  'Flip to Focus introduces physical friction: turn your phone completely face-down on your desk. '
                  'By removing the visual stimulus and activating native Do Not Disturb, you reclaim unbroken cognitive depth.',
            ),
            const SizedBox(height: AppSpacing.lg),

            // Local-First Privacy Commitment
            _buildSection(
              title: 'LOCAL-FIRST PRIVACY',
              content:
                  'We collect 0% of your data. No analytics, no tracking SDKs, no external servers, and no accounts. '
                  'Every session timestamp and metric resides exclusively in your encrypted device SQLite storage. '
                  'If you delete the app or wipe data, everything disappears forever.',
            ),
            const SizedBox(height: AppSpacing.lg),

            // Open Source & Licenses
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OPEN SOURCE LICENSES',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Built with Flutter, Riverpod, and SQLite. Explore open source libraries used in this application.',
                    style: AppTypography.bodyRegular.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: AppColors.accent,
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: const Text('View All Software Licenses'),
                    onPressed: () {
                      showLicensePage(
                        context: context,
                        applicationName: 'Flip to Focus',
                        applicationVersion: '1.0.0',
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: AppTypography.bodyRegular.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
