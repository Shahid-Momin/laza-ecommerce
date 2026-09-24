import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import '../../logic/review/review_bloc.dart';
import '../../logic/review/review_event.dart';
import '../../logic/theme/theme_bloc.dart';
import '../widgets/custom_button.dart';

class AddReviewScreen extends StatefulWidget {
  final bool isDarkMode;
  final int productId;

  const AddReviewScreen({
    super.key,
    this.isDarkMode = false,
    required this.productId,
  });

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  static const Color _purple = Color(0xFF9775FA);

  final _nameController = TextEditingController();
  final _experienceController = TextEditingController();
  double _rating = 2.5;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Prefill name from signed-in user
    final auth = context.read<AuthBloc>().state;
    if (auth is Authenticated) {
      _nameController.text = auth.user.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_nameController.text.trim().isEmpty ||
        _experienceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in your name and experience.')),
      );
      return;
    }

    final auth = context.read<AuthBloc>().state;
    if (auth is! Authenticated) return;

    setState(() => _isSubmitting = true);

    context.read<ReviewBloc>().add(
      ReviewSubmitRequested(
        productId: widget.productId,
        uid: auth.user.uid,
        name: _nameController.text.trim(),
        text: _experienceController.text.trim(),
        rating: _rating,
      ),
    );

    // Give the bloc a moment to write
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    final bg = isDark ? const Color(0xFF1B262C) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B262C);
    final labelColor =
    isDark ? Colors.white60 : const Color(0xFF9B9B9B);
    final subTextColor =
    isDark ? Colors.white70 : const Color(0xFF6B6B6B);
    final iconBg =
    isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF2F2F2);
    final fieldBg =
    isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF2F2F2);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: iconBg, shape: BoxShape.circle),
                      child: Icon(Icons.arrow_back,
                          color: textColor, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('Add Review',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: textColor)),
                ],
              ),

              const SizedBox(height: 28),

              Text('Name',
                  style: TextStyle(fontSize: 12, color: labelColor)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: TextStyle(color: textColor, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Type your name',
                  hintStyle: TextStyle(color: labelColor),
                  filled: true,
                  fillColor: fieldBg,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 20),

              Text('How was your experience ?',
                  style: TextStyle(fontSize: 12, color: labelColor)),
              const SizedBox(height: 8),
              TextField(
                controller: _experienceController,
                maxLines: 5,
                style: TextStyle(color: textColor, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Describe your experience?',
                  hintStyle: TextStyle(color: labelColor),
                  filled: true,
                  fillColor: fieldBg,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none),
                ),
              ),

              const Spacer(),

              Text('Star',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
              const SizedBox(height: 4),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _purple,
                  inactiveTrackColor: fieldBg,
                  thumbColor: _purple,
                  overlayColor: _purple.withOpacity(0.15),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _rating,
                  min: 0.0,
                  max: 5.0,
                  divisions: 50,
                  onChanged: (v) => setState(() => _rating = v),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0.0',
                      style:
                      TextStyle(fontSize: 11, color: subTextColor)),
                  Text('5.0',
                      style:
                      TextStyle(fontSize: 11, color: subTextColor)),
                ],
              ),

              const SizedBox(height: 20),

              CustomButton(
                label: 'Submit Review',
                isLoading: _isSubmitting,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}