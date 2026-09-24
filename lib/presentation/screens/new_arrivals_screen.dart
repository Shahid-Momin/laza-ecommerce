import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product_model.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import '../../logic/product/product_bloc.dart';
import '../../logic/product/product_event.dart';
import '../../logic/product/product_state.dart';
import '../../logic/theme/theme_bloc.dart';
import '../../logic/wishlist/wishlist_bloc.dart';
import '../../logic/wishlist/wishlist_event.dart';
import '../../logic/wishlist/wishlist_state.dart';
import 'cart_screen.dart';
import 'product_details_screen.dart';

enum SortOption {
  defaultOrder('Default'),
  priceLowHigh('Price: Low → High'),
  priceHighLow('Price: High → Low'),
  ratingHighLow('Rating: High → Low'),
  titleAToZ('Name: A → Z');

  final String label;
  const SortOption(this.label);
}

class NewArrivalsScreen extends StatefulWidget {
  final bool isDarkMode;
  const NewArrivalsScreen({super.key, this.isDarkMode = false});

  @override
  State<NewArrivalsScreen> createState() => _NewArrivalsScreenState();
}

class _NewArrivalsScreenState extends State<NewArrivalsScreen> {
  static const Color _purple = Color(0xFF9775FA);
  static const int _pageSize = 20;

  final ScrollController _scroll = ScrollController();

  final List<ProductModel> _products = [];
  bool _hasMore = true;
  bool _loadingMore = false;
  bool _firstLoad = true;

  SortOption _sortOption = SortOption.defaultOrder;

  int get _totalCount => _products.length;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(
      const ProductsFetchRequested(
        limit: _pageSize,
        skip: 0,
        refresh: true,
      ),
    );
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >=
        _scroll.position.maxScrollExtent - 400) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    context.read<ProductBloc>().add(
      ProductsFetchRequested(
        limit: _pageSize,
        skip: _products.length,
        refresh: false,
      ),
    );
  }

  /// Applies the current [_sortOption] to [_products] in place.
  void _applySort() {
    switch (_sortOption) {
      case SortOption.defaultOrder:
      // Sort by id so pagination appends in a stable order
        _products.sort((a, b) => a.id.compareTo(b.id));
        break;
      case SortOption.priceLowHigh:
        _products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighLow:
        _products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.ratingHighLow:
        _products.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.titleAToZ:
        _products.sort((a, b) =>
            a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _products.clear();
      _hasMore = true;
      _loadingMore = false;
      _firstLoad = true;
    });
    context.read<ProductBloc>().add(
      const ProductsFetchRequested(
        limit: _pageSize,
        skip: 0,
        refresh: true,
      ),
    );
  }

  /// Shows a bottom sheet to pick sort option.
  void _showSortOptions() {
    final isDark = context.read<ThemeBloc>().state.isDark;
    final sheetBg = isDark ? const Color(0xFF25333A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B262C);

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: textColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sort by',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                ...SortOption.values.map((option) {
                  final isSelected = _sortOption == option;
                  return InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _sortOption = option;
                        _applySort();
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option.label,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? _purple
                                    : textColor,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check,
                                color: _purple, size: 20),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    final bg = isDark ? const Color(0xFF1B262C) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B262C);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF6B6B6B);
    final iconBg =
    isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF2F2F2);
    final sortBg =
    isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF2F2F2);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top bar ───
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
                        'NEW ARRIVAL',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: textColor,
                          fontStyle: FontStyle.italic,
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

            // ─── Header row: N Items + Sort pill ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_totalCount Items',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Available in stock',
                        style: TextStyle(
                            fontSize: 13, color: subTextColor),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: _showSortOptions,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sortBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.swap_vert,
                            color: _sortOption == SortOption.defaultOrder
                                ? textColor
                                : _purple,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Sort',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _sortOption == SortOption.defaultOrder
                                  ? textColor
                                  : _purple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Active sort chip (only when not default) ───
            if (_sortOption != SortOption.defaultOrder)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _purple.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _sortOption.label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _purple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _sortOption = SortOption.defaultOrder;
                                _applySort();
                              });
                            },
                            child: const Icon(Icons.close,
                                size: 14, color: _purple),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // ─── Grid ───
            Expanded(
              child: BlocConsumer<ProductBloc, ProductState>(
                listener: (context, state) {
                  if (state is ProductLoaded) {
                    if (_firstLoad) {
                      _products
                        ..clear()
                        ..addAll(state.products);
                      _firstLoad = false;
                    } else {
                      final existingIds =
                      _products.map((p) => p.id).toSet();
                      _products.addAll(state.products
                          .where((p) => !existingIds.contains(p.id)));
                    }
                    // Re-apply sort after every batch load
                    _applySort();
                    _hasMore = state.products.length == _pageSize;
                    _loadingMore = false;
                    setState(() {});
                  } else if (state is ProductError) {
                    _loadingMore = false;
                    setState(() {});
                  } else if (state is ProductEmpty) {
                    _hasMore = false;
                    _loadingMore = false;
                    setState(() {});
                  }
                },
                builder: (context, state) {
                  if (_products.isEmpty && state is ProductLoading) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  if (_products.isEmpty && state is ProductError) {
                    return _buildError(
                        state.message, subTextColor, isDark);
                  }

                  if (_products.isEmpty) {
                    return Center(
                      child: Text('No products',
                          style: TextStyle(color: subTextColor)),
                    );
                  }

                  return RefreshIndicator(
                    color: _purple,
                    onRefresh: _handleRefresh,
                    child: GridView.builder(
                      controller: _scroll,
                      padding:
                      const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount:
                      _products.length + (_hasMore ? 1 : 0),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.68,
                      ),
                      itemBuilder: (_, i) {
                        if (i >= _products.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.2),
                              ),
                            ),
                          );
                        }
                        final p = _products[i];
                        return _ArrivalCard(
                          product: p,
                          isDark: isDark,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsScreen(
                                product: p,
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
    );
  }

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

  Widget _buildError(
      String message, Color subTextColor, bool isDark) {
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
              style: TextStyle(color: subTextColor),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _handleRefresh,
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
// Grid card
// ─────────────────────────────────────────
class _ArrivalCard extends StatelessWidget {
  final ProductModel product;
  final bool isDark;
  final Color textColor;
  final Color subTextColor;
  final VoidCallback onTap;

  const _ArrivalCard({
    required this.product,
    required this.isDark,
    required this.textColor,
    required this.subTextColor,
    required this.onTap,
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
                Positioned(
                  top: 8,
                  right: 8,
                  child: BlocBuilder<WishlistBloc, WishlistState>(
                    builder: (context, ws) {
                      final isWishlisted = ws is WishlistLoaded &&
                          ws.items
                              .any((w) => w.productId == product.id);

                      return GestureDetector(
                        onTap: () {
                          final auth =
                              context.read<AuthBloc>().state;
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
                            color: Colors.white.withOpacity(0.92),
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
          const SizedBox(height: 10),
          Text(
            product.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '\$${product.price.toStringAsFixed(0)}',
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