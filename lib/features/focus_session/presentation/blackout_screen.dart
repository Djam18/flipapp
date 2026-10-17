import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/focus_session_state.dart';
import 'focus_session_controller.dart';

/// Full-screen OLED True Blackout mode.
/// Completely deactivates OLED pixels (RGB #000000) during deep focus to eliminate
/// battery consumption and screen glare while resting face-down.
class BlackoutScreen extends ConsumerStatefulWidget {
  const BlackoutScreen({super.key});

  @override
  ConsumerState<BlackoutScreen> createState() => _BlackoutScreenState();
}

class _BlackoutScreenState extends ConsumerState<BlackoutScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // System UI immersive mode (hide navigation and status bars)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.1, end: 0.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // Restore normal system overlays
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(focusSessionProvider);

    // Auto-dismiss if session is no longer in focusing or arming state
    if (sessionState.status != SessionStatus.focusing &&
        sessionState.status != SessionStatus.arming) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }

    final elapsedSeconds = sessionState.elapsedSeconds;
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.black, // Pure OLED black #000000
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Faint breathing indicator dot
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent.withValues(alpha: _pulseAnimation.value),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: _pulseAnimation.value * 0.5),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Subtle, low-contrast elapsed counter
              Text(
                timeStr,
                style: GoogleFonts.jetBrainsMono(
                  color: Colors.white12, // Very low luminance to preserve darkness
                  fontSize: 28,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.restingFaceDown,
                style: AppTypography.caption.copyWith(
                  color: Colors.white10,
                  letterSpacing: 2,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
