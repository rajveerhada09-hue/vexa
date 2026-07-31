// lib/features/onboarding/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';

/// Premium splash screen for Vexa Voice.
/// - Pure black background
/// - Logo fades in over ~1.2s
/// - "Powered by Avento" appears slightly after
/// - Total duration 2.0s then navigates to onboarding
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _poweredByFade;

  @override
  void initState() {
    super.initState();

    // Force dark system UI for the entire splash
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Logo: fade + subtle scale (0 → 1) from 0ms → 1200ms
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.60, curve: Curves.easeOutCubic),
    );

    _logoScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.60, curve: Curves.easeOutCubic),
      ),
    );

    // "Powered by Avento" fades in later (800ms → 1600ms)
    _poweredByFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.40, 0.80, curve: Curves.easeOut),
    );

    _controller.forward();

    // Navigate after full 2 seconds
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        // Replace with your actual onboarding route
        // Example with named routes:
        // Navigator.of(context).pushReplacementNamed('/onboarding');
        //
        // Or with go_router:
        // context.go('/onboarding');
        //
        // Temporary placeholder until routes are wired:
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const _OnboardingPlaceholder(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Logo ──────────────────────────────────────────
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: const _VexaLogo(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Powered by ────────────────────────────────────
                  FadeTransition(
                    opacity: _poweredByFade,
                    child: Text(
                      'Powered by Avento',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textTertiary,
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Clean, premium wordmark. Replace with Image.asset when you have the real logo.
class _VexaLogo extends StatelessWidget {
  const _VexaLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Optional logo mark (simple geometric for now)
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.35),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.graphic_eq_rounded, // replace with your logo icon later
            size: 28,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Vexa',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -1.2,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Voice',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 3.5,
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

/// Temporary placeholder so the splash can navigate.
/// Delete this class once real onboarding screen exists.
class _OnboardingPlaceholder extends StatelessWidget {
  const _OnboardingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Onboarding Screen\n(replace this)',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}