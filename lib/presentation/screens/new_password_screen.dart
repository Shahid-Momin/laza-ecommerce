import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../logic/theme/theme_bloc.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'login_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  final bool isDarkMode;
  final String email;

  const NewPasswordScreen({
    super.key,
    this.isDarkMode = false,
    this.email = '',
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Check your email for the reset link, then return to login.',
        ),
        backgroundColor: AppColors.purple,
        duration: Duration(seconds: 4),
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(isDarkMode: widget.isDarkMode),
      ),
          (route) => false,
    );
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
        child: Padding(
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
                    child: Icon(Icons.arrow_back, color: textColor, size: 20),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'New Password',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 56),
                CustomTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                  showObscureToggle: true,
                  isDarkMode: isDark,
                  validator: (v) =>
                  (v == null || v.length < 6) ? 'Min. 6 characters' : null,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Confirm Password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  showObscureToggle: true,
                  isDarkMode: isDark,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Confirm your password';
                    }
                    if (v != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const Spacer(),
                Center(
                  child: Text(
                    'Please write your new password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: subTextColor),
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  label: 'Reset Password',
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _handleResetPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}