import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../data/services/onboarding_service.dart';
import 'Onboarding_screen.dart';
import 'Get_started_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  static const double _logoWidth = 59.000003814697266;
  static const double _logoHeight = 36.00094985961914;
  static const Color _lightBgColor = Color(0xFF9775FA);
  static const Color _darkBgColor = Color(0xFF1B262C);

  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Wait 3 seconds, then navigate based on auth + onboarding state
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      _decideNextScreen();
    });
  }

  Future<void> _decideNextScreen() async {
    if (_navigated || !mounted) return;

    final authState = context.read<AuthBloc>().state;
    final isDark = context.read<ThemeBloc>().state.isDark;

    // If AuthBloc is still loading, wait a bit more and re-check
    if (authState is AuthLoading || authState is AuthInitial) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      _decideNextScreen();
      return;
    }

    _navigated = true;

    // 1. Logged in → Home
    if (authState is Authenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(isDarkMode: isDark)),
      );
      return;
    }

    // 2. Not logged in — check onboarding flag
    final onboardingDone = await OnboardingService.isOnboardingDone();
    if (!mounted) return;

    if (onboardingDone) {
      // Gender already picked → skip Onboarding → Get Started
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GetStartedScreen(isDarkMode: isDark),
        ),
      );
    } else {
      // First-time user → Onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OnboardingScreen(isDarkMode: isDark),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.watch<ThemeBloc>().state.isDark;
    final Color backgroundColor = isDark ? _darkBgColor : _lightBgColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Centered logo
          Center(
            child: _buildLogo(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return SizedBox(
      width: _logoWidth,
      height: _logoHeight,
      child: Opacity(
        opacity: 1.0,
        child: Transform.rotate(
          angle: 0.0,
          child: Image.asset(
            // Switch image based on mode
            isDark
                ? 'assets/logo/logo_dark.png'
                : 'assets/logo/logo_light.png',
            width: _logoWidth,
            height: _logoHeight,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderLogo(isDark);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderLogo(bool isDark) {
    return Container(
      width: _logoWidth,
      height: _logoHeight,
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? Colors.white70 : const Color(0xFF9775FA),
          width: 1.2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        isDark ? 'DARK' : 'LIGHT',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF9775FA),
        ),
      ),
    );
  }
}

