import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/platform/native_sensor_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';

/// Interactive hardware calibration and practice screen.
/// Allows the user to physically flip their phone to test accelerometer and proximity sensor integration.
class InteractiveFlipTestScreen extends ConsumerStatefulWidget {
  const InteractiveFlipTestScreen({super.key});

  @override
  ConsumerState<InteractiveFlipTestScreen> createState() => _InteractiveFlipTestScreenState();
}

class _InteractiveFlipTestScreenState extends ConsumerState<InteractiveFlipTestScreen> {
  StreamSubscription<bool>? _sensorSub;
  bool _isFlipped = false;
  int _flipCount = 0;

  @override
  void initState() {
    super.initState();
    final sensorService = ref.read(nativeSensorServiceProvider);
    try {
      _sensorSub = sensorService.flipStream.listen((flipped) {
        _handleFlipUpdate(flipped);
      }, onError: (_) {
        // Stream may error in unit tests or unsupported hardware
      });
    } catch (_) {}
  }

  void _handleFlipUpdate(bool flipped) {
    if (flipped != _isFlipped) {
      setState(() {
        _isFlipped = flipped;
        if (flipped) _flipCount++;
      });
      final sensor = ref.read(nativeSensorServiceProvider);
      if (flipped) {
        sensor.triggerSuccessHaptic();
      } else {
        sensor.triggerHapticFeedback();
      }
    }
  }

  @override
  void dispose() {
    _sensorSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'HARDWARE CALIBRATION',
          style: AppTypography.titleMedium.copyWith(
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              Text(
                'PHYSICAL FLIP TEST',
                style: AppTypography.caption.copyWith(
                  letterSpacing: 2,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Turn your device face down on a flat desk to verify sensor detection and haptic feedback.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyRegular.copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),

              // 3D Animated Phone Visualizer
              _build3DPhone(),

              const SizedBox(height: AppSpacing.xl),

              // Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(
                    color: _isFlipped ? AppColors.accent : AppColors.border,
                    width: _isFlipped ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isFlipped ? AppColors.accent : AppColors.accentAmber,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _isFlipped ? 'STATUS: FACE DOWN (ARMED)' : 'STATUS: FACE UP (WAITING)',
                          style: AppTypography.caption.copyWith(
                            color: _isFlipped ? AppColors.accent : AppColors.accentAmber,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Successful Flips: $_flipCount',
                      style: AppTypography.bodyRegular.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Manual Simulation Controls (Useful on desktop/emulator)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                ),
                onPressed: () => _handleFlipUpdate(!_isFlipped),
                icon: Icon(_isFlipped ? Icons.screen_rotation_rounded : Icons.flip_to_back_rounded, size: 18),
                label: Text(
                  _isFlipped
                      ? AppLocalizations.of(context)!.simulateFlipUp
                      : AppLocalizations.of(context)!.simulateFlipDown,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DPhone() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: _isFlipped ? math.pi : 0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutBack,
      builder: (context, rotation, child) {
        final isFront = rotation < math.pi / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateX(rotation),
          child: Container(
            width: 160,
            height: 260,
            decoration: BoxDecoration(
              color: isFront ? AppColors.surface : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isFlipped ? AppColors.accent : AppColors.border,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_isFlipped ? AppColors.accent : Colors.black).withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: isFront ? _buildPhoneFront() : _buildPhoneBack(),
          ),
        );
      },
    );
  }

  Widget _buildPhoneFront() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Spacer(),
        const Icon(Icons.touch_app_outlined, size: 40, color: AppColors.accent),
        const SizedBox(height: 8),
        Text(
          'SCREEN UP',
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildPhoneBack() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateX(math.pi),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield_rounded, size: 48, color: AppColors.accent),
          const SizedBox(height: 8),
          Text(
            'SHIELD ACTIVE',
            style: AppTypography.caption.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
