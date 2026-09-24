import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product_model.dart';
import '../../data/models/wishlist_item_model.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/wishlist/wishlist_bloc.dart';
import '../../logic/wishlist/wishlist_event.dart';
import '../../logic/wishlist/wishlist_state.dart';
import 'cart_screen.dart';
import 'product_details_screen.dart';

class WishlistScreen extends StatefulWidget {
  final bool isDarkMode;
  const WishlistScreen({super.key, this.isDarkMode = false});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {


  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    if (auth is Authenticated) {
      final uid = auth.user.uid;
      final current = context.read<WishlistBloc>().state;
      if (current is! WishlistLoaded) {
        context.read<WishlistBloc>().add(WishlistSubscribed(uid));
      }
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  _circleIcon(
                    Icons.arrow_back,
                    iconBg,
                    textColor,
                        () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Wishlist',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  _circleIcon(
                    Icons.shopping_bag_outlined,
                    iconBg,
                    textColor,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CartScreen(isDarkMode: isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BlocBuilder<WishlistBloc, WishlistState>(
                builder: (context, state) {
                  final count =
                  state is WishlistLoaded ? state.items.length : 0;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$count Items',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'in wishlist',
                            style: TextStyle(
                                fontSize: 13, color: subTextColor),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : const Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined,
                                  color: textColor, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: BlocBuilder<WishlistBloc, WishlistState>(
                builder: (context, state) {
                  if (state is WishlistLoading || state is WishlistInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is WishlistError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                size: 56, color: subTextColor),
                            const SizedBox(height: 12),
                            Text(state.message,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: subTextColor)),
                          ],
                        ),
                      ),
                    );
                  }

                  final items =
                  state is WishlistLoaded ? state.items : <WishlistItemModel>[];

                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite_border,
                              size: 72,
                              color: subTextColor.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'Your wishlist is empty',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap the heart on any product to save it here.',
                            style: TextStyle(fontSize: 12, color: subTextColor),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: items.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return _WishlistCard(
                        item: item,
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        onTap: () {
                          // Convert WishlistItemModel → ProductModel for details
                          final product = ProductModel(
                            id: item.productId,
                            title: item.title,
                            description: '',
                            category: '',
                            price: item.price,
                            brand: item.brand,
                            thumbnail: item.thumbnail,
                            images: [item.thumbnail],
                            rating: item.rating,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsScreen(
                                product: product,
                                isDarkMode: isDark,
                              ),
                            ),
                          );
                        },
                        onRemove: () {
                          final auth = context.read<AuthBloc>().state;
                          if (auth is! Authenticated) return;
                          context.read<WishlistBloc>().add(
                            WishlistRemoveRequested(
                                auth.user.uid, item.productId),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable circular icon button

  Widget _circleIcon(
      IconData icon,
      Color bg,
      Color fg,
      VoidCallback onTap,
      ) {
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
}

// Wishlist grid card
class _WishlistCard extends StatelessWidget {
  final WishlistItemModel item;
  final bool isDark;
  final Color textColor;
  final Color subTextColor;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _WishlistCard({
    required this.item,
    required this.isDark,
    required this.textColor,
    required this.subTextColor,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final imageBg =
    isDark ? const Color(0xFF25333A) : const Color(0xFFF6F6F6);

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
                      item.thumbnail,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
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

                // Filled heart — tap to remove from Firestore
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        size: 16,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${item.price.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}