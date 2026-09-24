import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_event.dart';
import '../../logic/auth/auth_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../data/services/onboarding_service.dart';
import '../../data/services/remember_me_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'forgot_password_screen.dart';
import 'interests_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool isDarkMode;

  const LoginScreen({super.key, this.isDarkMode = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final remember = await RememberMeService.isRememberMeOn();
    if (!mounted) return;

    if (remember) {
      final email = await RememberMeService.getSavedEmail();
      final password = await RememberMeService.getSavedPassword();
      if (!mounted) return;

      setState(() {
        _rememberMe = true;
        if (email != null) _usernameController.text = email;
        if (password != null) _passwordController.text = password;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      AuthSignInRequested(
        email: _usernameController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _handleForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ForgotPasswordScreen(isDarkMode: widget.isDarkMode),
      ),
    );
  }

  Future<void> _afterAuthSuccess(
      BuildContext context,
      String uid,
      bool isDark,
      ) async {
    // Save or clear credentials based on the toggle
    if (_rememberMe) {
      await RememberMeService.saveCredentials(
        email: _usernameController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      await RememberMeService.clearCredentials();
    }

    final interestsDone = await OnboardingService.isInterestsDone();
    if (!context.mounted) return;

    if (interestsDone) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(isDarkMode: isDark)),
            (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => InterestsScreen(
            isDarkMode: isDark,
            userId: uid,
          ),
        ),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    final backgroundColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subTextColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final backButtonBg =
    isDark ? Colors.white.withOpacity(0.08) : AppColors.lightField;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) async {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }

            if (state is Authenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Login successful!'),
                  backgroundColor: AppColors.purple,
                ),
              );
              await _afterAuthSuccess(context, state.user.uid, isDark);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: backButtonBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_back,
                            color: textColor, size: 20),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text('Welcome',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: textColor)),
                    const SizedBox(height: 6),
                    Text('Please enter your data to continue',
                        style: TextStyle(
                            fontSize: 13, color: subTextColor)),
                    const SizedBox(height: 40),

                    // Email / Username
                    CustomTextField(
                      label: 'Username',
                      controller: _usernameController,
                      keyboardType: TextInputType.emailAddress,
                      isDarkMode: isDark,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter your email'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Password
                    CustomTextField(
                      label: 'Password',
                      controller: _passwordController,
                      obscureText: true,
                      showObscureToggle: true,
                      isDarkMode: isDark,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Enter your password'
                          : null,
                      trailing: GestureDetector(
                        onTap: _handleForgotPassword,
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ─── Remember Me (now functional) ───
                    Row(
                      children: [
                        Text('Remember me',
                            style: TextStyle(
                                fontSize: 14, color: textColor)),
                        const Spacer(),
                        Switch(
                          value: _rememberMe,
                          activeColor: AppColors.purple,
                          onChanged: (v) async {
                            setState(() => _rememberMe = v);
                            if (!v) {
                              // Clear immediately when toggled off
                              await RememberMeService.clearCredentials();
                            }
                          },
                        ),
                      ],
                    ),

                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'By connecting your account confirm that you agree with our '
                            'Term and Condition',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: subTextColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                    CustomButton(
                      label: 'Login',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _handleLogin,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}