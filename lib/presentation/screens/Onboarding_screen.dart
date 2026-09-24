import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_event.dart';
import '../../data/services/onboarding_service.dart';
import '../widgets/background_ellipses.dart';
import 'Get_started_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isDarkMode;

  const OnboardingScreen({super.key, this.isDarkMode = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  Future<void> _handleGenderSelection(String? gender) async {
    if (gender != null) {
      await OnboardingService.saveOnboarding(gender: gender);

      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        try {
          await OnboardingService.saveGenderToFirestore(
            uid: authState.user.uid,
            gender: gender,
          );
        } catch (_) {}
      }
    }

    if (!mounted) return;
    final isDark = context.read<ThemeBloc>().state.isDark;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GetStartedScreen(isDarkMode: isDark),
      ),
    );
  }

  void _toggleTheme() =>
      context.read<ThemeBloc>().add(const ToggleTheme());

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    final backgroundColor = isDark ? AppColors.darkBg : AppColors.purple;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          BackgroundEllipses(isDarkMode: isDark),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: screenSize.height * 0.20,
            child: _buildModelImage(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _buildInfoCard(isDark),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: SafeArea(child: _buildThemeToggle(isDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildModelImage() {
    return Image.asset(
      'assets/model.png',
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      errorBuilder: (_, __, ___) => Center(
        child: Icon(
          Icons.person,
          size: 280,
          color: Colors.white.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    final cardColor = isDark ? AppColors.darkCard : Colors.white;
    final titleColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtitleColor =
    isDark ? Colors.white70 : AppColors.textSecondary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Look Good, Feel Good',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Create your individual & unique style and\nlook amazing everyday.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildGenderButton(
                  label: 'Men',
                  isPrimary: false,
                  isDark: isDark,
                  onTap: () => _handleGenderSelection('Men'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGenderButton(
                  label: 'Women',
                  isPrimary: true,
                  isDark: isDark,
                  onTap: () => _handleGenderSelection('Women'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () => _handleGenderSelection(null),
            child: Text(
              'Skip',
              style: TextStyle(
                fontSize: 14,
                color: subtitleColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderButton({
    required String label,
    required bool isPrimary,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    if (isPrimary) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.purple,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } else {
      final bg = isDark
          ? Colors.white.withOpacity(0.08)
          : AppColors.lightField;
      final textColor = isDark ? Colors.white70 : AppColors.textSecondary;

      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildThemeToggle(bool isDark) {
    return GestureDetector(
      onTap: _toggleTheme,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          isDark ? '🌙 Dark' : '☀️ Light',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}