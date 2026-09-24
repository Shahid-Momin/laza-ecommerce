import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_event.dart';
import '../../logic/auth/auth_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../widgets/custom_button.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'sign_up_screen.dart';

class GetStartedScreen extends StatelessWidget {
  final bool isDarkMode;

  const GetStartedScreen({super.key, this.isDarkMode = false});

  void _handleGoogleSignIn(BuildContext context) {
    context.read<AuthBloc>().add(const AuthGoogleSignInRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    final backgroundColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subTextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }

            if (state is Authenticated) {
              // Route straight to Home after Google sign-in
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => HomeScreen(isDarkMode: isDark),
                ),
                    (route) => false,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    "Let's Get Started",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const Spacer(flex: 3),

                  // ─── Facebook (placeholder) ───
                  _SocialButton(
                    label: 'Facebook',
                    icon: Icons.facebook,
                    color: AppColors.facebook,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                          Text('Facebook sign-in — coming soon'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  // ─── Twitter (placeholder) ───
                  _SocialButton(
                    label: 'Twitter',
                    icon: Icons.alternate_email,
                    color: AppColors.twitter,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                          Text('Twitter sign-in — coming soon'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  // ─── Google (functional) ───
                  _SocialButton(
                    label: 'Google',
                    icon: Icons.g_mobiledata,
                    color: AppColors.google,
                    isLoading: isLoading,
                    onTap: isLoading
                        ? null
                        : () => _handleGoogleSignIn(context),
                  ),

                  const Spacer(flex: 5),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                              fontSize: 13, color: subTextColor),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LoginScreen(isDarkMode: isDark),
                            ),
                          ),
                          child: const Text(
                            'Signin',
                            style: TextStyle(
                              color: AppColors.purple,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    label: 'Create an Account',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SignUpScreen(isDarkMode: isDark),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Social button (with loading state)
// ─────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isLoading;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onTap,
        icon: isLoading
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: Colors.white,
          ),
        )
            : Icon(icon, color: Colors.white, size: 20),
        label: Text(
          isLoading ? 'Signing in...' : label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color.withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}