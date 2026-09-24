import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/services/profile_image_service.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_event.dart';
import '../../logic/auth/auth_state.dart';
import '../../logic/order/order_bloc.dart';

import '../../logic/order/order_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_event.dart';
import 'account_info_screen.dart';
import 'orders_screen.dart';
import 'payment_screen.dart';
import 'splash_screen.dart';
import 'wishlist_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isDarkMode;

  const ProfileScreen({super.key, this.isDarkMode = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _purple = Color(0xFF9775FA);
  static const Color _red = Color(0xFFE84C4C);

  String? _imagePath;
  bool _loadingImage = true;

  @override
  void initState() {
    super.initState();
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

    final savedPath = await ProfileImageService.saveImage(
      picked.path,
      auth.user.uid,
    );
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
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    final authState = context.watch<AuthBloc>().state;

    String userName = 'Guest';
    String userEmail = '';
    if (authState is Authenticated) {
      userName = authState.user.name.isNotEmpty ? authState.user.name : 'User';
      userEmail = authState.user.email;
    }

    final bg = isDark ? const Color(0xFF1B262C) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B262C);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF6B6B6B);
    final iconBg =
    isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF2F2F2);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: iconBg, shape: BoxShape.circle),
                child: Icon(Icons.tune, color: textColor, size: 20),
              ),
              const SizedBox(height: 24),

              // User Info Header
              Row(
                children: [
                  // Tappable avatar
                  GestureDetector(
                    onTap: _pickProfileImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
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
                              color: isDark ? Colors.white24 : Colors.white,
                              width: 2,
                            ),
                          ),
                          child: _imagePath == null
                              ? const Icon(Icons.person,
                              color: Colors.white, size: 30)
                              : null,
                        ),
                        // Small camera badge on bottom-right
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: _purple,
                              shape: BoxShape.circle,
                              border: Border.all(color: bg, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            )),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                userEmail.isNotEmpty
                                    ? userEmail
                                    : 'Verified Profile',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12, color: subTextColor),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified,
                                color: _purple, size: 14),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Orders badge — real count from OrderBloc
                  BlocBuilder<OrderBloc, OrderState>(
                    builder: (context, orderState) {
                      final count = orderState is OrderLoaded
                          ? orderState.orders.length
                          : 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count Orders',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Menu
              _menuItem(
                icon: Icons.light_mode_outlined,
                label: 'Dark Mode',
                textColor: textColor,
                trailing: Switch(
                  value: isDark,
                  activeColor: _purple,
                  onChanged: (_) {
                    context.read<ThemeBloc>().add(const ToggleTheme());
                  },
                ),
              ),
              _menuItem(
                icon: Icons.info_outline,
                label: 'Account Information',
                textColor: textColor,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AccountInfoScreen(isDarkMode: isDark),
                  ),
                ),
              ),
              _menuItem(
                icon: Icons.lock_outline,
                label: 'Password',
                textColor: textColor,
                onTap: () {
                  // TODO: Change password screen
                },
              ),
              _menuItem(
                icon: Icons.shopping_bag_outlined,
                label: 'Order',
                textColor: textColor,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrdersScreen(isDarkMode: isDark),
                  ),
                ),
              ),
              _menuItem(
                icon: Icons.credit_card,
                label: 'My Cards',
                textColor: textColor,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentScreen(isDarkMode: isDark),
                  ),
                ),
              ),
              _menuItem(
                icon: Icons.favorite_border,
                label: 'Wishlist',
                textColor: textColor,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WishlistScreen(isDarkMode: isDark),
                  ),
                ),
              ),
              _menuItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                textColor: textColor,
                onTap: () {
                  // TODO: Settings screen
                },
              ),

              const SizedBox(height: 40),

              // Logout
              TextButton.icon(
                onPressed: () {
                  context
                      .read<AuthBloc>()
                      .add(const AuthSignOutRequested());
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (!context.mounted) return;
                    Navigator.of(context, rootNavigator: true)
                        .pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const SplashScreen(),
                      ),
                          (route) => false,
                    );
                  });
                },
                icon: const Icon(Icons.logout, color: _red, size: 20),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    color: _red,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required Color textColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: textColor.withOpacity(0.85), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          if (trailing != null)
            trailing
          else
            Icon(
              Icons.chevron_right,
              color: textColor.withOpacity(0.4),
              size: 20,
            ),
        ],
      ),
    );

    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: row,
    );
  }
}