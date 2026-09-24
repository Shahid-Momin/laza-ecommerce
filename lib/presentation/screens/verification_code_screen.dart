import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_event.dart';
import '../../logic/theme/theme_bloc.dart';
import '../widgets/custom_button.dart';
import 'new_password_screen.dart';

class VerificationCodeScreen extends StatefulWidget {
  final bool isDarkMode;
  final String email;

  const VerificationCodeScreen({
    super.key,
    this.isDarkMode = false,
    this.email = '',
  });

  @override
  State<VerificationCodeScreen> createState() =>
      _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  static const int _codeLength = 4;
  static const int _resendSeconds = 20;

  final List<TextEditingController> _controllers =
  List.generate(_codeLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(_codeLength, (_) => FocusNode());

  Timer? _timer;
  int _secondsLeft = _resendSeconds;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _formattedTime {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get _enteredCode => _controllers.map((c) => c.text).join();

  void _handleResend() {
    if (_secondsLeft > 0) return;
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
    _startResendTimer();

    context.read<AuthBloc>().add(
      AuthPasswordResetRequested(email: widget.email),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reset email sent again')),
    );
  }

  void _handleConfirmCode() {
    if (_enteredCode.length != _codeLength) return;

    final isDark = context.read<ThemeBloc>().state.isDark;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewPasswordScreen(
          isDarkMode: isDark,
          email: widget.email,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    final backgroundColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subTextColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final backButtonBg =
    isDark ? Colors.white.withOpacity(0.08) : AppColors.lightField;
    final bool canResend = _secondsLeft == 0;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
                  'Verification Code',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Sent to ${widget.email}',
                  style: TextStyle(fontSize: 12, color: subTextColor),
                ),
              ),
              const SizedBox(height: 36),
              Center(child: _buildCloudLockIllustration()),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_codeLength, (index) {
                  return _OtpBox(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    isDarkMode: isDark,
                    onChanged: (value) {
                      if (value.isNotEmpty && index < _codeLength - 1) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                      setState(() {});
                    },
                  );
                }),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: canResend ? _handleResend : null,
                  child: Text(
                    canResend
                        ? 'Resend confirmation code'
                        : '$_formattedTime resend confirmation code.',
                    style: TextStyle(
                      fontSize: 12,
                      color: canResend ? AppColors.purple : subTextColor,
                      fontWeight:
                      canResend ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              CustomButton(
                label: 'Confirm Code',
                onPressed: _enteredCode.length == _codeLength
                    ? _handleConfirmCode
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCloudLockIllustration() {
    return SizedBox(
      width: 160,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.cloud,
            size: 140,
            color: AppColors.purple.withOpacity(0.9),
          ),
          Positioned(
            bottom: 10,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.amber,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.lock,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDarkMode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.isDarkMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final boxBg =
    isDarkMode ? Colors.white.withOpacity(0.06) : AppColors.lightField;
    final textColor =
    isDarkMode ? Colors.white : AppColors.textPrimary;

    return SizedBox(
      width: 60,
      height: 60,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: boxBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.purple,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}