import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/onboarding_service.dart';
import '../../logic/theme/theme_bloc.dart';
import '../widgets/custom_button.dart';
import 'home_screen.dart';

class InterestsScreen extends StatefulWidget {
  final bool isDarkMode;
  final String userId;

  const InterestsScreen({
    super.key,
    this.isDarkMode = false,
    required this.userId,
  });

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  static const List<Map<String, dynamic>> _categories = [
    {'label': 'Electronics', 'icon': Icons.devices},
    {'label': 'Fashion', 'icon': Icons.checkroom},
    {'label': 'Shoes', 'icon': Icons.directions_walk},
    {'label': 'Watches', 'icon': Icons.watch},
    {'label': 'Beauty', 'icon': Icons.spa},
    {'label': 'Home', 'icon': Icons.home_outlined},
    {'label': 'Sports', 'icon': Icons.sports_basketball},
    {'label': 'Books', 'icon': Icons.menu_book},
    {'label': 'Toys', 'icon': Icons.toys},

  ];

  final Set<String> _selected = {};
  bool _isSaving = false;

  void _toggle(String label) {
    setState(() {
      if (_selected.contains(label)) {
        _selected.remove(label);
      } else {
        _selected.add(label);
      }
    });
  }

  Future<void> _handleContinue() async {
    if (_selected.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least 3 interests')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await context.read<AuthRepository>().saveFavoriteCategories(
        widget.userId,
        _selected.toList(),
      );

      await OnboardingService.saveInterestsDone();

      if (!mounted) return;
      final isDark = context.read<ThemeBloc>().state.isDark;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(isDarkMode: isDark)),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Your Interests',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick 3–5 categories so we can personalize your feed.',
                style: TextStyle(fontSize: 13, color: subTextColor),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _categories.map((cat) {
                    final bool selected = _selected.contains(cat['label']);
                    return GestureDetector(
                      onTap: () => _toggle(cat['label']),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.purple
                              : (isDark
                              ? Colors.white.withOpacity(0.06)
                              : AppColors.lightField),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat['icon'] as IconData,
                              size: 16,
                              color: selected ? Colors.white : textColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              cat['label'],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: 'Continue (${_selected.length} selected)',
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _handleContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}