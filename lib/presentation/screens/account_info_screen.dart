import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/services/profile_image_service.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_event.dart';
import '../../logic/auth/auth_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AccountInfoScreen extends StatefulWidget {
  final bool isDarkMode;
  const AccountInfoScreen({super.key, this.isDarkMode = false});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  static const Color _purple = Color(0xFF9775FA);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _dobCtrl;

  String _gender = '';
  List<String> _favoriteCategories = [];
  bool _isSaving = false;

  // Profile image
  String? _imagePath;
  bool _loadingImage = true;

  @override
  void initState() {
    super.initState();

    final auth = context.read<AuthBloc>().state;
    final user = auth is Authenticated ? auth.user : null;

    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _dobCtrl = TextEditingController(
      text: user?.dateOfBirth != null
          ? '${user!.dateOfBirth!.year}-'
          '${user.dateOfBirth!.month.toString().padLeft(2, '0')}-'
          '${user.dateOfBirth!.day.toString().padLeft(2, '0')}'
          : '',
    );
    _gender = user?.gender ?? '';
    _favoriteCategories = List<String>.from(user?.favoriteCategories ?? []);

    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is Authenticated) {
      final path = await ProfileImageService.getImagePath(auth.user.uid);
      if (!mounted) return;
      setState(() {
        _imagePath = path;
        _loadingImage = false;
      });
    } else {
      setState(() => _loadingImage = false);
    }
  }

  Future<void> _pickProfileImage() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! Authenticated) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (picked == null) return;

    final savedPath =
    await ProfileImageService.saveImage(picked.path, auth.user.uid);
    if (!mounted) return;
    setState(() => _imagePath = savedPath);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile picture updated'),
        backgroundColor: _purple,
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthBloc>().state;
    if (auth is! Authenticated) return;

    setState(() => _isSaving = true);

    try {
      DateTime? dob;
      if (_dobCtrl.text.trim().isNotEmpty) {
        dob = DateTime.tryParse(_dobCtrl.text.trim());
      }

      await context.read<AuthRepository>().updateProfile(auth.user.uid, {
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'gender': _gender,
        if (dob != null) 'dateOfBirth': dob,
        'favoriteCategories': _favoriteCategories,
      });

      if (!mounted) return;

      context.read<AuthBloc>().add(AuthUserChanged(uid: auth.user.uid));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated'),
          backgroundColor: _purple,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    final bg = isDark ? const Color(0xFF1B262C) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B262C);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF6B6B6B);
    final iconBg =
    isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF2F2F2);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header ───
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: iconBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_back,
                            color: textColor, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('Account Information',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: textColor)),
                  ],
                ),

                const SizedBox(height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // ─── Profile image (top-center) ───
                        Center(
                          child: GestureDetector(
                            onTap: _pickProfileImage,
                            child: Stack(
                              children: [
                                Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFE0E0E0),
                                    image: _imagePath != null && !_loadingImage
                                        ? DecorationImage(
                                      image: FileImage(File(_imagePath!)),
                                      fit: BoxFit.cover,
                                    )
                                        : null,
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white24
                                          : Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                  child: _imagePath == null
                                      ? const Icon(Icons.person,
                                      color: Colors.white, size: 48)
                                      : null,
                                ),
                                // Camera badge
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: _purple,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: bg, width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to change photo',
                          style: TextStyle(
                              fontSize: 12, color: subTextColor),
                        ),

                        const SizedBox(height: 28),

                        CustomTextField(
                          label: 'Full Name',
                          controller: _nameCtrl,
                          isDarkMode: isDark,
                          validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Enter your name'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        CustomTextField(
                          label: 'Email',
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          isDarkMode: isDark,
                          validator: (v) =>
                          (v == null || !v.contains('@'))
                              ? 'Enter a valid email'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        CustomTextField(
                          label: 'Phone',
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          isDarkMode: isDark,
                        ),
                        const SizedBox(height: 20),

                        _genderSelector(isDark, textColor, subTextColor),
                        const SizedBox(height: 20),

                        CustomTextField(
                          label: 'Date of Birth (YYYY-MM-DD)',
                          controller: _dobCtrl,
                          isDarkMode: isDark,
                          hintText: '1995-08-15',
                        ),
                        const SizedBox(height: 24),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Favorite Categories',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textColor)),
                        ),
                        const SizedBox(height: 12),
                        _categoryChips(isDark, textColor),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                CustomButton(
                  label: 'Save Changes',
                  isLoading: _isSaving,
                  onPressed: _isSaving ? null : _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _genderSelector(bool isDark, Color textColor, Color subTextColor) {
    Widget chip(String value) {
      final selected = _gender == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _gender = value),
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? _purple
                  : (isDark
                  ? Colors.white.withOpacity(0.06)
                  : const Color(0xFFF2F2F2)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : textColor,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender',
            style: TextStyle(fontSize: 13, color: subTextColor)),
        const SizedBox(height: 8),
        Row(
          children: [
            chip('Men'),
            const SizedBox(width: 12),
            chip('Women'),
          ],
        ),
      ],
    );
  }

  Widget _categoryChips(bool isDark, Color textColor) {
    const categories = [
      'Electronics',
      'Fashion',
      'Shoes',
      'Watches',
      'Beauty',
      'Home',
      'Sports',
      'Books',
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories.map((cat) {
        final selected = _favoriteCategories.contains(cat);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (selected) {
                _favoriteCategories.remove(cat);
              } else {
                _favoriteCategories.add(cat);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? _purple
                  : (isDark
                  ? Colors.white.withOpacity(0.06)
                  : const Color(0xFFF2F2F2)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              cat,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : textColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}