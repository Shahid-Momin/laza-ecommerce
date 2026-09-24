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
import 'interests_screen.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  final bool isDarkMode;

  const SignUpScreen({super.key, this.isDarkMode = false});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    final remember = await RememberMeService.isRememberMeOn();
    if (!mounted) return;

    if (remember) {
      final email = await RememberMeService.getSavedEmail();
      final password = await RememberMeService.getSavedPassword();
      if (!mounted) return;
      setState(() {
        _rememberMe = true;
        if (email != null) _emailController.text = email;
        if (password != null) _passwordController.text = password;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      AuthSignUpRequested(
        name: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
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
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      await RememberMeService.clearCredentials();
    }

    // Save gender to Firestore if it was picked during onboarding
    final gender = await OnboardingService.getLocalGender() ?? '';
    if (gender.isNotEmpty) {
      await OnboardingService.saveGenderToFirestore(
        uid: uid,
        gender: gender,
      );
    }

    // Has the user already seen the Interests screen?
    final interestsDone = await OnboardingService.isInterestsDone();
    if (!context.mounted) return;

    if (interestsDone) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(isDarkMode: isDark),
        ),
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
                  content: Text('Account created successfully!'),
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
                    // ─── Back button ───
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

                    Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ─── Username ───
                    CustomTextField(
                      label: 'Username',
                      controller: _usernameController,
                      isDarkMode: isDark,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter a username'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // ─── Password ───
                    CustomTextField(
                      label: 'Password',
                      controller: _passwordController,
                      obscureText: true,
                      showObscureToggle: true,
                      isDarkMode: isDark,
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Min. 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // ─── Email ───
                    CustomTextField(
                      label: 'Email Address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      isDarkMode: isDark,
                      validator: (v) =>
                      (v == null || !v.contains('@'))
                          ? 'Enter a valid email'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // ─── Remember Me (functional) ───
                    Row(
                      children: [
                        Text(
                          'Remember me',
                          style: TextStyle(fontSize: 14, color: textColor),
                        ),
                        const Spacer(),
                        Switch(
                          value: _rememberMe,
                          activeColor: AppColors.purple,
                          onChanged: (v) async {
                            setState(() => _rememberMe = v);
                            if (!v) {
                              await RememberMeService.clearCredentials();
                            }
                          },
                        ),
                      ],
                    ),

                    const Spacer(),

                    // ─── Already have an account ───
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
                            onTap: () => Navigator.pop(context),
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

                    // ─── Sign Up button ───
                    CustomButton(
                      label: 'Sign Up',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _handleSignUp,
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