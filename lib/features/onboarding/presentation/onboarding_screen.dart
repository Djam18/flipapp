import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/platform/native_sensor_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../focus_session/presentation/cockpit_screen.dart';
import '../../settings/presentation/settings_controller.dart';

/// Interactive onboarding flow explaining the physical flip paradigm and requesting DND permission.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _finishOnboarding() {
    ref.read(settingsProvider.notifier).completeOnboarding();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CockpitScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sensorService = ref.read(nativeSensorServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: Text(
                  'SKIP',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            // Page View with Slides
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildSlide(
                    icon: Icons.stay_current_portrait_rounded,
                    title: 'THE PHYSICAL GESTURE',
                    subtitle:
                        'Turn your phone completely face-down on your desk. Deep work begins with a physical commitment, not a virtual tap.',
                  ),
                  _buildSlide(
                    icon: Icons.sensors_rounded,
                    title: 'HARDWARE PRECISION',
                    subtitle:
                        'Gravity and proximity sensors guard your focus. If you pick up your phone, a 10-second grace countdown gives you time to put it back.',
                  ),
                  _buildSlide(
                    icon: Icons.do_not_disturb_on_rounded,
                    title: 'DISTRACTION SHIELD',
                    subtitle:
                        'Grant Android Do Not Disturb permission so the app can automatically mute incoming calls and alerts while your phone is face down.',
                    actionButton: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        side: const BorderSide(color: AppColors.accent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
                      ),
                      icon: const Icon(Icons.security_rounded, size: 18),
                      label: const Text('Grant DND Permission'),
                      onPressed: () => sensorService.requestDndPermission(),
                    ),
                  ),
                ],
              ),
            ),

            // Page Indicator and Next/Start Button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dot Indicators
                  Row(
                    children: List.generate(3, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.accent : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                      );
                    }),
                  ),

                  // Action Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      ),
                    ),
                    onPressed: () {
                      if (_currentPage < 2) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finishOnboarding();
                      }
                    },
                    child: Text(
                      _currentPage == 2 ? 'ENTER COCKPIT' : 'NEXT',
                      style: AppTypography.button.copyWith(
                        color: AppColors.background,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? actionButton,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: Icon(icon, size: 54, color: AppColors.accent),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.titleLarge.copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.bodyRegular.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          if (actionButton != null) ...[
            const SizedBox(height: AppSpacing.xl),
            actionButton,
          ],
        ],
      ),
    );
  }
}
