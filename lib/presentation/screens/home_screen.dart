import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laza/presentation/screens/analytics_dashboard_screen.dart';

import 'search_screen.dart';
import 'product_details_screen.dart';
import 'wishlist_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'orders_screen.dart';
import 'account_info_screen.dart';
import 'payment_screen.dart';
import 'forgot_password_screen.dart';
import 'brands_screen.dart';
import 'new_arrivals_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';

import '../../data/models/product_model.dart';
import '../../data/services/profile_image_service.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_event.dart';
import '../../logic/auth/auth_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/theme/theme_event.dart';
import '../../logic/product/product_bloc.dart';
import '../../logic/product/product_event.dart';
import '../../logic/product/product_state.dart';
import '../../logic/wishlist/wishlist_bloc.dart';
import '../../logic/wishlist/wishlist_event.dart';
import '../../logic/wishlist/wishlist_state.dart';
import '../../logic/cart/cart_bloc.dart';
import '../../logic/cart/cart_event.dart';
import '../../logic/order/order_bloc.dart';
import '../../logic/order/order_state.dart';
import 'splash_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;

  const HomeScreen({super.key, this.isDarkMode = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color _purple = Color(0xFF9775FA);

  static const List<String> _brands = ['Adidas', 'Nike', 'Fila', 'Puma'];

  @override
  void initState() {
    super.initState();

    // Load products from DummyJSON API
    context.read<ProductBloc>().add(
      const ProductsFetchRequested(limit: 20, skip: 0, refresh: true),
    );

    // Subscribe to Firestore streams if user is signed in
    final auth = context.read<AuthBloc>().state;
    if (auth is Authenticated) {
      context.read<WishlistBloc>().add(WishlistSubscribed(auth.user.uid));
      context.read<CartBloc>().add(CartSubscribed(auth.user.uid));
    }
  }

  void _openMenu() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    final backgroundColor = isDark ? const Color(0xFF1B262C) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B262C);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF6B6B6B);
    final iconBg =
    isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF2F2F2);
    final searchBg =
    isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF2F2F2);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      extendBody: true,

      // ─── LEFT SIDEBAR DRAWER ───
      drawer: const _HomeDrawer(),
      drawerScrimColor: Colors.black.withOpacity(0.25),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Top bar ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleIcon(Icons.menu, iconBg, textColor, onTap: _openMenu),
                  _circleIcon(
                    Icons.shopping_bag_outlined,
                    iconBg,
                    textColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CartScreen(isDarkMode: isDark),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ─── Greeting ───
              Text('Hello',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: textColor)),
              const SizedBox(height: 2),
              Text('Welcome to Laza.',
                  style: TextStyle(fontSize: 13, color: subTextColor)),
              const SizedBox(height: 20),

              // ─── Search bar ───
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SearchScreen(isDarkMode: isDark),
                        ),
                      ),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: searchBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: subTextColor, size: 20),
                            const SizedBox(width: 10),
                            Text('Search...',
                                style: TextStyle(
                                    color: subTextColor, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: _purple,
                        borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.mic_none,
                        color: Colors.white, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ─── Choose Brand (View All → BrandsScreen) ───
              _sectionHeader(
                'Choose Brand',
                textColor,
                subTextColor,
                onViewAll: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BrandsScreen(isDarkMode: isDark),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _brands.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final brand = _brands[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BrandsScreen(isDarkMode: isDark),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF25333A)
                              : const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          brand,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // ─── New Arrival (View All → NewArrivalsScreen) ───
              _sectionHeader(
                'New Arrival',
                textColor,
                subTextColor,
                onViewAll: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewArrivalsScreen(isDarkMode: isDark),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    if (state is ProductLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is ProductError) {
                      return _buildError(state.message, subTextColor, isDark);
                    }

                    if (state is ProductEmpty) {
                      return Center(
                        child: Text('No products found',
                            style: TextStyle(color: subTextColor)),
                      );
                    }

                    final products = state is ProductLoaded
                        ? state.products
                        : <ProductModel>[];

                    return RefreshIndicator(
                      color: _purple,
                      onRefresh: () async {
                        context.read<ProductBloc>().add(
                          const ProductsFetchRequested(refresh: true),
                        );
                      },
                      child: GridView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: products.length,
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.72,
                        ),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return _ProductCard(
                            product: product,
                            isDarkMode: isDark,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsScreen(
                                  product: product,
                                  isDarkMode: isDark,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // ─── Bottom nav ───
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _bottomIndex,
        isDarkMode: isDark,
        onItemTapped: (index) {
          setState(() => _bottomIndex = index);
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WishlistScreen(isDarkMode: isDark),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CartScreen(isDarkMode: isDark),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentScreen(isDarkMode: isDark),
              ),
            );
          }
        },
      ),
    );
  }

  // ─────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────

  /// Section header with an optional "View All" action.
  /// When [onViewAll] is null, "View All" is greyed out and non-tappable.
  Widget _sectionHeader(
      String title,
      Color textColor,
      Color subTextColor, {
        VoidCallback? onViewAll,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700, color: textColor)),
        GestureDetector(
          onTap: onViewAll,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              'View All',
              style: TextStyle(
                fontSize: 12,
                color: onViewAll == null ? subTextColor : _purple,
                fontWeight:
                onViewAll == null ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _circleIcon(IconData icon, Color bg, Color fg,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: fg, size: 20),
      ),
    );
  }

  Widget _buildError(String message, Color subTextColor, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: 56, color: subTextColor),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: subTextColor, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => context.read<ProductBloc>().add(
                const ProductsFetchRequested(refresh: true),
              ),
              child: const Text('Retry',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// LEFT SIDEBAR DRAWER — avatar taps to change image (local)
// ─────────────────────────────────────────
class _HomeDrawer extends StatefulWidget {
  const _HomeDrawer();

  @override
  State<_HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<_HomeDrawer> {
  static const Color _purple = Color(0xFF9775FA);
  static const Color _red = Color(0xFFE84C4C);

  String? _imagePath;
  bool _loadingImage = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
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

  Future<void> _pickImage() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! Authenticated) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (picked == null) return;

    final saved =
    await ProfileImageService.saveImage(picked.path, auth.user.uid);

    if (!mounted) return;
    setState(() => _imagePath = saved);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile picture updated'),
        backgroundColor: _purple,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    final authState = context.watch<AuthBloc>().state;

    final userName =
    authState is Authenticated && authState.user.name.isNotEmpty
        ? authState.user.name
        : 'Mrh Raju';

    final bgColor = isDark ? const Color(0xFF25333A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B262C);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF6B6B6B);
    final iconBg =
    isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF2F2F2);

    return Drawer(
      backgroundColor: bgColor,
      elevation: 8,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      width: MediaQuery.of(context).size.width * 0.72,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Tune icon → Profile ───
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 20, 0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(isDarkMode: isDark),
                    ),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration:
                  BoxDecoration(color: iconBg, shape: BoxShape.circle),
                  child: Icon(Icons.tune, size: 18, color: textColor),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── User info row ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE0E0E0),
                            border: Border.all(
                              color:
                              isDark ? Colors.white24 : Colors.white,
                              width: 1.5,
                            ),
                          ),
                          child: (_imagePath != null && !_loadingImage)
                              ? Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                          )
                              : const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: _purple,
                              shape: BoxShape.circle,
                              border: Border.all(color: bgColor, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              'Verified Profile',
                              style: TextStyle(
                                  fontSize: 11, color: subTextColor),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.check_circle,
                                color: Color(0xFF4CAF50), size: 12),
                          ],
                        ),
                      ],
                    ),
                  ),
                  BlocBuilder<OrderBloc, OrderState>(
                    builder: (context, orderState) {
                      final count = orderState is OrderLoaded
                          ? orderState.orders.length
                          : 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.08)
                              : const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count Orders',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ─── Menu items ───
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _drawerItem(
                      context,
                      icon: Icons.wb_sunny_outlined,
                      label: 'Dark Mode',
                      textColor: textColor,
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: isDark,
                          activeColor: _purple,
                          materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                          onChanged: (_) {
                            context
                                .read<ThemeBloc>()
                                .add(const ToggleTheme());
                          },
                        ),
                      ),
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.info_outline,
                      label: 'Account Information',
                      textColor: textColor,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AccountInfoScreen(isDarkMode: isDark),
                          ),
                        );
                      },
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.lock_outline,
                      label: 'Password',
                      textColor: textColor,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ForgotPasswordScreen(isDarkMode: isDark),
                          ),
                        );
                      },
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.shopping_bag_outlined,
                      label: 'Order',
                      textColor: textColor,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                OrdersScreen(isDarkMode: isDark),
                          ),
                        );
                      },
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.credit_card,
                      label: 'My Cards',
                      textColor: textColor,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PaymentScreen(isDarkMode: isDark),
                          ),
                        );
                      },
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.favorite_border,
                      label: 'Wishlist',
                      textColor: textColor,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                WishlistScreen(isDarkMode: isDark),
                          ),
                        );
                      },
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.analytics_outlined,
                      label: 'Analytics',
                      textColor: textColor,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnalyticsDashboardScreen(isDarkMode: isDark),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ─── Logout ───
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
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
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: _red, size: 20),
                    const SizedBox(width: 12),
                    const Text(
                      'Logout',
                      style: TextStyle(
                        color: _red,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
      BuildContext context, {
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
          Icon(icon, size: 20, color: textColor.withOpacity(0.85)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          if (trailing != null) trailing,
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

// ─────────────────────────────────────────
// Product card — API-driven + Firestore wishlist
// ─────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1B262C);
    final subTextColor =
    isDarkMode ? Colors.white70 : const Color(0xFF6B6B6B);
    final imageBg =
    isDarkMode ? const Color(0xFF25333A) : const Color(0xFFF6F6F6);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: imageBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      product.thumbnail,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: subTextColor,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.checkroom,
                        size: 48,
                        color: subTextColor,
                      ),
                    ),
                  ),
                ),

                // Wishlist heart (Firestore-backed)
                Positioned(
                  top: 8,
                  right: 8,
                  child: BlocBuilder<WishlistBloc, WishlistState>(
                    builder: (context, ws) {
                      final isWishlisted = ws is WishlistLoaded &&
                          ws.items.any((w) => w.productId == product.id);

                      return GestureDetector(
                        onTap: () {
                          final auth = context.read<AuthBloc>().state;
                          if (auth is! Authenticated) return;
                          if (isWishlisted) {
                            context.read<WishlistBloc>().add(
                              WishlistRemoveRequested(
                                  auth.user.uid, product.id),
                            );
                          } else {
                            context.read<WishlistBloc>().add(
                              WishlistAddRequested(
                                  auth.user.uid, product),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color: isWishlisted
                                ? Colors.redAccent
                                : subTextColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${product.price.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 13,
              color: subTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}